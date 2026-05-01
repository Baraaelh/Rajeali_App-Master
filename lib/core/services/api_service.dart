import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  ApiService({required SharedPreferences prefs}) : _prefs = prefs {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
        final String? token = await getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException e, ErrorInterceptorHandler handler) {
        handler.next(e);
      },
    ));
  }

  static const String baseUrl = 'https://rajeali.kulshy.online/api/v1';
  late final Dio _dio;
  final SharedPreferences _prefs;

  Dio get dio => _dio;

  // ── Token management ──
  static const String _tokenKey = 'auth_token';

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }

  Future<bool> hasToken() async {
    final String? token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Onboarding flag ──
  static const String _onboardingKey = 'onboarding_done';

  Future<bool> isOnboardingDone() async {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingDone() async {
    await _prefs.setBool(_onboardingKey, true);
  }

  // ── Generic error extractor ──
  String extractError(DioException e) {
    if (e.response?.data is Map) {
      final Map<String, dynamic> data = e.response!.data as Map<String, dynamic>;
      // Try common Laravel error shapes
      if (data.containsKey('message')) {
        return data['message'] as String;
      }
      if (data.containsKey('errors')) {
        final Map<String, dynamic> errors = data['errors'] as Map<String, dynamic>;
        final StringBuffer sb = StringBuffer();
        errors.forEach((String key, dynamic value) {
          if (value is List) {
            sb.writeln(value.first);
          }
        });
        return sb.toString().trim();
      }
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة الاتصال. تحقق من الإنترنت';
      case DioExceptionType.connectionError:
        return 'لا يوجد اتصال بالإنترنت';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}

