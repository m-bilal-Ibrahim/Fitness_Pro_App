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
        title: const Text("My Gym Management", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search your branches...",
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.grey.shade900,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditGymScreen())),
        label: const Text("Add Branch", style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: neonGreen,
        foregroundColor: Colors.black,
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
        color: Colors.grey.shade900, // Matches ExploreGyms Dark Card
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE (Flex 45)
          Expanded(
            flex: 45,
            child: Stack(
              fit: StackFit.expand,
              children: [
                hasImage
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : Container(
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade700])),
                  child: const Center(child: Icon(Icons.fitness_center, color: Colors.white24, size: 40)),
                ),
                Positioned(
                  top: 6, right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: neonGreen, borderRadius: BorderRadius.circular(6)),
                    child: const Text("EDIT", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),

          // CONTENT (Flex 55)
          Expanded(
            flex: 55,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(gym.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, height: 1.1), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(children: [const Icon(Icons.location_on, size: 12, color: Colors.white38), const SizedBox(width: 2), Expanded(child: Text(gym.address, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis))]),

                  // Pushes content below to the bottom of the card
                  const Spacer(),
                  const Divider(height: 8, thickness: 0.5, color: Colors.white10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(gym.status.toUpperCase(), style: TextStyle(color: gym.status == 'open' ? neonGreen : Colors.red, fontWeight: FontWeight.w900, fontSize: 10)),
                      Row(children: [const Icon(Icons.people, size: 12, color: Colors.white38), const SizedBox(width: 2), Text("$totalMembers", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white38))])
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