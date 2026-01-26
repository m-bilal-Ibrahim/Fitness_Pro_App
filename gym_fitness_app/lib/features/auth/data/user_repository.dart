import 'package:firebase_database/firebase_database.dart';
import '../domain/user_model.dart';

class UserRepository {
  final FirebaseDatabase _realtimeDb;

  UserRepository(this._realtimeDb);

  // 1. Save User Data
  Future<void> saveUserData(UserModel user) async {
    try {
      await _realtimeDb.ref("users/${user.uid}").set(user.toMap());
    } catch (e) {
      throw Exception("Failed to save user data: $e");
    }
  }

  // 2. Stream User Data (Primary Method)
  Stream<UserModel?> getUserStream(String uid) {
    return _realtimeDb.ref("users/$uid").onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        try {
          // Safe Casting: Dynamic Map -> String Key Map
          final rawData = event.snapshot.value as Map<dynamic, dynamic>;
          final safeMap = rawData.map((key, value) => MapEntry(key.toString(), value));
          return UserModel.fromMap(safeMap);
        } catch (e) {
          // If data is corrupt, return null so we can handle it in UI
          return null;
        }
      }
      return null;
    });
  }

  // 3. Get Single (Utility Method - kept for safety)
  Future<UserModel?> getUserData(String uid) async {
    try {
      final snapshot = await _realtimeDb.ref("users/$uid").get();
      if (snapshot.exists && snapshot.value != null) {
        final rawData = snapshot.value as Map<dynamic, dynamic>;
        final safeMap = rawData.map((key, value) => MapEntry(key.toString(), value));
        return UserModel.fromMap(safeMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}