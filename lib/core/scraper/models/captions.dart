class Caption {
  final double start;
  final double duration;
  final String text;

  const Caption({
    required this.start,
    required this.duration,
    required this.text,
  });

  double get end => start + duration;
}