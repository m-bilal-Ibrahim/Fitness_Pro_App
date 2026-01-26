import 'dart:async'; // Required for Timer
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';
import 'login_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          if (user.emailVerified) {
            return const DashboardScreen();
          } else {
            return const EmailVerificationScreen();
          }
        } else {
          return const LoginScreen();
        }
      },
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E))),
      ),
      error: (e, trace) => Scaffold(
        body: Center(child: Text("Error: $e")),
      ),
    );
  }
}

// --- WAITING SCREEN FOR EMAIL VERIFICATION ---
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  bool _isLoading = false;
  static const Color neonGreen = Color(0xFFD0FD3E);
  Timer? _timer;
  int _start = 0; // Cooldown timer in seconds

  void _startTimer() {
    setState(() => _start = 60); // 60 seconds cooldown
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() => timer.cancel());
      } else {
        setState(() => _start--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerification() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload(); // Force refresh from Firebase
      if (user?.emailVerified == true) {
        ref.invalidate(authStateProvider);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email not verified yet. Please check your inbox.")),
          );
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendEmail() async {
    if (_start > 0) return; // Prevent clicking if timer running

    try {
      await ref.read(authControllerProvider).sendVerification();
      _startTimer(); // Start cooldown
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification email sent! Check Spam folder too.")),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Verify Email", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: neonGreen),
        actions: [
          TextButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            child: const Text("Sign Out", style: TextStyle(color: Colors.redAccent)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_unread, size: 80, color: neonGreen),
            const SizedBox(height: 20),
            const Text("Check your Inbox", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              "We have sent a verification link to your email. You must verify it to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _checkVerification,
                style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("I HAVE VERIFIED", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _start > 0 ? null : _resendEmail,
              child: Text(
                _start > 0 ? "Resend in $_start s" : "Resend Email Link",
                style: TextStyle(color: _start > 0 ? Colors.grey : neonGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}