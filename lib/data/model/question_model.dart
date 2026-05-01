class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.foundItemId,
    required this.questionText,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as int,
      foundItemId: json['found_item_id'] as int? ?? 0,
      questionText: (json['question_text'] ?? json['question'] ?? '') as String,
    );
  }

  final int id;
  final int foundItemId;
  final String questionText;
}

class AnswerModel {
  const AnswerModel({
    required this.id,
    required this.questionId,
    required this.answerText,
    required this.foundItemUserId,
    this.status,
    this.createdAt,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id'] as int,
      questionId: json['question_id'] as int? ?? 0,
      answerText: (json['answer_text'] ?? '') as String,
      foundItemUserId: json['found_item_user_id'] as int? ?? 0,
      status: json['status']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  final int id;
  final int questionId;
  final String answerText;
  final int foundItemUserId;
  final String? status;
  final DateTime? createdAt;

  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}

