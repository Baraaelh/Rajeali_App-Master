import 'package:dio/dio.dart' as dio_lib;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rajeali_app/core/services/api_service.dart';
import 'package:rajeali_app/data/model/user_model.dart';

class AuthController extends GetxController {
  AuthController({required ApiService api}) : _api = api;

  final ApiService _api;

  // ── Text controllers ──
  final TextEditingController nationalIdCtrl = TextEditingController();
  final TextEditingController fullNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();
  final TextEditingController loginEmailCtrl = TextEditingController();
  final TextEditingController loginPasswordCtrl = TextEditingController();

  // ── Observables ──
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxString error = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool onboardingDone = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    onboardingDone.value = await _api.isOnboardingDone();
    // If we have a saved token, try to fetch user via GET /me
    if (await _api.hasToken()) {
      await fetchMe();
    }
  }

  // ── Onboarding ──
  Future<void> completeOnboarding() async {
    await _api.setOnboardingDone();
    onboardingDone.value = true;
  }

  // ── POST /register ──
  Future<bool> register() async {
    error.value = '';

    final String nationalId = nationalIdCtrl.text.trim();
    final String name = fullNameCtrl.text.trim();
    final String email = emailCtrl.text.trim();
    final String phone = phoneCtrl.text.trim();
    final String password = passwordCtrl.text;
    final String location = locationCtrl.text.trim();

    // Client-side validation
    if (nationalId.isEmpty || name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || location.isEmpty) {
      error.value = 'جميع الحقول مطلوبة';
      return false;
    }
    if (!RegExp(r'^\d{9}$').hasMatch(nationalId)) {
      error.value = 'رقم الهوية يجب أن يتكون من 9 أرقام بالضبط';
      return false;
    }
    if (!GetUtils.isEmail(email)) {
      error.value = 'يرجى إدخال بريد إلكتروني صالح';
      return false;
    }
    if (password.length < 6) {
      error.value = 'كلمة المرور يجب أن لا تقل عن 6 أحرف';
      return false;
    }

    isLoading.value = true;
    try {
      final dio_lib.Response<dynamic> response = await _api.dio.post(
        '/register',
        data: <String, dynamic>{
          'national_id': nationalId,
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'location': location,
        },
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      final String? token = _extractToken(body);
      if (token == null) {
        error.value = 'حدث خطأ في استجابة السيرفر';
        return false;
      }
      await _api.saveToken(token);

      final Map<String, dynamic>? userData = _extractUser(body);
      if (userData != null) {
        currentUser.value = UserModel.fromJson(userData);
      }

      _clearRegisterFields();
      return true;
    } on dio_lib.DioException catch (e) {
      error.value = _api.extractError(e);
      return false;
    } catch (e) {
      error.value = 'حدث خطأ غير متوقع';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── POST /login ──
  Future<bool> login() async {
    error.value = '';

    final String email = loginEmailCtrl.text.trim();
    final String password = loginPasswordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      error.value = 'البريد الإلكتروني وكلمة المرور مطلوبان';
      return false;
    }

    isLoading.value = true;
    try {
      final dio_lib.Response<dynamic> response = await _api.dio.post(
        '/login',
        data: <String, dynamic>{
          'email': email,
          'password': password,
        },
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      final String? token = _extractToken(body);
      if (token == null) {
        error.value = 'حدث خطأ في استجابة السيرفر';
        return false;
      }
      await _api.saveToken(token);

      final Map<String, dynamic>? userData = _extractUser(body);
      if (userData != null) {
        currentUser.value = UserModel.fromJson(userData);
      }

      loginEmailCtrl.clear();
      loginPasswordCtrl.clear();
      return true;
    } on dio_lib.DioException catch (e) {
      error.value = _api.extractError(e);
      return false;
    } catch (e) {
      error.value = 'حدث خطأ غير متوقع';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Extract token from various API response shapes
  String? _extractToken(Map<String, dynamic> body) {
    // Try: { "token": "..." }
    if (body['token'] is String) return body['token'] as String;
    // Try: { "access_token": "..." }
    if (body['access_token'] is String) return body['access_token'] as String;
    // Try: { "data": { "token": "..." } }
    if (body['data'] is Map) {
      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      if (data['token'] is String) return data['token'] as String;
      if (data['access_token'] is String) return data['access_token'] as String;
    }
    return null;
  }

  /// Extract user map from various API response shapes
  Map<String, dynamic>? _extractUser(Map<String, dynamic> body) {
    if (body['user'] is Map) return body['user'] as Map<String, dynamic>;
    if (body['data'] is Map) {
      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      if (data['user'] is Map) return data['user'] as Map<String, dynamic>;
    }
    return null;
  }

  // ── POST /logout 🔒 ──
  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _api.dio.post('/logout');
    } on dio_lib.DioException catch (_) {
      // Even if server fails, clear local session
    } finally {
      await _api.clearToken();
      currentUser.value = null;
      isLoading.value = false;
    }
  }

  // ── GET /me 🔒 ──
  Future<void> fetchMe() async {
    try {
      final dio_lib.Response<dynamic> response = await _api.dio.get('/me');
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      // API might return user directly or nested under 'user'
      final Map<String, dynamic> userData =
          body.containsKey('user') ? body['user'] as Map<String, dynamic> : body;

      currentUser.value = UserModel.fromJson(userData);
    } on dio_lib.DioException catch (_) {
      // Token expired or invalid — clear session
      await _api.clearToken();
      currentUser.value = null;
    }
  }

  bool get isLoggedIn => currentUser.value != null;

  void _clearRegisterFields() {
    nationalIdCtrl.clear();
    fullNameCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    passwordCtrl.clear();
    locationCtrl.clear();
  }

  @override
  void onClose() {
    nationalIdCtrl.dispose();
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    locationCtrl.dispose();
    loginEmailCtrl.dispose();
    loginPasswordCtrl.dispose();
    super.onClose();
  }
}
