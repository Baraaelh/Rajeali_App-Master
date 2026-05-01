import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rajeali_app/controller/post_controller.dart';
import 'package:rajeali_app/core/services/location_helper.dart';
import 'package:rajeali_app/core/shared/app_theme.dart';
import 'package:rajeali_app/data/model/category_model.dart';

class ReportLostScreen extends StatelessWidget {
  const ReportLostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PostController ctrl = Get.find<PostController>();
    final RxBool isLocating = false.obs;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('الإبلاغ عن شيء مفقود',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Info banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.info_outline_rounded, color: AppColors.error.withValues(alpha: 0.7), size: 22),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('أدخل تفاصيل دقيقة لمساعدتنا في إيجاد الغرض المفقود',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Title
            _buildLabel('اسم الغرض المفقود'),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl.lostTitleCtrl,
              decoration: _inputDecoration(hint: 'مثال: هاتف آيفون 15 أسود', icon: Icons.title_rounded),
            ),
            const SizedBox(height: 20),

            // Category from API
            _buildLabel('نوع الغرض'),
            const SizedBox(height: 8),
            Obx(() {
              if (ctrl.categoriesLoading.value) {
                return const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)));
              }
              return Wrap(
                spacing: 8, runSpacing: 8,
                children: ctrl.categories.map((CategoryModel cat) {
                  final bool isSelected = ctrl.lostCategory.value?.id == cat.id;
                  return GestureDetector(
                    onTap: () => ctrl.lostCategory.value = cat,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
                      ),
                      child: Text(cat.name,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                              color: isSelected ? AppColors.white : AppColors.textSecondary)),
                    ),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 20),

            // Description
            _buildLabel('وصف تفصيلي'),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl.lostDescCtrl,
              maxLines: 4, maxLength: 500,
              decoration: _inputDecoration(hint: 'صف الغرض بالتفصيل... (10 أحرف على الأقل)', icon: Icons.description_rounded)
                  .copyWith(counterStyle: const TextStyle(fontSize: 11, color: AppColors.grey)),
            ),
            const SizedBox(height: 12),

            // Image picker
            _buildLabel('صورة الغرض (اختياري)'),
            const SizedBox(height: 8),
            Obx(() => GestureDetector(
                  onTap: () => ctrl.pickImage(isLost: true),
                  child: Container(
                    width: double.infinity, height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.greyLight, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                    ),
                    child: ctrl.lostImage.value != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(File(ctrl.lostImage.value!.path), fit: BoxFit.cover, width: double.infinity),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const <Widget>[
                              Icon(Icons.add_photo_alternate_rounded, size: 36, color: AppColors.grey),
                              SizedBox(height: 8),
                              Text('اضغط لاختيار صورة', style: TextStyle(fontSize: 13, color: AppColors.grey)),
                            ],
                          ),
                  ),
                )),
            const SizedBox(height: 20),

            // Location
            _buildLabel('موقع الفقدان'),
            const SizedBox(height: 8),
            Obx(() => GestureDetector(
                  onTap: isLocating.value ? null : () async {
                    isLocating.value = true;
                    final result = await LocationHelper.getCurrentLocation();
                    if (result != null) {
                      ctrl.lostLocationCtrl.text = result.name;
                      ctrl.lostLatCtrl.text = result.lat.toString();
                      ctrl.lostLngCtrl.text = result.lng.toString();
                    }
                    isLocating.value = false;
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: ctrl.lostLocationCtrl,
                      decoration: _inputDecoration(hint: 'اضغط لتحديد موقعك تلقائياً', icon: Icons.location_on_rounded).copyWith(
                        suffixIcon: isLocating.value
                            ? const Padding(padding: EdgeInsets.all(14),
                                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)))
                            : const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 22),
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 20),

            // Date
            _buildLabel('تاريخ الفقدان'),
            const SizedBox(height: 8),
            Obx(() => GestureDetector(
                  onTap: () async {
                    final DateTime? d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
                    if (d != null) ctrl.lostDate.value = d;
                  },
                  child: Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(color: AppColors.greyLight, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.calendar_month_rounded, color: AppColors.grey, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          ctrl.lostDate.value != null
                              ? '${ctrl.lostDate.value!.year}/${ctrl.lostDate.value!.month}/${ctrl.lostDate.value!.day}'
                              : 'اختر التاريخ',
                          style: TextStyle(fontSize: 14, color: ctrl.lostDate.value != null ? AppColors.textPrimary : AppColors.grey),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down_rounded, color: AppColors.grey),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 24),

            // Error
            Obx(() {
              if (ctrl.error.value.isEmpty) return const SizedBox.shrink();
              return Container(
                width: double.infinity, margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3))),
                child: Row(children: <Widget>[
                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(ctrl.error.value, style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w500))),
                ]),
              );
            }),

            // Submit
            Obx(() => SizedBox(
                  width: double.infinity, height: 54,
                  child: ElevatedButton.icon(
                    onPressed: ctrl.isSubmitting.value ? null : () async {
                      final bool ok = await ctrl.createLostItem();
                      if (ok) {
                        Get.back();
                        Get.snackbar('تم بنجاح ✅', 'تم نشر بلاغ المفقود بنجاح',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.success.withValues(alpha: 0.1),
                            colorText: AppColors.success);
                      }
                    },
                    icon: ctrl.isSubmitting.value
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded, size: 20),
                    label: Text(ctrl.isSubmitting.value ? 'جاري النشر...' : 'نشر البلاغ',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error, foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary));

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint, prefixIcon: Icon(icon, color: AppColors.grey, size: 22),
      filled: true, fillColor: AppColors.greyLight,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

