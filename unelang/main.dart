import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:unelang_test/screens/application.dart';
import 'package:unelang_test/models/teach.dart';
import 'package:unelang_test/models/teach_audio.dart';
import 'package:unelang_test/common/audio.dart';

Future<void> main() async {
  await AudioPlayerHandler.init();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TeachState()),
        ChangeNotifierProvider(create: (_) => TeachAudioState()),
      ],
      child: Application(),
    ),
  );
}