import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'flashcard_quiz.db');
    return openDatabase(
      path,
      version: 3,
      onConfigure: (Database db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE topics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        topic TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE qna (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        topic_id INTEGER NOT NULL,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS qna');
      await db.execute('DROP TABLE IF EXISTS topics');
      await _onCreate(db, newVersion);
    }
  }

  Future<int> insertTopic(String name) async {
    final Database db = await database;
    return db.insert(
      'topics',
      <String, Object?>{'topic': name.trim()},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> insertQnA({
    required int topicId,
    required String question,
    required String answer,
  }) async {
    final Database db = await database;
    return db.insert('qna', <String, Object?>{
      'topic_id': topicId,
      'question': question.trim(),
      'answer': answer.trim(),
    });
  }

  Future<List<Map<String, Object?>>> getTopics() async {
    final Database db = await database;
    return db.query('topics', orderBy: 'id DESC');
  }

  Future<List<Map<String, Object?>>> getQnAForTopic(int topicId) async {
    final Database db = await database;
    return db.query(
      'qna',
      where: 'topic_id = ?',
      whereArgs: <Object>[topicId],
      orderBy: 'id DESC',
    );
  }

  Future<int> deleteTopic(int topicId) async {
    final Database db = await database;
    return db.delete(
      'topics',
      where: 'id = ?',
      whereArgs: <Object>[topicId],
    );
  }

  Future<int> deleteTopicData(int qnaId) async {
    final Database db = await database;
    return db.delete(
      'qna',
      where: 'id = ?',
      whereArgs: <Object>[qnaId],
    );
  }
}
