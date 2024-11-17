import 'dart:async';
import 'dart:io';

import 'package:unelang_test/common/logger.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

class Storage {
  //static const String pathAppFolder = 'storage/emulated/0/unelang';
  static const String pathDB = '/db.json';
  static const String pathSettings = '/settings.json';
  static const String pathSplinters = '/data/splinters';
  static const String pathDictionaries = '/data/dictionaries';
  static const String backupName = 'unelang.backup';

  static Future<Directory> _getFolderPath({String path = ''}) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final directory = Directory('${appDocDir.path}$path');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  static Future<String> readSettings() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final file = File('${appDocDir.path}$pathSettings');
    if (await file.exists()) {
      final data = await file.readAsString();
      return data;
    }

    return '{}';
  }

  static Future writeSettings(String data) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final file = File('${appDocDir.path}$pathSettings');
    if (await file.exists()) {
      await file.delete();
    }

    await file.writeAsString(data);
  }

  static Future<String> readDB() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final file = File('${appDocDir.path}$pathDB');
    Logger.info('ApplicationDocumentsDirectory: ${appDocDir.path}');
    if (await file.exists()) {
      final data = await file.readAsString();
      return data;
    }

    return '{}';
  }

  static Future writeDB(String data) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final file = File('${appDocDir.path}$pathDB');
    if (await file.exists()) {
      await file.delete();
    }

    await file.writeAsString(data);
  }

  static Future<List<String>> getDictionaries() async {
    final folder = await _getFolderPath(path: pathDictionaries);
    final entitiesList = await folder.list().toList();
    Logger.info('count of entities in dictionaries folder ${entitiesList.length}');

    final dataList = <String>[];
    for (final entity in entitiesList) {
      Logger.info('entities in dictionaries folder ${entity.path}');
      if (entity.path.contains('.json')) {
        var fileName = basename(entity.path);
        fileName = fileName.replaceAll('.json', '');
        dataList.add(fileName);
      }
    }
    return dataList;
  }

  static Future<Map<String, String>> readDictionaries() async {
    final folder = await _getFolderPath(path: pathDictionaries);
    final entitiesList = await folder.list().toList();
    Logger.info('count of entities in dictionaries folder ${entitiesList.length}');

    final Map<String, String> dictMap = {};
    for (final entity in entitiesList) {
      Logger.info('entities in dictionaries folder: ${entity.path}');
      if (entity.path.contains('.json')) {
        var fileName = basename(entity.path);
        fileName = fileName.replaceAll('.json', '');
        final file = File(entity.path);
        final data = await file.readAsString();
        dictMap[fileName] = data;
      }
    }
    return dictMap;
  }

  static Future removeDictionary(String name) async {
    final folder = await _getFolderPath(path: pathDictionaries);
    final entitiesList = await folder.list().toList();

    for (final entity in entitiesList) {
      if (entity.path.contains(name)) {
        final file = File(entity.path);
        await file.delete();
      }
    }
  }

  static Future<File> getFileToWire(String name) async {
    final path = (await _getFolderPath(path: pathDictionaries)).path;
    final file = File('$path/$name');

    return file;
  }

  static Future<List<String>> readSplinter() async {
    final folder = await _getFolderPath(path: pathSplinters);
    final entitiesList = await folder.list().toList();
    Logger.info('count of entities in splinter folder ${entitiesList.length}');

    // Sort by name (by time).
    entitiesList.sort((a, b) => a.path.compareTo(b.path));

    final dataList = <String>[];
    for (final entity in entitiesList) {
      Logger.info('entities in splinter folder ${entity.path}');
      if (entity.path.contains('ds_') && entity.path.endsWith('.json')) {
        final file = File(entity.path);
        final data = await file.readAsString();
        await file.delete();
        dataList.add(data);
      }
    }
    return dataList;
  }

  static Future deleteSplinters() async {
    final folder = await _getFolderPath(path: pathSplinters);
    final entitiesList = await folder.list().toList();
    Logger.info('count of entities in splinter folder (to delete) ${entitiesList.length}');

    for (final entity in entitiesList) {
      Logger.info('entities in splinter folder ${entity.path}');
      if (entity.path.contains('ds_') && entity.path.endsWith('.json')) {
        final file = File(entity.path);
        await file.delete();
      }
    }
  }

  static Future writeSplinter(String data) async {
    final path = (await _getFolderPath(path: pathSplinters)).path;
    final timeMS = DateTime.now().millisecondsSinceEpoch;
    final filename = 'ds_${timeMS.toString()}.json';
    final file = File('$path/$filename');

    Logger.info('writeSplinter: $path/$filename');

    await file.writeAsString(data);
  }

  static Future backupFilepicker() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final file = File('${appDocDir.path}$pathDB');
    if (await file.exists()) {
      final params = SaveFileDialogParams(sourceFilePath: file.path, fileName: backupName);
      final filePath = await FlutterFileDialog.saveFile(params: params);
    }
  }

  static Future<bool> loadBackupFilepicker() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final oldFile = File('${appDocDir.path}$pathDB');
    if (await oldFile.exists()) {
      final params = OpenFileDialogParams();
      final filePath = await FlutterFileDialog.pickFile(params: params) ?? '';
      final newFile = File(filePath);
      if (await newFile.exists()) {
        await deleteSplinters();
        await oldFile.delete();
        await newFile.copy('${appDocDir.path}$pathDB');
        Logger.info('import from db: $filePath');

        return true;
      }
    }
    return false;
  }
}