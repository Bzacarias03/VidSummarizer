import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:vidsummarizer/core/constants.dart';
import 'package:vidsummarizer/model/user_preferences.dart';
import 'package:vidsummarizer/model/user_summary.dart';

class RealtimeManager extends ChangeNotifier {
  RealtimeChannel? _summaryChannel;
  RealtimeChannel? _preferencesChannel;

  /// Contains the list of user-made summaries
  final List<UserSummary> _summaries = [];
  /// Getter variable for user-made summaries
  List<UserSummary> get summaries => _summaries;
  
  /// Contains the map of user preferences
  UserPreferences? _preferences;
  /// Getter variable for user perferences
  UserPreferences get preferences => _preferences ?? UserPreferences(authManager.currentUser!.id, 0, 0, true);

  RealtimeManager();

  // TODO: Add logic for lifecycle events

  Future<void> _fetchSummaries(String userId) async {
    final response = await supabase.from("user_summaries")
      .select()
      .eq("user_id", userId)
      .order("created_at", ascending: false);

    if (response.isEmpty) return;
    for (final summary in response) {
      _summaries.add(UserSummary.fromJSON(summary));
    }
  }

  Future<void> _fetchPreferences(String userId) async {
    final response = await supabase.from("user_preferences")
      .select()
      .eq("user_id", userId)
      .single();
    
    _preferences = UserPreferences.fromJSON(response);
  }

  void _handlePreferencesUpdate(UserPreferences newPreferences) {
    _preferences = newPreferences;
    notifyListeners();
  }

  void _handleSummaryInsertion(UserSummary newSummary) {
    _summaries.insert(0, newSummary);
    notifyListeners();
  }

  void _handleSummaryDeletion(String summaryId) {
    _summaries.removeWhere((summary) => summary.summaryId == summaryId);
    notifyListeners();
  }

  Future<void> initializeSummaryChannel(String userId) async {
    try {
      await _fetchSummaries(userId);
    }
    catch (error) {
      rethrow;
    }

    if (_summaryChannel != null) {
      await _summaryChannel?.unsubscribe();
    }

    _summaryChannel = supabase.channel("public:user_summaries")
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: "public",
        table: "user_summaries",
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: "user_id",
          value: userId
        ),
        callback: (payload) => {
          _handleSummaryInsertion(UserSummary.fromJSON(payload.newRecord))
        }
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: "public",
        table: "user_summaries",
        callback: (payload) => {
          _handleSummaryDeletion(payload.oldRecord["summary_id"])
        }
      );

    await _summaryChannel?.subscribe((status, error) {
      debugPrint('Realtime status (summaries): $status');
      if (error != null) {
        debugPrint('Realtime error (summaries): $error');
      } else {
        debugPrint('Successfully subscribed to summary updates');
      }
    });
  }

  Future<void> initializePreferencesChannel(String userId) async {
    try {
      await _fetchPreferences(userId);
    }
    catch (error) {
      rethrow;
    }

    if (_preferencesChannel != null) {
      await _preferencesChannel?.unsubscribe();
    }

    _preferencesChannel = supabase.channel("public:user_preferences")
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: "public",
        table: "user_preferences",
        callback: (payload) => {
          _handlePreferencesUpdate(UserPreferences.fromJSON(payload.newRecord))
        }
      );

    // ignore: await_only_futures
    await _preferencesChannel?.subscribe((status, error) {
      debugPrint("Realtime status (preferences): $status");
      if (error != null) {
        debugPrint("Realtime error (preferences): $error");
      } else {
        debugPrint("Successfully subscribed to preferences updates");
      }
    });
  }

  void clean() {
    _summaryChannel?.unsubscribe();
    _preferencesChannel?.unsubscribe();
    _summaries.clear();
    _preferences = null;
    notifyListeners();
  }
}