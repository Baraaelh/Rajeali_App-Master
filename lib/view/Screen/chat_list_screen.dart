import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: <Widget>[
          // ── Header ──
          _buildHeader(ctrl),

          // ── List ──
          Expanded(
            child: Obx(() {
              if (userId == null) {
                return _EmptyState(
                  icon: Icons.login_rounded,
                  title: 'سجّل الدخول أولاً',
                  subtitle: 'يجب تسجيل الدخول لعرض المحادثات',
                  color: AppColors.primary,
                );
              }

              if (ctrl.myRooms.isEmpty) {
                return _EmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'لا توجد محادثات بعد',
                  subtitle: 'ستظهر المحادثات هنا بعد التحقق من ملكية غرض',
                  color: AppColors.primary,
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  HapticFeedback.mediumImpact();
                  if (userId != null) ctrl.loadRoomsForUser(userId);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  physics: const BouncingScrollPhysics(),
                  itemCount: ctrl.myRooms.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int i) {
                    final ChatRoomModel room = ctrl.myRooms[i];
                    final bool hasMessages = room.messages.isNotEmpty;
                    final String lastMsg = hasMessages
                        ? room.messages.last.message
                        : 'لا توجد رسائل بعد';
                    final String time = _formatTime(
                      hasMessages
                          ? room.messages.last.createdAt
                          : room.createdAt,
                    );
                    final bool hasUnread = hasMessages;

                    return _ChatCard(
                      room: room,
                      lastMsg: lastMsg,
                      time: time,
                      hasUnread: hasUnread,
                      onTap: () => Get.toNamed(
                        AppRoutes.chatRoom,
                        arguments: room.roomId,
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ChatController ctrl) {
    return Container(
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
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
          child: Row(
            children: <Widget>[
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'المحادثات 💬',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'تواصل مع أصحاب البلاغات بأمان',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              const Spacer(),
              // Count badge
              Obx(
                () => ctrl.myRooms.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${ctrl.myRooms.length} محادثة',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
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

// ─────────────────────────────────────────
// Chat Card
// ─────────────────────────────────────────
class _ChatCard extends StatefulWidget {
  const _ChatCard({
    required this.room,
    required this.lastMsg,
    required this.time,
    required this.hasUnread,
    required this.onTap,
  });
  final ChatRoomModel room;
  final String lastMsg;
  final String time;
  final bool hasUnread;
  final VoidCallback onTap;

  @override
  State<_ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<_ChatCard>
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
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              // Avatar
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFF1976D2), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'محادثة #${widget.room.postId.length > 6 ? widget.room.postId.substring(0, 6) : widget.room.postId}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: widget.hasUnread
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                        Text(
                          widget.time,
                          style: TextStyle(
                            fontSize: 11,
                            color: widget.hasUnread
                                ? AppColors.primary
                                : AppColors.grey,
                            fontWeight: widget.hasUnread
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            widget.lastMsg,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: widget.hasUnread
                                  ? const Color(0xFF374151)
                                  : AppColors.textSecondary,
                              fontWeight: widget.hasUnread
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (widget.room.messages.isNotEmpty)
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${widget.room.messages.length > 9 ? '9+' : widget.room.messages.length}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: color),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
