import 'package:vidsummarizer/core/scraper/models/playability_status.dart';

class InnerTubeResponse {
  final PlayabilityStatus? playabilityStatus;
  final Map<String, dynamic>? captions;

  const InnerTubeResponse({
    this.playabilityStatus,
    this.captions,
  });

  factory InnerTubeResponse.fromJson(Map<String, dynamic> json) {
    return InnerTubeResponse(
      playabilityStatus: json['playabilityStatus'] != null
          ? PlayabilityStatus.fromJson(json['playabilityStatus'])
          : null,
      captions: json['captions'] as Map<String, dynamic>?,
    );
  }
}