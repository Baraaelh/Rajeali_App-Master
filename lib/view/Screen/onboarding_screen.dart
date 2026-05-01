import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rajeali_app/controller/auth_controller.dart';import 'package:rajeali_app/controller/post_controller.dart';
import 'package:rajeali_app/core/constant/app_routes.dart';

class OnboardingScreen extends GetView<AuthController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.onboardingDone.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.isLoggedIn) {
          Get.find<PostController>().loadAllData();
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.offAllNamed(AppRoutes.login);
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final PageController pageCtrl = PageController();
    final RxInt currentPage = 0.obs;

    final List<_OnboardingData> pages = <_OnboardingData>[
      const _OnboardingData(
        image: 'assets/images/onboarding1.png',
        title: 'فقدت شيئاً؟',
        subtitle: 'أبلغ عن مفقوداتك وسنساعدك في العثور عليها بذكاء اصطناعي متقدم',
      ),
      const _OnboardingData(
        image: 'assets/images/onboarding2.png',
        title: 'وجدت شيئاً؟',
        subtitle: 'ساعد الآخرين في استرداد ممتلكاتهم بأمان وموثوقية عبر نظام التحقق الذكي',
      ),
      const _OnboardingData(
        image: 'assets/images/onboarding3.png',
        title: 'قريب منك',
        subtitle: 'اكتشف المفقودات والموجودات القريبة من موقعك واستردّ أغراضك بسرعة',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Skip button
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                child: TextButton(
                  onPressed: () async {
                    await controller.completeOnboarding();
                    Get.offAllNamed(AppRoutes.login);
                  },
                  child: const Text('تخطي', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),

            // PageView with images
            Expanded(
              child: PageView.builder(
                controller: pageCtrl,
                itemCount: pages.length,
                onPageChanged: (int i) => currentPage.value = i,
                itemBuilder: (BuildContext context, int i) {
                  final _OnboardingData data = pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Onboarding image — constrained for proper sizing
                        Flexible(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Image.asset(
                              data.image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          data.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          data.subtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                        ),
                        const Spacer(flex: 1),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots indicator
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(pages.length, (int i) {
                    final bool active = currentPage.value == i;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                )),
            const SizedBox(height: 28),

            // Next / Start button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Obx(() => FilledButton(
                    onPressed: () async {
                      if (currentPage.value < pages.length - 1) {
                        pageCtrl.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        await controller.completeOnboarding();
                        Get.offAllNamed(AppRoutes.login);
                      }
                    },
                    child: Text(
                      currentPage.value < pages.length - 1
                          ? 'التالي'
                          : 'ابدأ الآن',
                      style: const TextStyle(fontSize: 16),
                    ),
                  )),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final String image;
  final String title;
  final String subtitle;
}

