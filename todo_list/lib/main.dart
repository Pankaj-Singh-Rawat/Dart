import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(title: 'Todo Lists'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> notes = [];

  void loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNotes = prefs.getStringList('notes') ?? [];

    setState(() {
      notes = savedNotes;
    });
  }

  void saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('notes', notes);
  }

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // open menu drawer
          },
          tooltip: "Menu",
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),

      //Main App Body that will show Notes will come up Here

      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
            itemCount: notes.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //defines how many cards(to write notes) will come in a row
              crossAxisCount: 2, // for this app -> 2
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2,
            ),
            itemBuilder: (context, index) {
              // builds each individual note card
              return Dismissible(
                  // Dismissible ? : Give the slide behavior

                  key: ValueKey(
                      notes[index]), // passing a unique key to each item
                  direction: DismissDirection
                      .horizontal, //swiping both left or right works fine

                  onDismissed: (Direction) {
                    setState(() {
                      notes.removeAt(index); // deletes the note
                    });
                    saveNotes();
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: GestureDetector(
                      onTap: () async {
                        final updatedNote = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NoteEditorPage(
                                      initialText: notes[index],
                                    )));

                        if (updatedNote?.isNotEmpty == true) {
                          setState(() {
                            notes[index] = updatedNote!;
                          });
                          saveNotes();
                        }
                      },
                      child: NoteCard(
                        noteText: notes[index],
                      )));
            }),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newNote = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NoteEditorPage(),
            ),
          );

          //if note is not empty , add it

          if (newNote?.isNotEmpty == true) {
            setState(() {
              notes.add(newNote!);
            });
            saveNotes();
          }
        },
        tooltip: "New Note",
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final String noteText;
  final VoidCallback? onTap;

  const NoteCard({super.key, required this.noteText, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      //fills the entire grid tile
      child: GestureDetector(
        onTap:
            onTap, //ontap is used from constuctor added above as a final variable
        child: Container(
          // each note appears with a clean card with text in it
          height: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.deepPurple[100],
            borderRadius: BorderRadius.circular(12),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  noteText,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NoteEditorPage extends StatefulWidget {
  final String? initialText;
  const NoteEditorPage({
    super.key,
    this.initialText, // this allows us to pass in existing text when Editing notes
  });

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _controller;
  String noteText = "";

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? "");
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _controller.text.trim());
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("New Note"),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _controller,
            autofocus: true,
            maxLines: null,
            onChanged: (value) {
              setState(() {
                noteText = value;
              });
            },
            decoration: const InputDecoration(
              hintText: "New note here...",
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
