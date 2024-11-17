import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';


late AudioPlayerHandler audioHandler;

class AudioPlayerHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final _flutterTts = FlutterTts();
  String ttsLang = 'null';
  double ttsSpeechRate = 0.0;

  static Future<void> init() async {
    audioHandler = await AudioService.init(
      builder: () => AudioPlayerHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.example.unelang_test.channel.audio',
        androidNotificationChannelName: 'Music playback',
      ),
    );

    //await audioHandler._flutterTts.setLanguage(audioHandler.ttsLang);
    //await audioHandler._flutterTts.setSpeechRate(audioHandler.ttsSpeechRate);

    await audioHandler._flutterTts.setVolume(1.0);
    await audioHandler._flutterTts.setPitch(1.0);
    await audioHandler._flutterTts.awaitSpeakCompletion(true);
  }

  Future changeTTSLanguage(String lang) async {
    if (ttsLang != lang) {
      await _flutterTts.setLanguage(lang);
      ttsLang = lang;
    }
  }

  Future changeTTSSpeechRate(double rate) async {
    if (ttsSpeechRate != rate) {
      await _flutterTts.setSpeechRate(rate);
      ttsSpeechRate = rate;
    }
  }

  Future playWord(String text) async {
    await changeTTSLanguage('en-US');
    await changeTTSSpeechRate(0.2);
    await audioHandler._flutterTts.speak(text);
  }

  Future playWordTranslation(String text) async {
    await changeTTSLanguage('ru-RU');
    await changeTTSSpeechRate(0.5);
    await audioHandler._flutterTts.speak(text);
  }

  Future playWordStop() async {
    await audioHandler._flutterTts.stop();
  }

  AudioPlayerHandler() {
    //_player.setUrl("https://exampledomain.com/song.mp3");
    //_player.setUrl('https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3');
  }

  @override
  Future<void> play() async {
    //_player.play();
  }

  @override
  Future<void> pause() async {
     //_player.pause();
  }
}