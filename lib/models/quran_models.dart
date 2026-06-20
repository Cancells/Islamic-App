class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      englishNameTranslation: json['englishNameTranslation'] as String,
      numberOfAyahs: json['numberOfAyahs'] as int,
      revelationType: json['revelationType'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'name': name,
    'englishName': englishName,
    'englishNameTranslation': englishNameTranslation,
    'numberOfAyahs': numberOfAyahs,
    'revelationType': revelationType,
  };
}

class Ayah {
  final int number;
  final int numberInSurah;
  final String text;
  final String translation;
  final int juz;

  Ayah({
    required this.number,
    required this.numberInSurah,
    required this.text,
    required this.translation,
    required this.juz,
  });

  factory Ayah.fromEditions(Map<String, dynamic> arabicJson, Map<String, dynamic> englishJson) {
    return Ayah(
      number: arabicJson['number'] as int,
      numberInSurah: arabicJson['numberInSurah'] as int,
      text: arabicJson['text'] as String,
      translation: englishJson['text'] as String,
      juz: arabicJson['juz'] as int,
    );
  }
}
