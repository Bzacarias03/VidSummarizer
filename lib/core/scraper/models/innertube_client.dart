class InnerTubeClient {
  final String hl;
  final String gl;
  final String clientName;
  final String clientVersion;

  const InnerTubeClient({
    required this.hl,
    required this.gl,
    required this.clientName,
    required this.clientVersion,
  });

  Map<String, dynamic> toJson() => {
        'hl': hl,
        'gl': gl,
        'clientName': clientName,
        'clientVersion': clientVersion,
      };
}