import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rajeali_app/controller/auth_controller.dart';
import 'package:rajeali_app/controller/post_controller.dart';
import 'package:rajeali_app/core/constant/app_routes.dart';
import 'package:rajeali_app/core/shared/app_theme.dart';
import 'package:rajeali_app/data/model/lost_item_model.dart';
import 'package:rajeali_app/data/model/found_item_model.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find<AuthController>();
    final PostController postCtrl = Get.find<PostController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Obx(() {
        final String userName = auth.currentUser.value?.name ?? 'مستخدم';
        final String firstName = userName.split(' ').first;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            await postCtrl.fetchLostItems();
            await postCtrl.fetchFoundItems();
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: <Widget>[
              // ── Header ──
              SliverToBoxAdapter(child: _Header(firstName: firstName)),

              // ── Body ──
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    // ── Quick Actions ──
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.search_rounded,
                            title: 'فقدت شيئاً',
                            subtitle: 'أبلغ عن مفقود',
                            color: const Color(0xFFE53935),
                            bgColor: const Color(0xFFFFF0F0),
                            onTap: () => Get.toNamed(AppRoutes.reportLost),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.handshake_rounded,
                            title: 'وجدت شيئاً',
                            subtitle: 'أبلغ عن موجود',
                            color: const Color(0xFF2E7D32),
                            bgColor: const Color(0xFFF0FFF4),
                            onTap: () => Get.toNamed(AppRoutes.reportFound),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── AI Image Match Banner ──
                    _AIMatchBanner(),
                    const SizedBox(height: 20),

                    // ── Stats ──
                    Obx(
                      () => _StatsRow(
                        lostCount: postCtrl.lostItems.length,
                        foundCount: postCtrl.foundItems.length,
                        categoriesCount: postCtrl.categories.length,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Lost Items ──
                    _SectionHeader(
                      title: 'أحدث المفقودات',
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFE53935),
                      onSeeAll: () {},
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (postCtrl.lostLoading.value) {
                        return const _LoadingShimmer();
                      }
                      if (postCtrl.lostItems.isEmpty) {
                        return const _EmptyState(
                          icon: Icons.inbox_rounded,
                          message: 'لا توجد مفقودات حالياً',
                        );
                      }
                      return Column(
                        children: postCtrl.lostItems
                            .take(5)
                            .map(
                              (LostItemModel p) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _LostCard(item: p),
                              ),
                            )
                            .toList(),
                      );
                    }),

                    const SizedBox(height: 24),

                    // ── Found Items ──
                    _SectionHeader(
                      title: 'أحدث المعثورات',
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xFF2E7D32),
                      onSeeAll: () {},
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (postCtrl.foundLoading.value) {
                        return const _LoadingShimmer();
                      }
                      if (postCtrl.foundItems.isEmpty) {
                        return const _EmptyState(
                          icon: Icons.inbox_rounded,
                          message: 'لا توجد معثورات حالياً',
                        );
                      }
                      return Column(
                        children: postCtrl.foundItems
                            .take(5)
                            .map(
                              (FoundItemModel p) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _FoundCard(item: p),
                              ),
                            )
                            .toList(),
                      );
                    }),
                  ]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────
// Header
// ─────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.firstName});
  final String firstName;

  @override
  Widget build(BuildContext context) {
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
          stops: <double>[0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Top row
              Row(
                children: <Widget>[
                  // Avatar
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        firstName.isNotEmpty ? firstName[0].toUpperCase() : 'م',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'أهلاً، $firstName 👋',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'نتمنى نساعدك تلاقي اللي ضاع منك',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.toNamed(AppRoutes.notifications);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          const Icon(
                            Icons.notifications_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          // Badge
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF5252),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search bar
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.search_rounded,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'ابحث عن غرض مفقود أو موجود...',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'بحث',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
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
// Action Card
// ─────────────────────────────────────────
class _ActionCard extends StatefulWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard>
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
      end: 0.95,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: widget.color.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: widget.bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, color: widget.color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: widget.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
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
// AI Match Banner
// ─────────────────────────────────────────
class _AIMatchBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Get.toNamed(AppRoutes.imageMatch);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[
              Color(0xFF4A148C),
              Color(0xFF7B1FA2),
              Color(0xFF9C27B0),
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF7B1FA2).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            // أيقونة AI
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.image_search_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'بحث بالصورة',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      // AI Badge
                      _AIBadge(),
                    ],
                  ),
                  SizedBox(height: 3),
                  Text(
                    'ارفع صورة الغرض وسيجد الذكاء الاصطناعي التطابق تلقائياً',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AIBadge extends StatelessWidget {
  const _AIBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: const Text(
        'AI 🤖',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Stats Row
// ─────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.lostCount,
    required this.foundCount,
    required this.categoriesCount,
  });
  final int lostCount;
  final int foundCount;
  final int categoriesCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          _StatItem(
            value: '$lostCount',
            label: 'مفقود',
            color: const Color(0xFFE53935),
            icon: Icons.warning_amber_rounded,
          ),
          _Divider(),
          _StatItem(
            value: '$foundCount',
            label: 'موجود',
            color: const Color(0xFF2E7D32),
            icon: Icons.check_circle_rounded,
          ),
          _Divider(),
          _StatItem(
            value: '$categoriesCount',
            label: 'تصنيف',
            color: AppColors.primary,
            icon: Icons.category_rounded,
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
    required this.icon,
  });
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
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
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
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

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 50, color: const Color(0xFFF0F0F0));
  }
}

// ─────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    required this.onSeeAll,
  });
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'عرض الكل',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Lost Card
// ─────────────────────────────────────────
class _LostCard extends StatelessWidget {
  const _LostCard({required this.item});
  final LostItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 56,
              height: 56,
              color: const Color(0xFFFFEBEE),
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.search_rounded,
                        color: Color(0xFFE53935),
                        size: 26,
                      ),
                    )
                  : const Icon(
                      Icons.search_rounded,
                      color: Color(0xFFE53935),
                      size: 26,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: AppColors.grey,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        item.mapLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.categoryName != null) ...<Widget>[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.categoryName!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'مفقود',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Found Card
// ─────────────────────────────────────────
class _FoundCard extends StatelessWidget {
  const _FoundCard({required this.item});
  final FoundItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 56,
              height: 56,
              color: const Color(0xFFE8F5E9),
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.handshake_rounded,
                        color: Color(0xFF2E7D32),
                        size: 26,
                      ),
                    )
                  : const Icon(
                      Icons.handshake_rounded,
                      color: Color(0xFF2E7D32),
                      size: 26,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.finderName.isNotEmpty
                      ? item.finderName
                      : item.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: AppColors.grey,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        item.mapLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.categoryName != null) ...<Widget>[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.categoryName!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'موجود',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Loading Shimmer
// ─────────────────────────────────────────
class _LoadingShimmer extends StatefulWidget {
  const _LoadingShimmer();

  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Column(
        children: List<Widget>.generate(
          3,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            height: 72,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: _anim.value),
              borderRadius: BorderRadius.circular(16),
            ),
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
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: AppColors.grey),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
