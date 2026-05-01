import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;
import 'package:image_picker/image_picker.dart';
import 'package:rajeali_app/core/constant/app_routes.dart';
import 'package:rajeali_app/core/services/api_service.dart';
import 'package:rajeali_app/core/shared/app_theme.dart';
import 'package:rajeali_app/data/model/image_match_model.dart';

/// حالات شاشة مقارنة الصور
enum ImageMatchState {
  idle,       // الشاشة الأولية
  uploading,  // جاري الرفع
  analyzing,  // الـ AI يحلل
  matched,    // وجد تطابق ✅
  notMatched, // لا تطابق ❌
  error,      // خطأ
}

class ImageMatchController extends GetxController {
  ImageMatchController({required ApiService api}) : _api = api;

  final ApiService _api;
  final ImagePicker _picker = ImagePicker();

  // ── State ──
  final Rx<ImageMatchState> state = ImageMatchState.idle.obs;
  final Rxn<XFile> pickedImage = Rxn<XFile>();
  final Rxn<ImageMatchModel> matchResult = Rxn<ImageMatchModel>();
  final RxString errorMessage = ''.obs;
  final RxDouble similarityScore = 0.0.obs;

  // ── إذا جاء من شاشة بلاغ معين ──
  int? targetLostItemId;   // لو الشخص الواجد يقارن مع بلاغ محدد
  int? targetFoundItemId;  // لو صاحب المفقود يقارن مع موجود محدد

  /// اختيار صورة من الجاليري أو الكاميرا
  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (image != null) {
        pickedImage.value = image;
        // إعادة الوضع للـ idle بعد الاختيار
        if (state.value != ImageMatchState.idle) {
          state.value = ImageMatchState.idle;
          matchResult.value = null;
        }
      }
    } catch (e) {
      debugPrint('pickImage error: $e');
    }
  }

  /// إرسال الصورة لـ API لمقارنتها مع قاعدة البيانات
  Future<void> analyzeImage() async {
    if (pickedImage.value == null) {
      Get.snackbar('تنبيه', 'اختر صورة أولاً',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          colorText: Colors.orange);
      return;
    }

    errorMessage.value = '';
    state.value = ImageMatchState.uploading;

    try {
      // بناء الـ FormData
      final FormData form = FormData.fromMap(<String, dynamic>{
        'image': await MultipartFile.fromFile(
          pickedImage.value!.path,
          filename: 'item_image.jpg',
        ),
        // إذا عندنا ID محدد نرسله
        if (targetLostItemId != null) 'lost_item_id': targetLostItemId,
        if (targetFoundItemId != null) 'found_item_id': targetFoundItemId,
      });

      state.value = ImageMatchState.analyzing;

      // ── استدعاء الـ endpoint ──
      // POST /api/v1/image-match
      final Response<dynamic> response =
          await _api.dio.post('/image-match', data: form);

      final Map<String, dynamic> body = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      final dynamic data =
          body.containsKey('data') ? body['data'] : body;

      final ImageMatchModel result =
          ImageMatchModel.fromJson(data as Map<String, dynamic>);

      matchResult.value = result;
      similarityScore.value = result.similarityScore;

      if (result.isMatch) {
        state.value = ImageMatchState.matched;
        // إذا رجع الـ API chat_room_id → افتح الشات مباشرة
        if (result.chatRoomId != null) {
          await _openChatAfterMatch(result);
        }
      } else {
        state.value = ImageMatchState.notMatched;
      }
    } on DioException catch (e) {
      errorMessage.value = _api.extractError(e);
      state.value = ImageMatchState.error;
    } catch (e) {
      errorMessage.value = 'حدث خطأ غير متوقع';
      state.value = ImageMatchState.error;
      debugPrint('analyzeImage error: $e');
    }
  }

  /// فتح الشات بعد التطابق
  Future<void> _openChatAfterMatch(ImageMatchModel result) async {
    // انتظر لحظة لعرض نتيجة التطابق قبل التنقل
    await Future<void>.delayed(const Duration(seconds: 2));
    Get.toNamed(
      AppRoutes.chatRoom,
      arguments: <String, dynamic>{
        'chat_room_id': result.chatRoomId,
        'lost_item_name': result.lostItemName,
        'found_item_name': result.foundItemName,
        'match_score': result.similarityScore,
        'from_image_match': true,
      },
    );
  }

  /// فتح الشات بعد التطابق يدوياً (لو ما انفتح تلقائي)
  void openMatchedChat() {
    final ImageMatchModel? result = matchResult.value;
    if (result?.chatRoomId != null) {
      Get.toNamed(
        AppRoutes.chatRoom,
        arguments: <String, dynamic>{
          'chat_room_id': result!.chatRoomId,
          'lost_item_name': result.lostItemName,
          'found_item_name': result.foundItemName,
          'match_score': result.similarityScore,
          'from_image_match': true,
        },
      );
    }
  }

  /// إعادة المحاولة
  void reset() {
    pickedImage.value = null;
    matchResult.value = null;
    errorMessage.value = '';
    similarityScore.value = 0.0;
    state.value = ImageMatchState.idle;
  }
}
