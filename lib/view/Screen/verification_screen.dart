import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rajeali_app/controller/verification_controller.dart';
import 'package:rajeali_app/core/shared/app_theme.dart';
import 'package:rajeali_app/data/model/found_item_model.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FoundItemModel foundItem = Get.arguments as FoundItemModel;
    final VerificationController ctrl = Get.find<VerificationController>();

    // Load questions when screen opens
    ctrl.selectFoundItem(foundItem);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('التحقق من الملكية',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: Obx(() {
        if (ctrl.isLoadingQuestions.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'أجب على الأسئلة التالية بدقة للتحقق من ملكيتك للغرض.\nسيتم مراجعة إجاباتك من قبل الواجد.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
                ),
              ),
              const SizedBox(height: 24),

              // Questions
              if (ctrl.questions.isEmpty)
                const Center(child: Text('لا توجد أسئلة لهذا الغرض',
                    style: TextStyle(color: AppColors.textSecondary)))
              else
                for (int i = 0; i < ctrl.questions.length && i < 3; i++) ...<Widget>[
                  _buildQuestionCard(
                    index: i + 1,
                    question: ctrl.questions[i].questionText,
                    controller: i == 0 ? ctrl.ans1Ctrl : i == 1 ? ctrl.ans2Ctrl : ctrl.ans3Ctrl,
                  ),
                  const SizedBox(height: 14),
                ],

              const SizedBox(height: 8),

              // Error
              if (ctrl.error.value.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Text(ctrl.error.value,
                      style: const TextStyle(color: AppColors.error, fontSize: 13)),
                ),

              // Success
              if (ctrl.verificationPassed.value)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: const <Widget>[
                      Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
                      SizedBox(height: 12),
                      Text('تم إرسال إجاباتك بنجاح!',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.success)),
                      SizedBox(height: 4),
                      Text('في انتظار مراجعة المالك',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),

              if (!ctrl.verificationPassed.value && ctrl.questions.isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 54,
                  child: ElevatedButton(
                    onPressed: ctrl.isVerifying.value ? null : () async {
                      await ctrl.submitVerification(foundItemUserId: foundItem.userId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: ctrl.isVerifying.value
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text('إرسال الإجابات',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildQuestionCard({
    required int index,
    required String question,
    required TextEditingController controller,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('$index',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(question,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'إجابتك هنا...',
              filled: true, fillColor: AppColors.greyLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

