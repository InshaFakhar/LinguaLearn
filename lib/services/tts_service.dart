import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();

  final Map<String, String> _languageCodes = {
    'Spanish': 'es-ES',
    'French': 'fr-FR',
    'Italian': 'it-IT',
    'Urdu': 'ur-PK',
    'English': 'en-US',
  };

  Future<void> speak(String text, String language) async {
    try {
      final langCode = _languageCodes[language] ?? 'en-US';
      await _tts.setLanguage(langCode);
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.speak(text);
    } catch (e) {
      // Agar us language ka TTS device pe support nahi hai to silently ignore
    }
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}