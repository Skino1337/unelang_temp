import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';

import 'package:unelang_test/common/logger.dart';
import 'package:unelang_test/models/application.dart';
import 'package:unelang_test/models/teach.dart';

// TODO on diffenent word len dif text size = dif word height = offset to up

class Teach extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Logger.info('Teach widget build');
    final pageViewBuilder = PageView.builder(
                scrollDirection: Axis.vertical,
                onPageChanged: (int index) {
                  context.read<TeachState>().onPageViewChangeNotStatic(index);
                  TeachState.onPageViewChange(index);
                  
                },
                controller: TeachState.pageController,
                itemBuilder: (context, index) => WordWidget(index),
                // itemCount: null,
              );
    if (!ApplicationState.isWordListReady()) {
      return Scaffold(
        body: SafeArea(
          child: FutureBuilder(
            future: ApplicationState.waitWordList(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                Logger.info('create PageView.builder in Teach widget build (isWordListReady NOT)');
                return pageViewBuilder;
              } else {
                Logger.info('create CircularProgressIndicator in Teach widget build (isWordListReady NOT)');
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      );
    }
    else {
      Logger.info('create PageView.builder in Teach widget build (isWordListReady)');
      return Scaffold(body: SafeArea(child: pageViewBuilder));
    }
  }
}

class WordWidget extends StatelessWidget {
  final int index;
  const WordWidget(this.index);

  @override
  Widget build(BuildContext context) {
    Logger.info('Word widget build');
    var wordIndex = -1;
    if (ApplicationState.firstWord) {
      TeachState.currentPageIndex = index;
      TeachState.pageStartTime = DateTime.now();
      //ApplicationState.generateNextWordIndex();
      ApplicationState.generateWordIndexNext();
      ApplicationState.generateWordIndexNext();
      wordIndex = ApplicationState.wordIndexStack.last;
      ApplicationState.firstWord = false;
    }
    else {
      wordIndex =  ApplicationState.wordIndexNext;
    }
    //Logger.info('wordIndexStack: ${ApplicationState.wordIndexStack}, wordIndexNext: ${ApplicationState.wordIndexNext}');
    if (ApplicationState.wordIndexNext == -1) {
      ApplicationState.updateWordStatistic();
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Невозможно подобрать слово,'),
            const Text('добавьте больше слов для изучения.'),
            const SizedBox(height: 20),
            Text('Всего слов: ${ApplicationState.totalWordsCount}'),
            Text('Выученных слов: ${ApplicationState.learnedWordsCount}'),
            Text('Новых слов: ${ApplicationState.newWordsCount}'),
            Text('Слов для повторения: ${ApplicationState.repeatWordsCount}'),
          ]
        )
      );
    }

    final word = ApplicationState.wordList[wordIndex];
    final List<Widget> debugWidgetList = [];
    final ts = (word.transcription.isNotEmpty) ? word.transcription : word.word;
    if (true) {
      final d = DateTime.fromMillisecondsSinceEpoch(word.repeat * 60000);
      final timeDiff = DateTime.now().difference(TeachState.pageStartTime).inMilliseconds;
      var timeFormated = '${d.day}.${d.month}.${d.year}';
      timeFormated += ' ${d.hour}:${d.minute}:${d.second}';
      debugWidgetList.add(Text('current mem level ${word.mem}',
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 20,
              color: Color.fromARGB(200, 0, 0, 0),
          )));
      debugWidgetList.add(
        Text('date to rem $timeFormated',
          textAlign: TextAlign.left,
          style: const TextStyle(
          fontSize: 20,
          color: Color.fromARGB(200, 0, 0, 0),
      )));
      debugWidgetList.add(
        Text('previous unrevealed: ${TeachState.isReveal}',
          textAlign: TextAlign.left,
          style: const TextStyle(
          fontSize: 20,
          color: Color.fromARGB(200, 0, 0, 0),
      )));
      debugWidgetList.add(
        Text('time to swap: ${timeDiff / 1000}',
          textAlign: TextAlign.left,
          style: const TextStyle(
          fontSize: 20,
          color: Color.fromARGB(200, 0, 0, 0),
      )));
    }
    //final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          SizedBox(
            height: height * (1 / 3),
            child: Column(
              children: [...debugWidgetList],
            ),
          ), 
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
              ReadWordWidget(word: word),
            ]
          ),
          const SizedBox(height: 12),
          RevealTranslateWidget(word: word),
        ],
      )
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

class RevealTranslateWidget extends StatefulWidget {
  const RevealTranslateWidget({ Key? key, this.word}) : super(key: key);

  final Word? word;

  @override
  _RevealTranslateWidget createState() => _RevealTranslateWidget();

}

class _RevealTranslateWidget extends State<RevealTranslateWidget> {
  _RevealTranslateWidget();

  bool isReveal = false;
  Word? word;

  @override
  void initState() {
    word = widget.word;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isReveal) {
      return Column(
        children: [
          Text(word!.translate,
            textAlign: TextAlign.center,
            style: const TextStyle(
            fontSize: 36,
            color: Color.fromARGB(200, 0, 0, 0)
          )),
          const SizedBox(height: 12),
          PartsOfSpeechAndExampleAreaWidget(word: word),
        ],
      );
    }
    else {
      return SizedBox(
        width: 100,
        height: 100,
        child: ElevatedButton(
          onPressed:() {
            isReveal = true;
            TeachState.setReveal(true);
            setState((){});
          },
          child: const Icon(Icons.remove_red_eye),
        ),
      );
    }
  }
}

class PartsOfSpeechAndExampleAreaWidget extends StatelessWidget {
  final Word? word;

  const PartsOfSpeechAndExampleAreaWidget({this.word});

  @override
  Widget build(BuildContext context) {
    final bool hasExample = word?.coloredExamples.isNotEmpty ?? false;
    if (hasExample) {
      return Container(
        height: 300,
        padding: EdgeInsets.symmetric(horizontal: 40),
        //color: Colors.yellow,
        child: PageView(
          children: <Widget>[
            PartsOfSpeechAreaWidget(word),
            ExamplesAreaWidget(word),
          ],
        ),
      );
    }
    else {
      return Container(
        height: 300,
        padding: EdgeInsets.symmetric(horizontal: 40),
        //color: Colors.yellow,
        child: PartsOfSpeechAreaWidget(word),
      );
    }
  }
}

class PartsOfSpeechAreaWidget extends StatelessWidget {
  final Word? word;

  const PartsOfSpeechAreaWidget(this.word);

  @override
  Widget build(BuildContext context) {
    final bool hasExample = word?.coloredExamples.isNotEmpty ?? false;
    List<Widget> widgedList = [];
    word?.partOfSpeech.forEach((key, value) {
      final heading = TeachState.getPartOfSpeechName(key);
      widgedList = widgedList + [
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
    return Row(
      children: [
        Column(
          children: widgedList
        ),
        Spacer(),
        if (hasExample) Row(
          children: [
            Icon(Icons.keyboard_arrow_left),
            Container(
              alignment: Alignment.centerRight,
              child: RotatedBox(quarterTurns: -1,
                child: Text('Examples')
              ),
            ),
          ]
        )
      ]
    );
  }
}

class ExamplesAreaWidget extends StatelessWidget {
  final Word? word;

  const ExamplesAreaWidget(this.word);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgeList = [];
    widgeList = widgeList + [
        const SizedBox(height: 16),
        Text('Примеры',
          style: const TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 26, 115, 232)
          )
        ),
        const SizedBox(height: 16),
      ];
    if (word != null) {
      for (final coloredExample in word!.coloredExamples) {
        final List<TextSpan> textSpanList = [];
        for(var i = 0; i < coloredExample.learnLangExample.length; i++) {
          if (i == coloredExample.coloredIndex) {
            textSpanList.add(TextSpan(
              text: coloredExample.learnLangExample[i],
              style: TextStyle(color: Color.fromARGB(255, 26, 115, 232))
            ));
          }
          else {
            textSpanList.add(TextSpan(text: coloredExample.learnLangExample[i]));
          }
        }
        widgeList = widgeList + [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
              children: textSpanList
            ),
          ),
          const SizedBox(height: 2),
          Text(coloredExample.selfLangExample),
          const SizedBox(height: 12),
        ];
      }
    }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgetList);
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