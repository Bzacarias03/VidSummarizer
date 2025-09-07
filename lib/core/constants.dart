import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import 'package:vidsummarizer/core/supabase/auth.dart';
import 'package:vidsummarizer/core/supabase/realtime.dart';
import 'package:vidsummarizer/core/supabase/database.dart';

/// Global variables for the app
late final AuthManager authManager;
final supabase = Supabase.instance.client;
final realtimeManager = RealtimeManager();
final databaseManager = DatabaseManager();

late final Map<String, String> env;
/// Global background color for all screens
final primary = Color(0xFF2C2C2C);
final primaryDark = Color.fromARGB(255, 26, 26, 26);

/// List of language types available
final List<String> languageTypes = [
  "English",
  "Spanish",
  "Chinese"
];

/// List of summary types available
final List<String> summaryTypes = [
  "Ultra-Concise",
  "Short Bullet Points",
  "Brief Paragraph",
  "Detailed Explanation",
  "Full Transcript-Based"
];

/// Link headers for parsing
final webLink = "https://www.youtube.com/watch?v=";
final mobileLink = "https://youtu.be/";

/// Reusable prompt to be sent to OpenAI API
/// 
/// [ captions ] is the text that is going to be summarized by the AI model
/// 
/// [ summaryType ] decides how long or short the summary should be
/// 
/// [ languageType ] decides which language to make the summary in
String createPrompt({
  required String captions,
  required String summaryType,
  required String languageType
}) => "Create a $summaryType summary in $languageType based on this text: $captions";

/// Reusable ISO8601 time formatter
///
/// [ date ] is the ISO8601 time to be formatted into: 'Month day, year'
String formatDate({required DateTime date}) {
  late DateFormat formatter;
  switch (date.day) {
    case 1:
      formatter = DateFormat("MMMM d'st', yyyy");
      return formatter.format(date);
    case 2: 
      formatter = DateFormat("MMMM d'nd', yyyy");
      return formatter.format(date);
    case 3:
      formatter = DateFormat("MMMM d'rd', yyyy");
      return formatter.format(date);
    default:
      formatter = DateFormat("MMMM d'th', yyyy");
      return formatter.format(date);
  }
}