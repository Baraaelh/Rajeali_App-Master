enum PostType { lost, found }
enum PostStatus { lost, found, returned, expired }

enum ItemCategory {
  phone,
  wallet,
  keys,
  bag,
  jewelry,
  clothes,
  documents,
  glasses,
  other,
}

class VerificationQuestion {
  const VerificationQuestion({
    required this.question,
    required this.encryptedAnswer,
  });

  final String question;
  final String encryptedAnswer;
}

class PostModel {
  PostModel({
    required this.postId,
    required this.userId,
    required this.userNationalIdHash,
    required this.postType,
    required this.title,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.eventDate,
    required this.createdAt,
    required this.status,
    this.imageUrls = const <String>[],
    this.hiddenImageUrls = const <String>[],
    this.verificationQuestions = const <VerificationQuestion>[],
  });

  final String postId;
  final String userId;
  final String userNationalIdHash;
  final PostType postType;
  final String title;
  final ItemCategory category;
  final String description;
  final double latitude;
  final double longitude;
  final String locationName;
  final DateTime eventDate;
  final DateTime createdAt;
  PostStatus status;
  final List<String> imageUrls;
  final List<String> hiddenImageUrls;
  final List<VerificationQuestion> verificationQuestions;

  String get categoryLabel {
    switch (category) {
      case ItemCategory.phone:
        return 'هاتف';
      case ItemCategory.wallet:
        return 'محفظة';
      case ItemCategory.keys:
        return 'مفاتيح';
      case ItemCategory.bag:
        return 'حقيبة';
      case ItemCategory.jewelry:
        return 'مجوهرات';
      case ItemCategory.clothes:
        return 'ملابس';
      case ItemCategory.documents:
        return 'وثائق';
      case ItemCategory.glasses:
        return 'نظارة';
      case ItemCategory.other:
        return 'أخرى';
    }
  }

  String get statusLabel {
    switch (status) {
      case PostStatus.lost:
        return 'مفقود';
      case PostStatus.found:
        return 'موجود';
      case PostStatus.returned:
        return 'تم الإرجاع';
      case PostStatus.expired:
        return 'منتهي';
    }
  }

  bool get isExpired {
    return DateTime.now().difference(createdAt).inDays > 90;
  }
}

