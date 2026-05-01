import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rajeali_app/core/services/api_service.dart';
import 'package:rajeali_app/data/model/found_item_model.dart';
import 'package:rajeali_app/data/model/question_model.dart';
import 'package:rajeali_app/data/repository/app_repository.dart';

class VerificationController extends GetxController {
  VerificationController({required AppRepository repo, required ApiService api})
      : _repo = repo,
        _api = api;

  final AppRepository _repo;
  final ApiService _api;

  // Answer controllers for 3 questions
  final TextEditingController ans1Ctrl = TextEditingController();
  final TextEditingController ans2Ctrl = TextEditingController();
  final TextEditingController ans3Ctrl = TextEditingController();

  final Rxn<FoundItemModel> selectedFoundItem = Rxn<FoundItemModel>();
  final RxList<QuestionModel> questions = <QuestionModel>[].obs;
  final RxList<AnswerModel> answers = <AnswerModel>[].obs;
  final RxBool isVerifying = false.obs;
  final RxBool isLoadingQuestions = false.obs;
  final RxString error = ''.obs;
  final RxString resultMessage = ''.obs;
  final RxBool verificationPassed = false.obs;

  /// Select a found item and load its questions from API
  Future<void> selectFoundItem(FoundItemModel item) async {
    selectedFoundItem.value = item;
    verificationPassed.value = false;
    resultMessage.value = '';
    ans1Ctrl.clear();
    ans2Ctrl.clear();
    ans3Ctrl.clear();
    error.value = '';

    await _loadQuestions(item.id);
  }

  Future<void> _loadQuestions(int foundItemId) async {
    isLoadingQuestions.value = true;
    try {
      // Try to get existing questions first
      List<QuestionModel> qs = await _repo.getQuestions(foundItemId);
      // If none, generate them
      if (qs.isEmpty) {
        qs = await _repo.generateQuestions(foundItemId);
      }
      questions.assignAll(qs);
    } on DioException catch (e) {
      error.value = _api.extractError(e);
    } catch (_) {
      error.value = 'تعذر تحميل الأسئلة';
    }
    isLoadingQuestions.value = false;
  }

  /// Submit answers to all 3 questions via API
  Future<bool> submitVerification({required int foundItemUserId}) async {
    if (questions.length < 3) {
      error.value = 'لا توجد أسئلة كافية';
      return false;
    }

    final List<String> ansTexts = <String>[
      ans1Ctrl.text.trim(),
      ans2Ctrl.text.trim(),
      ans3Ctrl.text.trim(),
    ];
    if (ansTexts.any((String a) => a.isEmpty)) {
      error.value = 'يرجى الإجابة على جميع الأسئلة';
      return false;
    }

    isVerifying.value = true;
    error.value = '';

    try {
      final List<AnswerModel> submitted = <AnswerModel>[];
      for (int i = 0; i < 3; i++) {
        final AnswerModel ans = await _repo.submitAnswer(
          questionId: questions[i].id,
          answerText: ansTexts[i],
          foundItemUserId: foundItemUserId,
        );
        submitted.add(ans);
      }
      answers.assignAll(submitted);
      resultMessage.value = 'تم إرسال إجاباتك بنجاح! في انتظار مراجعة المالك.';
      verificationPassed.value = true;
      isVerifying.value = false;
      return true;
    } on DioException catch (e) {
      error.value = _api.extractError(e);
      isVerifying.value = false;
      return false;
    } catch (_) {
      error.value = 'حدث خطأ أثناء إرسال الإجابات';
      isVerifying.value = false;
      return false;
    }
  }

  /// Owner verifies a specific answer
  Future<bool> verifyAnswer({
    required int foundItemId,
    required int answerId,
    required String status, // 'approved' or 'rejected'
  }) async {
    try {
      await _repo.verifyAnswer(
        foundItemId: foundItemId,
        answerId: answerId,
        status: status,
      );
      // Refresh answers list
      answers.assignAll(await _repo.getAnswers(foundItemId));
      return true;
    } on DioException catch (e) {
      error.value = _api.extractError(e);
      return false;
    }
  }

  /// Load all answers for a found item (owner view)
  Future<void> loadAnswers(int foundItemId) async {
    try {
      answers.assignAll(await _repo.getAnswers(foundItemId));
    } on DioException catch (e) {
      error.value = _api.extractError(e);
    }
  }

  @override
  void onClose() {
    ans1Ctrl.dispose();
    ans2Ctrl.dispose();
    ans3Ctrl.dispose();
    super.onClose();
  }
}
