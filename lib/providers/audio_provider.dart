import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

class AudioService {
  final FlutterTts _flutterTts;
  bool _isConfigured = false;

  AudioService() : _flutterTts = FlutterTts() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("de-DE");
    await _flutterTts.setSpeechRate(0.5); // Slightly slower for language learners
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    _isConfigured = true;
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    if (!_isConfigured) {
      await _initTts();
    }
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
