import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/notes_database.dart'; // Importing the notes database
import '../model/note.dart'; // Importing the note model
import '../page/edit_note_page.dart'; // Importing the edit note page

class NoteDetailPage extends StatefulWidget {
  final int noteId;

  const NoteDetailPage({
    Key? key,
    required this.noteId,
  }) : super(key: key);

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late Note note;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshNote(); // Refresh note when the widget is created
  }

  // Function to refresh the note asynchronously
  Future refreshNote() async {
    setState(() => isLoading = true); // Set loading state to true

    note = await NotesDatabase.instance
        .readNote(widget.noteId); // Read the note from the database

    setState(() => isLoading = false); // Set loading state to false when done
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor:
              Colors.black, // Setting app bar background color to black
          actions: [editButton(), deleteButton()], // Actions in the app bar
        ),
        backgroundColor: Colors.black, // Setting background color to black
        body: isLoading
            ? Center(
                child:
                    CircularProgressIndicator()) // Show loading indicator if isLoading is true
            : Padding(
                padding: const EdgeInsets.all(12),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Text(
                      note.title,
                      style: const TextStyle(
                        color: Colors.white, // Setting text color to white
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat.yMMMd().format(note.createdTime),
                      style: const TextStyle(
                          color: Color.fromARGB(255, 252, 251,
                              251)), // Setting text color to white with reduced opacity
                    ),
                    const SizedBox(height: 8),
                    Text(
                      note.description,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18), // Setting text color to white
                    )
                  ],
                ),
              ),
      );

  // Function to build the edit button
  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined,
          color: Colors.white), // Setting icon color to white
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditNotePage(
              note:
                  note), // Navigate to AddEditNotePage when the button is pressed
        ));

        refreshNote(); // Refresh note after navigating back from AddEditNotePage
      });

  // Function to build the delete button
  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete,
            color: Colors.white), // Setting icon color to white
        onPressed: () async {
          await NotesDatabase.instance
              .delete(widget.noteId); // Delete the note from the database

          Navigator.of(context).pop(); // Close the page after deleting
        },
      );
}
