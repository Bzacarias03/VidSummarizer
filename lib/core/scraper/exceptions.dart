class YouTubeTranscriptException implements Exception {
  final String message;
  const YouTubeTranscriptException(this.message);

  @override
  String toString() => 'YouTubeTranscriptException: $message';
}

class VideoUnavailableException extends YouTubeTranscriptException {
  const VideoUnavailableException(String reason) 
      : super('Video unavailable: $reason');
}

class CaptionsNotFoundException extends YouTubeTranscriptException {
  const CaptionsNotFoundException(String videoId) 
      : super('No captions found for video: $videoId');
}

class TranscriptsDisabledException extends YouTubeTranscriptException {
  const TranscriptsDisabledException(String videoId) 
      : super('Transcripts are disabled for video: $videoId');
}

class LanguageNotFoundException extends YouTubeTranscriptException {
  const LanguageNotFoundException(String languageCode) 
      : super('No captions found for language: $languageCode');
}

class ApiKeyExtractionException extends YouTubeTranscriptException {
  const ApiKeyExtractionException(String videoId) 
      : super('Failed to extract API key for video: $videoId');
}

class IpBlockedException extends YouTubeTranscriptException {
  const IpBlockedException(String videoId) 
      : super('IP blocked by YouTube for video: $videoId');
}