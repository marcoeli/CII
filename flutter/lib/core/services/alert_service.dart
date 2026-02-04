import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AlertService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playAlert() async {
    try {
      // Warning beep (single tone)
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      debugPrint('Error playing alert sound: $e');
    }
  }

  Future<void> playCriticalLoop() async {
    try {
      // Configurar para loop
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('sounds/alarm.mp3'));
    } catch (e) {
      debugPrint('Error playing critical loop: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      debugPrint('Error stopping sound: $e');
    }
  }

  Future<void> playSuccess() async {
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      debugPrint('Error playing success sound: $e');
    }
  }

  Future<void> playDoorbell() async {
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.play(AssetSource('sounds/doorbell.mp3'));
    } catch (e) {
      debugPrint('Error playing doorbell sound: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}




