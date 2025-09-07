import 'dart:async';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:vidsummarizer/core/constants.dart';
import 'package:vidsummarizer/core/supabase/auth.dart';
import 'package:vidsummarizer/screens/auth/login_page.dart';
import 'package:vidsummarizer/screens/main/main_page.dart';

Future<AuthManager> _createAuthManager() async {
  return AuthManager();
}

Future<void> _initUserData() async {
  if (authManager.currentUser != null) {
    await authManager.initUser(authManager.currentUser!.id);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  env = dotenv.env;

  await Supabase.initialize(
    url: env['SUPABASE_URL']!,
    anonKey: env['SUPABASE_ANON_KEY']!,
  );

  OpenAI.apiKey = env["OPENAI_API_KEY"]!;
  
  authManager = await _createAuthManager();
  await _initUserData();
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: primary,
      debugShowCheckedModeBanner: false,
      home: authManager.currentUser == null
       ? LoginPage()
       : MainPage(),
    );
  }
}
