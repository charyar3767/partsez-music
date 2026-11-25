String wagtFormat(Duration d) {
  final min = d.inMinutes;
  final sek = d.inSeconds % 60;
  return '$min:${sek.toString().padLeft(2, '0')}';
}
