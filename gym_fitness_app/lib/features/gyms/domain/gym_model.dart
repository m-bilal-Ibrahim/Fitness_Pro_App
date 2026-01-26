class GymModel {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String address;
  final List<String> images;
  final double rating;
  final String status;
  final String openTime;
  final String closeTime;
  final int activeMembers; // (Legacy field, we use GymLogic now for display)
  final int slotCapacity;
  final double priceSilver;
  final double priceGold;
  final double pricePlatinum;
  final double trainerFee;

  GymModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.address,
    this.images = const [],
    this.rating = 0.0,
    required this.status,
    required this.openTime,
    required this.closeTime,
    this.activeMembers = 0,
    required this.slotCapacity,
    required this.priceSilver,
    required this.priceGold,
    required this.pricePlatinum,
    required this.trainerFee,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'address': address,
      'images': images,
      'rating': rating,
      'status': status,
      'openTime': openTime,
      'closeTime': closeTime,
      'activeMembers': activeMembers,
      'slotCapacity': slotCapacity,
      'priceSilver': priceSilver,
      'priceGold': priceGold,
      'pricePlatinum': pricePlatinum,
      'trainerFee': trainerFee,
    };
  }

  factory GymModel.fromMap(Map<String, dynamic> map) {
    double safeDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }
    int safeInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return GymModel(
      id: map['id']?.toString() ?? '',
      ownerId: map['ownerId']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unknown Gym',
      description: map['description']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      images: (map['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      rating: safeDouble(map['rating']),
      status: map['status']?.toString() ?? 'closed',
      openTime: map['openTime']?.toString() ?? '09:00',
      closeTime: map['closeTime']?.toString() ?? '22:00',
      activeMembers: safeInt(map['activeMembers']),
      slotCapacity: safeInt(map['slotCapacity']),
      priceSilver: safeDouble(map['priceSilver']),
      priceGold: safeDouble(map['priceGold']),
      pricePlatinum: safeDouble(map['pricePlatinum']),
      trainerFee: safeDouble(map['trainerFee']),
    );
  }
}