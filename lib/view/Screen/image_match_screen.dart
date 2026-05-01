import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rajeali_app/controller/image_match_controller.dart';
import 'package:rajeali_app/core/shared/app_theme.dart';
import 'package:rajeali_app/data/model/image_match_model.dart';

/// شاشة مقارنة الصور بالـ AI
/// تُفتح من زر في شاشة Home أو من صفحة التفاصيل
class ImageMatchScreen extends StatelessWidget {
  const ImageMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ImageMatchController ctrl = Get.find<ImageMatchController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'مطابقة الصور بالذكاء الاصطناعي',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        final ImageMatchState state = ctrl.state.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ── Banner ──
              _InfoBanner(state: state),
              const SizedBox(height: 24),

              // ── Image Picker ──
              _buildLabel('صورة الغرض'),
              const SizedBox(height: 10),
              _ImagePickerCard(ctrl: ctrl),
              const SizedBox(height: 28),

              // ── Result Card ──
              if (state == ImageMatchState.matched ||
                  state == ImageMatchState.notMatched)
                _ResultCard(ctrl: ctrl),

              // ── Error ──
              if (state == ImageMatchState.error)
                _ErrorCard(message: ctrl.errorMessage.value),

              const SizedBox(height: 8),

              // ── Analyze Button ──
              if (state != ImageMatchState.matched)
                _AnalyzeButton(ctrl: ctrl, state: state),

              // ── Reset Button ──
              if (state == ImageMatchState.matched ||
                  state == ImageMatchState.notMatched ||
                  state == ImageMatchState.error) ...<Widget>[
                const SizedBox(height: 12),
                _ResetButton(ctrl: ctrl),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
      );
}

// ─────────────────────────────────────────
// ① Banner بناءً على الحالة
// ─────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.state});
  final ImageMatchState state;

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;
    IconData icon;

    switch (state) {
      case ImageMatchState.uploading:
        text = 'جاري رفع الصورة...';
        color = AppColors.primary;
        icon = Icons.cloud_upload_rounded;
        break;
      case ImageMatchState.analyzing:
        text = 'الذكاء الاصطناعي يحلل الصورة ويبحث عن تطابق...';
        color = Colors.purple;
        icon = Icons.psychology_rounded;
        break;
      case ImageMatchState.matched:
        text = 'تم إيجاد تطابق! سيتم فتح المحادثة قريباً 🎉';
        color = AppColors.success;
        icon = Icons.check_circle_rounded;
        break;
      case ImageMatchState.notMatched:
        text = 'لم يتم إيجاد تطابق. حاول برفع صورة أوضح.';
        color = AppColors.error;
        icon = Icons.search_off_rounded;
        break;
      case ImageMatchState.error:
        text = 'حدث خطأ. تحقق من اتصالك بالإنترنت.';
        color = AppColors.error;
        icon = Icons.error_outline_rounded;
        break;
      default:
        text = 'ارفع صورة الغرض وسيقوم الذكاء الاصطناعي بالبحث عن تطابق تلقائياً';
        color = AppColors.primary;
        icon = Icons.tips_and_updates_rounded;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 13, color: color, fontWeight: FontWeight.w500, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// ② بطاقة اختيار الصورة
// ─────────────────────────────────────────
class _ImagePickerCard extends StatelessWidget {
  const _ImagePickerCard({required this.ctrl});
  final ImageMatchController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool hasImage = ctrl.pickedImage.value != null;
      final bool isLoading = ctrl.state.value == ImageMatchState.uploading ||
          ctrl.state.value == ImageMatchState.analyzing;

      return Column(
        children: <Widget>[
          // صورة معاينة
          GestureDetector(
            onTap: isLoading ? null : () => _showPickerOptions(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: hasImage
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : Colors.grey.shade300,
                  width: hasImage ? 2 : 1,
                ),
              ),
              child: hasImage
                  ? Stack(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(ctrl.pickedImage.value!.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        // Loading overlay
                        if (isLoading)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 3),
                                  SizedBox(height: 14),
                                  Text('جاري التحليل...',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        // Change photo button
                        if (!isLoading)
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () => _showPickerOptions(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(Icons.edit_rounded,
                                        color: Colors.white, size: 16),
                                    SizedBox(width: 6),
                                    Text('تغيير',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_photo_alternate_rounded,
                              size: 38, color: AppColors.primary),
                        ),
                        const SizedBox(height: 14),
                        const Text('اضغط لإضافة صورة الغرض',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        const Text('يدعم صور الكاميرا والجاليري',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
            ),
          ),

          // أزرار الكاميرا والجاليري
          if (!hasImage && !isLoading) ...<Widget>[
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: _SourceButton(
                    icon: Icons.photo_library_rounded,
                    label: 'الجاليري',
                    onTap: () => ctrl.pickImage(source: ImageSource.gallery),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SourceButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'الكاميرا',
                    onTap: () => ctrl.pickImage(source: ImageSource.camera),
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Text('اختر مصدر الصورة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.photo_library_rounded,
                      label: 'الجاليري',
                      onTap: () {
                        Navigator.pop(context);
                        ctrl.pickImage(source: ImageSource.gallery);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'الكاميرا',
                      onTap: () {
                        Navigator.pop(context);
                        ctrl.pickImage(source: ImageSource.camera);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// ③ بطاقة النتيجة
// ─────────────────────────────────────────
class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.ctrl});
  final ImageMatchController ctrl;

  @override
  Widget build(BuildContext context) {
    final ImageMatchModel? result = ctrl.matchResult.value;
    final bool isMatch = ctrl.state.value == ImageMatchState.matched;
    final double score = ctrl.similarityScore.value;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: 1,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isMatch
              ? AppColors.success.withValues(alpha: 0.06)
              : AppColors.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isMatch
                ? AppColors.success.withValues(alpha: 0.3)
                : AppColors.error.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: <Widget>[
            // أيقونة النتيجة
            Icon(
              isMatch
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: isMatch ? AppColors.success : AppColors.error,
              size: 52,
            ),
            const SizedBox(height: 12),

            Text(
              isMatch ? 'تم إيجاد تطابق! 🎉' : 'لم يتم إيجاد تطابق',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isMatch ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: 8),

            // نسبة التشابه
            Text(
              'نسبة التشابه: ${(score * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),

            // Progress bar للنسبة
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: score,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                    isMatch ? AppColors.success : AppColors.error),
              ),
            ),

            // تفاصيل الغرضين إذا في نتيجة
            if (isMatch && result != null) ...<Widget>[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _ItemMiniCard(
                      label: 'المفقود',
                      name: result.lostItemName ?? '',
                      imageUrl: result.lostImageUrl,
                      color: AppColors.error,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.compare_arrows_rounded,
                        color: AppColors.success, size: 30),
                  ),
                  Expanded(
                    child: _ItemMiniCard(
                      label: 'الموجود',
                      name: result.foundItemName ?? '',
                      imageUrl: result.foundImageUrl,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // زر فتح الشات لو مش بيفتح تلقائي
              if (result.chatRoomId != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => ctrl.openMatchedChat(),
                    icon: const Icon(Icons.chat_rounded, size: 20),
                    label: const Text('فتح المحادثة',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// ④ Mini card لعرض الغرض في النتيجة
// ─────────────────────────────────────────
class _ItemMiniCard extends StatelessWidget {
  const _ItemMiniCard({
    required this.label,
    required this.name,
    required this.color,
    this.imageUrl,
  });
  final String label;
  final String name;
  final String? imageUrl;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
            color: AppColors.greyLight,
          ),
          child: imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                          Icons.image_not_supported_rounded,
                          color: AppColors.grey)),
                )
              : Icon(Icons.image_rounded, color: AppColors.grey, size: 30),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ),
        const SizedBox(height: 4),
        Text(name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

// ─────────────────────────────────────────
// ⑤ بطاقة الخطأ
// ─────────────────────────────────────────
class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// ⑥ زر التحليل الرئيسي
// ─────────────────────────────────────────
class _AnalyzeButton extends StatelessWidget {
  const _AnalyzeButton({required this.ctrl, required this.state});
  final ImageMatchController ctrl;
  final ImageMatchState state;

  @override
  Widget build(BuildContext context) {
    final bool isLoading = state == ImageMatchState.uploading ||
        state == ImageMatchState.analyzing;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : ctrl.analyzeImage,
        icon: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : const Icon(Icons.image_search_rounded, size: 22),
        label: Text(
          isLoading
              ? (state == ImageMatchState.uploading
                  ? 'جاري الرفع...'
                  : 'جاري التحليل...')
              : 'بحث بالصورة',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// ⑦ زر إعادة المحاولة
// ─────────────────────────────────────────
class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.ctrl});
  final ImageMatchController ctrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: ctrl.reset,
        icon: const Icon(Icons.refresh_rounded, size: 20),
        label: const Text('إعادة المحاولة',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// ⑧ زر المصدر (كاميرا / جاليري)
// ─────────────────────────────────────────
class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
