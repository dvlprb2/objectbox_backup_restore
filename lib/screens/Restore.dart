import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:objectbox_backup_restore/screens/Tasks.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class Restore extends StatefulWidget {
  const Restore({Key? key}) : super(key: key);

  @override
  _RestoreState createState() => _RestoreState();
}

class _RestoreState extends State<Restore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: ElevatedButton(
            onPressed: () => _selectBackupFile(context),
            child: Text("Select Backup File"),
          ),
        ),
      ),
    );
  }

  Future<void> _selectBackupFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    String _path = (await getApplicationDocumentsDirectory()).path;
    print(_path);
    if (result != null) {
      File file = File(result.files.single.path!);
      file.copy(join(_path, 'db.zip'));
      _restoreDB(context);
    } else {
      // User canceled the picker
      print("canceled picker");
    }
  }

  // void _removeOldFiles() async {
  //   String _path = (await getApplicationDocumentsDirectory()).path;
  //   final dir = Directory(join(_path, 'db')).path;
  //
  //   File dataFile = File(join(dir, 'data.mdb'));
  //   File lockFile = File(join(dir, 'lock.mdb'));
  //   dataFile.deleteSync();
  //   lockFile.deleteSync();
  // }

  void _copyNewFile() async {
    String _path = (await getApplicationDocumentsDirectory()).path;
    final dir = Directory(join(_path, 'db', 'db')).path;
    final copyDir = Directory(join(_path, 'db')).path;

    File dataFile = File(join(dir, 'data.mdb'));
    File lockFile = File(join(dir, 'lock.mdb'));
    dataFile.copySync(join(copyDir, 'data.mdb'));
    lockFile.copySync(join(copyDir, 'lock.mdb'));
  }

  void _restoreDB(BuildContext context) async {
    print("Restoring db...");
    String _path = (await getApplicationDocumentsDirectory()).path;
    final dataDir = Directory(join(_path, 'db'));
    print(dataDir.path);

    if (dataDir.existsSync()) {
      dataDir.deleteSync(recursive: true);
      final zipFile = File(join(_path, 'db.zip'));
      final destinationDir = Directory(join(_path, 'db'));
      try {
        print("Unzipping file...");
        await ZipFile.extractToDirectory(
            zipFile: zipFile, destinationDir: destinationDir);

        print("Unzipping done...");
        _copyNewFile();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Tasks()),
        );
      } catch (e) {
        print(e);
      }
    }
  }
}
