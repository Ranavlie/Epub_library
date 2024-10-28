import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart' as p1;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'timer_provider.dart'; // Import TimerProvider here

class ReaderPage extends StatefulWidget {
  final p1.EpubController epubController;

  const ReaderPage({Key? key, required this.epubController}) : super(key: key);

  @override
  _ReaderPageState createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  bool isVerticalScroll = true;
  final ValueNotifier<double> brightness = ValueNotifier<double>(0.5);
  final ValueNotifier<double> fontSize = ValueNotifier<double>(18.0);
  bool isBarsVisible = true;
  String selectedFontType = 'Default';
  Color? selectedHighlightColor;
  String selectedText = ''; // To store selected text

  List<String> fontTypes = ['Default', 'Serif', 'Sans-serif', 'Monospace'];

  @override
  void didChangePlatformBrightness() {
    _setSystemUIOverlayStyle();
  }

  Brightness get platformBrightness =>
      MediaQueryData.fromView(WidgetsBinding.instance.window).platformBrightness;

  void _setSystemUIOverlayStyle() {
    final isDarkMode = Provider.of<TimerProvider>(context).isDarkMode; // Get dark mode state
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDarkMode ? Colors.grey[850] : Colors.grey[50],
      systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    ));
  }

  void _toggleBarsVisibility() {
    setState(() {
      isBarsVisible = !isBarsVisible;
    });
  }

  void _onTextSelection(Offset globalPosition) {
    // Logic to determine selected text based on the gesture position
    setState(() {
      selectedText = 'Selected text based on gesture'; // Replace with actual selection logic
    });

    // Show the highlight menu when a text is selected
    if (selectedText.isNotEmpty) {
      _showHighlightMenu(selectedText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isBarsVisible
          ? AppBar(
        title: p1.EpubViewActualChapter(
          controller: widget.epubController,
          builder: (chapterValue) => Text(
            'Chapter: ' +
                (chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? ''),
          ),
        ),
      )
          : null,
      drawer: Drawer(
        child: p1.EpubViewTableOfContents(controller: widget.epubController),
      ),
      body: GestureDetector(
        onLongPressStart: (details) {
          selectedText = ''; // Reset selection
        },
        onLongPressMoveUpdate: (details) {
          // Update selection based on drag position
          _onTextSelection(details.globalPosition);
        },
        onLongPressEnd: (details) {
          // Finalize the selection
          if (selectedText.isNotEmpty) {
            // Optionally show some feedback here
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Highlighted: $selectedText')),
            );
          }
        },
        onTap: _toggleBarsVisibility,
        child: Stack(
          children: [
            p1.EpubView(
              controller: widget.epubController,
            ),
          ],
        ),
      ),
      floatingActionButton: isBarsVisible
          ? FloatingActionButton(
        onPressed: () => _showSettings(),
        child: Icon(Icons.settings),
        tooltip: 'Settings',
        backgroundColor: Colors.grey[200],
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showHighlightMenu(String selectedText) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Highlight Text',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: [
                  _colorOption(Colors.yellow, selectedText),
                  _colorOption(Colors.green, selectedText),
                  _colorOption(Colors.blue, selectedText),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _colorOption(Color color, String text) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        setState(() {
          selectedHighlightColor = color;
        });
        _highlightText(text, color);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  void _highlightText(String text, Color color) {
    print("Selected Text: $text, Color: $color");
    // Implement the logic to highlight the text in the EpubView here.
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Settings', style: TextStyle(fontSize: 20)),
                ListTile(
                  title: Text('Brightness'),
                  subtitle: ValueListenableBuilder<double>(
                    valueListenable: brightness,
                    builder: (context, value, child) {
                      return Slider(
                        value: value,
                        min: 0,
                        max: 1,
                        onChanged: (newValue) {
                          brightness.value = newValue;
                          _setSystemUIOverlayStyle();
                        },
                      );
                    },
                  ),
                ),
                Divider(),
                ExpansionTile(
                  title: Text('Themes'),
                  children: [
                    ListTile(
                      title: Text('Dark Mode'),
                      trailing: Switch(
                        value: Provider.of<TimerProvider>(context).isDarkMode, // Use provider for dark mode
                        onChanged: (value) {
                          // Toggle dark mode in TimerProvider
                          Provider.of<TimerProvider>(context, listen: false).toggleDarkMode();
                          _setSystemUIOverlayStyle(); // Update UI overlay style
                          setState(() {}); // Refresh UI
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Font Type'),
                      trailing: DropdownButton<String>(
                        value: selectedFontType,
                        items: fontTypes.map((String fontType) {
                          return DropdownMenuItem<String>(
                            value: fontType,
                            child: Text(fontType),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedFontType = newValue!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Font Size'),
                      subtitle: ValueListenableBuilder<double>(
                        valueListenable: fontSize,
                        builder: (context, value, child) {
                          return Slider(
                            value: value,
                            min: 12,
                            max: 30,
                            onChanged: (newValue) {
                              fontSize.value = newValue;
                            },
                          );
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Scroll Orientation'),
                      trailing: DropdownButton<bool>(
                        value: isVerticalScroll,
                        items: [
                          DropdownMenuItem<bool>(
                            value: true,
                            child: Text('Vertical'),
                          ),
                          DropdownMenuItem<bool>(
                            value: false,
                            child: Text('Horizontal'),
                          ),
                        ],
                        onChanged: (bool? value) {
                          setState(() {
                            isVerticalScroll = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
