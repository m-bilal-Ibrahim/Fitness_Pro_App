import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gym_controller.dart';
import 'gym_detail_screen.dart';
import '../domain/gym_model.dart';
import '../domain/gym_logic.dart';

class ExploreGymsScreen extends ConsumerStatefulWidget {
  const ExploreGymsScreen({super.key});

  @override
  ConsumerState<ExploreGymsScreen> createState() => _ExploreGymsScreenState();
}

class _ExploreGymsScreenState extends ConsumerState<ExploreGymsScreen> {
  String _searchQuery = "";
  static const Color neonGreen = Color(0xFFD0FD3E);

  @override
  Widget build(BuildContext context) {
    final allGymsAsync = ref.watch(allGymsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Find a Gym", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          // 1. SLIMMER SEARCH BAR CONTAINER
          preferredSize: const Size.fromHeight(25),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: SizedBox(
              height: 30, // Explicit Slim Height
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 12), // Smaller Input Text
                decoration: InputDecoration(
                    hintText: "Search name or location...",
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
      body: allGymsAsync.when(
        data: (gyms) {
          final filtered = gyms.where((gym) => gym.name.toLowerCase().contains(_searchQuery) || gym.address.toLowerCase().contains(_searchQuery)).toList();

          if (filtered.isEmpty) return const Center(child: Text("No gyms found.", style: TextStyle(color: Colors.white54)));

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
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GymDetailScreen(gym: filtered[index]))),
                child: _ProfessionalGymCard(gym: filtered[index]),
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

class _ProfessionalGymCard extends StatelessWidget {
  final GymModel gym;
  const _ProfessionalGymCard({required this.gym});
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
        borderRadius: BorderRadius.circular(14), // Slightly tighter radius
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE SECTION
          Expanded(
            flex: 45,
            child: Stack(
              fit: StackFit.expand,
              children: [
                hasImage
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade800, Colors.grey.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                  ),
                  child: const Center(child: Icon(Icons.fitness_center, color: Colors.white24, size: 30)),
                ),
                Positioned(
                  top: 6, right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 9, color: neonGreen), // Tiny Star
                        const SizedBox(width: 2),
                        Text(
                            gym.rating.toString(),
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // CONTENT SECTION
          Expanded(
            flex: 55,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. TITLE (Small: 14)
                  Text(
                      gym.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: Colors.white,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 2),

                  // 3. LOCATION (Smallest: 9)
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 7, color: Colors.white38),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                            gym.address,
                            style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 7,
                                fontWeight: FontWeight.w600
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // 4. DESCRIPTION (Medium: 11 - Distinct size)
                  Expanded(
                    child: Text(
                      gym.description,
                      style: const TextStyle(
                        color: Colors.white30,
                        fontSize: 9,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const Divider(height: 8, thickness: 0.5, color: Colors.white10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 5. PRICE (Small: 13)
                      Text(
                          "\$${gym.priceSilver.toInt()}",
                          style: const TextStyle(
                              color: neonGreen,
                              fontWeight: FontWeight.w900,
                              fontSize: 9
                          )
                      ),
                      // 6. MEMBERS (Smallest: 10)
                      Row(
                        children: [
                          const Icon(Icons.people, size: 8, color: Colors.white38),
                          const SizedBox(width: 2),
                          Text(
                              "$totalMembers",
                              style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white38
                              )
                          )
                        ],
                      )
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