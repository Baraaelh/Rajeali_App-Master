/// نموذج نتيجة مطابقة الصور من الـ API
class ImageMatchModel {
  ImageMatchModel({
    required this.lostItemId,
    required this.foundItemId,
    required this.similarityScore,
    required this.isMatch,
    this.chatRoomId,
    this.lostItemName,
    this.foundItemName,
    this.lostImageUrl,
    this.foundImageUrl,
  });

  factory ImageMatchModel.fromJson(Map<String, dynamic> json) {
    return ImageMatchModel(
      lostItemId: _parseInt(json['lost_item_id']),
      foundItemId: _parseInt(json['found_item_id']),
      similarityScore: json['similarity_score'] is num
          ? (json['similarity_score'] as num).toDouble()
          : double.tryParse(json['similarity_score']?.toString() ?? '') ?? 0.0,
      isMatch: json['is_match'] == true || json['is_match'] == 1,
      chatRoomId: json['chat_room_id']?.toString(),
      lostItemName: json['lost_item_name']?.toString(),
      foundItemName: json['found_item_name']?.toString(),
      lostImageUrl: _buildImageUrl(json['lost_image_url'] ?? json['lost_image']),
      foundImageUrl: _buildImageUrl(json['found_image_url'] ?? json['found_image']),
    );
  }

  final int lostItemId;
  final int foundItemId;
  final double similarityScore;
  final bool isMatch;
  final String? chatRoomId;
  final String? lostItemName;
  final String? foundItemName;
  final String? lostImageUrl;
  final String? foundImageUrl;

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
    return 'https://rajeali.kulshy.online${s.startsWith('/') ? s : '/storage/$s'}';
  }
}
