import 'package:flutter/material.dart';
import 'package:unelang_test/models/settings.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);


  @override
  _Settings createState() => _Settings();

}

class _Settings extends State<Settings> {
  _Settings();

  bool _autoReadWord = false;
  bool _autoReadWordHeadsetOnly = false;

  @override
  void initState() {
    super.initState();
    _autoReadWord = SettingsState.autoReadWord;
    _autoReadWordHeadsetOnly = SettingsState.autoReadWordHeadsetOnly;
  }

  final _textStyle = TextStyle(fontSize: 16, color: Color.fromARGB(200, 0, 0, 0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Настройки')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Авто чтение слова', style: _textStyle),
            value: _autoReadWord,
            onChanged: (bool value) {
              _autoReadWord = value;
              SettingsState.autoReadWord = value;
              SettingsState.saveSettings();
              setState(() {});
            },
          ),
          Divider(),
          SwitchListTile(
            title: Text('Авто чтение слова только в наушниках', style: _textStyle),
            value: _autoReadWordHeadsetOnly,
            onChanged: (bool value) {
              _autoReadWordHeadsetOnly = value;
              SettingsState.autoReadWordHeadsetOnly = value;
              SettingsState.saveSettings();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}