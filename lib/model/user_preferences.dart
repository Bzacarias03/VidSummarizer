class UserPreferences {

  String? userId;
  int? languageType;
  int? summaryType;
  bool? publicSummaries;

  UserPreferences(
    this.userId,
    this.languageType,
    this.summaryType,
    this.publicSummaries
  );

  UserPreferences.fromJSON(Map<String, dynamic> data) {
    userId = data["user_id"];
    languageType = data["summary_language"];
    summaryType = data["summary_type"];
    publicSummaries = data["public_summaries"];
  }

  Map<String, dynamic> toMap() {
    return {
      "user_id": userId,
      "summary_language": languageType,
      "summary_type": summaryType,
      "public_summaries": publicSummaries
    };
  }
}