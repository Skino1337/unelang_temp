import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:unelang_test/common/logger.dart';
import 'package:unelang_test/common/audio.dart';
import 'package:unelang_test/models/application.dart';
import 'package:unelang_test/models/settings.dart';

import 'package:flutter_tts/flutter_tts.dart';


class TeachAudioState extends ChangeNotifier {
  static int currentPageIndex = 0;
  static bool isReveal = false;
  static DateTime pageStartTime = DateTime.now();
  static FlutterTts flutterTts = FlutterTts();
  static bool _isVoicePlay = false;
  static PageController pageController = PageController(initialPage: 9999);

  static List<Word> shuffledWordList = [];
  int wordIndex = 0;
  bool isPlaying = false;

  static Future init() async {
    if (ApplicationState.wordList.isNotEmpty){
      shuffleWords();
    }
  }

  static void updateWordInShuffledWords(Word updatedWord) {
    var removedIndex = -1;
    for(int i = 0; i < shuffledWordList.length; i++) {
      if (shuffledWordList[i].word == updatedWord.word) {
        if (updatedWord.mem >= 0 && updatedWord.mem <= 8) {
          shuffledWordList[i] = updatedWord;
          break;
        }
        else {
          removedIndex = i;
          break;
        }
      }
    }
    if (removedIndex != -1) {
      shuffledWordList.removeAt(removedIndex);
    }
  }

  static void shuffleWords() {
    final List<Word> tempWordList = [];
    for (final word in ApplicationState.wordList) {
      if (word.mem >= 0 && word.mem <= 8) {
        tempWordList.add(word);
        // todo check situation if all word in lias are learned ( mem = 9)
        // бд удаляется если нет проверки ниже на пустой список и все слова mem9
        // придумать как сохранять порядок при добавлении словарей
        // появляются слова если в словаре wordlist все слова с mem9
      }
    }
    if (tempWordList.isNotEmpty) {
      shuffledWordList = tempWordList;
      shuffledWordList.shuffle();
      shuffledWordList[0] = correctWord(0);
    }
  }

  Future startPlayng({bool onlyThis = true}) async {
    if (!onlyThis) {
      isPlaying = true;
      notifyListeners();
    }

    
    await audioHandler.playWord(shuffledWordList[wordIndex].word);
    if (!isPlaying)
      return;

    await Future.delayed(const Duration(milliseconds: 400));
    if (!isPlaying)
      return;

    final List<String> translationsList = [];
    translationsList.add(shuffledWordList[wordIndex].translate);
    shuffledWordList[wordIndex].partOfSpeech.forEach((key, meaningList) async {
      for (final meaning in meaningList) {
        if (!translationsList.contains(meaning.translation?.toLowerCase())) {
          translationsList.add(meaning.translation!.toLowerCase());
        }
      }
    });

    for (final translation in translationsList) {
      if (isPlaying || onlyThis) {
        await audioHandler.playWordTranslation(translation);
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }

    if (isPlaying) {
        await Future.delayed(const Duration(seconds: 2));

        goToNextWord();

        startPlayng(onlyThis: false);
    }
  }

  Future stopPlayng() async {
    isPlaying = false;
    notifyListeners();

    await audioHandler.playWordStop();
  }

  void goToNextWord() {
    audioHandler.playWordStop();

    wordIndex = wordIndex + 1;
    if (wordIndex == shuffledWordList.length) {
      wordIndex = 0;
    }
    shuffledWordList[wordIndex] = correctWord(wordIndex);
    notifyListeners();

    //audioHandler.playWord(shuffledWordList[wordIndex].word);
  }

  void goToPreviousWord() {
    wordIndex = wordIndex - 1;
    if (wordIndex == -1) {
      wordIndex = shuffledWordList.length - 1;
    }
    shuffledWordList[wordIndex] = correctWord(wordIndex);
    notifyListeners();

    //audioHandler.playWord(shuffledWordList[wordIndex].word);
  }

  static Word correctWord(int index) {
    final word = shuffledWordList[index];
    final tempWord = Word();
    word.partOfSpeech.forEach((key, meaningList) {
      var meaningCounter = 0;
      for (final meaning in meaningList) {
        meaningCounter = meaningCounter + 1;
        if (meaning.frequency! >= 2) {
          if (tempWord.partOfSpeech[key] == null) {
            tempWord.partOfSpeech[key] = [];
          }
          if (word.partOfSpeech.length >= 3 && meaningCounter == 3) {
            continue;
          }
          tempWord.partOfSpeech[key]?.add(meaning);
        }
        //Logger.info('add correct meaning: key[$key], freq[${meaning.frequency}], tr[${meaning.translation}]');
      }
    });

    if (tempWord.partOfSpeech.length >= 3) {

    }

    word.partOfSpeech = tempWord.partOfSpeech;
    return word;
  }

  bool get isVoicePlay => _isVoicePlay;
  set isVoicePlay(bool value) {
    _isVoicePlay = value;
    notifyListeners();
  }

  static void setReveal(bool rev) {
    isReveal = rev;
    return;
  }

  Future speakStart(String text) async {
    if (!isVoicePlay) {
      isVoicePlay = true;
      await flutterTts.speak(text);
      isVoicePlay = false;
    }
  }

  Future speakStop() async {
    await flutterTts.stop();
    isVoicePlay = false;
  }

  static void onPageViewChange(int index) {

    pageController.animateToPage(index,
      duration: const Duration(milliseconds: 100),
      curve: Curves.linear);

    final timeDiff = DateTime.now().difference(pageStartTime).inMilliseconds;
    pageStartTime = DateTime.now();

    if (!ApplicationState.wordsOver) {
      if (index > currentPageIndex) {
        //Logger.info('swap to next $index');
        ApplicationState.onWordChanged(true, isReveal, timeDiff);
      }
      else {
        //Logger.info('swap to prev $index');
        ApplicationState.onWordChanged(false, isReveal, timeDiff);
      }
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
    
    speakStart(ApplicationState.wordList[ApplicationState.wordIndexStack.last].word);
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