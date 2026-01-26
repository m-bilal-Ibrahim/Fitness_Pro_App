class UserModel {
  final String uid;
  final String email;
  final String role; // "owner" or "member"
  final DateTime createdAt;

  // New Fields
  final String fullName;
  final String age;
  final String contact;
  final String address;
  final String state;
  final String city;
  final String country;
  final String postalCode;
  final String profilePic;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.createdAt,
    this.fullName = '',
    this.age = '',
    this.contact = '',
    this.address = '',
    this.state = '',
    this.city = '',
    this.country = '',
    this.postalCode = '',
    this.profilePic = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'fullName': fullName,
      'age': age,
      'contact': contact,
      'address': address,
      'state': state,
      'city': city,
      'country': country,
      'postalCode': postalCode,
      'profilePic': profilePic,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'member',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      fullName: map['fullName'] ?? '',
      age: map['age'] ?? '',
      contact: map['contact'] ?? '',
      address: map['address'] ?? '',
      state: map['state'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? '',
      postalCode: map['postalCode'] ?? '',
      profilePic: map['profilePic'] ?? '',
    );
  }
}