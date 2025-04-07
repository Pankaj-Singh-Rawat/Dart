import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: (){
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
            ), 

          itemBuilder: (context, index){
            // builds each individual note card
            return NoteCard(noteText: "Note ${index + 1}",);
          }
          ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed:() async {
          final newNote = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NoteEditorPage(),
              ),
          );

          //if note is not empty , add it 

          if (newNote?.isNotEmpty == true){
            setState(() {
              notes.add(newNote!);
            });
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
  const NoteCard({super.key, required this.noteText});

  @override
  Widget build(BuildContext context) {
    return Container(
      // each note appears with a clean card with text in it
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(noteText),
    );
  }
} 

class NoteEditorPage extends StatefulWidget{
  const NoteEditorPage({super.key});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage>{
  String noteText = "";

  @override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      Navigator.pop(context, noteText.trim());
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
