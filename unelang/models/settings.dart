import 'dart:convert';
import 'package:unelang_test/common/storage.dart';

class SettingsState {
  static bool autoReadWord = false;
  static bool autoReadWordHeadsetOnly = false;

  static Future saveSettings() async {
    final settings = {};
    settings['autoReadWord'] = autoReadWord;
    settings['autoReadWordHeadsetOnly'] = autoReadWordHeadsetOnly;
    final settingsJSON = json.encode(settings);
    
    Storage.writeSettings(settingsJSON);
  }

  static Future loadSettings() async {
    final settingsJSON = await Storage.readSettings();
    final settings = json.decode(settingsJSON);
    if (settings['autoReadWord'] != null) {
      autoReadWord = settings['autoReadWord'] as bool;
    }
    if (settings['autoReadWordHeadsetOnly'] != null) {
      autoReadWordHeadsetOnly = settings['autoReadWordHeadsetOnly'] as bool;
    }
  }
}