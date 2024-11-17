import 'package:firebase_storage/firebase_storage.dart';
import 'package:unelang_test/screens/dictionaries.dart';
import 'dart:io';


class StorageWeb {
  static final instance = FirebaseStorage.instance;

  static Future<List<String>> getDictionariesNames() async {
    final ListResult result = await instance.ref('/data/dictionaries').listAll();
    final List<String> dictionariesList = [];

    result.items.forEach((Reference ref) {
      var fileName = ref.name;
      if (fileName.contains('.json')) {
        fileName = fileName.replaceAll('.json', '');
        dictionariesList.add(fileName);
      }
      print('Found file: $ref');
    });

    result.prefixes.forEach((Reference ref) {
      print('Found directory: $ref');
    });

    return dictionariesList;
    // https://firebase.flutter.dev/docs/storage/usage
  }

  static Future downloadFile(File file, String name) async {
    final ref = instance.ref('/data/dictionaries/$name');
    await ref.writeToFile(file);
  }
}