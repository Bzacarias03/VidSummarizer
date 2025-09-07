class UserInfo {

  String? userId;
  String? username;

  UserInfo() {
    userId;
    username;
  }

  UserInfo.fromJSON(Map<String, dynamic> data) {
    userId = data["user_id"];
    username = data["username"];
  }

  Map<String, dynamic> toMap() {
    return {
      "user_id": userId,
      "username": username
    };
  }
}