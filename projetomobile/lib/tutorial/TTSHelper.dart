import 'package:flutter_tts/flutter_tts.dart';

class TTSHelper {
  static final FlutterTts _flutterTts = FlutterTts();
  static String _text = ""; // Texto que será lido

  /// Define o texto que será falado
  static void setText(String text) {
    _text = text;
  }

  /// Lê o texto armazenado
  static Future<void> speak() async {
    if (_text.isEmpty) {
      print("Nenhum texto definido para leitura!");
      return;
    }
    await _flutterTts.setLanguage("pt-BR");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(_text);
  }
}