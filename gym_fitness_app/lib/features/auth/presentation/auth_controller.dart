import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart'; // REQUIRED IMPORT
import '../data/firebase_auth_repository.dart';
import '../domain/auth_repository.dart';
import '../data/user_repository.dart';
import '../domain/user_model.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final realtimeDbProvider = Provider<FirebaseDatabase>((ref) {
  return FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://lab11-4b757-default-rtdb.asia-southeast1.firebasedatabase.app',
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(ref.watch(firebaseAuthProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(realtimeDbProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (firebaseUser) {
      if (firebaseUser == null) return const Stream.empty();
      final userRepo = ref.read(userRepositoryProvider);
      return userRepo.getUserStream(firebaseUser.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

class AuthController {
  final AuthRepository _authRepository;
  final Ref _ref; // Added Ref to access DB provider

  AuthController(this._authRepository, this._ref);

  Future<User?> register({required String email, required String password}) async {
    return await _authRepository.registerWithEmailAndPassword(email, password);
  }

  Future<void> login(String email, String password) async {
    await _authRepository.signInWithEmailAndPassword(email, password);
  }

  Future<void> sendPasswordReset(String email) async {
    await _authRepository.sendPasswordResetEmail(email);
  }

  Future<void> sendVerification() async {
    await _authRepository.sendEmailVerification();
  }

  // --- NEW: GOOGLE LOGIN LOGIC ---
  Future<bool> signInWithGoogle() async {
    try {
      // 1. Trigger Google Sign In Flow
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return true; // User canceled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 2. Sign in to Firebase
      final UserCredential userCred =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCred.user;

      if (user != null) {
        // 3. CHECK DATABASE: Is this user actually registered in our app?
        // We check the 'users' node directly using the DB provider
        final snapshot = await _ref.read(realtimeDbProvider)
            .ref()
            .child('users')
            .child(user.uid)
            .get();

        if (!snapshot.exists) {
          // User authenticated with Google, but has NO record in our DB.
          // Sign them out immediately so AuthGate doesn't let them in.
          await FirebaseAuth.instance.signOut();
          await googleSignIn.signOut();
          return false; // Not registered
        }
        return true; // Registered and logged in
      }
      return true;
    } catch (e) {
      throw e;
    }
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  // UPDATED: Pass 'ref' here
  return AuthController(ref.watch(authRepositoryProvider), ref);
});