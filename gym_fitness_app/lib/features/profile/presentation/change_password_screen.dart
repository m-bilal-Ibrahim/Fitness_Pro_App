import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, String? email});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  static const Color neonGreen = Color(0xFFD0FD3E);

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) throw Exception("User not logged in");

      // Use the ACTUAL logged-in email for re-auth
      final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPassCtrl.text
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newPassCtrl.text);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Password Changed Successfully!", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black87,
        ));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String msg = e.message ?? "Update failed";
        if (e.code == 'wrong-password') msg = "Incorrect Current Password.";
        if (e.code == 'requires-recent-login') msg = "Session expired. Log out and back in.";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade900,
        ));
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
      appBar: AppBar(
        title: const Text("EDIT MY PASSWORD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: neonGreen),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPassInput("Current Password", _currentPassCtrl),
              const SizedBox(height: 20),
              _buildPassInput("New Password", _newPassCtrl, isNew: true),
              const SizedBox(height: 20),
              _buildPassInput("Confirm New Password", _confirmPassCtrl, isConfirm: true),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text("UPDATE PASSWORD", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassInput(String label, TextEditingController ctrl, {bool isNew = false, bool isConfirm = false}) {
    return TextFormField(
      controller: ctrl,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.grey.shade900,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: neonGreen)),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return "Required";
        if (isNew) {
          String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
          if (!RegExp(pattern).hasMatch(v)) return "Must be 8+ chars (Upper, Lower, Digit, Special)";
        }
        if (isConfirm && v != _newPassCtrl.text) return "Passwords do not match";
        return null;
      },
    );
  }
}