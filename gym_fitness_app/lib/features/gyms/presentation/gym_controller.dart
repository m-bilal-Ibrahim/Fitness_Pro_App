import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/gym_repository.dart';
import '../domain/gym_model.dart';

final gymRepositoryProvider = Provider<GymRepository>((ref) {
  return GymRepository(ref.watch(realtimeDbProvider));
});

class GymController {
  final GymRepository _repo;
  final Ref _ref;

  GymController(this._repo, this._ref);

  Future<void> createOrUpdateGym({
    required String name,
    required String description,
    required String address,
    required String status,
    required String openTime,
    required String closeTime,
    required int slotCapacity,
    required double priceSilver,
    required double priceGold,
    required double pricePlatinum,
    required double trainerFee,
    List<String> images = const [],
    String? existingId,
    String? overrideOwnerId, // <--- ADDED THIS PARAMETER
  }) async {
    final user = _ref.read(firebaseAuthProvider).currentUser;

    // Use override ID if provided (for signup), otherwise fallback to current user
    final ownerId = overrideOwnerId ?? user?.uid;

    if (ownerId == null) throw Exception("User not logged in or owner not identified");

    final gymId = existingId ?? const Uuid().v4();
    double rating = 5.0;

    if (existingId == null) {
      // Logic for new gym
      final randomRating = 3.5 + Random().nextDouble() * 1.5;
      rating = double.parse(randomRating.toStringAsFixed(1));
    } else {
      // When editing, we should arguably keep the old rating, but sticking to your logic:
      // If you want to PRESERVE rating during edit, you would typically fetch the old gym first.
      // For now, I'll keep your logic: if existingId is NOT null, you set rating to 0.0?
      // (Note: You might want to fix this logic later to preserve ratings on edit)
      rating = 0.0;
    }

    final gym = GymModel(
      id: gymId,
      ownerId: ownerId, // Use the resolved ownerId
      name: name,
      description: description,
      address: address,
      status: status,
      openTime: openTime,
      closeTime: closeTime,
      slotCapacity: slotCapacity,
      priceSilver: priceSilver,
      priceGold: priceGold,
      pricePlatinum: pricePlatinum,
      trainerFee: trainerFee,
      rating: rating == 0.0 ? 5.0 : rating, // Fallback to 5.0 if 0.0
      images: images,
      activeMembers: 0,
    );

    await _repo.saveGym(gym);
    _ref.invalidate(myGymsProvider);
    _ref.invalidate(allGymsProvider);
  }

  Future<void> deleteGym(String gymId) async {
    await _repo.deleteGym(gymId);
    _ref.invalidate(myGymsProvider);
    _ref.invalidate(allGymsProvider);
  }

  Future<void> joinGym({
    required GymModel gym,
    required String planName,
    required double price,
    required String timeSlot,
    required bool hasTrainer,
    required String bankAccountNumber,
  }) async {
    final user = _ref.read(firebaseAuthProvider).currentUser;
    if (user == null) throw Exception("Must be logged in");

    await Future.delayed(const Duration(seconds: 2));

    DateTime now = DateTime.now();
    DateTime expiryDate;
    if (planName.contains("Weekly") || planName == "Silver") {
      expiryDate = now.add(const Duration(days: 7));
    } else if (planName.contains("Monthly") || planName == "Gold") {
      expiryDate = now.add(const Duration(days: 30));
    } else {
      expiryDate = now.add(const Duration(days: 365));
    }

    final booking = {
      'userId': user.uid,
      'userEmail': user.email,
      'gymId': gym.id,
      'gymName': gym.name,
      'gymAddress': gym.address,
      'plan': planName,
      'price': price,
      'slot': timeSlot,
      'hasTrainer': hasTrainer,
      'paymentAccount': bankAccountNumber,
      'bookedAt': now.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
    };

    await _repo.saveBooking(booking);
    _ref.invalidate(userActiveBookingProvider);
    _ref.invalidate(gymBookingsProvider(gym.id));
  }

  // --- CANCEL BOOKING / MEMBERSHIP ---
  Future<void> cancelBooking(String bookingId) async {
    await _repo.deleteBooking(bookingId);
    _ref.invalidate(userActiveBookingProvider);
  }

  // Alias for backward compatibility if used elsewhere
  Future<void> cancelMembership(String bookingId) async {
    return cancelBooking(bookingId);
  }

  // --- RATE GYM ---
  Future<void> rateGym({
    required String gymId,
    required String bookingId,
    required double currentUserRating,
    required double currentGymRating,
  }) async {
    double newGlobalRating = (currentGymRating + currentUserRating) / 2;
    newGlobalRating = double.parse(newGlobalRating.toStringAsFixed(1));

    await _repo.updateGymRating(gymId, newGlobalRating);
    await _repo.updateUserRatingInBooking(bookingId, currentUserRating);

    _ref.invalidate(allGymsProvider);
    _ref.invalidate(userActiveBookingProvider);
  }
}

final gymControllerProvider = Provider<GymController>((ref) {
  return GymController(ref.watch(gymRepositoryProvider), ref);
});

// --- PROVIDERS ---
final myGymsProvider = FutureProvider<List<GymModel>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) return [];
  return ref.read(gymRepositoryProvider).getGymsByOwner(user.uid);
});

final allGymsProvider = FutureProvider<List<GymModel>>((ref) async {
  return ref.read(gymRepositoryProvider).getAllGyms();
});

final gymBookingsProvider =
FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, gymId) async {
      return ref.read(gymRepositoryProvider).getBookingsForGym(gymId);
    });

final userActiveBookingProvider =
FutureProvider<Map<String, dynamic>?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) return null;
  return ref.read(gymRepositoryProvider).getActiveBookingForUser(user.uid);
});