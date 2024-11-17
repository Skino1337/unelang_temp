import 'package:flutter/material.dart';
import 'package:unelang_test/common/audio.dart';

import 'package:unelang_test/common/storage.dart';
import 'package:unelang_test/models/application.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ApplicationState.updateWordStatistic();
    return Scaffold(
      appBar: AppBar(),
      drawer: DrawerWidget(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Всего слов: ${ApplicationState.totalWordsCount}'),
            Text('Выученных слов слов: ${ApplicationState.learnedWordsCount}'),
            Text('Новых слов: ${ApplicationState.newWordsCount}'),
            Text('Слов для повторения: ${ApplicationState.repeatWordsCount}'),
            const SizedBox(height: 60),
            const Text('Hi'),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/teach');
                  ApplicationState.headsetCheck();
                },
                child: const Text('Teach words')),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/teach_audio'),
                child: const Text('listen words')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/dictionaries'),
              child: const Text('Dictionaries')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ApplicationState.backupDB();
              },
              child: const Text('save backup to file')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ApplicationState.loadBackupDB();
              },
              child: const Text('load from backup')),
            //ElevatedButton(child: Text("Play"), onPressed: audioHandler.play),
            //ElevatedButton(child: Text("Pause"), onPressed: audioHandler.pause),
          ],
      ),
    ));
  }
}

class DrawerWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            MenuHead(),
            const Divider(height: 2),
            MenuItem('Настройки',
              onClick: () {Navigator.pushNamed(context, '/settings');}),
            const Divider(height: 2),
            MenuItem('О программе', onClick: () {}),
          ],
        ),
      ),
    );
  }
}

class MenuHead extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40, bottom: 40),
      child: Text('Unelang v1.0',
        style: TextStyle(
          fontSize: 20,
          color: Color.fromARGB(200, 0, 0, 0)
        )),
    );
  }
}

class MenuItem extends StatelessWidget {
  @required final String title;
  final VoidCallback? onClick;

  const MenuItem(this.title, {this.onClick});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title,
        style: TextStyle(
          fontSize: 20,
          color: Color.fromARGB(200, 0, 0, 0)
        )
      ),
      hoverColor: Colors.white70,
      onTap: onClick,
    );
  }
}
