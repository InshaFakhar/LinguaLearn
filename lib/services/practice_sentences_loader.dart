import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/word.dart';

class PracticeSentencesLoader {
  static final Map<String, List<Word>> _cache = {};

  static final Map<String, String> _filePaths = {
    'Italian': 'assets/data/italian_sentences.csv',
    'Spanish': 'assets/data/spanish_sentences.csv',
    'French': 'assets/data/french_sentences.csv',
    'Urdu': 'assets/data/urdu_sentences.csv',
  };

  static Future<List<Word>> load(String language) async {
    if (_cache.containsKey(language)) {
      return _cache[language]!;
    }

    final path = _filePaths[language];
    if (path == null) return [];

    try {
      final raw = await rootBundle.loadString(path);
      // eol specify NAHI karna — auto-detect karne do (CRLF/LF dono handle karega)
      final rows = const CsvToListConverter().convert(raw, shouldParseNumbers: false);

      final words = <Word>[];
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 2) continue;
        final wordText = row[0].toString().trim();
        final translationText = row[1].toString().trim();
        if (wordText.isEmpty || translationText.isEmpty) continue;

        words.add(Word(
          id: '${language.toLowerCase()}_ps_$i',
          word: wordText,
          translation: translationText,
          pronunciation: '',
          language: language,
          category: 'Practice Sentences',
          isSentence: true,
        ));
      }

      _cache[language] = words;
      return words;
    } catch (e) {
      debugPrintFallback(e);
      return [];
    }
  }

  static void debugPrintFallback(Object e) {
    // ignore: avoid_print
    print('CSV load error: $e');
  }
}