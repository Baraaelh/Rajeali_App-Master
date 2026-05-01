import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rajeali_app/core/shared/app_theme.dart';
import 'package:rajeali_app/data/datasource/verification_datasource.dart';
import 'package:rajeali_app/data/model/user_model.dart';
import 'package:rajeali_app/data/model/verification_attempt_model.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppDataSource ds = Get.find<AppDataSource>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'لوحة التحكم',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── Stats cards ──
            Row(
              children: <Widget>[
                _StatCard(
                  icon: Icons.people_rounded,
                  label: 'المستخدمين',
                  value: '${ds.allUsers.length}',
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  icon: Icons.article_rounded,
                  label: 'البلاغات',
                  value: '${ds.allPosts.length}',
                  color: AppColors.success,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  icon: Icons.verified_user_rounded,
                  label: 'المحاولات',
                  value: '${ds.allAttempts.length}',
                  color: const Color(0xFFFF9800),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── AI Settings ──
            const Text(
              'إعدادات الذكاء الاصطناعي',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: <Widget>[
                  _ThresholdSlider(
                    icon: Icons.psychology_rounded,
                    label: 'عتبة التحقق من الملكية',
                    value: ds.aiThreshold,
                    min: 0.60,
                    max: 0.85,
                    color: AppColors.primary,
                    onChanged: (double v) => ds.aiThreshold = v,
                  ),
                  const SizedBox(height: 20),
                  _ThresholdSlider(
                    icon: Icons.compare_arrows_rounded,
                    label: 'عتبة إشعارات المطابقة',
                    value: ds.matchingThreshold,
                    min: 0.50,
                    max: 0.75,
                    color: AppColors.success,
                    onChanged: (double v) => ds.matchingThreshold = v,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Users ──
            const Text(
              'إدارة المستخدمين',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            if (ds.allUsers.isEmpty)
              _emptyCard('لا يوجد مستخدمين حالياً', Icons.people_outline_rounded)
            else
              ...ds.allUsers.map((UserModel u) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                u.name.isNotEmpty ? u.name[0] : '?',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(u.name,
                                    style: const TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w600)),
                                Text(u.email,
                                    style: const TextStyle(
                                        fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'نشط',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            const SizedBox(height: 28),

            // ── Verification logs ──
            const Text(
              'سجلات التحقق',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            if (ds.allAttempts.isEmpty)
              _emptyCard('لا توجد محاولات تحقق', Icons.history_rounded)
            else
              ...ds.allAttempts.take(20).map((VerificationAttemptModel a) {
                final double pct = a.averageScore * 100;
                final Color scoreColor = pct >= 70
                    ? AppColors.success
                    : pct >= 50
                        ? const Color(0xFFFF9800)
                        : AppColors.error;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: scoreColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            pct >= 70 ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: scoreColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                a.resultLabel,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'بلاغ: #${a.postId.substring(0, 6)}',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: scoreColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${pct.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: scoreColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard(String msg, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 36, color: AppColors.grey),
          const SizedBox(height: 8),
          Text(msg, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThresholdSlider extends StatefulWidget {
  const _ThresholdSlider({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  State<_ThresholdSlider> createState() => _ThresholdSliderState();
}

class _ThresholdSliderState extends State<_ThresholdSlider> {
  late double _current;

  @override
  void initState() {
    super.initState();
    _current = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(widget.icon, color: widget.color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(_current * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: widget.color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: widget.color,
            inactiveTrackColor: widget.color.withValues(alpha: 0.15),
            thumbColor: widget.color,
            overlayColor: widget.color.withValues(alpha: 0.1),
            trackHeight: 4,
          ),
          child: Slider(
            value: _current,
            min: widget.min,
            max: widget.max,
            divisions: ((widget.max - widget.min) * 100).round(),
            onChanged: (double v) {
              setState(() => _current = v);
              widget.onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}
