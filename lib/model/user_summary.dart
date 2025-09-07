class UserSummary implements Comparable<UserSummary> {

  String? userId;
  String? summaryId;
  String? captionsUrl;
  String? summaryName;
  String? summaryUrl;
  String? thumbnailUrl;
  String? videoTitle;
  String? videoAuthor;
  String? videoLength;
  DateTime? createdAt;

  UserSummary(
    this.userId,
    this.summaryId,
    this.captionsUrl,
    this.summaryName,
    this.summaryUrl,
    this.thumbnailUrl,
    this.videoTitle,
    this.videoAuthor,
    this.videoLength,
    [this.createdAt]
  );

  UserSummary.fromJSON(Map<String, dynamic> data) {
    userId = data["user_id"];
    summaryId = data["summary_id"];
    captionsUrl = data["captions_url"];
    summaryName = data["summary_name"];
    summaryUrl = data["summary_url"];
    thumbnailUrl = data["thumbnail_url"];
    videoTitle = data["video_title"];
    videoAuthor = data["video_author"];
    videoLength = data["video_length"];
    createdAt = DateTime.parse(data["created_at"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "user_id": userId,
      "summary_id": summaryId,
      "captions_url": captionsUrl,
      "summary_name": summaryName,
      "summary_url": summaryUrl,
      "thumbnail_url": thumbnailUrl,
      "video_title": videoTitle,
      "video_author": videoAuthor,
      "video_length": videoLength,
      "created_at": createdAt
    };    
  }
  
  @override
  int compareTo(UserSummary other) {
    if (createdAt!.isBefore(other.createdAt!)) {
      return -1;
    }
    else if (createdAt!.isAfter(other.createdAt!)) {
      return 1;
    }
    else {
      return 0;
    }
  }
}