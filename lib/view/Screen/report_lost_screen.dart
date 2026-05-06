import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      backgroundColor: const Color(0xFFFFF5F5),
      body: Column(
        children: <Widget>[
          // ── Header ──
          _buildHeader(context),

          // ── Form ──
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // ── Steps indicator ──
                  _StepsIndicator(),
                  const SizedBox(height: 24),

                  // ── اسم الغرض ──
                  _SectionCard(
                    icon: Icons.title_rounded,
                    title: 'اسم الغرض المفقود',
                    color: const Color(0xFFE53935),
                    child: TextField(
                      controller: ctrl.lostTitleCtrl,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: _inputDeco(
                        hint: 'مثال: هاتف آيفون 15 أسود',
                        icon: Icons.title_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── التصنيف ──
                  _SectionCard(
                    icon: Icons.category_rounded,
                    title: 'نوع الغرض',
                    color: const Color(0xFFE53935),
                    child: Obx(() {
                      if (ctrl.categoriesLoading.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFE53935),
                            ),
                          ),
                        );
                      }
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ctrl.categories.map((CategoryModel cat) {
                          final bool sel =
                              ctrl.lostCategory.value?.id == cat.id;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              ctrl.lostCategory.value = cat;
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: sel
                                    ? const Color(0xFFE53935)
                                    : const Color(0xFFFFF5F5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: sel
                                      ? const Color(0xFFE53935)
                                      : Colors.grey.shade300,
                                  width: sel ? 1.5 : 1,
                                ),
                                boxShadow: sel
                                    ? <BoxShadow>[
                                        BoxShadow(
                                          color: const Color(
                                            0xFFE53935,
                                          ).withValues(alpha: 0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                cat.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: sel
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),

                  // ── الوصف ──
                  _SectionCard(
                    icon: Icons.description_rounded,
                    title: 'وصف تفصيلي',
                    color: const Color(0xFFE53935),
                    child: TextField(
                      controller: ctrl.lostDescCtrl,
                      maxLines: 4,
                      maxLength: 500,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration:
                          _inputDeco(
                            hint:
                                'صف الغرض بالتفصيل... اللون، الحجم، المميزات...',
                            icon: Icons.description_rounded,
                          ).copyWith(
                            counterStyle: const TextStyle(
                              fontSize: 11,
                              color: AppColors.grey,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── الصورة ──
                  _SectionCard(
                    icon: Icons.photo_camera_rounded,
                    title: 'صورة الغرض (اختياري)',
                    color: const Color(0xFFE53935),
                    child: Obx(
                      () => GestureDetector(
                        onTap: () => ctrl.pickImage(isLost: true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 130,
                          decoration: BoxDecoration(
                            color: ctrl.lostImage.value != null
                                ? Colors.transparent
                                : const Color(0xFFFFF5F5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: ctrl.lostImage.value != null
                                  ? const Color(
                                      0xFFE53935,
                                    ).withValues(alpha: 0.4)
                                  : Colors.grey.shade200,
                              width: ctrl.lostImage.value != null ? 2 : 1,
                              style: ctrl.lostImage.value != null
                                  ? BorderStyle.solid
                                  : BorderStyle.solid,
                            ),
                          ),
                          child: ctrl.lostImage.value != null
                              ? Stack(
                                  children: <Widget>[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(ctrl.lostImage.value!.path),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE53935),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                              Icons.edit_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'تغيير',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFE53935,
                                        ).withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add_photo_alternate_rounded,
                                        size: 28,
                                        color: Color(0xFFE53935),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'اضغط لإضافة صورة',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── الموقع ──
                  _SectionCard(
                    icon: Icons.location_on_rounded,
                    title: 'موقع الفقدان',
                    color: const Color(0xFFE53935),
                    child: Obx(
                      () => GestureDetector(
                        onTap: isLocating.value
                            ? null
                            : () async {
                                isLocating.value = true;
                                final result =
                                    await LocationHelper.getCurrentLocation();
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
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration:
                                _inputDeco(
                                  hint: 'اضغط لتحديد موقعك تلقائياً',
                                  icon: Icons.location_on_rounded,
                                ).copyWith(
                                  suffixIcon: isLocating.value
                                      ? const Padding(
                                          padding: EdgeInsets.all(14),
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFFE53935),
                                            ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.my_location_rounded,
                                          color: Color(0xFFE53935),
                                          size: 22,
                                        ),
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── التاريخ ──
                  _SectionCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'تاريخ الفقدان',
                    color: const Color(0xFFE53935),
                    child: Obx(
                      () => GestureDetector(
                        onTap: () async {
                          final DateTime? d = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            builder: (BuildContext ctx, Widget? child) => Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFFE53935),
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (d != null) ctrl.lostDate.value = d;
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5F5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: ctrl.lostDate.value != null
                                  ? const Color(
                                      0xFFE53935,
                                    ).withValues(alpha: 0.4)
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.calendar_month_rounded,
                                color: ctrl.lostDate.value != null
                                    ? const Color(0xFFE53935)
                                    : AppColors.grey,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                ctrl.lostDate.value != null
                                    ? '${ctrl.lostDate.value!.year}/${ctrl.lostDate.value!.month.toString().padLeft(2, '0')}/${ctrl.lostDate.value!.day.toString().padLeft(2, '0')}'
                                    : 'اختر تاريخ الفقدان',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: ctrl.lostDate.value != null
                                      ? AppColors.textPrimary
                                      : AppColors.grey,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_drop_down_rounded,
                                color: ctrl.lostDate.value != null
                                    ? const Color(0xFFE53935)
                                    : AppColors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Error ──
                  Obx(() {
                    if (ctrl.error.value.isEmpty)
                      return const SizedBox.shrink();
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              ctrl.error.value,
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

                  // ── Submit ──
                  Obx(
                    () => _SubmitButton(
                      isLoading: ctrl.isSubmitting.value,
                      onTap: () async {
                        HapticFeedback.mediumImpact();
                        final bool ok = await ctrl.createLostItem();
                        if (ok) {
                          Get.back();
                          Get.snackbar(
                            'تم بنجاح ✅',
                            'تم نشر بلاغ المفقود بنجاح',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.success.withValues(
                              alpha: 0.1,
                            ),
                            colorText: AppColors.success,
                            borderRadius: 14,
                            margin: const EdgeInsets.all(16),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFB71C1C),
            Color(0xFFE53935),
            Color(0xFFEF5350),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 20, 20),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Get.back(),
              ),
              const SizedBox(width: 4),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'الإبلاغ عن مفقود',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'أدخل تفاصيل الغرض للبحث عنه',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static InputDecoration _inputDeco({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.grey, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
      filled: true,
      fillColor: const Color(0xFFFFF5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

// ─────────────────────────────────────────
// Steps Indicator
// ─────────────────────────────────────────
class _StepsIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFE53935),
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'أدخل تفاصيل دقيقة لمساعدتنا في إيجاد الغرض المفقود',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Section Card
// ─────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Submit Button
// ─────────────────────────────────────────
class _SubmitButton extends StatefulWidget {
  const _SubmitButton({required this.isLoading, required this.onTap});
  final bool isLoading;
  final VoidCallback onTap;

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => !widget.isLoading ? _ctrl.forward() : null,
      onTapUp: (_) {
        _ctrl.reverse();
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFFB71C1C), Color(0xFFE53935)],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFFE53935).withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'نشر البلاغ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
