import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rajeali_app/controller/auth_controller.dart';
import 'package:rajeali_app/data/datasource/verification_datasource.dart';
import 'package:rajeali_app/data/model/notification_model.dart';
import 'package:rajeali_app/core/shared/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find<AuthController>();
    final AppDataSource ds = Get.find<AppDataSource>();
    final String userId = auth.currentUser.value?.id.toString() ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Text(
                    'الإشعارات',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'تابع آخر التحديثات والأحداث',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            // ── Notifications list ──
            Expanded(
              child: Builder(
                builder: (BuildContext context) {
                  final List<NotificationModel> notifications =
                      ds.notificationsForUser(userId);

                  if (notifications.isEmpty) {
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
                              child: const Icon(Icons.notifications_off_rounded,
                                  size: 40, color: AppColors.grey),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'لا توجد إشعارات',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'ستظهر الإشعارات هنا عند وجود تحديثات',
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: notifications.length,
                    separatorBuilder: (BuildContext c, int i) => const SizedBox(height: 8),
                    itemBuilder: (BuildContext context, int i) {
                      final NotificationModel n = notifications[i];
                      final _NotifStyle style = _styleFor(n.type);

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: n.isRead
                              ? AppColors.white
                              : style.color.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: n.isRead
                                ? Colors.grey.shade100
                                : style.color.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: style.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(style.icon, color: style.color, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    n.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                          n.isRead ? FontWeight.w500 : FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    n.body,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(n.createdAt),
                              style:
                                  const TextStyle(fontSize: 11, color: AppColors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _NotifStyle _styleFor(NotificationType type) {
    switch (type) {
      case NotificationType.matchFound:
        return _NotifStyle(Icons.compare_arrows_rounded, AppColors.primary);
      case NotificationType.claimRequest:
        return _NotifStyle(Icons.person_search_rounded, Color(0xFFFF9800));
      case NotificationType.verificationSuccess:
        return _NotifStyle(Icons.verified_rounded, AppColors.success);
      case NotificationType.verificationNotifyFinder:
        return _NotifStyle(Icons.notification_important_rounded, Color(0xFFFF9800));
      case NotificationType.newMessage:
        return _NotifStyle(Icons.chat_bubble_rounded, AppColors.primary);
      case NotificationType.returnConfirmed:
        return _NotifStyle(Icons.check_circle_rounded, AppColors.success);
      case NotificationType.accountBanned:
        return _NotifStyle(Icons.block_rounded, AppColors.error);
      case NotificationType.expiryWarning:
        return _NotifStyle(Icons.timer_rounded, Color(0xFFFF9800));
    }
  }

  String _formatTime(DateTime dt) {
    final Duration diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    return 'منذ ${diff.inDays} ي';
  }
}

class _NotifStyle {
  const _NotifStyle(this.icon, this.color);
  final IconData icon;
  final Color color;
}
