class Verse {
  final int id;
  final String text;

  Verse({required this.id, required this.text});

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(id: json['id'], text: json['text']);
  }
}

class Chapter {
  final int id;
  final String name;
  final String transliteration;
  final String type;
  final int totalVerses;
  final List<Verse> verses;

  Chapter({
    required this.id,
    required this.name,
    required this.transliteration,
    required this.type,
    required this.totalVerses,
    required this.verses,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      name: json['name'],
      transliteration: json['transliteration'],
      type: json['type'],
      totalVerses: json['total_verses'],
      verses: (json['verses'] as List).map((v) => Verse.fromJson(v)).toList(),
    );
  }
}
