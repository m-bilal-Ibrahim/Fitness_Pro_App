import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart'; // Uncomment if you have this package

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const Color neonGreen = Color(0xFFD0FD3E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("ABOUT US", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: neonGreen, size: 18),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            // This ensures content is spaced out to fill the screen without scrolling
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // --- HEADER SECTION ---
              const Column(
                children: [
                  Icon(Icons.fitness_center, size: 40, color: neonGreen),
                  SizedBox(height: 15),
                  Text("Fitness Pro", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  SizedBox(height: 10),
                  Text("Level Up Your Life!", style: TextStyle(color: Colors.white54, fontSize: 12), textAlign: TextAlign.center),
                ],
              ),

              const Divider(color: Colors.white24),

              // --- DEVELOPERS SECTION ---
              Column(
                children: [
                  const Text(
                    "DEVELOPERS",
                    style: TextStyle(color: neonGreen, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12),
                  ),
                  const SizedBox(height: 20),

                  // --- DEVELOPER 1 ---
                  const Text("Muhammad Bilal Ibrahim", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton("GitHub", "https://github.com/m-bilal-ibrahim"),
                      const SizedBox(width: 15),
                      _buildSocialButton("LinkedIn", "https://linkedin.com/in/m-bilal-ibrahim"),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- DEVELOPER 2 ---
                  const Text("Raja Rehan Mustafa", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton("GitHub", "https://github.com/RehanRaja18"),
                      const SizedBox(width: 15),
                      _buildSocialButton("LinkedIn", "https://https://www.linkedin.com/in/rajarehan/"),
                    ],
                  ),
                ],
              ),

              // --- FOOTER ---
              const Text("© 2025 All Rights Reserved", style: TextStyle(color: Colors.white24, fontSize: 9)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label, String url) {
    return InkWell(
      onTap: () {
        // TODO: Implement URL launch
        // launchUrl(Uri.parse(url));
        debugPrint("Opening $url");
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.05),
        ),
        child: Row(
          children: [
            // Using generic Icons.link since specific brand icons require external packages
            // If you have font_awesome_flutter, use FontAwesomeIcons.github / .linkedin
            Icon(label == "GitHub" ? Icons.code : Icons.business, color: Colors.white54, size: 12),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}