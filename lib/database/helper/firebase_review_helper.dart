import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_rawg/database/model/review_model.dart';

class FirestoreReviewHelper {
  static final FirestoreReviewHelper _instance =
      FirestoreReviewHelper.internal();
  factory FirestoreReviewHelper() => _instance;
  FirestoreReviewHelper.internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception(
        "FirestoreReviewHelper só pode ser usado quando o usuário está logado.",
      );
    }
    return _firestore.collection("users").doc(user.uid).collection("reviews");
  }

  Future<Review> saveReview(Review review) async {
    final docRef = await _collection.add(review.toMap());
    await docRef.update({"id": docRef.id});
    review.id = docRef.id;
    return review;
  }

  Future<Review?> getReview(String id) async {
    final doc = await _collection.doc(id).get();

    if (!doc.exists) return null;

    return Review.fromMap(doc.data()!..["id"] = doc.id);
  }

  Future<Review?> getReviewByGameId(int gameId) async {
    final query = await _collection
        .where("gameId", isEqualTo: gameId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final doc = query.docs.first;
    return Review.fromMap(doc.data()..["id"] = doc.id);
  }

  Future<List<Review>> getAllReviews() async {
    final query = await _collection.get();

    return query.docs
        .map((d) => Review.fromMap(d.data()..["id"] = d.id))
        .toList();
  }

  Future<void> deleteReview(String id) async {
    await _collection.doc(id).delete();
  }

  Future<void> updateReview(Review review) async {
    if (review.id == null) {
      throw Exception(
        "Review sem idString não pode ser atualizada no Firestore.",
      );
    }

    await _collection.doc(review.id).update(review.toMap());
  }
}
