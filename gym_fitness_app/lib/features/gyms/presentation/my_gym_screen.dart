// my_gym_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gym_controller.dart';
import 'add_edit_gym_screen.dart';
import '../domain/gym_model.dart';
import '../domain/gym_logic.dart';

class MyGymScreen extends ConsumerStatefulWidget {
  const MyGymScreen({super.key});

  @override
  ConsumerState<MyGymScreen> createState() => _MyGymScreenState();
}

class _MyGymScreenState extends ConsumerState<MyGymScreen> {
  String _searchQuery = "";
  static const Color neonGreen = Color(0xFFD0FD3E);

  @override
  Widget build(BuildContext context) {
    final myGymsAsync = ref.watch(myGymsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("My Gym Management", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // 1. MATCHED SLIMMER SEARCH BAR CONTAINER from User Screen
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(25),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: SizedBox(
              height: 30, // Explicit Slim Height
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 12), // Smaller Input Text
                decoration: InputDecoration(
                    hintText: "Search your branches...",
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 12), // Smaller Hint
                    prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 15), // Smaller Icon
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    isDense: true, // Removes default internal padding
                    contentPadding: EdgeInsets.zero, // Centers text vertically
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)),
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              ),
            ),
          ),
        ),
      ),

      // 2. SMALLER ADD BUTTON
      floatingActionButton: FloatingActionButton(
        mini: true, // Makes it smaller
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditGymScreen())),
        backgroundColor: neonGreen,
        child: const Icon(Icons.add, color: Colors.black),
      ),

      body: myGymsAsync.when(
        data: (gyms) {
          final filtered = gyms.where((gym) => gym.name.toLowerCase().contains(_searchQuery)).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text("No branches found.", style: TextStyle(color: Colors.white54)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.82,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final gym = filtered[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditGymScreen(gymToEdit: gym)));
                },
                child: _ProfessionalOwnerCard(gym: gym),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: neonGreen)),
        error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}

class _ProfessionalOwnerCard extends StatelessWidget {
  final GymModel gym;
  const _ProfessionalOwnerCard({required this.gym});
  static const Color neonGreen = Color(0xFFD0FD3E);

  @override
  Widget build(BuildContext context) {
    final hasImage = gym.images.isNotEmpty;
    final imageUrl = hasImage ? gym.images.first : '';
    final totalMembers = GymLogic.getTotalActiveMembers(gym.id);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(14), // Matches User Screen Radius
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE (Flex 45) - Identical Ratio
          Expanded(
            flex: 45,
            child: Stack(
              fit: StackFit.expand,
              children: [
                hasImage
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : Container(
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade700])),
                  child: const Center(child: Icon(Icons.fitness_center, color: Colors.white24, size: 30)),
                ),
                Positioned(
                  top: 6, right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(color: neonGreen, borderRadius: BorderRadius.circular(4)),
                    child: const Text("EDIT", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),

          // CONTENT (Flex 55) - Identical Ratio & Styling
          Expanded(
            flex: 55,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(gym.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white, height: 1.1), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  // Location
                  Row(children: [const Icon(Icons.location_on, size: 7, color: Colors.white38), const SizedBox(width: 2), Expanded(child: Text(gym.address, style: const TextStyle(color: Colors.white38, fontSize: 7, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis))]),

                  // Description (or Spacer if you prefer empty space like before, but Description fills space better)
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      gym.description, // Re-added description to match User Card layout flow
                      style: const TextStyle(color: Colors.white30, fontSize: 7.5, height: 1.1),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const Divider(height: 8, thickness: 0.5, color: Colors.white10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status instead of Price for Owners
                      Text(gym.status.toUpperCase(), style: TextStyle(color: gym.status == 'open' ? neonGreen : Colors.red, fontWeight: FontWeight.w900, fontSize: 9)),
                      // Members Count
                      Row(children: [const Icon(Icons.people, size: 8, color: Colors.white38), const SizedBox(width: 2), Text("$totalMembers", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white38))])
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}