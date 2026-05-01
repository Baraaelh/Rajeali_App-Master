import 'dart:math';

import 'package:rajeali_app/core/services/crypto_service.dart';
import 'package:rajeali_app/core/services/semantic_similarity_service.dart';
import 'package:rajeali_app/data/datasource/verification_datasource.dart';
import 'package:rajeali_app/data/model/notification_model.dart';
import 'package:rajeali_app/data/model/post_model.dart';
import 'package:rajeali_app/data/model/verification_attempt_model.dart';
import 'package:uuid/uuid.dart';

class VerificationService {
  VerificationService({
    required AppDataSource ds,
    required CryptoService crypto,
    required SemanticSimilarityService ai,
  })  : _ds = ds,
        _crypto = crypto,
        _ai = ai;

  final AppDataSource _ds;
  final CryptoService _crypto;
  final SemanticSimilarityService _ai;
  static const Uuid _uuid = Uuid();

  /// Run AI verification for a found-post claim (3 questions).
  /// Returns the attempt model with scores and decision.
  VerificationAttemptModel verify({
    required PostModel post,
    required String claimantUserId,
    required List<String> answers,
  }) {
    final int fails = _ds.failedCount(post.postId, claimantUserId);

    if (fails >= 3) {
      return _buildAttempt(
        post: post,
        claimantUserId: claimantUserId,
        answers: answers,
        scores: <double>[0, 0, 0],
        avg: 0,
        result: VerificationResult.blocked,
      );
    }

    final List<double> scores = <double>[];
    for (int i = 0; i < post.verificationQuestions.length && i < answers.length; i++) {
      final String ref = _crypto.decrypt(post.verificationQuestions[i].encryptedAnswer);
      double score = _ai.compare(ref, answers[i]);

      // Numeric bonus/penalty per FRD §10.3.5
      final String refDigits = ref.replaceAll(RegExp(r'[^\d٠-٩]'), '');
      final String ansDigits = answers[i].replaceAll(RegExp(r'[^\d٠-٩]'), '');
      if (refDigits.isNotEmpty && ansDigits.isNotEmpty) {
        if (_normalizeDigits(refDigits) == _normalizeDigits(ansDigits)) {
          score = min(1.0, score + 0.20);
        } else {
          score = max(0.0, score - 0.20);
        }
      }
      scores.add(score);
    }

    final double avg = scores.isEmpty ? 0 : scores.reduce((double a, double b) => a + b) / scores.length;
    final double threshold = _ds.aiThreshold;

    VerificationResult result;
    if (avg >= threshold) {
      result = VerificationResult.accepted;
    } else if (avg >= 0.50) {
      result = VerificationResult.review;
    } else {
      result = VerificationResult.rejected;
    }

    final VerificationAttemptModel attempt = _buildAttempt(
      post: post,
      claimantUserId: claimantUserId,
      answers: answers,
      scores: scores,
      avg: avg,
      result: result,
    );
    _ds.addAttempt(attempt);

    if (result == VerificationResult.accepted) {
      _ds.resetFailed(post.postId, claimantUserId);
      // Create chat room if not exists
      if (_ds.findChatRoom(post.postId, claimantUserId) == null) {
        _ds.createChatRoom(
          roomId: _uuid.v4(),
          postId: post.postId,
          finderUserId: post.userId,
          claimantUserId: claimantUserId,
        );
      }
      // Notify finder
      _ds.addNotification(NotificationModel(
        notificationId: _uuid.v4(),
        userId: post.userId,
        type: NotificationType.verificationNotifyFinder,
        title: 'تم التحقق من هوية مطالب',
        body: 'تم التحقق من هوية مطالب — المحادثة مفتوحة',
        createdAt: DateTime.now(),
        postId: post.postId,
      ));
      // Notify claimant
      _ds.addNotification(NotificationModel(
        notificationId: _uuid.v4(),
        userId: claimantUserId,
        type: NotificationType.verificationSuccess,
        title: 'تم التحقق بنجاح',
        body: 'يمكنك الآن التواصل مع الواجد',
        createdAt: DateTime.now(),
        postId: post.postId,
      ));
    } else {
      final int newFails = _ds.incrementFailed(post.postId, claimantUserId);
      if (newFails >= 3) {
        _ds.addNotification(NotificationModel(
          notificationId: _uuid.v4(),
          userId: claimantUserId,
          type: NotificationType.accountBanned,
          title: 'تم تعليق حسابك',
          body: 'تم تعليق حسابك بسبب محاولات تحقق متكررة غير صحيحة',
          createdAt: DateTime.now(),
          postId: post.postId,
        ));
      }
    }

    return attempt;
  }

  VerificationAttemptModel _buildAttempt({
    required PostModel post,
    required String claimantUserId,
    required List<String> answers,
    required List<double> scores,
    required double avg,
    required VerificationResult result,
  }) {
    final String claimantHash = _crypto.hash(claimantUserId);
    return VerificationAttemptModel(
      attemptId: _uuid.v4(),
      postId: post.postId,
      claimantUserId: claimantUserId,
      claimantNationalIdHash: claimantHash,
      answers: answers,
      questionScores: scores,
      averageScore: avg,
      result: result,
      createdAt: DateTime.now(),
    );
  }

  String _normalizeDigits(String input) {
    const String arabic = '٠١٢٣٤٥٦٧٨٩';
    const String english = '0123456789';
    String output = input;
    for (int i = 0; i < arabic.length; i++) {
      output = output.replaceAll(arabic[i], english[i]);
    }
    return output;
  }
}

