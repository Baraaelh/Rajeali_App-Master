import 'package:get/get.dart';
import 'package:rajeali_app/controller/auth_controller.dart';
import 'package:rajeali_app/controller/chat_controller.dart';
import 'package:rajeali_app/controller/image_match_controller.dart';
import 'package:rajeali_app/controller/post_controller.dart';
import 'package:rajeali_app/controller/verification_controller.dart';
import 'package:rajeali_app/core/services/api_service.dart';
import 'package:rajeali_app/data/datasource/verification_datasource.dart';
import 'package:rajeali_app/data/repository/app_repository.dart';
import 'package:rajeali_app/main.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Core services
    Get.put<ApiService>(ApiService(prefs: sharedPrefs), permanent: true);
    Get.put<AppDataSource>(AppDataSource(), permanent: true);

    // Repository
    Get.put<AppRepository>(
      AppRepository(api: Get.find<ApiService>()),
      permanent: true,
    );

    // Controllers
    Get.put<AuthController>(
      AuthController(api: Get.find<ApiService>()),
      permanent: true,
    );
    Get.put<PostController>(
      PostController(
        repo: Get.find<AppRepository>(),
        api: Get.find<ApiService>(),
      ),
      permanent: true,
    );
    Get.put<VerificationController>(
      VerificationController(
        repo: Get.find<AppRepository>(),
        api: Get.find<ApiService>(),
      ),
      permanent: true,
    );
    Get.put<ChatController>(
      ChatController(ds: Get.find<AppDataSource>()),
      permanent: true,
    );

    Get.put<ImageMatchController>(
  ImageMatchController(api: Get.find<ApiService>()),
  permanent: true,
);
  }
}
