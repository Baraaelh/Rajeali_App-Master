import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rajeali_app/core/services/api_service.dart';
import 'package:rajeali_app/data/model/category_model.dart';
import 'package:rajeali_app/data/model/found_item_model.dart';
import 'package:rajeali_app/data/model/image_match_model.dart';
import 'package:rajeali_app/data/model/lost_item_model.dart';
import 'package:rajeali_app/data/model/question_model.dart';

/// Centralised API repository — wraps all endpoints.
class AppRepository {
  AppRepository({required ApiService api}) : _api = api;

  final ApiService _api;

  // ── helpers ──
  List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> e) {
            try { return fromJson(e); }
            catch (err) { debugPrint('⚠ parseList item error: $err'); return null; }
          })
          .whereType<T>()
          .toList();
    }
    if (data is Map) {
      // Try "data" key (Laravel standard)
      if (data.containsKey('data')) return _parseList(data['data'], fromJson);
      // Single object wrapped — return as single-element list
      if (data.containsKey('id')) {
        try { return <T>[fromJson(data as Map<String, dynamic>)]; }
        catch (_) {}
      }
    }
    debugPrint('⚠ _parseList: unexpected data type ${data.runtimeType}');
    return <T>[];
  }

  Map<String, dynamic> _body(Response<dynamic> r) {
    if (r.data is Map<String, dynamic>) return r.data as Map<String, dynamic>;
    return <String, dynamic>{};
  }

  // ═══════════════════════════════════════════════
  //  CATEGORIES
  // ═══════════════════════════════════════════════

  Future<List<CategoryModel>> getCategories() async {
    final Response<dynamic> r = await _api.dio.get('/categories');
    return _parseList(r.data, CategoryModel.fromJson);
  }

  // ═══════════════════════════════════════════════
  //  LOST ITEMS
  // ═══════════════════════════════════════════════

  Future<List<LostItemModel>> getLostItems({int? categoryId}) async {
    final Map<String, dynamic> query = <String, dynamic>{};
    if (categoryId != null) query['category_id'] = categoryId;
    final Response<dynamic> r =
        await _api.dio.get('/lost-items', queryParameters: query);
    return _parseList(r.data, LostItemModel.fromJson);
  }

  Future<LostItemModel> getLostItem(int id) async {
    final Response<dynamic> r = await _api.dio.get('/lost-items/$id');
    final Map<String, dynamic> body = _body(r);
    final dynamic item = body.containsKey('data') ? body['data'] : body;
    return LostItemModel.fromJson(item as Map<String, dynamic>);
  }

  Future<LostItemModel> createLostItem({
    required int categoryId,
    required String itemName,
    required String description,
    required String mapLocation,
    required String lostTime,
    String? imagePath,
  }) async {
    final FormData form = FormData.fromMap(<String, dynamic>{
      'category_id': categoryId,
      'item_name': itemName,
      'description': description,
      'map_location': mapLocation,
      'lost_time': lostTime,
      if (imagePath != null)
        'image': await MultipartFile.fromFile(imagePath, filename: 'image.jpg'),
    });
    final Response<dynamic> r = await _api.dio.post('/lost-items', data: form);
    final Map<String, dynamic> body = _body(r);
    final dynamic item = body.containsKey('data') ? body['data'] : body;
    return LostItemModel.fromJson(item as Map<String, dynamic>);
  }

  Future<void> deleteLostItem(int id) async {
    await _api.dio.delete('/lost-items/$id');
  }

  /// 🔥 Matches for a lost item
  Future<List<FoundItemModel>> getLostItemMatches(int lostItemId) async {
    final Response<dynamic> r =
        await _api.dio.get('/lost-items/$lostItemId/matches');
    return _parseList(r.data, FoundItemModel.fromJson);
  }

  // ═══════════════════════════════════════════════
  //  FOUND ITEMS
  // ═══════════════════════════════════════════════

  Future<List<FoundItemModel>> getFoundItems({int? categoryId}) async {
    final Map<String, dynamic> query = <String, dynamic>{};
    if (categoryId != null) query['category_id'] = categoryId;
    final Response<dynamic> r =
        await _api.dio.get('/found-items', queryParameters: query);
    return _parseList(r.data, FoundItemModel.fromJson);
  }

  Future<FoundItemModel> getFoundItem(int id) async {
    final Response<dynamic> r = await _api.dio.get('/found-items/$id');
    final Map<String, dynamic> body = _body(r);
    final dynamic item = body.containsKey('data') ? body['data'] : body;
    return FoundItemModel.fromJson(item as Map<String, dynamic>);
  }

  Future<FoundItemModel> createFoundItem({
    required int categoryId,
    required String finderName,
    required String description,
    required String mapLocation,
    required String foundTime,
    String? imagePath,
  }) async {
    final FormData form = FormData.fromMap(<String, dynamic>{
      'category_id': categoryId,
      'finder_name': finderName,
      'description': description,
      'map_location': mapLocation,
      'found_time': foundTime,
      if (imagePath != null)
        'image': await MultipartFile.fromFile(imagePath, filename: 'image.jpg'),
    });
    final Response<dynamic> r = await _api.dio.post('/found-items', data: form);
    final Map<String, dynamic> body = _body(r);
    final dynamic item = body.containsKey('data') ? body['data'] : body;
    return FoundItemModel.fromJson(item as Map<String, dynamic>);
  }

  Future<void> deleteFoundItem(int id) async {
    await _api.dio.delete('/found-items/$id');
  }

  /// 🔥 Search lost items that match a found item
  Future<List<LostItemModel>> searchLostForFound(int foundItemId) async {
    final Response<dynamic> r =
        await _api.dio.get('/found-items/$foundItemId/search-lost');
    return _parseList(r.data, LostItemModel.fromJson);
  }

 
/// مقارنة صورة مع قاعدة البيانات بالذكاء الاصطناعي
Future<ImageMatchModel> compareImage({
  required String imagePath,
  int? lostItemId,
  int? foundItemId,
}) async {
  final FormData form = FormData.fromMap(<String, dynamic>{
    'image': await MultipartFile.fromFile(imagePath, filename: 'item_image.jpg'),
    if (lostItemId != null) 'lost_item_id': lostItemId,
    if (foundItemId != null) 'found_item_id': foundItemId,
  });
  final Response<dynamic> r = await _api.dio.post('/image-match', data: form);
  final Map<String, dynamic> body = _body(r);
  final dynamic item = body.containsKey('data') ? body['data'] : body;
  return ImageMatchModel.fromJson(item as Map<String, dynamic>);
}


 // ═══════════════════════════════════════════════
  //  QUESTIONS
  // ═══════════════════════════════════════════════
  Future<List<QuestionModel>> generateQuestions(int foundItemId) async {
    final Response<dynamic> r =
        await _api.dio.post('/questions/generate/$foundItemId');
    return _parseList(r.data, QuestionModel.fromJson);
  }

  

  Future<List<QuestionModel>> getQuestions(int foundItemId) async {
    final Response<dynamic> r =
        await _api.dio.get('/questions/$foundItemId');
    return _parseList(r.data, QuestionModel.fromJson);
  }

  // ═══════════════════════════════════════════════
  //  ANSWERS
  // ═══════════════════════════════════════════════

  Future<AnswerModel> submitAnswer({
    required int questionId,
    required String answerText,
    required int foundItemUserId,
  }) async {
    final Response<dynamic> r = await _api.dio.post('/answers', data: <String, dynamic>{
      'question_id': questionId,
      'answer_text': answerText,
      'found_item_user_id': foundItemUserId,
    });
    final Map<String, dynamic> body = _body(r);
    final dynamic item = body.containsKey('data') ? body['data'] : body;
    return AnswerModel.fromJson(item as Map<String, dynamic>);
  }

  Future<List<AnswerModel>> getAnswers(int foundItemId) async {
    final Response<dynamic> r = await _api.dio.get('/answers/$foundItemId');
    return _parseList(r.data, AnswerModel.fromJson);
  }

  /// 🔥 Owner verifies an answer (approve / reject)
  Future<AnswerModel> verifyAnswer({
    required int foundItemId,
    required int answerId,
    required String status, // 'approved' or 'rejected'
  }) async {
    final Response<dynamic> r = await _api.dio.post(
      '/answers/verify/$foundItemId',
      data: <String, dynamic>{
        'answer_id': answerId,
        'status': status,
      },
    );
    final Map<String, dynamic> body = _body(r);
    final dynamic item = body.containsKey('data') ? body['data'] : body;
    return AnswerModel.fromJson(item as Map<String, dynamic>);
  }
}

