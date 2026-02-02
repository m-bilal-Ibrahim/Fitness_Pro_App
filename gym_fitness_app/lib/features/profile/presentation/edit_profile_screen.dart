import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      final updatedUser = UserModel(
        uid: widget.user.uid,
        email: widget.user.email,
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
      // Prevents the layout from scrolling/resizing when keyboard opens
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("EDIT PERSONAL INFO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: neonGreen, size: 18),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      // Removed SingleChildScrollView
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
        child: Form(
          key: _formKey,
          child: Column(
            // Distribute space evenly to fit the single page
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInput("Full Name", _nameCtrl, required: true,
                  regex: RegExp(r"^[a-zA-Z\s]+$"), errorMsg: "Only letters allowed"),

              // Email Field (Read-Only) - Made Compact
              Padding(
                padding: const EdgeInsets.only(bottom: 8), // Reduced bottom padding
                child: TextFormField(
                  initialValue: widget.user.email,
                  readOnly: true,
                  style: const TextStyle(color: Colors.white54, fontSize: 11), // Smaller text
                  decoration: InputDecoration(
                    labelText: "Email (Read-only)",
                    labelStyle: const TextStyle(color: Colors.white38, fontSize: 11), // Smaller label
                    filled: true,
                    isDense: true, // Compacts the field
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Tighter padding
                    fillColor: Colors.grey.shade900,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
              ),

              _buildInput("Profile Pic URL", _picCtrl),

              Row(children: [
                Expanded(child: _buildInput("Age", _ageCtrl, required: true, number: true,
                    validator: (v) {
                      int? age = int.tryParse(v ?? "");
                      if (age == null || age < 12 || age > 100) return "Invalid";
                      return null;
                    }
                )),
                const SizedBox(width: 8),
                Expanded(child: _buildInput("Contact", _contactCtrl, required: true, minLength: 10)),
              ]),

              const Divider(color: Colors.white24, height: 10), // Reduced height

              _buildInput("Street Address", _addressCtrl, required: true, minLength: 5),

              Row(children: [
                Expanded(child: _buildInput("City", _cityCtrl, required: true, regex: RegExp(r"^[a-zA-Z\s]+$"))),
                const SizedBox(width: 8),
                Expanded(child: _buildInput("State", _stateCtrl, required: true, regex: RegExp(r"^[a-zA-Z\s]+$"))),
              ]),

              Row(children: [
                Expanded(child: _buildInput("Country", _countryCtrl, required: true, regex: RegExp(r"^[a-zA-Z\s]+$"))),
                const SizedBox(width: 8),
                Expanded(child: _buildInput("Postal Code", _postalCtrl, number: true)),
              ]),

              const SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                height: 32, // Smaller button height
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
                  child: _isLoading
                      ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Text("SAVE CHANGES", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, {
    bool required = false,
    bool number = false,
    int minLength = 0,
    RegExp? regex,
    String? errorMsg,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8), // Reduced from 16 to 8
      child: TextFormField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white, fontSize: 11), // Smaller input text
        keyboardType: number ? TextInputType.number : TextInputType.text,
        inputFormatters: number
            ? [FilteringTextInputFormatter.digitsOnly]
            : [],
        validator: validator ?? (v) {
          if (required && (v == null || v.trim().isEmpty)) return "Required";
          if (minLength > 0 && v!.length < minLength) return "Min $minLength";
          if (regex != null && !regex.hasMatch(v!)) {
            return errorMsg ?? "Invalid";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54, fontSize: 11), // Smaller label text
          filled: true,
          fillColor: Colors.grey.shade900,
          isDense: true, // Reduces vertical height significantly
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Tighter internal padding
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), // Slightly smaller radius
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: neonGreen)),
        ),
      ),
    );
  }
}