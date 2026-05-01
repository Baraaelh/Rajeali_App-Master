import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rajeali_app/controller/auth_controller.dart';
import 'package:rajeali_app/controller/post_controller.dart';
import 'package:rajeali_app/core/constant/app_routes.dart';
import 'package:rajeali_app/core/services/location_helper.dart';
import 'package:rajeali_app/core/shared/app_theme.dart';

class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RxBool obscurePass = true.obs;
    final RxBool obscureConfirm = true.obs;
    final TextEditingController confirmCtrl = TextEditingController();
    final RxInt currentStep = 0.obs;
    final Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // ── Header ──
            _buildHeader(size),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 28),
                  const Text(
                    'إنشاء حساب جديد ✨',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'أدخل بياناتك للتسجيل في تطبيق رجعلي',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Step indicator ──
                  Obx(() => _buildStepIndicator(currentStep.value)),
                  const SizedBox(height: 24),

                  // ── Step content ──
                  Obx(() {
                    if (currentStep.value == 0) {
                      return _buildStep1(obscurePass, obscureConfirm, confirmCtrl);
                    } else {
                      return _buildStep2();
                    }
                  }),

                  const SizedBox(height: 8),

                  // ── Error message ──
                  Obx(() {
                    if (controller.error.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.error_outline_rounded,
                              color: AppColors.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              controller.error.value,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // ── Action buttons ──
                  Obx(() {
                    if (currentStep.value == 0) {
                      return SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            controller.error.value = '';
                            // Validate step 1
                            if (controller.fullNameCtrl.text.trim().isEmpty) {
                              controller.error.value = 'يرجى إدخال الاسم الكامل';
                              return;
                            }
                            if (controller.emailCtrl.text.trim().isEmpty ||
                                !GetUtils.isEmail(controller.emailCtrl.text.trim())) {
                              controller.error.value = 'يرجى إدخال بريد إلكتروني صالح';
                              return;
                            }
                            if (controller.passwordCtrl.text.length < 6) {
                              controller.error.value = 'كلمة المرور يجب أن لا تقل عن 6 أحرف';
                              return;
                            }
                            if (controller.passwordCtrl.text != confirmCtrl.text) {
                              controller.error.value = 'كلمات المرور غير متطابقة';
                              return;
                            }
                            currentStep.value = 1;
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const <Widget>[
                              Text('التالي',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      );
                    }

                    // Step 2 buttons
                    return Column(
                      children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () async {
                                    controller.error.value = '';
                                    if (!RegExp(r'^\d{9}$')
                                        .hasMatch(controller.nationalIdCtrl.text.trim())) {
                                      controller.error.value =
                                          'رقم الهوية يجب أن يتكون من 9 أرقام';
                                      return;
                                    }
                                    if (controller.phoneCtrl.text.trim().isEmpty) {
                                      controller.error.value = 'يرجى إدخال رقم الهاتف';
                                      return;
                                    }
                                    if (controller.locationCtrl.text.trim().isEmpty) {
                                      controller.error.value = 'يرجى إدخال الموقع';
                                      return;
                                    }
                                    final bool ok = await controller.register();
                                    if (ok) {
                                      Get.find<PostController>().loadAllData();
                                      Get.offAllNamed(AppRoutes.home);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              disabledBackgroundColor:
                                  AppColors.primary.withValues(alpha: 0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text('إنشاء حساب',
                                    style:
                                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {
                              controller.error.value = '';
                              currentStep.value = 0;
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const <Widget>[
                                Icon(Icons.arrow_back_rounded,
                                    size: 20, color: AppColors.primary),
                                SizedBox(width: 8),
                                Text('السابق',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),

                  // ── Login link ──
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text(
                          'لديك حساب بالفعل؟  ',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: const Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader(Size size) {
    return ClipPath(
      clipper: _RegisterHeaderClipper(),
      child: Container(
        width: size.width,
        height: size.height * 0.22,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF1976D2),
              Color(0xFF0D47A1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: <Widget>[
                // Back button
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.white, size: 18),
                  ),
                ),
                const Spacer(),
                // Logo + text
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                ),
                const SizedBox(width: 12),
                const Text(
                  'رجعلي',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 40), // Balance the back button
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Step indicator ──
  Widget _buildStepIndicator(int step) {
    return Row(
      children: <Widget>[
        _stepDot(label: 'البيانات الأساسية', stepIndex: 0, current: step),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: step >= 1 ? AppColors.primary : AppColors.greyLight,
          ),
        ),
        _stepDot(label: 'معلومات إضافية', stepIndex: 1, current: step),
      ],
    );
  }

  Widget _stepDot({required String label, required int stepIndex, required int current}) {
    final bool isActive = current >= stepIndex;
    return Column(
      children: <Widget>[
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.greyLight,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isActive && current > stepIndex
                ? const Icon(Icons.check_rounded, color: AppColors.white, size: 18)
                : Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      color: isActive ? AppColors.white : AppColors.grey,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? AppColors.primary : AppColors.grey,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ── Step 1: Name, Email, Password ──
  Widget _buildStep1(
    RxBool obscurePass,
    RxBool obscureConfirm,
    TextEditingController confirmCtrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildLabel('الاسم الكامل'),
        const SizedBox(height: 8),
        TextField(
          controller: controller.fullNameCtrl,
          decoration: _inputDecoration(
            hint: 'أدخل اسمك الكامل',
            icon: Icons.person_rounded,
          ),
        ),
        const SizedBox(height: 18),

        _buildLabel('البريد الإلكتروني'),
        const SizedBox(height: 8),
        TextField(
          controller: controller.emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          decoration: _inputDecoration(
            hint: 'example@email.com',
            icon: Icons.alternate_email_rounded,
          ),
        ),
        const SizedBox(height: 18),

        _buildLabel('كلمة المرور'),
        const SizedBox(height: 8),
        Obx(() => TextField(
              controller: controller.passwordCtrl,
              obscureText: obscurePass.value,
              decoration: _inputDecoration(
                hint: '6 أحرف على الأقل',
                icon: Icons.lock_rounded,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePass.value ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: AppColors.grey,
                    size: 22,
                  ),
                  onPressed: () => obscurePass.toggle(),
                ),
              ),
            )),
        const SizedBox(height: 18),

        _buildLabel('تأكيد كلمة المرور'),
        const SizedBox(height: 8),
        Obx(() => TextField(
              controller: confirmCtrl,
              obscureText: obscureConfirm.value,
              decoration: _inputDecoration(
                hint: 'أعد إدخال كلمة المرور',
                icon: Icons.lock_outline_rounded,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirm.value
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.grey,
                    size: 22,
                  ),
                  onPressed: () => obscureConfirm.toggle(),
                ),
              ),
            )),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Step 2: National ID, Phone, Location ──
  Widget _buildStep2() {
    final RxBool locationLoading = false.obs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildLabel('رقم الهوية'),
        const SizedBox(height: 8),
        TextField(
          controller: controller.nationalIdCtrl,
          keyboardType: TextInputType.number,
          maxLength: 9,
          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
          decoration: _inputDecoration(
            hint: 'أدخل رقم الهوية (9 أرقام)',
            icon: Icons.badge_rounded,
          ).copyWith(counterText: ''),
        ),
        const SizedBox(height: 18),

        _buildLabel('رقم الهاتف'),
        const SizedBox(height: 8),
        TextField(
          controller: controller.phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: _inputDecoration(
            hint: '05XXXXXXXX',
            icon: Icons.phone_rounded,
          ),
        ),
        const SizedBox(height: 18),

        _buildLabel('الموقع'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            locationLoading.value = true;
            try {
              final result = await LocationHelper.getCurrentLocation();
              if (result != null) {
                controller.locationCtrl.text = result.name;
              }
            } finally {
              locationLoading.value = false;
            }
          },
          child: AbsorbPointer(
            child: Obx(() => TextField(
              controller: controller.locationCtrl,
              decoration: _inputDecoration(
                hint: locationLoading.value
                    ? 'جارٍ تحديد الموقع...'
                    : 'اضغط لتحديد موقعك تلقائياً',
                icon: Icons.my_location_rounded,
              ).copyWith(
                suffixIcon: locationLoading.value
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.gps_fixed_rounded,
                        color: AppColors.primary, size: 22),
              ),
            )),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.grey, size: 22),
      filled: true,
      fillColor: AppColors.greyLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

/// Custom clipper for the register header
class _RegisterHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path()
      ..lineTo(0, size.height - 30)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + 15,
        size.width,
        size.height - 30,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
