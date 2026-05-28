import 'package:cognitiveroulletegame/shared/user_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeakerService {
  final userPreferences = UserPreferences();
  final FlutterTts flutterTts = FlutterTts();

  Future<void> speak(String textToSpeak) async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
    if (!userPreferences.isMute) {
      await flutterTts.speak(textToSpeak);
    }
  }

  Future stop() async {
    await flutterTts.stop();
    // setState(() => ttsState = TtsState.stopped);
  }
}
