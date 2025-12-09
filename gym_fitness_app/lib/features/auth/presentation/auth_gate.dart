import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';
import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This watches the stream we created in auth_controller.dart
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          // USER IS LOGGED IN -> Show Dashboard
          // (For now, a placeholder Dashboard)
          return Scaffold(
            appBar: AppBar(
              title: const Text("Dashboard"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => ref.read(authRepositoryProvider).signOut(),
                ),
              ],
            ),
            body: const Center(child: Text("Welcome to your Fitness Dashboard!")),
          );
        } else {
          // USER IS LOGGED OUT -> Show Login Screen
          return const LoginScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, trace) => Scaffold(
        body: Center(child: Text("Error: $e")),
      ),
    );
  }
}