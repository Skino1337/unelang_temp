import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:googleapis/drive/v3.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:headset_connection_event/headset_event.dart';

import 'package:unelang_test/common/logger.dart';
import 'package:unelang_test/common/storage.dart';
import 'package:unelang_test/models/dictionaries.dart';
import 'package:unelang_test/models/teach.dart';
import 'package:unelang_test/models/teach_audio.dart';
import 'package:unelang_test/models/settings.dart';

int counter = 0;

class ApplicationState extends ChangeNotifier {
  static List<Word> wordList = [];
  static bool firstWord = true;
  static bool isWordsLoaded = false;
  
  static List<int> wordIndexStack = [-1];
  static int wordIndexNext = -1;
  static bool wordsOver = false;

  static int totalWordsCount = 0;
  static int learnedWordsCount = 0;
  static int newWordsCount = 0;
  static int repeatWordsCount = 0;


  static HeadsetEvent headsetPlugin = HeadsetEvent();
  static bool isHeadsetPlugged = false;

  static void printWordList() {
    for (final word in wordList) {
        Logger.info('word: ${word.word}, m: ${word.mem}, r: ${word.repeat}');
    }
  }

  static void headsetEvent(HeadsetState? state) {
    isHeadsetPlugged = state == HeadsetState.CONNECT;
    Logger.info('headsetEvent, status: $isHeadsetPlugged');
  }

  static Future headsetCheck() async {
    final state = await headsetPlugin.getCurrentState;
    headsetEvent(state);
  }

  static Future headsetInit() async {
    final state = await headsetPlugin.getCurrentState;
    headsetEvent(state);
    headsetPlugin.setListener((state) => headsetEvent(state));
  }

  static void updateWordStatistic() {
    totalWordsCount = wordList.length;
    learnedWordsCount = 0;
    newWordsCount = 0;
    repeatWordsCount = 0;
    for(var i = 0; i < wordList.length; i++) {
      if (wordList[i].mem == 0) {
        newWordsCount += 1;
      }
      else if (wordList[i].mem == 9) {
        learnedWordsCount += 1;
      }
      else if (wordList[i].mem > 0 && wordList[i].mem < 9) {
        repeatWordsCount += 1;
      }
    }
  }

 /*  static void generateNextWordIndex() {
    var lastRepeat = ((DateTime.now().millisecondsSinceEpoch / 1000) / 60).round();
    var lastIndex = -1;
    List<int> newWordIndexList = [];

    if (firstWord) {
      for(var i = 0; i < wordList.length; i++) {
        if (wordList[i].mem < 9) {
          if (wordList[i].repeat != 0 && wordList[i].repeat < lastRepeat) {
            lastRepeat = wordList[i].repeat;
            lastIndex = i;
          }
          if (wordList[i].mem == 0) {
            newWordIndexList.add(i);
          }
        }
      }
      if (lastIndex == -1 && newWordIndexList.isNotEmpty) {
        final randomInt = Random().nextInt(newWordIndexList.length);
        lastIndex = newWordIndexList[randomInt];
      }
      if (lastIndex != -1) {
        currentWordIndex = lastIndex;
      }
    }
    else {
      if (!wordsOver) {
        previousWordIndex = currentWordIndex;
        currentWordIndex = nextWordIndex;
      }
    }

    lastRepeat = ((DateTime.now().millisecondsSinceEpoch / 1000) / 60).round();
    lastIndex = -1;
    newWordIndexList = [];
    for(int i = 0; i < wordList.length; i++) {
      if (wordList[i].mem < 9 && i != currentWordIndex) {
        if (wordList[i].repeat != 0 && wordList[i].repeat < lastRepeat) {
          lastRepeat = wordList[i].repeat;
          lastIndex = i;
        }
        if (wordList[i].mem == 0) {
          newWordIndexList.add(i);
        }
      }
    }
    if (lastIndex == -1 && newWordIndexList.isNotEmpty) {
      final randomInt = Random().nextInt(newWordIndexList.length);
      lastIndex = newWordIndexList[randomInt];
    }

    if (lastIndex == -1) {
      wordsOver = true;
      updateWordStatistic();
    }
    else {
      wordsOver = false;
      nextWordIndex = lastIndex;
    }
  } */

  static void generateWordIndexNext() {
    var lastRepeat = ((DateTime.now().millisecondsSinceEpoch / 1000) / 60).round();
    var lastIndex = -1;
    final List<int> newWordIndexList = [];

    for(int i = 0; i < wordList.length; i++) {
      if (wordList[i].mem >= 9)
        continue;
      
      if (i == wordIndexNext)
        continue;

      if (wordList[i].mem == 0) {
          newWordIndexList.add(i);
          continue;
      }

      if (wordList[i].repeat != 0 && wordList[i].repeat < lastRepeat) {
        lastRepeat = wordList[i].repeat;
        lastIndex = i;
      }
    }

    if (lastIndex == -1) {
      if (newWordIndexList.isNotEmpty) {
        final randomInt = Random().nextInt(newWordIndexList.length);
        lastIndex = newWordIndexList[randomInt];
      }
    }

    wordsOver = wordIndexNext == -1 && lastIndex == -1;

    if (wordIndexNext != -1) {
      if (wordIndexStack.length >= 10) {
        wordIndexStack.removeAt(0);
      }
      wordIndexStack.add(wordIndexNext);
    }
    wordIndexNext = lastIndex;

    Logger.info('wordIndexStack: $wordIndexStack, wordIndexNext: $wordIndexNext');
  }

  static void onWordChanged(bool rem, bool isUnreveal, int timeDiff) {
    final indx = wordIndexStack.last;
    if (indx == -1 || wordsOver) {
      generateWordIndexNext();
      return;
    }
    final currentWordMem = wordList[indx].mem;
    final currentMin = ((DateTime.now().millisecondsSinceEpoch / 1000) / 60).round();
    var reactionAspect = 1;
    if (timeDiff < 2500) {
      reactionAspect = 3;
    } else if (timeDiff >= 2500 && timeDiff < 5000 ) {
      reactionAspect = 2;
    } else if (timeDiff >= 5000) {
      reactionAspect = 1;
    }

    if (rem) {
      if (currentWordMem == 0) {
        if (isUnreveal) {
          wordList[indx].mem = 8;
          wordList[indx].repeat = currentMin + 60 * 24;
        }
        else {
          wordList[indx].mem = 9;
        }
      }
      else if (currentWordMem > 0 && currentWordMem < 9) {
        if (isUnreveal) {
          wordList[indx].mem = max(currentWordMem - 1, 1);
          wordList[indx].repeat = currentMin + 60 * 24 * currentWordMem;
        }
        else {
          wordList[indx].mem = min(currentWordMem + 2, 9);
          wordList[indx].repeat = currentMin + 60 * 24 * (currentWordMem * reactionAspect);
        }
      }
    }
    else {
      if (currentWordMem == 0 || currentWordMem == 1) {
        wordList[indx].mem = 1;
        wordList[indx].repeat = currentMin + 10;
        // TODO add 10 min wordList[currentWordIndex].repeat = currentMin + 10;
      }
      else if (currentWordMem > 1 && currentWordMem < 9) {
        wordList[indx].mem = max(currentWordMem - 2, 1);
        wordList[indx].repeat = currentMin + 60 * 24 * currentWordMem;
      }
    }

    TeachAudioState.updateWordInShuffledWords(wordList[indx]);
    saveJsonDataSplinter([wordList[indx]]);
    generateWordIndexNext();
  }

  static bool isWordListReady() {
    return wordList.isNotEmpty;
  }

  static Future backupDB() async {
    await Storage.backupFilepicker();
  }

  static Future loadBackupDB() async {
    final result = await Storage.loadBackupFilepicker();

    if (result) {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      }
      else if (Platform.isIOS) {
        exit(0);
      }
    }
  }

  static Future googleLigIn() async {
    try {
      var googleSignIn = GoogleSignIn(scopes: [DriveApi.driveScope]);
      var account = await googleSignIn.signIn();
      Logger.info('User account $account');
    } catch (error) {
      Logger.info('google login error: ${error.toString()}');
    }
  }

  static Future init() async {
    Logger.info('exec Application init');

    Firebase.initializeApp();

    Logger.info('start headsetInit');
    await headsetInit();
    Logger.info('finish headsetInit');

    Logger.info('start loadJsonData');
    await loadJsonData();
    Logger.info('finish loadJsonData');

    Logger.info('start saveJsonData');
    await saveJsonData();
    Logger.info('finish saveJsonData');

    Logger.info('start loadSettings');
    await SettingsState.loadSettings();
    Logger.info('finish loadSettings');

    Logger.info('start TeachState.init');
    await TeachState.init();
    Logger.info('finish TeachState.init');

    Logger.info('start DictionariesState.init');
    await DictionariesState.init();
    Logger.info('finish DictionariesState.init');

    Logger.info('start TeachAudioState.init');
    await TeachAudioState.init();
    Logger.info('finish TeachAudioState.init');

    await Future.delayed(const Duration(milliseconds: 10));
  }

  static Future waitWordList() async {
    if (isWordsLoaded) return;

    while (!isWordsLoaded)
    {
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  static Future loadWordPool() async {
    final dictMap = await Storage.readDictionaries();
    dictMap.forEach((dictName, dictData) {
      if (dictData.isNotEmpty) {
        final decodeFile = json.decode(dictData);
        if (decodeFile['data'] != null) {
          for (final decodeWord in decodeFile['data']) {
            final word = Word.fromJson(decodeWord as Map<String, dynamic>);
            word.fromDict.add(dictName);
            addWordToWordList(word);
          }
        }
      }
    });
  }

  static Future loadJsonData() async {
    var jsonText = '{}';
    jsonText = await Storage.readDB();
    final decodeFile = json.decode(jsonText);
    if (decodeFile['data'] != null) {
      for (final decodeWord in decodeFile['data']) {
        final word = Word.fromJson(decodeWord as Map<String, dynamic>);
        //Logger.info('add to wordlist: $decodeWord');
        wordList.add(word);
      }
    }
    updateWordStatistic();
    Logger.info('Total words loaded after db: $totalWordsCount');

    await loadWordPool();
    updateWordStatistic();
    Logger.info('Total words loaded after pool: $totalWordsCount');

    await loadJsonDataSplinter();
    updateWordStatistic();
    Logger.info('Total words loaded after splinters: $totalWordsCount');

    updateWordStatistic();
    isWordsLoaded = true;
  }

  static Future saveJsonData() async {
    final data = {};
    data['version'] = '0.1';
    final tempList = [];
    for (final word in wordList) {
      if (word.mem != 0) {
        tempList.add(word.toJson());
      }
    }
    data['data'] = tempList;
    final dataJSON = json.encode(data);
    
 
    if (Platform.isAndroid || Platform.isIOS) {
      Storage.writeDB(dataJSON);
    }
  }

  static Future saveJsonDataSplinter(List<Word> savedWordList, {bool fullSave = false}) async {
    final data = <String, dynamic>{};
    data['version'] = '0.1';
    final tempList = [];
    for (final word in savedWordList) {
      if (!fullSave) {
        final emptyWord = Word();
        emptyWord.word = word.word;
        emptyWord.mem = word.mem;
        emptyWord.repeat = word.repeat;
        tempList.add(emptyWord.toJson());
      }
      else {
        tempList.add(word.toJson());
      }
    }
    data['data'] = tempList;
    final dataJSON = json.encode(data);
    Logger.info(data['data'].toString());
    
    if (Platform.isAndroid) {
      await Storage.writeSplinter(dataJSON);
    }
  }

  static void addWordToWordList(Word word, {bool fullReplase = true}) {
    var isInList = false;
    for(var i = 0; i < wordList.length; i++) {
      if (wordList[i].word == word.word) {
        isInList = true;
        if (word.mem != 0) {
          if (fullReplase) {
            final tempDictList = [...wordList[i].fromDict, ...word.fromDict];
            wordList[i] = word;
            wordList[i].fromDict = tempDictList;
          }
          else {
            wordList[i].mem = word.mem;
            wordList[i].repeat = word.repeat;
          }
        }
        break;
      }
    }
    if (!isInList) {
      wordList.add(word);
    }
  }

  static Future loadJsonDataSplinter() async {
    final jsonTextList = await Storage.readSplinter();
    for (final jsonText in jsonTextList) {
      final decodeFile = json.decode(jsonText);
      if (decodeFile['data'] != null) {
        for (final decodeWord in decodeFile['data']) {
          final word = Word.fromJson(decodeWord as Map<String, dynamic>);
          Logger.info(decodeWord.toString());
          addWordToWordList(word, fullReplase: false);
        }
      }
    }
  }

  static Future removeDictionary(String dictName) async {
    final jsonTextList = await Storage.readSplinter();
    final List<Word> savedWordList = [];
    for (final jsonText in jsonTextList) {
      final decodeFile = json.decode(jsonText);
      if (decodeFile['data'] != null) {
        for (final decodeWord in decodeFile['data']) {
          final word = Word.fromJson(decodeWord as Map<String, dynamic>);
            for(var i = 0; i < wordList.length; i++) {
              if (wordList[i].word == word.word) {
                // Becose we delete all splinters :(
                //if (wordList[i].fromDict.contains(dictName)) {
                  //if (wordList[i].fromDict.length == 1) {
                    savedWordList.add(wordList[i]);
                  //}
                //}
              }
            }
        }
      }
    }
    await saveJsonDataSplinter(savedWordList, fullSave: true);

    for(var i = 0; i < wordList.length; i++) {
      if (wordList[i].fromDict.contains(dictName)) {
        if (wordList[i].fromDict.length == 1) {
          wordList.removeAt(i);
          break;
        }
        else if (wordList[i].fromDict.length > 1) {
          wordList[i].fromDict.remove(dictName);
          break;
        }
      }
    }
  }
}



class Word {
  String word = '';
  String transcription  = '';
  String translate  = '';
  Map<String, List<Meaning>> partOfSpeech = {};
  List<String> examples = [];

  List<ColoredExample> coloredExamples = [];
  List<String> fromDict = [];

  int mem = 0;
  int repeat = 0;

  Word();

  Word.fromJson(Map<String, dynamic> jsonData) {
    if (jsonData['w'] != null) {
      word = jsonData['w'] as String;
    }

    if (jsonData['tc'] != null) {
      transcription = jsonData['tc'] as String;
    }

    if (jsonData['tl'] != null) {
      translate = jsonData['tl'] as String;
    }

    if (jsonData['m'] != null) {
      mem = jsonData['m']  as int;
    }

    if (jsonData['r'] != null) {
      repeat = jsonData['r'] as int;
    }

    jsonData.forEach((key, value) {
      if (value is Iterable && key == 'ex') {
        for (final jsonExample in value) {
            examples.add(jsonExample as String);
        }
      }
    });

    jsonData.forEach((key, value) {
      if (value is Iterable && key == 'ex') {
        var counter = 0;
        var previousString = '';
        for (var exampleString in value) {
          exampleString = exampleString as String;
          if (counter.isOdd) {
            coloredExamples.add(ColoredExample.fromTwoString(previousString, exampleString));
          }
          counter++;
          previousString = exampleString;
        }
      }
    });

    jsonData.forEach((key, value) {
      if (value is Iterable && key != 'ex') {
        final meaningList = <Meaning>[];
        for (final jsonMeaning in value) {
          meaningList.add(Meaning.fromJson(jsonMeaning as Map<String, dynamic>));
        }
        partOfSpeech[key] = meaningList;
      }
    });
  }

  Map toJson() {
    final data = <String, dynamic>{};
    if (word != '') {
      data['w'] = word;
    }
    if (transcription != '') {
      data['tc'] = transcription;
    }
    if (translate != '') {
      data['tl'] = translate;
    }
    if (mem > 0) {
      data['m'] = mem;
    }
    if (repeat > 0) {
      data['r'] = repeat;
    }

    if (examples.isNotEmpty) {
      data['ex'] = <String>[];
      for (final example in examples) {
        data['ex'].add(example);
      }
    }

    partOfSpeech.forEach((key, meaningList) {
      final tempList = [];
      for (final meaning in meaningList) {
        tempList.add(meaning.toJson());
      }
      data[key] = tempList;
    });
    return data;
  }
}

class ColoredExample {
  List<String> learnLangExample = [];
  String selfLangExample = '';
  int coloredIndex = -1;

  ColoredExample.fromTwoString(String s1, String s2) {
    final startIndex = s1.indexOf('[');
    final endIndex = s1.indexOf(']');
    if (startIndex >= 0 && endIndex >= 0) {
      final beforeString = s1.substring(0, startIndex);
      if (beforeString.isNotEmpty) {
        learnLangExample.add(beforeString);
      }
      final middleString = s1.substring(startIndex + 1, endIndex);
      if (middleString.isNotEmpty) {
        learnLangExample.add(middleString);
        coloredIndex = learnLangExample.length -1;
      }
      final afterString = s1.substring(endIndex + 1, s1.length);
      if (afterString.isNotEmpty) {
        learnLangExample.add(afterString);
      }
    }
    else {
      learnLangExample.add(s1);
    }
    selfLangExample = s2;
  }
}

class Meaning {
  int? frequency;
  String? translation;

  Meaning(
    {
      this.frequency,
      this.translation,
    }
  );

  Meaning.fromJson(Map<String, dynamic> jsonData)
  {
    frequency = jsonData['f'] as int;
    translation = jsonData['w'] as String;
  }

  Map<String, dynamic> toJson() =>
  {
    'f': frequency,
    'w': translation,
  };
}