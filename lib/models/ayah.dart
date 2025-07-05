class Ayah {
  final int surah;
  final int ayah;
  final String arabic;
  final String translation;

  Ayah({
    required this.surah,
    required this.ayah,
    required this.arabic,
    required this.translation,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      surah: json['surah'],
      ayah: json['ayah'],
      arabic: json['arabic'],
      translation: json['translation'],
    );
  }
}
