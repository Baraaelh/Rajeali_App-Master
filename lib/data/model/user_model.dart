enum UserRole { finder, loser, admin }

class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.nationalId,
    this.phone,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      nationalId: json['national_id']?.toString(),
      phone: json['phone']?.toString(),
      location: json['location']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  final int id;
  final String name;
  final String email;
  final String? nationalId;
  final String? phone;
  final String? location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'national_id': nationalId,
      'phone': phone,
      'location': location,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get maskedNationalId {
    if (nationalId == null || nationalId!.length <= 4) return '****';
    return '*****${nationalId!.substring(nationalId!.length - 4)}';
  }
}
