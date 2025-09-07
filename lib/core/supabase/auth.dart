import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:vidsummarizer/core/constants.dart';
import 'package:vidsummarizer/model/user_info.dart';

class AuthManager {
  User? _currentUser;
  User? get currentUser => _currentUser;

  UserInfo? _userInfo;
  UserInfo? get userInfo => _userInfo;

  AuthManager() {
    setupAuth();
  }
  
  Future<void> setupAuth() async {
    try {
      _currentUser = supabase.auth.currentUser;
      supabase.auth.onAuthStateChange.listen((data) async {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;

        _currentUser = session?.user;
        if (event == AuthChangeEvent.signedIn) {
          await initUser(session!.user.id);
        }
      });
    }
    catch (error) {
      rethrow;
    }
  }

  Future<void> initUser(String userId) async {
    await Future.wait([
      _getUserInfo(userId),
      realtimeManager.initializePreferencesChannel(userId),
      realtimeManager.initializeSummaryChannel(userId),
    ]);
  }

  Future<void> _getUserInfo(String userId) async {
    try {
      final response = await supabase.from("users")
        .select()
        .eq("user_id", userId)
        .single();
      
      _userInfo = UserInfo.fromJSON(response);
    }
    catch (error) {
      rethrow;
    }
  }

  Future<bool> _checkExistingAccount(String newEmail) async {
    return await supabase.from("users")
      .select("email")
      .eq("email", newEmail)
      .maybeSingle() != null;
  }

  Future<void> _createUser(String newUserId, String newUsername, String newEmail) async {
    await supabase.from("users")
      .insert({
        "user_id": newUserId,
        "username": newUsername,
        "email": newEmail
      });
  }

  Future<void> signup(String newUsername, String newEmail, String newPassword) async {
    if (await _checkExistingAccount(newEmail)) {
      throw Exception("email_exists");
    }

    try {
      final response = await supabase.auth.signUp(
        email: newEmail,
        password: newPassword
      );

      final newUserId = response.user!.id;
      await _createUser(newUserId, newUsername, newEmail);
      await _getUserInfo(newUserId);
    }
    catch (error) {
      rethrow;
    }
  }

  Future<void> login(String userEmail, String userPassword) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: userEmail,
        password: userPassword
      );
      await _getUserInfo(response.user!.id);
    }
    catch (error) {
      rethrow;
    }
  }

  Future<void> signout() async {
    try {
      await supabase.auth.signOut();
    }
    catch (error) {
      rethrow;
    }
  }
}