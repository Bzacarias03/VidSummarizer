import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'package:vidsummarizer/core/constants.dart';
import 'package:vidsummarizer/core/scraper/caption_parser.dart';
import 'package:vidsummarizer/core/scraper/exceptions.dart';
import 'package:vidsummarizer/core/scraper/youtube_transcript_fetcher.dart';

class Scraper {
  late YouTubeTranscriptFetcher _fetcher;

  Scraper() {
    _fetcher = YouTubeTranscriptFetcher();
  }

  String _parseId(String url) {
    if (url.contains(mobileLink)) {
      String tempUrl = url.split("?si=")[0];
      return tempUrl.split(mobileLink)[1];
    }
    else {
      return url.split(webLink)[1];
    }
  }

  String _durationToMinutes(Duration duration) => duration.inMinutes.toString();

  Future<String> getCaptions(String url) async {
    String videoId = _parseId(url);

    try {
      final captionXml = await _fetcher.fetchCaptions(
        'https://www.youtube.com/watch?v=$videoId',
        languageCode: 'en',
      );

      final parsedCaptions = CaptionParser.parseXml(captionXml);
      final List<String> captions = [];
      for (final caption in parsedCaptions) {
        captions.add(caption.text.trim());
      }

      return captions.join(' ');
    }
    on YouTubeTranscriptException catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
    catch (e) {
      debugPrint('Unexpected error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMetadata(String url) async {
    String videoId = _parseId(url);

    final client = YoutubeExplode();
    try {
      final video = await client.videos.get(videoId);
      return <String, dynamic>{
        "thumbnail": video.thumbnails.highResUrl,
        "title": video.title,
        "author": video.author,
        "length": _durationToMinutes(video.duration!)
      };
    }
    catch (error) {
      rethrow;
    }
  }
}