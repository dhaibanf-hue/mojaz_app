import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> initTts() async {
    await _flutterTts.setLanguage("ar");
    await _flutterTts.setSpeechRate(0.9); // زيادة السرعة بنسبة 1.5 (0.6 * 1.5 = 0.9)
    await _flutterTts.setPitch(1.0);

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      var voices = await _flutterTts.getVoices;
      for (var voice in voices) {
        if (voice["name"].toString().toLowerCase().contains("male") ||
            voice["name"].toString().toLowerCase().contains("hamed")) {
          await _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
          break;
        }
      }
    }
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  FlutterTts get engine => _flutterTts;
}
