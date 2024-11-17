import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:unelang_test/common/logger.dart';
import 'package:unelang_test/common/audio.dart';
import 'package:unelang_test/models/application.dart';
import 'package:unelang_test/models/settings.dart';


class TeachState extends ChangeNotifier {
  static int currentPageIndex = 0;
  static bool isReveal = false;
  static DateTime pageStartTime = DateTime.now();
  static bool _isVoicePlay = false;
  static PageController pageController = PageController(initialPage: 9999);

  bool get isVoicePlay => _isVoicePlay;
  set isVoicePlay(bool value) {
    _isVoicePlay = value;
    notifyListeners();
  }

  static void setReveal(bool rev) {
    isReveal = rev;
    return;
  }

  static Future init() async {
  }

  Future speakStart(String text) async {
    if (!isVoicePlay) {
      isVoicePlay = true;
      await audioHandler.playWord(text);
      isVoicePlay = false;
    }
  }

  Future speakStop() async {
    await audioHandler.playWordStop();
    isVoicePlay = false;
  }

  static void onPageViewChange(int index) {

    pageController.animateToPage(index,
      duration: const Duration(milliseconds: 100),
      curve: Curves.linear);

    final timeDiff = DateTime.now().difference(pageStartTime).inMilliseconds;
    pageStartTime = DateTime.now();

    if (index > currentPageIndex) {
      //Logger.info('swap to next $index');
      ApplicationState.onWordChanged(true, isReveal, timeDiff);
    }
    else {
      //Logger.info('swap to prev $index');
      ApplicationState.onWordChanged(false, isReveal, timeDiff);
    }

    currentPageIndex = index;
    isReveal = false;
  }

  void onPageViewChangeNotStatic(int index) {
    speakStop();

    if (!SettingsState.autoReadWord)
      return;
    if (SettingsState.autoReadWordHeadsetOnly && !ApplicationState.isHeadsetPlugged)
      return;
    
    speakStart(ApplicationState.wordList[ApplicationState.wordIndexNext].word);
  }

  static String getPartOfSpeechName(String data){
    var partOfSpeech = data;
    if (data == 'vrnt') {
      partOfSpeech = 'Еще варианты';
    } else if (data == 'noun') {
      partOfSpeech = 'Имя существительное';
    } else if (data == 'adj') {
      partOfSpeech = 'Имя прилагательное';
    } else if (data == 'union') {
      partOfSpeech = 'Союз';
    } else if (data == 'pretext') {
      partOfSpeech = 'Предлог';
    } else if (data == 'verb') {
      partOfSpeech = 'Глагол';
    } else if (data == 'pronoun') {
      partOfSpeech = 'Местоимение';
    } else if (data == 'reduction') {
      partOfSpeech = 'Сокращение';
    } else if (data == 'adverb') {
      partOfSpeech = 'Наречие';
    } else {
      Logger.info('wrong part of speech: $data');
    }

    return partOfSpeech;
  }
}