import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for InputFormatters
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/user_model.dart';
import '../../auth/data/user_repository.dart';
import '../../auth/presentation/auth_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  static const Color neonGreen = Color(0xFFD0FD3E);

  late TextEditingController _nameCtrl;
  // Removed _emailCtrl since we don't edit it anymore
  late TextEditingController _ageCtrl;
  late TextEditingController _contactCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _postalCtrl;
  late TextEditingController _picCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.fullName);
    _ageCtrl = TextEditingController(text: widget.user.age);
    _contactCtrl = TextEditingController(text: widget.user.contact);
    _addressCtrl = TextEditingController(text: widget.user.address);
    _stateCtrl = TextEditingController(text: widget.user.state);
    _cityCtrl = TextEditingController(text: widget.user.city);
    _countryCtrl = TextEditingController(text: widget.user.country);
    _postalCtrl = TextEditingController(text: widget.user.postalCode);
    _picCtrl = TextEditingController(text: widget.user.profilePic);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // 1. Update Realtime Database ONLY (No Auth/Email changes)
      final updatedUser = UserModel(
        uid: widget.user.uid,
        email: widget.user.email, // Keep existing email
        role: widget.user.role,
        createdAt: widget.user.createdAt,
        fullName: _nameCtrl.text.trim(),
        age: _ageCtrl.text.trim(),
        contact: _contactCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
        postalCode: _postalCtrl.text.trim(),
        profilePic: _picCtrl.text.trim(),
      );

      await ref.read(userRepositoryProvider).saveUserData(updatedUser);
      ref.invalidate(currentUserProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Profile Updated Successfully!", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black87,
        ));
        Navigator.pop(context);
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
        title: const Text("EDIT PERSONAL INFO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: neonGreen),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. Name: Letters Only
              _buildInput("Full Name", _nameCtrl, required: true,
                  regex: RegExp(r"^[a-zA-Z\s]+$"), errorMsg: "Only letters allowed"),

              // Email Field (Read-Only)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  initialValue: widget.user.email,
                  readOnly: true, // Prevent editing
                  style: const TextStyle(color: Colors.white54), // Dimmed text
                  decoration: InputDecoration(
                    labelText: "Email Address (Cannot change)",
                    labelStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
              ),

              _buildInput("Profile Pic URL", _picCtrl),

              Row(children: [
                // 2. Age: Numbers only, 12-100
                Expanded(child: _buildInput("Age", _ageCtrl, required: true, number: true,
                    validator: (v) {
                      int? age = int.tryParse(v ?? "");
                      if (age == null || age < 12 || age > 100) return "12-100 only";
                      return null;
                    }
                )),
                const SizedBox(width: 10),
                // 3. Contact: Basic length check
                Expanded(child: _buildInput("Contact", _contactCtrl, required: true, minLength: 10)),
              ]),

              const Divider(color: Colors.white24, height: 40),

              // 4. Address: Min length
              _buildInput("Street Address", _addressCtrl, required: true, minLength: 5),

              Row(children: [
                // 5. City: Letters Only
                Expanded(child: _buildInput("City", _cityCtrl, required: true, regex: RegExp(r"^[a-zA-Z\s]+$"))),
                const SizedBox(width: 10),
                // 6. State: Letters Only
                Expanded(child: _buildInput("State", _stateCtrl, required: true, regex: RegExp(r"^[a-zA-Z\s]+$"))),
              ]),

              Row(children: [
                // 7. Country: Letters Only
                Expanded(child: _buildInput("Country", _countryCtrl, required: true, regex: RegExp(r"^[a-zA-Z\s]+$"))),
                const SizedBox(width: 10),
                // 8. Postal Code: Numbers Only
                Expanded(child: _buildInput("Postal Code", _postalCtrl, number: true)),
              ]),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text("SAVE CHANGES", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- UPDATED INPUT WIDGET WITH RESTRICTIONS ---
  Widget _buildInput(String label, TextEditingController ctrl, {
    bool required = false,
    bool number = false,
    int minLength = 0,
    RegExp? regex,
    String? errorMsg,
    String? Function(String?)? validator, // Allow custom validator override
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white),
        keyboardType: number ? TextInputType.number : TextInputType.text,
        // Allow digits only if 'number' is true
        inputFormatters: number
            ? [FilteringTextInputFormatter.digitsOnly]
            : [],
        validator: validator ?? (v) {
          if (required && (v == null || v.trim().isEmpty)) return "Required";
          if (minLength > 0 && v!.length < minLength) return "Min $minLength chars";

          if (regex != null && !regex.hasMatch(v!)) {
            return errorMsg ?? "Invalid format (Letters only)";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.grey.shade900,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: neonGreen)),
        ),
      ),
    );
  }
}