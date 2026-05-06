import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rajeali_app/controller/post_controller.dart';
import 'package:rajeali_app/core/shared/app_theme.dart';
import 'package:rajeali_app/data/model/category_model.dart';
import 'package:rajeali_app/data/model/found_item_model.dart';
import 'package:rajeali_app/data/model/lost_item_model.dart';

class AllItemsScreen extends StatelessWidget {
  const AllItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PostController ctrl = Get.find<PostController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: <Widget>[
          // ── Header ──
          _Header(ctrl: ctrl),

          // ── List ──
          Expanded(
            child: Obx(() {
              final bool showLost = ctrl.filterType.value != 'found';
              final bool showFound = ctrl.filterType.value != 'lost';
              final int? catFilter = ctrl.filterCategoryId.value;

              final List<LostItemModel> lost = showLost
                  ? (catFilter != null
                        ? ctrl.lostItems
                              .where(
                                (LostItemModel l) => l.categoryId == catFilter,
                              )
                              .toList()
                        : ctrl.lostItems.toList())
                  : <LostItemModel>[];

              final List<FoundItemModel> found = showFound
                  ? (catFilter != null
                        ? ctrl.foundItems
                              .where(
                                (FoundItemModel f) => f.categoryId == catFilter,
                              )
                              .toList()
                        : ctrl.foundItems.toList())
                  : <FoundItemModel>[];

              final int total = lost.length + found.length;

              if (ctrl.lostLoading.value || ctrl.foundLoading.value) {
                return const _LoadingState();
              }

              if (total == 0) {
                return const _EmptyState();
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  HapticFeedback.mediumImpact();
                  await ctrl.fetchLostItems();
                  await ctrl.fetchFoundItems();
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  physics: const BouncingScrollPhysics(),
                  children: <Widget>[
                    // Count badge
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$total نتيجة',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    ...lost.map(
                      (LostItemModel l) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ItemCard(
                          title: l.itemName,
                          category: l.categoryName ?? '',
                          location: l.mapLocation,
                          imageUrl: l.imageUrl,
                          isLost: true,
                        ),
                      ),
                    ),
                    ...found.map(
                      (FoundItemModel f) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ItemCard(
                          title: f.finderName.isNotEmpty
                              ? f.finderName
                              : f.description,
                          category: f.categoryName ?? '',
                          location: f.mapLocation,
                          imageUrl: f.imageUrl,
                          isLost: false,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Header
// ─────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.ctrl});
  final PostController ctrl;

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
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Title row
              Row(
                children: <Widget>[
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'جميع العناصر',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'تصفح المفقودات والمعثورات',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Stats pills
                  Obx(
                    () => Row(
                      children: <Widget>[
                        _MiniPill(
                          count: ctrl.lostItems.length,
                          label: 'مفقود',
                          color: const Color(0xFFFF5252),
                        ),
                        const SizedBox(width: 6),
                        _MiniPill(
                          count: ctrl.foundItems.length,
                          label: 'موجود',
                          color: const Color(0xFF69F0AE),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Type filter tabs
              Obx(
                () => Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: <Widget>[
                      _TabButton(
                        label: 'الكل',
                        isSelected: ctrl.filterType.value == 'all',
                        selectedColor: const Color(0xFF42A5F5),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ctrl.filterType.value = 'all';
                        },
                      ),
                      _TabButton(
                        label: 'مفقودات',
                        isSelected: ctrl.filterType.value == 'lost',
                        selectedColor: const Color(0xFFFF5252),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ctrl.filterType.value = 'lost';
                        },
                      ),
                      _TabButton(
                        label: 'معثورات',
                        isSelected: ctrl.filterType.value == 'found',
                        selectedColor: const Color(0xFF43A047),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ctrl.filterType.value = 'found';
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Category filter
              Obx(
                () => SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: <Widget>[
                      _CatChip(
                        label: 'الكل',
                        isSelected: ctrl.filterCategoryId.value == null,
                        onTap: () => ctrl.filterCategoryId.value = null,
                      ),
                      ...ctrl.categories.map(
                        (CategoryModel c) => Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8),
                          child: _CatChip(
                            label: c.name,
                            isSelected: ctrl.filterCategoryId.value == c.id,
                            onTap: () => ctrl.filterCategoryId.value = c.id,
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
// Mini Pill (stats)
// ─────────────────────────────────────────
class _MiniPill extends StatelessWidget {
  const _MiniPill({
    required this.count,
    required this.label,
    required this.color,
  });
  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Tab Button
// ─────────────────────────────────────────
class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final Color color = selectedColor ?? Colors.white;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? color : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Category Chip
// ─────────────────────────────────────────
class _CatChip extends StatelessWidget {
  const _CatChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Item Card
// ─────────────────────────────────────────
class _ItemCard extends StatefulWidget {
  const _ItemCard({
    required this.title,
    required this.category,
    required this.location,
    required this.isLost,
    this.imageUrl,
  });
  final String title;
  final String category;
  final String location;
  final String? imageUrl;
  final bool isLost;

  @override
  State<_ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<_ItemCard>
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
    final Color color = widget.isLost
        ? const Color(0xFFE53935)
        : const Color(0xFF2E7D32);
    final Color bgColor = widget.isLost
        ? const Color(0xFFFFEBEE)
        : const Color(0xFFE8F5E9);

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
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
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 60,
                  height: 60,
                  color: bgColor,
                  child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                      ? Image.network(
                          widget.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            widget.isLost
                                ? Icons.search_rounded
                                : Icons.handshake_rounded,
                            color: color,
                            size: 28,
                          ),
                        )
                      : Icon(
                          widget.isLost
                              ? Icons.search_rounded
                              : Icons.handshake_rounded,
                          color: color,
                          size: 28,
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 5),
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
                            widget.location,
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
                    if (widget.category.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.isLost ? 'مفقود' : 'موجود',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
// Loading State
// ─────────────────────────────────────────
class _LoadingState extends StatefulWidget {
  const _LoadingState();

  @override
  State<_LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<_LoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
      builder: (_, __) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: _anim.value),
            borderRadius: BorderRadius.circular(18),
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
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد نتائج',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'جرب تغيير الفلتر أو التصنيف',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
