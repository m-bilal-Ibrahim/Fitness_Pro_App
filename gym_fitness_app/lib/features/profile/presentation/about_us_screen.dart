import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const Color neonGreen = Color(0xFFD0FD3E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("ABOUT US", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: neonGreen),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            // This ensures content is spaced out to fill the screen without scrolling
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // --- HEADER SECTION ---
              Column(
                children: [
                  Icon(Icons.fitness_center, size: 80, color: neonGreen),
                  SizedBox(height: 20),
                  Text("Fitness Pro", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  SizedBox(height: 10),
                  Text("Semester Project for Mobile Computing", style: TextStyle(color: Colors.white54, fontSize: 16), textAlign: TextAlign.center),
                ],
              ),

              Divider(color: Colors.white24),

              // --- DEVELOPERS SECTION ---
              Column(
                children: [
                  Text(
                    "DEVELOPERS",
                    style: TextStyle(color: neonGreen, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 14),
                  ),
                  SizedBox(height: 20),
                  Text("Muhammad Bilal Ibrahim", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("ID: 230973", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 20),
                  Text("Raja Rehan Mustafa", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("ID: 230947", style: TextStyle(color: Colors.grey)),
                ],
              ),

              // --- FOOTER ---
              Text("© 2025 All Rights Reserved", style: TextStyle(color: Colors.white24, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}