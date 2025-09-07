import 'package:vidsummarizer/core/scraper/models/innertube_client.dart';

class InnerTubeContext {
  final InnerTubeClient client;

  const InnerTubeContext({required this.client});

  Map<String, dynamic> toJson() => {
        'client': client.toJson(),
      };
}