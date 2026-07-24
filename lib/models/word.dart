class Word {
  final String id;
  final String word;
  final String translation;
  final String pronunciation;
  final String language;
  final String category;
  final bool isSentence;

  Word({
    required this.id,
    required this.word,
    required this.translation,
    required this.pronunciation,
    required this.language,
    required this.category,
    this.isSentence = false,
  });
}