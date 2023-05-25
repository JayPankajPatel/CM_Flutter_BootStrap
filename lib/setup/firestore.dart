import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addFavorite(String userId, WordPair favorite) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      await userRef.update({
        'favorites': FieldValue.arrayUnion([favorite.asPascalCase]),
      });
    } catch (e) {
      print('Error adding favorite to Firestore: $e');
    }
  }

  Future<void> removeFavorite(String userId, WordPair favorite) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      await userRef.update({
        'favorites': FieldValue.arrayRemove([favorite.asPascalCase]),
      });
    } catch (e) {
      print('Error removing favorite from Firestore: $e');
    }
  }

  Future<List<WordPair>> getFavorites(String userId) async {
    try {
      final userSnapshot =
          await _firestore.collection('users').doc(userId).get();
      if (userSnapshot.exists) {
        final userData = userSnapshot.data();
        final favorites = userData!['favorites'] as List<dynamic>? ?? [];
        final favoriteWordPairs =
            favorites.map((fav) => WordPair(fav.toString(), ""));
        return List<WordPair>.from(favoriteWordPairs);
      } else {
        return [];
      }
    } catch (e) {
      print('Error retrieving favorites from Firestore: $e');
      return [];
    }
  }
}
