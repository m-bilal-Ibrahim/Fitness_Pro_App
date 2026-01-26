import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/data/user_repository.dart';
import '../../auth/domain/user_model.dart';
import '../../auth/domain/auth_repository.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  bool _isSaving = false;

  Future<void> _setRole(String role) async {
    setState(() => _isSaving = true);

    final currentUser = ref.read(firebaseAuthProvider).currentUser;

    if (currentUser != null) {
      try {
        final newUser = UserModel(
          uid: currentUser.uid,
          email: currentUser.email ?? '',
          role: role,
          createdAt: DateTime.now(),
        );

        await ref.read(userRepositoryProvider).saveUserData(newUser);
        // Force refresh of profile provider to trigger navigation
        ref.invalidate(currentUserProfileProvider);

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }

    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 20),
              const Text(
                "Welcome!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "To get started, please select your role.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),

              if (_isSaving)
                const CircularProgressIndicator()
              else ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    onPressed: () => _setRole('owner'),
                    icon: const Icon(Icons.business, color: Colors.white),
                    label: const Text("I am a Gym Owner", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => _setRole('member'),
                    icon: const Icon(Icons.person),
                    label: const Text("I am a Member"),
                  ),
                ),
              ],

              const SizedBox(height: 40),
              TextButton(
                onPressed: () => ref.read(authRepositoryProvider).signOut(),
                child: const Text("Log Out"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}