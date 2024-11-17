import 'package:flutter/material.dart';

import 'package:unelang_test/common/theme.dart';
import 'package:unelang_test/common/logger.dart';
import 'package:unelang_test/screens/loading_app.dart';
import 'package:unelang_test/screens/home.dart';
import 'package:unelang_test/screens/settings.dart';
import 'package:unelang_test/screens/teach.dart';
import 'package:unelang_test/screens/dictionaries.dart';
import 'package:unelang_test/screens/dictionaries_add.dart';
import 'package:unelang_test/screens/teach_audio.dart';

class Application extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Logger.info('exec Application build');
    return MaterialApp(
      title: 'unelang_test',
      theme: appTheme,
      initialRoute: '/loading_app',
      routes: {
        '/loading_app': (context) => LoadingApp(),
        '/settings': (context) => Settings(),
        '/': (context) => Home(),
        '/teach': (context) => Teach(),
        '/teach_audio': (context) => TeachAudio(),
        '/dictionaries': (context) => Dictionaries(),
        '/dictionaries_add': (context) => DictionariesAdd(),
      },
    );
  }
}