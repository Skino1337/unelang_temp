import 'package:unelang_test/common/storage_web.dart';
import 'package:unelang_test/common/storage.dart';
import 'package:unelang_test/models/application.dart';

class DictionariesState {
  static List<String> availDictsList = [];
  static List<String> currentDictsList = [];

  static Future<List<String>> getDictionariesFromCloud() async {
    availDictsList = await StorageWeb.getDictionariesNames();
    return availDictsList;
  }

  static Future<List<String>> getDictionariesFromMem() async {
    currentDictsList = await Storage.getDictionaries();
    return currentDictsList;
  }

  static Future getDictionaries() async {
    if (availDictsList.isEmpty) {
      availDictsList = await StorageWeb.getDictionariesNames();
    }
    currentDictsList = await Storage.getDictionaries();
  }

  static Future init() async {
    currentDictsList = await Storage.getDictionaries();
  }

  static Future setupDictionary(String name) async {
    final nameFull = '$name.json';
    final file = await Storage.getFileToWire(nameFull);
    await StorageWeb.downloadFile(file, nameFull);
  }

  static Future removeDictionary(String name) async {
    await ApplicationState.removeDictionary(name);
    await Storage.removeDictionary(name);
  }

  static bool isInProgress(String dict) {
    var retVal = false;
    for (final it_dict in currentDictsList) {
      if (it_dict.contains(dict)) {
        retVal = true;
        break;
      }
    }

    return retVal;
  }
}