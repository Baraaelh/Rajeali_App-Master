import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rajeali_app/core/shared/app_theme.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailCtrl = TextEditingController();
    final RxBool sent = false.obs;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        title: const Text('استعادة كلمة المرور'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Obx(() => sent.value
            ? _successView(context, emailCtrl.text)
            : _formView(context, emailCtrl, sent)),
      ),
    );
  }

  Widget _formView(BuildContext context, TextEditingController emailCtrl, RxBool sent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'تغيير كلمة المرور',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'ادخل بريدك الالكتروني وسنرسل لك رابط لتغيير كلمة المرور',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'البريد الالكتروني',
            prefixIcon: Icon(Icons.email_outlined, color: AppColors.grey),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => sent.value = true,
          child: const Text('ارسال'),
        ),
      ],
    );
  }

  Widget _successView(BuildContext context, String email) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(Icons.mark_email_read_outlined, size: 80, color: AppColors.primary),
        const SizedBox(height: 24),
        const Text(
          'تحقق من بريدك الالكتروني',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'تم الارسال بنجاح الى $email',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text('العودة لتسجيل الدخول'),
        ),
      ],
    );
  }
}

