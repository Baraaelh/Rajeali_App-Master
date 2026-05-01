import 'dart:math';

import 'package:rajeali_app/core/services/semantic_similarity_service.dart';
import 'package:rajeali_app/data/datasource/verification_datasource.dart';
import 'package:rajeali_app/data/model/notification_model.dart';
import 'package:rajeali_app/data/model/post_model.dart';
import 'package:uuid/uuid.dart';

class MatchingService {
  MatchingService({
    required AppDataSource ds,
    required SemanticSimilarityService ai,
  })  : _ds = ds,
        _ai = ai;

  final AppDataSource _ds;
  final SemanticSimilarityService _ai;
  static const Uuid _uuid = Uuid();

  /// Called after every new post. Compares against opposite-type posts.
  void runMatching(PostModel newPost) {
    final PostType opposite =
        newPost.postType == PostType.lost ? PostType.found : PostType.lost;
    final List<PostModel> candidates = _ds.postsByType(opposite);

    for (final PostModel candidate in candidates) {
      if (candidate.status == PostStatus.returned) continue;
      final double score = _score(newPost, candidate);
      if (score >= _ds.matchingThreshold) {
        // Notify both users
        _ds.addNotification(NotificationModel(
          notificationId: _uuid.v4(),
          userId: newPost.userId,
          type: NotificationType.matchFound,
          title: 'وُجد شيء مشابه لما فقدته',
          body: 'وُجد شيء مشابه — اضغط للتفاصيل',
          createdAt: DateTime.now(),
          postId: candidate.postId,
        ));
        _ds.addNotification(NotificationModel(
          notificationId: _uuid.v4(),
          userId: candidate.userId,
          type: NotificationType.matchFound,
          title: 'تم العثور على تطابق محتمل',
          body: 'بلاغ جديد قد يتطابق مع ما نشرته — اضغط للتفاصيل',
          createdAt: DateTime.now(),
          postId: newPost.postId,
        ));
      }
    }
  }

  double _score(PostModel a, PostModel b) {
    double total = 0;

    // Category match (40%)
    if (a.category == b.category) {
      total += 0.40;
    }

    // Description similarity (30%)
    final double descSim = _ai.compare(a.description, b.description);
    total += descSim * 0.30;

    // Geographic proximity (20%) — <2km = full score
    final double dist = _haversine(a.latitude, a.longitude, b.latitude, b.longitude);
    if (dist <= 2000) {
      total += 0.20 * (1.0 - dist / 2000);
    }

    // Temporal proximity (10%) — <7 days = full score
    final int daysDiff = a.eventDate.difference(b.eventDate).inDays.abs();
    if (daysDiff <= 7) {
      total += 0.10 * (1.0 - daysDiff / 7);
    }

    return total;
  }

  static double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371000;
    final double dLat = _toRad(lat2 - lat1);
    final double dLon = _toRad(lon2 - lon1);
    final double a =
        sin(dLat / 2) * sin(dLat / 2) + cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _toRad(double deg) => deg * pi / 180;
}

