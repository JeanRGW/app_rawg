import 'package:app_rawg/database/model/review_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ReviewHelper {
  static final ReviewHelper _instance = ReviewHelper.internal();
  factory ReviewHelper() => _instance;
  ReviewHelper.internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "reviewsDB.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int newVersion) async {
        await db.execute("""
          CREATE TABLE $gameReviewTable (
            $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
            $gameIdColumn INTEGER,
            $platformColumn INTEGER,
            $progressStatusColumn INTEGER,
            $hoursPlayedColumn REAL,
            $recommendedColumn INTEGER,
            $scoreVisualColumn INTEGER,
            $scoreGameplayColumn INTEGER,
            $scoreNarrativeColumn INTEGER,
            $commentColumn TEXT
          )
        """);
      },
    );
  }

  Future<Review> saveReview(Review review) async {
    final dbReview = await db;
    review.id = (await dbReview.insert(
      gameReviewTable,
      review.toMap(),
    )).toString();
    return review;
  }

  Future<Review?> getReview(int id) async {
    final dbReview = await db;

    final maps = await dbReview.query(
      gameReviewTable,
      where: "$idColumn = ?",
      whereArgs: [id],
    );

    return maps.isNotEmpty ? Review.fromMap(maps.first) : null;
  }

  Future<Review?> getReviewByGameId(int gameId) async {
    final dbReview = await db;

    final maps = await dbReview.query(
      gameReviewTable,
      where: "$gameIdColumn = ?",
      whereArgs: [gameId],
    );

    return maps.isNotEmpty ? Review.fromMap(maps.first) : null;
  }

  Future<List<Review>> getAllReviews() async {
    final dbReview = await db;

    final maps = await dbReview.query(gameReviewTable);
    return maps.map((m) => Review.fromMap(m)).toList();
  }

  Future<int> deleteReview(String id) async {
    final dbReview = await db;

    return await dbReview.delete(
      gameReviewTable,
      where: "$idColumn = ?",
      whereArgs: [id],
    );
  }

  Future<int> updateReview(Review review) async {
    final dbReview = await db;

    return await dbReview.update(
      gameReviewTable,
      review.toMap(),
      where: "$idColumn = ?",
      whereArgs: [review.id],
    );
  }
}
