// lib/features/dashboard/presentation/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_screen.dart';
import '../../time_tools/presentation/time_tool_screen.dart';
import '../../gyms/presentation/explore_gyms_screen.dart';
import '../../gyms/presentation/my_gym_screen.dart';
import '../../workout/presentation/workout_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../auth/presentation/role_selection_screen.dart';
import '../../auth/presentation/auth_controller.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  static const Color neonGreen = Color(0xFFD0FD3E);

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return userProfileAsync.when(
      data: (user) {
        if (user == null) {
          return const RoleSelectionScreen();
        }

        final isOwner = user.role == 'owner';

        final List<Widget> screens = isOwner
            ? [
          const HomeScreen(),
          const MyGymScreen(),
          const TimeToolScreen(),
          const WorkoutScreen(),
          const ProfileScreen()
        ]
            : [
          const HomeScreen(),
          const ExploreGymsScreen(),
          const TimeToolScreen(),
          const WorkoutScreen(),
          const ProfileScreen()
        ];

        final List<NavigationDestination> tabs = isOwner
            ? const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.business), label: 'My Gym'),
          NavigationDestination(icon: Icon(Icons.timer), label: 'Tracker'),
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Workout'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ]
            : const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.storefront), label: 'Find Gyms'),
          NavigationDestination(icon: Icon(Icons.timer), label: 'Tracker'),
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Workouts'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: 60,
              backgroundColor: Colors.black, // Dark Theme
              indicatorColor: neonGreen, // Encircled active icon
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: Colors.black); // Black icon inside neon circle
                }
                return const IconThemeData(color: neonGreen); // Neon icons otherwise
              }),
            ),
            child: NavigationBar(
              elevation: 0,
              backgroundColor: Colors.black,
              selectedIndex: _currentIndex,
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              destinations: tabs,
            ),
          ),
        );
      },
      loading: () => const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: neonGreen))),
      error: (err, stack) => Scaffold(backgroundColor: Colors.black, body: Center(child: Text("Error: $err", style: const TextStyle(color: Colors.white)))),
    );
  }
}