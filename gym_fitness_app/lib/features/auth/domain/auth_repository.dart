import 'package:firebase_auth/firebase_auth.dart';

// This abstract class is a "contract".
// It says: "Any Auth system in this app MUST have these methods."
abstract class AuthRepository {
  Stream<User?> get authStateChanges;

  Future<User?> signInWithEmailAndPassword(String email, String password);

  Future<User?> registerWithEmailAndPassword(String email, String password);

  Future<void> signOut();

  User? get currentUser;
}