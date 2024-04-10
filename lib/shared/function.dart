import 'package:flutter_tts/flutter_tts.dart';

class DataSource {
  final FlutterTts flutterTts = FlutterTts();
  Future<void> speak(String textToSpeak) async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(textToSpeak);
  }
}
