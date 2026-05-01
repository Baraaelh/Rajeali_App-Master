class FoundItemModel {
  FoundItemModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.finderName,
    required this.description,
    required this.mapLocation,
    required this.foundTime,
    this.imageUrl,
    this.categoryName,
    this.createdAt,
    this.matchScore,
  });

  factory FoundItemModel.fromJson(Map<String, dynamic> json) {
    return FoundItemModel(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      categoryId: _parseInt(json['category_id']),
      finderName: (json['finder_name'] ?? json['name'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      mapLocation: (json['map_location'] ?? '') as String,
      foundTime: json['found_time'] != null
          ? DateTime.tryParse(json['found_time'].toString()) ?? DateTime.now()
          : DateTime.now(),
      imageUrl: _buildImageUrl(json['image'] ?? json['image_url']),
      categoryName: json['category'] is Map
          ? (json['category'] as Map<String, dynamic>)['name']?.toString()
          : json['category_name']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      matchScore: json['match_score'] is num
          ? (json['match_score'] as num).toDouble()
          : double.tryParse(json['match_score']?.toString() ?? ''),
    );
  }

  final int id;
  final int userId;
  final int categoryId;
  final String finderName;
  final String description;
  final String mapLocation;
  final DateTime foundTime;
  final String? imageUrl;
  final String? categoryName;
  final DateTime? createdAt;
  final double? matchScore;

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static String? _buildImageUrl(dynamic raw) {
    if (raw == null) return null;
    final String s = raw.toString();
    if (s.isEmpty) return null;
    if (s.startsWith('http')) return s;
    return 'https://rajeali.kulshy.online${ s.startsWith('/') ? s : '/storage/$s'}';
  }
}
