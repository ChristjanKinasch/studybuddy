import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:study_buddy/data/subjects_data_constructors.dart';
class FileHandler {
  static final List<Subject> subjectList = <Subject>[];

  ///Read data from static file in 'assets/' for testing

/*
  Future readFile() async {
    var values =
        jsonDecode(await rootBundle.loadString('assets/subjects.json'));

    return (values != null) ? onPopulated(values) : onNullOrEmpty();
  }
*/

  ///Read data from device file system
  ///Construct usable values and return StateContainer for application wide
  ///   access
  readFile() async {
    try {
      final file = await _localFile;
      print('FileHandler.readFile** Reading Data');
      var values = json.decode(await file.readAsString());
      return (values != null) ? onPopulated(values) : onNullOrEmpty();
    } catch (e) {
      print('FileHandler.readFile** File READ Error: $e');
      return onNullOrEmpty();
    }
  }

  onPopulated(dynamic values) {
    print('FileHandler.onPopulated** Parsing raw JSON');
    subjectList.clear();
    values.forEach((i) => subjectList.add(Subject.fromJson(i)));

    print('FileHandler.onPopulated** JSON parsed, returning List');
    return subjectList;
  }

  onNullOrEmpty() {
    print('FileHandler.onNullOrEmpty** EmptyValues');
  }

  ///Navigate to device file system path -
  /// getTemporaryDirectory() - path for testing so cache can be cleared,
  /// getApplicationDocumentsDirectory() - for storage until app is uninstalled
  Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    print('FileHandler._localPath** Retrieving Path');
    return dir.path;
  }

  ///Retrieve file within device system path
  Future<File> get _localFile async =>
      File('${await _localPath}/subjects.json');

  ///Write to file
  Future writeFile(List<dynamic> data) async {
    final file = await _localFile;

    print('FileHandler.writeFile** Writing Data');
    return file.writeAsString(json.encode(data));
  }
}
