import 'package:flutter/material.dart';
import '../db/notes_database.dart'; // Importing the notes database
import '../model/note.dart'; // Importing the note model
import '../widget/note_form_widget.dart'; // Importing the note form widget

class AddEditNotePage extends StatefulWidget {
  final Note? note; // Optional note parameter for editing

  const AddEditNotePage({
    Key? key,
    this.note,
  }) : super(key: key); // Constructor for AddEditNotePage widget

  @override
  State<AddEditNotePage> createState() =>
      _AddEditNotePageState(); // Creating state for AddEditNotePage
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>(); // Key for the form
  late bool isImportant; // Importance flag for the note
  late int number; // Number associated with the note
  late String title; // Title of the note
  late String description; // Description of the note

  @override
  void initState() {
    super.initState();

    // Initialize state variables with note values or defaults
    isImportant = widget.note?.isImportant ?? false;
    number = widget.note?.number ?? 0;
    title = widget.note?.title ?? '';
    description = widget.note?.description ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(
              109, 0, 0, 0), // Setting app bar background color to white
          actions: [buildButton()], // Actions in the app bar
        ),
        backgroundColor:
            Color.fromARGB(109, 0, 0, 0), // Setting background color to white
        body: Form(
          key: _formKey, // Key for the form
          child: NoteFormWidget(
            // Widget for note form
            isImportant: isImportant,
            number: number,
            title: title,
            description: description,
            onChangedImportant: (isImportant) =>
                setState(() => this.isImportant = isImportant),
            onChangedNumber: (number) => setState(() => this.number = number),
            onChangedTitle: (title) => setState(() => this.title = title),
            onChangedDescription: (description) =>
                setState(() => this.description = description),
          ),
        ),
      );

  // Function to build the save button
  Widget buildButton() {
    final isFormValid = title.isNotEmpty &&
        description.isNotEmpty; // Check if the form is valid

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black, // Setting text color to black
          backgroundColor: isFormValid
              ? Colors.blue
              : Colors
                  .grey.shade300, // Setting button color based on form validity
        ),
        onPressed: addOrUpdateNote, // Action when the button is pressed
        child: const Text('Save'), // Button text
      ),
    );
  }

  // Function to add or update the note
  void addOrUpdateNote() async {
    final isValid =
        _formKey.currentState!.validate(); // Check if the form is valid

    if (isValid) {
      final isUpdating =
          widget.note != null; // Check if the note is being updated

      if (isUpdating) {
        await updateNote(); // Update the note
      } else {
        await addNote(); // Add a new note
      }

      Navigator.of(context).pop(); // Close the page after saving
    }
  }

  // Function to update the note
  Future updateNote() async {
    final note = widget.note!.copy(
      isImportant: isImportant,
      number: number,
      title: title,
      description: description,
    );

    await NotesDatabase.instance
        .update(note); // Update the note in the database
  }

  // Function to add a new note
  Future addNote() async {
    final note = Note(
      title: title,
      isImportant: true,
      number: number,
      description: description,
      createdTime: DateTime.now(),
    );

    await NotesDatabase.instance.create(note); // Add the note to the database
  }
}
