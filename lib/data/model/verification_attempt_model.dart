enum VerificationResult { accepted, review, rejected, blocked }

class VerificationAttemptModel {
  const VerificationAttemptModel({
    required this.attemptId,
    required this.postId,
    required this.claimantUserId,
    required this.claimantNationalIdHash,
    required this.answers,
    required this.questionScores,
    required this.averageScore,
    required this.result,
    required this.createdAt,
    this.ipAddress = '',
    this.deviceId = '',
  });

  final String attemptId;
  final String postId;
  final String claimantUserId;
  final String claimantNationalIdHash;
  final List<String> answers;
  final List<double> questionScores;
  final double averageScore;
  final VerificationResult result;
  final DateTime createdAt;
  final String ipAddress;
  final String deviceId;

  String get resultLabel {
    switch (result) {
      case VerificationResult.accepted:
        return 'قبول';
      case VerificationResult.review:
        return 'مراجعة';
      case VerificationResult.rejected:
        return 'رفض';
      case VerificationResult.blocked:
        return 'محظور';
    }
  }

  String strengthLabel(double score) {
    if (score >= 0.70) return 'قوي';
    if (score >= 0.50) return 'مقبول';
    return 'ضعيف';
  }
}
