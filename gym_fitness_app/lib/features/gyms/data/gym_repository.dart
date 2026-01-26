import 'package:firebase_database/firebase_database.dart';
import '../domain/gym_model.dart';

class GymRepository {
  final FirebaseDatabase _realtimeDb;

  GymRepository(this._realtimeDb);

  // 1. Save or Update a Gym
  Future<void> saveGym(GymModel gym) async {
    await _realtimeDb.ref("gyms/${gym.id}").set(gym.toMap());
  }

  // 2. Get Gyms by Owner ID
  Future<List<GymModel>> getGymsByOwner(String ownerId) async {
    try {
      final snapshot = await _realtimeDb.ref("gyms").orderByChild("ownerId").equalTo(ownerId).get();
      if (snapshot.exists && snapshot.value != null) {
        final dataMap = snapshot.value as Map<dynamic, dynamic>;
        return dataMap.values.map((v) => GymModel.fromMap(Map<String, dynamic>.from(v as Map))).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 3. Get ALL Gyms
  Future<List<GymModel>> getAllGyms() async {
    try {
      final snapshot = await _realtimeDb.ref("gyms").get();
      if (snapshot.exists && snapshot.value != null) {
        final dataMap = snapshot.value as Map<dynamic, dynamic>;
        return dataMap.values.map((v) => GymModel.fromMap(Map<String, dynamic>.from(v as Map))).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 4. Delete Gym
  Future<void> deleteGym(String gymId) async {
    await _realtimeDb.ref("gyms/$gymId").remove();
  }

  // 5. Save Booking
  Future<void> saveBooking(Map<String, dynamic> bookingData) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _realtimeDb.ref("bookings/$id").set(bookingData);
  }

  // 6. Get Bookings for Gym (Slot Logic)
  Future<List<Map<String, dynamic>>> getBookingsForGym(String gymId) async {
    try {
      final snapshot = await _realtimeDb.ref("bookings").orderByChild("gymId").equalTo(gymId).get();
      if (snapshot.exists && snapshot.value != null) {
        final dataMap = snapshot.value as Map<dynamic, dynamic>;
        return dataMap.values.map((v) => Map<String, dynamic>.from(v as Map)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 7. Get Active User Booking (With ID FIX)
  Future<Map<String, dynamic>?> getActiveBookingForUser(String uid) async {
    try {
      final snapshot = await _realtimeDb.ref("bookings").orderByChild("userId").equalTo(uid).get();

      if (snapshot.exists && snapshot.value != null) {
        final dataMap = snapshot.value as Map<dynamic, dynamic>;
        // CRITICAL FIX: Include the 'id' (key) in the map so we can delete it later
        final bookings = dataMap.entries.map((e) {
          final map = Map<String, dynamic>.from(e.value as Map);
          map['id'] = e.key;
          return map;
        }).toList();

        // Sort by newest
        bookings.sort((a, b) => b['bookedAt'].compareTo(a['bookedAt']));

        final latest = bookings.first;
        final expiry = DateTime.parse(latest['expiryDate']);

        // Only return if not expired
        if (expiry.isAfter(DateTime.now())) {
          return latest;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 8. Delete Booking (Unsubscribe)
  Future<void> deleteBooking(String bookingId) async {
    await _realtimeDb.ref("bookings/$bookingId").remove();
  }

  // 9. Update Gym Rating (Global)
  Future<void> updateGymRating(String gymId, double newRating) async {
    await _realtimeDb.ref("gyms/$gymId").update({
      'rating': newRating
    });
  }

  // 10. Update User's Rating in Booking (Personal)
  Future<void> updateUserRatingInBooking(String bookingId, double rating) async {
    await _realtimeDb.ref("bookings/$bookingId").update({
      'myRating': rating
    });
  }
}