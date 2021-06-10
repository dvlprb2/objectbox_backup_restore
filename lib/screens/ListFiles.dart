import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class ListFiles extends StatefulWidget {
  const ListFiles({Key? key}) : super(key: key);

  @override
  _ListFilesState createState() => _ListFilesState();
}

class _ListFilesState extends State<ListFiles> {
  List files = [];

  @override
  void initState() {
    super.initState();
    _listFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo"),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: files
                    .map(
                      (_) => ListTile(
                        title: Text(
                          _.path,
                        ),
                      ),
                    )
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _listFiles() async {
    String directory = (await getApplicationDocumentsDirectory()).path;
    setState(() {
      files = Directory('$directory/db').listSync();
    });
  }
}
