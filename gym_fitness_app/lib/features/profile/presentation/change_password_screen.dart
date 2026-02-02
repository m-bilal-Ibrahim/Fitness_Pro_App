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
          content: Text("Password Changed Successfully!", style: TextStyle(color: Colors.white, fontSize: 12)),
          backgroundColor: Colors.black87,
        ));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String msg = e.message ?? "Update failed";
        if (e.code == 'wrong-password') msg = "Incorrect Current Password.";
        if (e.code == 'requires-recent-login') msg = "Session expired. Log out and back in.";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 12)),
          backgroundColor: Colors.red.shade900,
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e", style: const TextStyle(fontSize: 12))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Prevents resizing/overflow when keyboard opens
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("EDIT MY PASSWORD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: neonGreen, size: 18),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      // Removed SingleChildScrollView
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Aligns content to the top
            children: [
              const SizedBox(height: 20), // Spacing from AppBar
              _buildPassInput("Current Password", _currentPassCtrl),
              const SizedBox(height: 12), // Reduced spacing
              _buildPassInput("New Password", _newPassCtrl, isNew: true),
              const SizedBox(height: 12), // Reduced spacing
              _buildPassInput("Confirm New Password", _confirmPassCtrl, isConfirm: true),
              const SizedBox(height: 24), // Reduced spacing
              SizedBox(
                width: double.infinity,
                height: 32, // Smaller button height
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
                  child: _isLoading
                      ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Text("UPDATE PASSWORD", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
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
      style: const TextStyle(color: Colors.white, fontSize: 11), // Smaller input text
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 11), // Smaller label
        filled: true,
        fillColor: Colors.grey.shade900,
        isDense: true, // Reduces vertical height
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Tighter padding
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: neonGreen)),
        errorStyle: const TextStyle(fontSize: 9), // Smaller error text
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