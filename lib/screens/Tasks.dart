import 'dart:io';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:objectbox_backup_restore/entity.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import '../objectbox.g.dart';

class Tasks extends StatefulWidget {
  const Tasks({Key? key}) : super(key: key);

  @override
  _TasksState createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  final faker = Faker();

  late Store _store;
  late Stream<List<Task>> _stream;
  List files = [];

  bool hasBeenInitialized = false;

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((dir) {
      _store = Store(
        getObjectBoxModel(),
        directory: join(dir.path, 'db'),
      );

      setState(() {
        _stream = _store
            .box<Task>()
            .query()
            .watch(triggerImmediately: true)
            .map((query) => query.find());
        hasBeenInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    _store.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo"),
      ),
      body: !hasBeenInitialized
          ? Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder<List<Task>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Container(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                                onPressed: () => _zipFiles(),
                                child: Text("Backup")),
                            ElevatedButton(
                                onPressed: () => null, child: Text("Restore"))
                          ],
                        ),
                        Expanded(
                          child: ListView(
                            children: snapshot.data!
                                .map(
                                  (_) => ListTile(
                                    title: Text(
                                      _.title,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        )
                      ],
                    ),
                  );
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final task = Task(title: faker.lorem.sentence());
          _store.box<Task>().put(task);
        },
        tooltip: 'Add new task',
        child: Icon(Icons.add),
      ),
    );
  }

  // void _listofFiles() async {
  //   String directory = (await getApplicationDocumentsDirectory()).path;
  //   setState(() {
  //     files = Directory("$directory")
  //         .listSync(); //use your folder name insted of resume.
  //   });
  // }

  void _zipFiles() async {
    String directory = (await getApplicationDocumentsDirectory()).path;
    final dataDir = Directory(directory);

    // Zip files
    try {
      final zipFile = File(join(directory, 'db.zip'));
      if (await zipFile.exists()) {
        await zipFile.delete();
      }
      await ZipFile.createFromDirectory(
          sourceDir: dataDir, zipFile: zipFile, recurseSubDirs: true);
      await Share.shareFiles(['$directory/db.zip'], text: 'Backup file');
    } catch (e) {
      print(e);
    }
  }
}
