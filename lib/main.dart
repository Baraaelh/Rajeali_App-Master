import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:rajeali_app/view/Screen/image_match_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rajeali_app/core/class/app_bindings.dart';
import 'package:rajeali_app/core/constant/app_constants.dart';
import 'package:rajeali_app/core/constant/app_routes.dart';
import 'package:rajeali_app/core/shared/app_theme.dart';
import 'package:rajeali_app/view/Screen/admin_screen.dart';
import 'package:rajeali_app/view/Screen/all_items_screen.dart';
import 'package:rajeali_app/view/Screen/chat_list_screen.dart';
import 'package:rajeali_app/view/Screen/chat_room_screen.dart';
import 'package:rajeali_app/view/Screen/forgot_password_screen.dart';
import 'package:rajeali_app/view/Screen/login_screen.dart';
import 'package:rajeali_app/view/Screen/notifications_screen.dart';
import 'package:rajeali_app/view/Screen/onboarding_screen.dart';
import 'package:rajeali_app/view/Screen/post_detail_screen.dart';
import 'package:rajeali_app/view/Screen/profile_screen.dart';
import 'package:rajeali_app/view/Screen/register_screen.dart';
import 'package:rajeali_app/view/Screen/report_found_screen.dart';
import 'package:rajeali_app/view/Screen/report_lost_screen.dart';
import 'package:rajeali_app/view/Screen/splash_screen.dart';
import 'package:rajeali_app/view/Screen/verification_screen.dart';
import 'package:rajeali_app/view/screens/main_navigation_screen.dart';

late final SharedPreferences sharedPrefs;

void main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Pre-initialize & cache SharedPreferences to avoid MissingPluginException on hot restart
  sharedPrefs = await SharedPreferences.getInstance();

  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      initialBinding: AppBindings(),
      locale: const Locale('ar', 'SA'),
      fallbackLocale: const Locale('ar', 'SA'),
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.onboarding,
      getPages: <GetPage<dynamic>>[
        GetPage<dynamic>(
          name: AppRoutes.splash,
          page: () => const SplashScreen(),
        ),
        GetPage<dynamic>(
          name: AppRoutes.onboarding,
          page: () => const OnboardingScreen(),
        ),
        GetPage<dynamic>(
          name: AppRoutes.register,
          page: () => const RegisterScreen(),
        ),
        GetPage<dynamic>(
          name: AppRoutes.login,
          page: () => const LoginScreen(),
        ),
        GetPage<dynamic>(
          name: AppRoutes.forgotPassword,
          page: () => const ForgotPasswordScreen(),
        ),
        GetPage<dynamic>(
          name: AppRoutes.home,
          page: () => const MainNavigationScreen(),
        ),
        GetPage<dynamic>(
          name: AppRoutes.allItems,
          page: () => const AllItemsScreen(),
        ),
        GetPage<dynamic>(
          name: AppRoutes.profile,
          page: () => const ProfileScreen(),
        ),
        GetPage<dynamic>(
          name: AppRoutes.reportLost,
          page: () => const ReportLostScreen(),
        ),
        GetPage<dynamic>(
          name: AppRoutes.reportFound,
          page: () => const ReportFoundScreen(),
        ),
        GetPage<dynamic>(
          name: AppRoutes.postDetail,
          page: () => const PostDetailScreen(),
        ),
        GetPage<dynamic>(
          name: AppRoutes.verification,
          page: () => const VerificationScreen(),
        ),
        GetPage<dynamic>(
          name: AppRoutes.chat,
          page: () => const ChatListScreen(),
        ),
        GetPage<dynamic>(
          name: AppRoutes.chatRoom,
          page: () => const ChatRoomScreen(),
        ),
        GetPage<dynamic>(
          name: AppRoutes.notifications,
          page: () => const NotificationsScreen(),
        ),
        GetPage<dynamic>(
          name: AppRoutes.admin,
          page: () => const AdminScreen(),
        ),
        GetPage(
          name: AppRoutes.imageMatch,
          page: () => const ImageMatchScreen(),
        ),
      ],
    );
  }
}
