import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_controller.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  static const Color neonGreen = Color(0xFFD0FD3E);

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authControllerProvider)
          .login(_emailController.text.trim(), _passwordController.text.trim());
      // AuthGate handles navigation automatically
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- GOOGLE HANDLER ---
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final isRegistered = await ref.read(authControllerProvider).signInWithGoogle();

      if (!isRegistered) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Google account not registered. Please Sign Up first.", style: TextStyle(fontSize: 12)),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SignUpScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google Sign In Failed: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // 1. Prevents scrolling/resizing when keyboard opens
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              // 2. Distribute content evenly on the single page
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- HEADER ---
                const Column(
                  children: [
                    Icon(Icons.fitness_center, size: 50, color: neonGreen), // Reduced Size
                    SizedBox(height: 10),
                    Text(
                      "Fitness Pro",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22, // Reduced Font Size
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),

                // --- INPUTS ---
                Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white, fontSize: 11), // Small Text
                      decoration: _inputDec("Email", Icons.email),
                      validator: (v) => (v == null || !v.contains('@')) ? 'Invalid email' : null,
                    ),
                    const SizedBox(height: 10), // Reduced Spacing
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.white, fontSize: 11), // Small Text
                      decoration: _inputDec("Password", Icons.lock),
                      obscureText: true,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          );
                        },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 10), // Smaller Link
                        ),
                      ),
                    ),
                  ],
                ),

                // --- ACTIONS ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neonGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12), // Compact Button
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Text("LOGIN", style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? ", style: TextStyle(color: Colors.white70, fontSize: 11)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                          child: const Text("Sign Up", style: TextStyle(color: neonGreen, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                  ],
                ),

                // --- FOOTER / SOCIAL ---
                Column(
                  children: [
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white24)),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("OR", style: TextStyle(color: Colors.white54, fontSize: 10))),
                        Expanded(child: Divider(color: Colors.white24)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleLogin,
                      icon: Image.network(
                        'https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png',
                        height: 18, // Smaller Icon
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.public, color: Colors.white, size: 18),
                      ),
                      label: const Text("Login with Google", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40), // Compact Button
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 11), // Small Label
      prefixIcon: Icon(icon, color: neonGreen, size: 16), // Small Icon
      filled: true,
      fillColor: Colors.grey.shade900,
      isDense: true, // Compact Height
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Tight Padding
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );
  }
}

// ---------------------------------------------------------
// FORGOT PASSWORD SCREEN (COMPACT)
// ---------------------------------------------------------
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  static const Color neonGreen = Color(0xFFD0FD3E);

  Future<void> _handleReset() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid email")));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: Colors.grey.shade900,
              // Compact Dialog Styling
              insetPadding: const EdgeInsets.symmetric(horizontal: 60),
              title: const Text("Email Sent", style: TextStyle(color: neonGreen, fontSize: 14)),
              content: const Text(
                "A password reset link has been sent to your email.",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: const Text("OK", style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email not registered.")));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false, // 1. Fixed Page
      appBar: AppBar(
        title: const Text("RESET PASSWORD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: neonGreen, size: 18),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // 2. Aligned Top
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Enter your email address to verify and reset your password.",
              style: TextStyle(color: Colors.white70, fontSize: 12), // Small Text
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 11), // Small Input
              decoration: InputDecoration(
                labelText: "Email Address",
                labelStyle: const TextStyle(color: Colors.white54, fontSize: 11),
                prefixIcon: const Icon(Icons.email, color: neonGreen, size: 16),
                filled: true,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: neonGreen)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: neonGreen,
                padding: const EdgeInsets.symmetric(vertical: 12), // Compact Button
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : const Text("SEND RESET LINK", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}