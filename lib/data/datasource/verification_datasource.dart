import 'dart:math';

import 'package:rajeali_app/data/model/chat_room_model.dart';
import 'package:rajeali_app/data/model/notification_model.dart';
import 'package:rajeali_app/data/model/post_model.dart';
import 'package:rajeali_app/data/model/user_model.dart';
import 'package:rajeali_app/data/model/verification_attempt_model.dart';

class AppDataSource {
  // ── Users ──
  final Map<String, UserModel> _users = <String, UserModel>{};
  String? _currentUserId;

  UserModel? get currentUser =>
      _currentUserId == null ? null : _users[_currentUserId];

  void setCurrentUser(String? userId) => _currentUserId = userId;

  UserModel? findUserById(String id) => _users[id];

  UserModel? findUserByEmail(String email) {
    for (final UserModel u in _users.values) {
      if (u.email == email) return u;
    }
    return null;
  }

  UserModel? findUserByNationalIdHash(String hash) {
    for (final UserModel u in _users.values) {
      if (u.nationalId == hash) return u;
    }
    return null;
  }

  void addUser(UserModel user) => _users[user.id.toString()] = user;

  List<UserModel> get allUsers => _users.values.toList();

  // ── Posts ──
  final List<PostModel> _posts = <PostModel>[];

  List<PostModel> get allPosts => List<PostModel>.unmodifiable(_posts);

  void addPost(PostModel post) => _posts.insert(0, post);

  PostModel? findPostById(String id) {
    for (final PostModel p in _posts) {
      if (p.postId == id) return p;
    }
    return null;
  }

  List<PostModel> postsForUser(String userId) =>
      _posts.where((PostModel p) => p.userId == userId).toList();

  List<PostModel> postsByType(PostType type) =>
      _posts.where((PostModel p) => p.postType == type && p.status != PostStatus.expired).toList();

  List<PostModel> nearbyPosts(double lat, double lng, double radiusMeters) {
    return _posts.where((PostModel p) {
      final double dist = _haversine(lat, lng, p.latitude, p.longitude);
      return dist <= radiusMeters && p.status != PostStatus.expired;
    }).toList();
  }

  void removePost(String postId) =>
      _posts.removeWhere((PostModel p) => p.postId == postId);

  // ── Verification Attempts ──
  final List<VerificationAttemptModel> _attempts = <VerificationAttemptModel>[];
  final Map<String, int> _failCounts = <String, int>{};

  void addAttempt(VerificationAttemptModel attempt) =>
      _attempts.insert(0, attempt);

  List<VerificationAttemptModel> attemptsByPost(String postId) =>
      _attempts.where((VerificationAttemptModel a) => a.postId == postId).toList();

  List<VerificationAttemptModel> attemptsByUser(String userId) =>
      _attempts.where((VerificationAttemptModel a) => a.claimantUserId == userId).toList();

  List<VerificationAttemptModel> get allAttempts =>
      List<VerificationAttemptModel>.unmodifiable(_attempts);

  int failedCount(String postId, String userId) =>
      _failCounts['$postId::$userId'] ?? 0;

  int incrementFailed(String postId, String userId) {
    final String key = '$postId::$userId';
    final int next = (_failCounts[key] ?? 0) + 1;
    _failCounts[key] = next;
    return next;
  }

  void resetFailed(String postId, String userId) =>
      _failCounts.remove('$postId::$userId');

  // ── Chat Rooms ──
  final List<ChatRoomModel> _chatRooms = <ChatRoomModel>[];

  ChatRoomModel? findChatRoom(String postId, String claimantUserId) {
    for (final ChatRoomModel r in _chatRooms) {
      if (r.postId == postId && r.claimantUserId == claimantUserId) return r;
    }
    return null;
  }

  ChatRoomModel? findChatRoomById(String roomId) {
    for (final ChatRoomModel r in _chatRooms) {
      if (r.roomId == roomId) return r;
    }
    return null;
  }

  List<ChatRoomModel> chatRoomsForUser(String userId) =>
      _chatRooms
          .where((ChatRoomModel r) =>
              r.finderUserId == userId || r.claimantUserId == userId)
          .toList();

  ChatRoomModel createChatRoom({
    required String roomId,
    required String postId,
    required String finderUserId,
    required String claimantUserId,
  }) {
    final ChatRoomModel room = ChatRoomModel(
      roomId: roomId,
      postId: postId,
      finderUserId: finderUserId,
      claimantUserId: claimantUserId,
      createdAt: DateTime.now(),
    );
    _chatRooms.add(room);
    return room;
  }

  void addMessage(ChatMessageModel message) {
    final ChatRoomModel? room = findChatRoomById(message.roomId);
    room?.messages.add(message);
  }

  // ── Notifications ──
  final List<NotificationModel> _notifications = <NotificationModel>[];

  void addNotification(NotificationModel n) => _notifications.insert(0, n);

  List<NotificationModel> notificationsForUser(String userId) =>
      _notifications.where((NotificationModel n) => n.userId == userId).toList();

  int unreadCount(String userId) => _notifications
      .where((NotificationModel n) => n.userId == userId && !n.isRead)
      .length;

  // ── Onboarding ──
  bool onboardingCompleted = false;

  // ── Admin settings ──
  double aiThreshold = 0.70;
  double matchingThreshold = 0.60;

  // ── Helpers ──
  static double _haversine(
      double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371000;
    final double dLat = _toRad(lat2 - lat1);
    final double dLon = _toRad(lon2 - lon1);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _toRad(double deg) => deg * pi / 180;
}
