import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';

import 'package:unelang_test/common/logger.dart';
import 'package:unelang_test/models/application.dart';
import 'package:unelang_test/models/teach.dart';
import 'package:unelang_test/models/teach_audio.dart';

class TeachAudio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Logger.info('TeachAudio widget build');
    if (ApplicationState.isWordListReady()) {
      Logger.info('create TeachAudioLoaded in TeachAudio widget build (isWordListReady)');
      return Scaffold(body: SafeArea(child: WordWidget()));
    }
    else {
      return Scaffold(
        body: SafeArea(
          child: FutureBuilder(
            future: ApplicationState.waitWordList(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                Logger.info('create TeachAudioLoaded in TeachAudio widget build (isWordListReady NOT)');
                return WordWidget();
              } else {
                Logger.info('create CircularProgressIndicator in TeachAudio widget build (isWordListReady NOT)');
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      );
    }
  }
}

class WordWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Logger.info('Word widget TA build');

    if (TeachAudioState.shuffledWordList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Новые слова закончились'),
            Text('Всего слов: ${ApplicationState.totalWordsCount}'),
            Text('Новых слов: ${ApplicationState.newWordsCount}'),
            Text('Слов для повторения: ${ApplicationState.repeatWordsCount}'),
          ]
        )
      );
    }

    final index = context.select((TeachAudioState c) => c.wordIndex);
    final word = TeachAudioState.shuffledWordList[index];
    final ts = (word.transcription.isNotEmpty) ? word.transcription : word.word;
    final height = MediaQuery.of(context).size.height;
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          SizedBox(height: height * (1 / 5),), 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 20),
              Flexible(
                child: AutoSizeText(word.word,
                textAlign: TextAlign.center,
                maxLines: 1,
                minFontSize: 40,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 80,
                  color: Color.fromARGB(200, 0, 0, 0),
                  )
                ),
              ),
              const SizedBox(width: 20),
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: 
            [
              Text('[$ts]',
              textAlign: TextAlign.center,
              style: const TextStyle(
              fontSize: 16,
              color: Color.fromARGB(150, 0, 0, 0)
              )),
              const SizedBox(width: 12),
            ]
          ),
          const SizedBox(height: 12),
          TranslateWidget(word: word),
          AudioAreaWidget(),
          SizedBox(height: 60)
        ],
      )
    );
  }
}

class AudioAreaWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isPlaying = context.select((TeachAudioState c) => c.isPlaying);
    return Expanded(
      child: Container(
        alignment: Alignment.bottomCenter,
        //color: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 60),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () => {context.read<TeachAudioState>().goToPreviousWord()},
              child: Icon(Icons.skip_previous, size: 40),
            ),
            InkWell(
              onTap: () {
                if (isPlaying) {
                  context.read<TeachAudioState>().stopPlayng();
                } else {
                  context.read<TeachAudioState>().startPlayng(onlyThis: false);
                }
              },
              child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 100),
            ),
            InkWell(
              onTap: () => {context.read<TeachAudioState>().goToNextWord()},
              child: Icon(Icons.skip_next, size: 40),
            ),
          ],
        ),
      ),
    );
  }
}

class ReadWordWidget extends StatefulWidget {
  const ReadWordWidget({ Key? key, this.word}) : super(key: key);

  final Word? word;

  @override
  _ReadWordWidget createState() => _ReadWordWidget();
}

class _ReadWordWidget extends State<ReadWordWidget> {
  _ReadWordWidget();

  Word? word;

  @override
  void initState() {
    word = widget.word;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isVoicePlay = context.select((TeachState c) => c.isVoicePlay);
    return SizedBox(
    width: 40,
    height: 40,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: EdgeInsets.zero,
      ),
      onPressed:() {
        if (isVoicePlay) {
          context.read<TeachState>().speakStop();
        } else {
          context.read<TeachState>().speakStart(word!.word);
        }
        setState(() {});
      },
      child: Center(
        child: Icon(
        isVoicePlay ? Icons.stop : Icons.play_circle,
        size: 20)),
    ),);
  }
}

class TranslateWidget extends StatelessWidget {
  final Word? word;

  const TranslateWidget({this.word});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(word!.translate,
          textAlign: TextAlign.center,
          style: const TextStyle(
          fontSize: 36,
          color: Color.fromARGB(200, 0, 0, 0)
        )),
        const SizedBox(height: 12),
        PartsOfSpeechAreaWidget(word: word),
      ],
    );
  }
}

class PartsOfSpeechAreaWidget extends StatelessWidget {
  final Word? word;

  const PartsOfSpeechAreaWidget({this.word});

  @override
  Widget build(BuildContext context) {
    List<Widget> widgeList = [];
    word?.partOfSpeech.forEach((key, value) {
      final heading = TeachState.getPartOfSpeechName(key);
      widgeList = widgeList + [
        const SizedBox(height: 16),
        Text(heading,
          style: const TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 26, 115, 232)
          )
        ),
        const SizedBox(height: 8),
        PartOfSpeechAreaWidget(meaningList: value),
      ];
    });
    return Column(children: widgeList);
  }
}

class PartOfSpeechAreaWidget extends StatelessWidget {
  final List<Meaning>? meaningList;

  const PartOfSpeechAreaWidget({this.meaningList});

  @override
  Widget build(BuildContext context) {
    final widgetList = <Widget>[];
    for (final meaning in meaningList!) {
      widgetList.add(Translations(meaning: meaning));
      widgetList.add(const SizedBox(height: 10,));
    }
    return Padding(
      padding: const EdgeInsets.only(left: 100),
      child: Column(children: widgetList),
    );
  }
}

class Translations extends StatelessWidget {
  final Meaning meaning;

  const Translations({required this.meaning});

  @override
  Widget build(BuildContext context) {
    return Row (
      children: [
        Frequency(count: meaning.frequency!),
        const SizedBox(width: 8),
        Container(
          alignment: Alignment.topRight,
          child: Text(meaning.translation!,
          textAlign: TextAlign.center,))
      ]
    );
  }
}

class Frequency extends StatelessWidget {
  final int count;

  const Frequency({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 2.4),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: count > 0 ? Colors.blueAccent : Colors.grey,
              borderRadius: BorderRadius.circular(2)),
            width: 10,
            height: 6,
          ),
          const SizedBox(width: 2),
          Container(
            decoration: BoxDecoration(
              color: count > 1 ? Colors.blueAccent : Colors.grey,
              borderRadius: BorderRadius.circular(2)),
            width: 10,
            height: 6,
          ),
          const SizedBox(width: 2),
          Container(
            decoration: BoxDecoration(
              color: count > 2 ? Colors.blueAccent : Colors.grey,
              borderRadius: BorderRadius.circular(2)),
            width: 10,
            height: 6,
          )
        ],
      ),
    );
  }
}