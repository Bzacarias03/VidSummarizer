import 'dart:io';

import 'package:uuid/v4.dart';

import 'package:vidsummarizer/core/constants.dart';
import 'package:vidsummarizer/core/file_processor.dart';
import 'package:vidsummarizer/model/user_preferences.dart';

class DatabaseManager {
  final FileProcessor _fileProcessor = FileProcessor();
  final String storageBucket = "users";

  DatabaseManager();

  Future<void> deleteSummary(String summaryId) async {
    try {
      await supabase.from("user_summaries")
        .delete()
        .eq("summary_id", summaryId);
    }
    catch (error) {
      rethrow;
    }
  }

  Future<void> insertSummary(Map<String, dynamic> data) async {
    try {
      String summaryId = UuidV4().generate();
      final (thumbnailUrl, summaryUrl, captionsUrl) = await _uploadToStorage(
        summaryId: summaryId,
        thumbnail: data["thumbnail"],
        captions: data["captions"],
        summary: data["summary"],
      );

      await supabase.from("user_summaries")
        .insert({
          "user_id": authManager.currentUser!.id,
          "summary_id": summaryId,
          "captions_url": captionsUrl,
          "summary_name": data["summary_name"],
          "summary_url": summaryUrl,
          "thumbnail_url": thumbnailUrl,
          "video_title": data["video_title"],
          "video_author": data["video_author"],
          "video_length": data["video_length"]
        });
    }
    catch (error) {
      rethrow;
    }
  }

  Future<void> updatePreferences(UserPreferences newPreferences) async {
    try {
      await supabase.from("user_preferences")
        .update(newPreferences.toMap())
        .eq("user_id", authManager.currentUser!.id);
    }
    catch (error) {
      rethrow;
    }
  }

  Future<(String?, String?, String?)> _uploadToStorage({
    required String summaryId,
    required String thumbnail,
    required String captions,
    required String summary
  }) async {
    String storagePath = "${authManager.currentUser!.id}/$summaryId";

    File thumbnailFile = await _fileProcessor.getThumbnailFile(url: thumbnail);
    File summaryFile = await _fileProcessor.getSummaryFile(summary: summary);
    File captionFile = await _fileProcessor.getCaptionsFile(captions: captions);

    String? thumbnailUrl;
    String? summaryUrl;
    String? captionsUrl;
    try {
      String thumbnailPath = "$storagePath/thumbnail.png";
      await supabase.storage.from(storageBucket)
        .upload(thumbnailPath, thumbnailFile).whenComplete(() async {
          thumbnailUrl = supabase.storage.from(storageBucket).getPublicUrl(thumbnailPath);
        });

      String summaryPath = "$storagePath/summary.txt";
      await supabase.storage.from(storageBucket)
        .upload(summaryPath, summaryFile).whenComplete(() async {
          summaryUrl = supabase.storage.from(storageBucket).getPublicUrl(summaryPath);
        });

      String captionPath = "$storagePath/captions.txt";
      await supabase.storage.from(storageBucket)
        .upload(captionPath, captionFile).whenComplete(() async {
          captionsUrl = supabase.storage.from(storageBucket).getPublicUrl(captionPath);
        });
    }
    catch (error) {
      rethrow;
    }

    return (thumbnailUrl, summaryUrl, captionsUrl);
  }
}