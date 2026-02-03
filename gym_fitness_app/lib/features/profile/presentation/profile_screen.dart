import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/user_model.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/data/user_repository.dart';

// Imports for the new split files
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'about_us_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const Color neonGreen = Color(0xFFD0FD3E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "PROFILE",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18), // Smaller AppBar Text
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: () => _confirmLogout(context, ref),
            icon: const Icon(Icons.logout, color: Colors.redAccent, size: 10,),
            label: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text("User not found", style: TextStyle(color: Colors.white)));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 1. PROFILE HEADER
                _buildProfileHeader(user),

                const SizedBox(height: 20),

                // 2. ACTION CARDS
                _buildActionCard(
                  context,
                  icon: Icons.edit,
                  title: "Edit Personal Information",
                  subtitle: "Update email, photo & details",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(user: user))),
                ),

                _buildActionCard(
                  context,
                  icon: Icons.lock_outline,
                  title: "Edit My Password",
                  subtitle: "Change account security",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChangePasswordScreen(email: user.email))),
                ),

                _buildActionCard(
                  context,
                  icon: Icons.info_outline,
                  title: "About Us",
                  subtitle: "Project & Developer Info",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen())),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: neonGreen)),
        error: (e, _) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: neonGreen, width: 2),
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade900,
            backgroundImage: (user.profilePic.isNotEmpty) ? NetworkImage(user.profilePic) : null,
            child: (user.profilePic.isEmpty)
                ? const Icon(Icons.person, size: 30, color: Colors.white54)
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.fullName.isNotEmpty ? user.fullName.toUpperCase() : "FITNESS USER",
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        Text(
          user.email,
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4.5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: neonGreen, size: 14),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 8)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 12),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text("Logout?", style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text("Are you sure you want to log out?", style: TextStyle(color: Colors.white70, fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.white54, fontSize: 14))),
          TextButton(onPressed: () {
            Navigator.pop(ctx);
            ref.read(authRepositoryProvider).signOut();
          }, child: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14))),
        ],
      ),
    );
  }
}