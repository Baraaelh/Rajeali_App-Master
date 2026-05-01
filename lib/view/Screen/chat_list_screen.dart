import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rajeali_app/controller/auth_controller.dart';
import 'package:rajeali_app/controller/chat_controller.dart';
import 'package:rajeali_app/core/constant/app_routes.dart';
import 'package:rajeali_app/core/shared/app_theme.dart';
import 'package:rajeali_app/data/model/chat_room_model.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController ctrl = Get.find<ChatController>();
    final AuthController auth = Get.find<AuthController>();

    final String? userId = auth.currentUser.value?.id.toString();
    if (userId != null) {
      ctrl.loadRoomsForUser(userId);
    }

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
                children: <Widget>[
                  const Text(
                    'المحادثات',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'تواصل مع أصحاب البلاغات بأمان',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            // ── Chat list ──
            Expanded(
              child: Obx(() {
                if (userId == null) {
                  return _buildEmptyState(
                    icon: Icons.login_rounded,
                    message: 'سجّل الدخول أولاً',
                    subtitle: 'يجب تسجيل الدخول لعرض المحادثات',
                  );
                }

                if (ctrl.myRooms.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    message: 'لا توجد محادثات بعد',
                    subtitle: 'ستظهر المحادثات هنا بعد التحقق من ملكية غرض',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: ctrl.myRooms.length,
                  separatorBuilder: (BuildContext c, int i) => const SizedBox(height: 8),
                  itemBuilder: (BuildContext context, int i) {
                    final ChatRoomModel room = ctrl.myRooms[i];
                    final bool hasMessages = room.messages.isNotEmpty;
                    final String lastMsg = hasMessages
                        ? room.messages.last.message
                        : 'لا توجد رسائل بعد';
                    final String time = hasMessages
                        ? _formatTime(room.messages.last.createdAt)
                        : _formatTime(room.createdAt);

                    return GestureDetector(
                      onTap: () =>
                          Get.toNamed(AppRoutes.chatRoom, arguments: room.roomId),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: <Widget>[
                            // Avatar
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.chat_rounded,
                                  color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 14),
                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'محادثة البلاغ #${room.postId.substring(0, 6)}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    lastMsg,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Time + count
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  time,
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.grey),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${room.messages.length}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final Duration diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return '${diff.inMinutes} د';
    if (diff.inHours < 24) return '${diff.inHours} س';
    return '${diff.inDays} ي';
  }
}
