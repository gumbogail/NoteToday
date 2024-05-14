import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../db/notes_database.dart';
import '../model/note.dart';
import '../page/edit_note_page.dart';
import '../page/note_detail_page.dart';
import '../widget/note_card_widget.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late List<Note> notes;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  @override
  void dispose() {
    NotesDatabase.instance.close();
    super.dispose();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);
    notes = await NotesDatabase.instance.readAllNotes();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Notes',
            style: TextStyle(
                fontSize: 24, color: Color.fromARGB(255, 255, 255, 255)),
          ),
          actions: const [Icon(Icons.search), SizedBox(width: 12)],
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        body: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : notes.isEmpty
                  ? const Text(
                      'No Notes',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    )
                  : buildNotes(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          child: const Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddEditNotePage()),
            );
            refreshNotes();
          },
        ),
      );

  Widget buildNotes() => ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Color.fromARGB(255, 255, 164,
                  229), // Example color, you can change it to any color you like
              elevation: 2, // Add elevation for a better visual effect
              child: ListTile(
                title: Text(
                  note.title,
                  style: TextStyle(
                      color: const Color.fromARGB(
                          255, 0, 0, 0)), // Change text color to white
                ),
                subtitle: Text(
                  note.description,
                  style: TextStyle(
                      color: Colors.black), // Change text color to white
                ),
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => NoteDetailPage(noteId: note.id!),
                  ));
                  refreshNotes();
                },
              ),
            ),
          );
        },
      );
}
