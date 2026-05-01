import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rajeali_app/controller/auth_controller.dart';
import 'package:rajeali_app/core/constant/app_routes.dart';
import 'package:rajeali_app/core/shared/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        final user = auth.currentUser.value;
        if (user == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.greyLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_off_rounded,
                        size: 40, color: AppColors.grey),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'لم يتم تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Get.offAllNamed(AppRoutes.login),
                      child: const Text('تسجيل الدخول'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => auth.fetchMe(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: <Widget>[
                // ── Profile header ──
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[Color(0xFF1976D2), Color(0xFF0D47A1)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                      child: Column(
                        children: <Widget>[
                          // Title row
                          Row(
                            children: <Widget>[
                              const Expanded(
                                child: Text(
                                  'حسابي',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                              // Admin button (if applicable)
                              GestureDetector(
                                onTap: () => Get.toNamed(AppRoutes.admin),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.settings_rounded,
                                      color: AppColors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Avatar
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                user.name.isNotEmpty ? user.name[0] : '?',
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          if (user.createdAt != null) ...<Widget>[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'عضو منذ ${user.createdAt!.year}/${user.createdAt!.month}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Info cards ──
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'المعلومات الشخصية',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          children: <Widget>[
                            _ProfileInfoTile(
                              icon: Icons.person_rounded,
                              label: 'الاسم',
                              value: user.name,
                              color: AppColors.primary,
                            ),
                            _divider(),
                            _ProfileInfoTile(
                              icon: Icons.alternate_email_rounded,
                              label: 'البريد',
                              value: user.email,
                              color: Color(0xFFFF9800),
                            ),
                            _divider(),
                            _ProfileInfoTile(
                              icon: Icons.phone_rounded,
                              label: 'الهاتف',
                              value: user.phone ?? '-',
                              color: AppColors.success,
                            ),
                            _divider(),
                            _ProfileInfoTile(
                              icon: Icons.badge_rounded,
                              label: 'رقم الهوية',
                              value: user.maskedNationalId,
                              color: AppColors.error,
                            ),
                            _divider(),
                            _ProfileInfoTile(
                              icon: Icons.location_on_rounded,
                              label: 'الموقع',
                              value: user.location ?? '-',
                              color: Color(0xFF9C27B0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Quick actions ──
                      const Text(
                        'الإجراءات',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),

                      _ActionTile(
                        icon: Icons.chat_rounded,
                        label: 'محادثاتي',
                        color: AppColors.primary,
                        onTap: () => Get.toNamed(AppRoutes.chat),
                      ),
                      const SizedBox(height: 10),
                      _ActionTile(
                        icon: Icons.admin_panel_settings_rounded,
                        label: 'لوحة التحكم',
                        color: Color(0xFF9C27B0),
                        onTap: () => Get.toNamed(AppRoutes.admin),
                      ),
                      const SizedBox(height: 10),

                      // ── Logout ──
                      Obx(() => _ActionTile(
                            icon: Icons.logout_rounded,
                            label: 'تسجيل الخروج',
                            color: AppColors.error,
                            isLoading: auth.isLoading.value,
                            onTap: () {
                              Get.defaultDialog(
                                title: 'تسجيل الخروج',
                                middleText: 'هل أنت متأكد من تسجيل الخروج؟',
                                textConfirm: 'نعم',
                                textCancel: 'لا',
                                confirmTextColor: AppColors.white,
                                buttonColor: AppColors.error,
                                onConfirm: () async {
                                  Get.back();
                                  await auth.logout();
                                  Get.offAllNamed(AppRoutes.login);
                                },
                              );
                            },
                          )),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: Colors.grey.shade100, indent: 60);
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                      ),
                    )
                  : Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_sharp, size: 16, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}
