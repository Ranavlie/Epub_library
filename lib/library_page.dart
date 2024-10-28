import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:epub_view/epub_view.dart' as p1;
import 'reader_page.dart';

class LibraryPage extends StatefulWidget {
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<File> epubFiles = [];
  p1.EpubController? _epubController;

  @override
  void initState() {
    super.initState();
    _loadSavedEpubs();
  }

  Future<void> _saveEpubs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> filePaths = epubFiles.map((file) => file.path).toList();
    await prefs.setStringList('epubFiles', filePaths);
  }

  Future<void> _loadSavedEpubs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedPaths = prefs.getStringList('epubFiles');

    if (savedPaths != null) {
      setState(() {
        epubFiles = savedPaths.map((path) => File(path)).toList();
      });
    }
  }

  Future<void> _pickEpubFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['epub']);

    if (result != null) {
      setState(() {
        epubFiles.add(File(result.files.single.path!));
      });
      _saveEpubs();
    }
  }

  void _openEpub(File epubFile) async {
    p1.EpubBook epubBook = await p1.EpubReader.readBook(epubFile.readAsBytesSync());

    setState(() {
      _epubController = p1.EpubController(
        document: Future.value(epubBook),
      );
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderPage(
          epubController: _epubController!,
        ),
      ),
    );
  }

  void _deleteEpubFile(File epubFile) async {
    setState(() {
      epubFiles.remove(epubFile);
    });
    _saveEpubs(); // Güncellenmiş dosyaları kaydet
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Library')),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 4,
        ),
        itemCount: epubFiles.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => _openEpub(epubFiles[index]),
            onLongPress: () {
              // Uzun basma ile silme işlemi
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Sil'),
                  content: Text('Bu dosyayı silmek istediğinizden emin misiniz?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _deleteEpubFile(epubFiles[index]);
                        Navigator.of(context).pop();
                      },
                      child: Text('Evet'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Hayır'),
                    ),
                  ],
                ),
              );
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book, size: 100),
                  SizedBox(height: 10),
                  Text(
                    epubFiles[index].path.split('/').last,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickEpubFile,
        child: Icon(Icons.add),
      ),
    );
  }
}
