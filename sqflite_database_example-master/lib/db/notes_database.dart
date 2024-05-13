import 'package:path/path.dart'; // Importing path package for joining file paths
import 'package:sqflite/sqflite.dart'; // Importing sqflite package for SQLite database
import '../model/note.dart'; // Importing the note model

class NotesDatabase {
  static final NotesDatabase instance =
      NotesDatabase._init(); // Singleton instance of NotesDatabase

  static Database? _database; // Database instance

  NotesDatabase._init(); // Private constructor for initialization

  // Getter for the database instance
  Future<Database> get database async {
    if (_database != null)
      return _database!; // Return existing database instance if available

    // If database instance is not available, initialize it
    _database = await _initDB('notes.db');
    return _database!;
  }

  // Method to initialize the database
  Future<Database> _initDB(String filePath) async {
    final dbPath =
        await getDatabasesPath(); // Get path to the databases directory
    final path =
        join(dbPath, filePath); // Join database directory path with file name

    // Open or create the database with specified version and onCreate callback
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Method to create the database tables
  Future _createDB(Database db, int version) async {
    const idType =
        'INTEGER PRIMARY KEY AUTOINCREMENT'; // Data type for primary key
    const textType = 'TEXT NOT NULL'; // Data type for text fields
    const boolType = 'BOOLEAN NOT NULL'; // Data type for boolean fields
    const integerType = 'INTEGER NOT NULL'; // Data type for integer fields

    // SQL query to create notes table with defined fields
    await db.execute('''
CREATE TABLE $tableNotes ( 
  ${NoteFields.id} $idType, 
  ${NoteFields.isImportant} $boolType,
  ${NoteFields.number} $integerType,
  ${NoteFields.title} $textType,
  ${NoteFields.description} $textType,
  ${NoteFields.time} $textType
  )
''');
  }

  // Method to add a new note to the database
  Future<Note> create(Note note) async {
    final db = await instance.database;

    // Insert the note into the notes table and return the inserted note with updated ID
    final id = await db.insert(tableNotes, note.toJson());
    return note.copy(id: id);
  }

  // Method to read a note from the database based on its ID
  Future<Note> readNote(int id) async {
    final db = await instance.database;

    // Query the notes table for the specified ID
    final maps = await db.query(
      tableNotes,
      columns: NoteFields.values,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );

    // If the note with the specified ID exists, return it; otherwise, throw an exception
    if (maps.isNotEmpty) {
      return Note.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  // Method to read all notes from the database
  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;

    final orderBy =
        '${NoteFields.time} ASC'; // Order notes by creation time in ascending order

    // Query all notes from the notes table and return them as a list of Note objects
    final result = await db.query(tableNotes, orderBy: orderBy);
    return result.map((json) => Note.fromJson(json)).toList();
  }

  // Method to update an existing note in the database
  Future<int> update(Note note) async {
    final db = await instance.database;

    // Update the note in the notes table and return the number of affected rows
    return db.update(
      tableNotes,
      note.toJson(),
      where: '${NoteFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  // Method to delete a note from the database based on its ID
  Future<int> delete(int id) async {
    final db = await instance.database;

    // Delete the note from the notes table and return the number of affected rows
    return await db.delete(
      tableNotes,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );
  }

  // Method to close the database connection
  Future close() async {
    final db = await instance.database;

    db.close(); // Close the database connection
  }
}
