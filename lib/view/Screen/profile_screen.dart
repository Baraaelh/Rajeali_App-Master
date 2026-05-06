import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      backgroundColor: const Color(0xFFF0F4FF),
      body: Obx(() {
        final user = auth.currentUser.value;

        if (user == null) {
          return _buildNotLoggedIn();
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => auth.fetchMe(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: <Widget>[
                // ── Header ──
                _buildHeader(user, auth),
                const SizedBox(height: 20),

                // ── Stats Row ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _StatsRow(),
                ),
                const SizedBox(height: 20),

                // ── Info Card ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _InfoCard(user: user),
                ),
                const SizedBox(height: 16),

                // ── Actions ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ActionsSection(auth: auth),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(dynamic user, AuthController auth) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF0D47A1),
            Color(0xFF1976D2),
            Color(0xFF42A5F5),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            children: <Widget>[
              // Top row
              Row(
                children: <Widget>[
                  const Text(
                    'حسابي',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.toNamed(AppRoutes.admin);
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Avatar
              Stack(
                children: <Widget>[
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Online dot
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF69F0AE),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              if (user.createdAt != null) ...<Widget>[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'عضو منذ ${user.createdAt!.year}/${user.createdAt!.month.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_off_rounded,
                size: 42,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'لم يتم تسجيل الدخول',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Get.offAllNamed(AppRoutes.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'تسجيل الدخول',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Stats Row
// ─────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          _StatItem(value: '0', label: 'بلاغاتي', color: AppColors.primary),
          _VerticalDivider(),
          _StatItem(
            value: '0',
            label: 'مسترجع',
            color: const Color(0xFF2E7D32),
          ),
          _VerticalDivider(),
          _StatItem(
            value: '0',
            label: 'محادثات',
            color: const Color(0xFF9C27B0),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: const Color(0xFFF0F0F0));
  }
}

// ─────────────────────────────────────────
// Info Card
// ─────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'المعلومات الشخصية',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
          _InfoTile(
            icon: Icons.person_rounded,
            label: 'الاسم',
            value: user.name,
            color: AppColors.primary,
          ),
          const Divider(height: 1, indent: 64, color: Color(0xFFF5F5F5)),
          _InfoTile(
            icon: Icons.alternate_email_rounded,
            label: 'البريد',
            value: user.email,
            color: const Color(0xFFFF9800),
          ),
          const Divider(height: 1, indent: 64, color: Color(0xFFF5F5F5)),
          _InfoTile(
            icon: Icons.phone_rounded,
            label: 'الهاتف',
            value: user.phone ?? '-',
            color: const Color(0xFF2E7D32),
          ),
          const Divider(height: 1, indent: 64, color: Color(0xFFF5F5F5)),
          _InfoTile(
            icon: Icons.badge_rounded,
            label: 'رقم الهوية',
            value: user.maskedNationalId,
            color: AppColors.error,
          ),
          const Divider(height: 1, indent: 64, color: Color(0xFFF5F5F5)),
          _InfoTile(
            icon: Icons.location_on_rounded,
            label: 'الموقع',
            value: user.location ?? '-',
            color: const Color(0xFF9C27B0),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isLast = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, isLast ? 16 : 12),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
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
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
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

// ─────────────────────────────────────────
// Actions Section
// ─────────────────────────────────────────
class _ActionsSection extends StatelessWidget {
  const _ActionsSection({required this.auth});
  final AuthController auth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          _ActionTile(
            icon: Icons.chat_rounded,
            label: 'محادثاتي',
            color: AppColors.primary,
            onTap: () => Get.toNamed(AppRoutes.chat),
          ),
          const Divider(height: 1, indent: 64, color: Color(0xFFF5F5F5)),
          _ActionTile(
            icon: Icons.admin_panel_settings_rounded,
            label: 'لوحة التحكم',
            color: const Color(0xFF9C27B0),
            onTap: () => Get.toNamed(AppRoutes.admin),
          ),
          const Divider(height: 1, indent: 64, color: Color(0xFFF5F5F5)),
          Obx(
            () => _ActionTile(
              icon: Icons.logout_rounded,
              label: 'تسجيل الخروج',
              color: AppColors.error,
              isLoading: auth.isLoading.value,
              isDestructive: true,
              isLast: true,
              onTap: () {
                HapticFeedback.mediumImpact();
                Get.defaultDialog(
                  title: 'تسجيل الخروج',
                  middleText: 'هل أنت متأكد من تسجيل الخروج؟',
                  textConfirm: 'نعم',
                  textCancel: 'لا',
                  confirmTextColor: Colors.white,
                  buttonColor: AppColors.error,
                  onConfirm: () async {
                    Get.back();
                    await auth.logout();
                    Get.offAllNamed(AppRoutes.login);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatefulWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLoading = false,
    this.isDestructive = false,
    this.isLast = false,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isDestructive;
  final bool isLast;

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile>
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
      end: 0.97,
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
        if (!widget.isLoading) {
          HapticFeedback.lightImpact();
          widget.onTap();
        }
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, widget.isLast ? 16 : 14),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: widget.isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.color,
                        ),
                      )
                    : Icon(widget.icon, color: widget.color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: widget.isDestructive
                        ? AppColors.error
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
