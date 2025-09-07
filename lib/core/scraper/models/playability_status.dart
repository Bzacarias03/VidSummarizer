class PlayabilityStatus {
  final String status;
  final String? reason;

  const PlayabilityStatus({
    required this.status,
    this.reason,
  });

  factory PlayabilityStatus.fromJson(Map<String, dynamic> json) {
    return PlayabilityStatus(
      status: json['status'] as String,
      reason: json['reason'] as String?,
    );
  }

  bool get isOk => status == 'OK';
}