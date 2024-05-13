import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../db/notes_database.dart';
import '../model/note.dart';
import '../page/edit_note_page.dart';
import '../page/note_detail_page.dart';
import '../widget/note_card_widget.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key})
      : super(key: key); // Constructor for NotesPage widget

  @override
  State<NotesPage> createState() =>
      _NotesPageState(); // Creating state for NotesPage
}

class _NotesPageState extends State<NotesPage> {
  late List<Note> notes; // List to hold notes
  bool isLoading = false; // Loading state

  @override
  void initState() {
    super.initState();
    refreshNotes(); // Initialize and load notes when the widget is created
  }

  @override
  void dispose() {
    NotesDatabase.instance
        .close(); // Close the database connection when the widget is disposed
    super.dispose();
  }

  // Function to refresh the list of notes asynchronously
  Future refreshNotes() async {
    setState(() => isLoading = true); // Set loading state to true

    notes = await NotesDatabase.instance
        .readAllNotes(); // Read all notes from the database

    setState(() => isLoading = false); // Set loading state to false when done
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Notes', // Title of the app bar
            style: TextStyle(
                fontSize: 24, color: Color.fromARGB(255, 255, 255, 255)),
            // Style for the title text
          ),
          actions: const [
            Icon(Icons.search),
            SizedBox(width: 12)
          ], // Actions in the app bar
        ),
        backgroundColor: const Color.fromARGB(
            255, 0, 0, 0), // Background color of the scaffold
        body: Center(
          child: isLoading // Display loading indicator if isLoading is true
              ? const CircularProgressIndicator()
              : notes.isEmpty // Display 'No Notes' message if notes list is empty
                  ? const Text(
                      'No Notes', // Text to display when there are no notes
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24), // Style for the text
                    )
                  : buildNotes(), // Build notes if there are notes available
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor:
              Colors.white, // Background color of the floating action button
          child: const Icon(Icons.add), // Icon for the floating action button
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) =>
                      const AddEditNotePage()), // Navigate to AddEditNotePage when the button is pressed
            );

            refreshNotes(); // Refresh notes after navigating back from AddEditNotePage
          },
        ),
      );

  // Function to build the grid of notes
  Widget buildNotes() => StaggeredGrid.count(
        crossAxisCount: 2, // Number of columns in the grid
        mainAxisSpacing: 2, // Spacing between the rows
        crossAxisSpacing: 2, // Spacing between the columns
        children: List.generate(
          notes.length,
          (index) {
            final note = notes[index]; // Get the note at the current index

            return StaggeredGridTile.fit(
              crossAxisCellCount: 1,
              child: GestureDetector(
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => NoteDetailPage(
                        noteId: note
                            .id!), // Navigate to NoteDetailPage when a note is tapped
                  ));

                  refreshNotes(); // Refresh notes after navigating back from NoteDetailPage
                },
                child: NoteCardWidget(
                    note: note,
                    index:
                        index), // Display NoteCardWidget for the current note
              ),
            );
          },
        ),
      );
}
