import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provide the logic class to the rest of the app
final gymLogicProvider = Provider<GymLogic>((ref) => GymLogic());

class GymLogic {
  // Generates 4 consistent numbers for a specific gym based on its ID
  static List<int> getSlotCounts(String gymId) {
    final r = Random(gymId.hashCode);
    return [
      r.nextInt(15) + 5, // Morning
      r.nextInt(15) + 5, // Afternoon
      r.nextInt(15) + 5, // Evening
      r.nextInt(15) + 5, // Night
    ];
  }

  static int getTotalActiveMembers(String gymId) {
    final slots = getSlotCounts(gymId);
    return slots.reduce((a, b) => a + b);
  }

  static List<String> getSlotLabels(String open, String close) {
    return [
      "$open - 10:00",
      "10:00 - 14:00",
      "14:00 - 18:00",
      "18:00 - $close"
    ];
  }
}