import 'package:app_rawg/database/helper/firebase_review_helper.dart';
import 'package:app_rawg/database/helper/review_helper.dart';
import 'package:app_rawg/database/model/review_model.dart';
import 'package:app_rawg/view/auth_page.dart';

class ReviewRepository {
  static final ReviewHelper _local = ReviewHelper();
  static final FirestoreReviewHelper _remote = FirestoreReviewHelper();

  static dynamic get _provider => AuthPage.isGuest ? _local : _remote;

  Future<Review> saveReview(Review r) => _provider.saveReview(r);
  Future<Review?> getReview(dynamic id) => _provider.getReview(id);
  Future<Review?> getReviewByGameId(int id) => _provider.getReviewByGameId(id);
  Future<List<Review>> getAllReviews() => _provider.getAllReviews();
  Future<void> deleteReview(dynamic id) => _provider.deleteReview(id);
  Future<void> updateReview(Review r) => _provider.updateReview(r);
}
