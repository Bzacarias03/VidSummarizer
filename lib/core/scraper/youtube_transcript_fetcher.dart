import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vidsummarizer/core/scraper/exceptions.dart';
import 'package:vidsummarizer/core/scraper/models/caption_track.dart';
import 'package:vidsummarizer/core/scraper/models/innertube_context.dart';
import 'package:vidsummarizer/core/scraper/models/innertube_response.dart';
import 'package:vidsummarizer/core/scraper/models/innertube_client.dart';

class YouTubeTranscriptFetcher {
  static const String _watchUrl = 'https://www.youtube.com/watch?v=';
  static const String _innertubeApiUrl =
      'https://www.youtube.com/youtubei/v1/player?key=';

  static const InnerTubeContext _innertubeContext = InnerTubeContext(
    client: InnerTubeClient(
      hl: 'en',
      gl: 'US',
      clientName: 'WEB',
      clientVersion: '2.20210721.00.00',
    ),
  );

  final http.Client _httpClient;

  YouTubeTranscriptFetcher({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Extracts video ID from YouTube URL
  String _extractVideoId(String url) {
    final patterns = [
      RegExp(
          r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\n?#]+)'),
      RegExp(r'youtube\.com\/watch\?.*&v=([^&\n?#]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1)!;
      }
    }

    // If no pattern matches, assume the input is already a video ID
    if (!url.contains('/') && !url.contains('youtube')) {
      return url;
    }

    throw YouTubeTranscriptException('Invalid YouTube URL or video ID: $url');
  }

  /// Fetches the raw caption data (XML) for a YouTube video
  Future<String> fetchCaptions(String videoUrl, {String? languageCode}) async {
    final videoId = _extractVideoId(videoUrl);

    // Step 1: Fetch the video page HTML
    final html = await _fetchVideoHtml(videoId);

    // Step 2: Extract the API key from the HTML
    final apiKey = _extractApiKey(html, videoId);

    // Step 3: Fetch InnerTube data
    final innertubeResponse = await _fetchInnertubeData(videoId, apiKey);

    // Step 4: Extract caption tracks
    final captionTracks = _extractCaptionTracks(innertubeResponse, videoId);

    // Step 5: Find the desired caption track
    final captionUrl = _findCaptionUrl(captionTracks, languageCode);

    // Step 6: Fetch the actual caption XML
    final captionXml = await _fetchCaptionXml(captionUrl);

    return captionXml;
  }

  /// Fetches available caption tracks metadata
  Future<List<CaptionTrack>> fetchAvailableCaptions(String videoUrl) async {
    try {
      final videoId = _extractVideoId(videoUrl);

      // Fetch video page and extract data
      final html = await _fetchVideoHtml(videoId);
      final apiKey = _extractApiKey(html, videoId);
      final innertubeResponse = await _fetchInnertubeData(videoId, apiKey);

      return _extractCaptionTracks(innertubeResponse, videoId);
    } catch (e) {
      throw YouTubeTranscriptException('Failed to fetch available captions: $e');
    }
  }

  Future<String> _fetchVideoHtml(String videoId) async {
    final response = await _httpClient.get(
      Uri.parse('$_watchUrl$videoId'),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept-Language': 'en-US,en;q=0.9',
      },
    );

    if (response.statusCode != 200) {
      throw YouTubeTranscriptException(
          'Failed to fetch video page: ${response.statusCode}');
    }

    return response.body;
  }

  String _extractApiKey(String html, String videoId) {
    final pattern = RegExp(r'"INNERTUBE_API_KEY":\s*"([a-zA-Z0-9_-]+)"');
    final match = pattern.firstMatch(html);

    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }

    // Check for common error conditions
    if (html.contains('class="g-recaptcha"')) {
      throw IpBlockedException(videoId);
    }

    throw ApiKeyExtractionException(videoId);
  }

  Future<InnerTubeResponse> _fetchInnertubeData(
      String videoId, String apiKey) async {
    final response = await _httpClient.post(
      Uri.parse('$_innertubeApiUrl$apiKey'),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
      body: jsonEncode({
        'context': _innertubeContext.toJson(),
        'videoId': videoId,
      }),
    );

    if (response.statusCode != 200) {
      throw YouTubeTranscriptException(
          'Failed to fetch InnerTube data: ${response.statusCode}');
    }

    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
    return InnerTubeResponse.fromJson(jsonData);
  }

  List<CaptionTrack> _extractCaptionTracks(
      InnerTubeResponse innertubeResponse, String videoId) {
    // Check playability status
    if (innertubeResponse.playabilityStatus != null) {
      final status = innertubeResponse.playabilityStatus!;
      if (!status.isOk) {
        throw VideoUnavailableException(status.reason ?? 'Unknown error');
      }
    }

    // Extract caption tracks
    final captions = innertubeResponse.captions;
    if (captions == null) {
      throw CaptionsNotFoundException(videoId);
    }

    final trackList = captions['playerCaptionsTracklistRenderer'];
    if (trackList == null || trackList['captionTracks'] == null) {
      throw TranscriptsDisabledException(videoId);
    }

    final captionTracksJson =
        List<Map<String, dynamic>>.from(trackList['captionTracks']);

    return captionTracksJson
        .map((track) => CaptionTrack.fromJson(track))
        .toList();
  }

  String _findCaptionUrl(
      List<CaptionTrack> captionTracks, String? languageCode) {
    if (captionTracks.isEmpty) {
      throw const YouTubeTranscriptException('No caption tracks available');
    }

    // If no language specified, return the first available
    if (languageCode == null || languageCode.isEmpty) {
      return captionTracks.first.url;
    }

    // Try to find exact language match
    for (final track in captionTracks) {
      if (track.languageCode == languageCode) {
        return track.url;
      }
    }

    // Try to find partial language match (e.g., 'en' matches 'en-US')
    for (final track in captionTracks) {
      if (track.languageCode.startsWith(languageCode)) {
        return track.url;
      }
    }

    throw LanguageNotFoundException(languageCode);
  }

  Future<String> _fetchCaptionXml(String captionUrl) async {
    final response = await _httpClient.get(
      Uri.parse(captionUrl),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
    );

    if (response.statusCode != 200) {
      throw YouTubeTranscriptException(
          'Failed to fetch caption XML: ${response.statusCode}');
    }

    return response.body;
  }

  void dispose() {
    _httpClient.close();
  }
}