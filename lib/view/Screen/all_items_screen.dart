import 'package:flutter/material.dart';
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('جميع العناصر',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('تصفح المفقودات والمعثورات',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),

                  // Type filter
                  Obx(() => Row(
                        children: <Widget>[
                          _FilterChip(label: 'الكل', isSelected: ctrl.filterType.value == 'all',
                              onTap: () => ctrl.filterType.value = 'all'),
                          const SizedBox(width: 8),
                          _FilterChip(label: 'مفقودات', isSelected: ctrl.filterType.value == 'lost',
                              color: AppColors.error, onTap: () => ctrl.filterType.value = 'lost'),
                          const SizedBox(width: 8),
                          _FilterChip(label: 'معثورات', isSelected: ctrl.filterType.value == 'found',
                              color: AppColors.success, onTap: () => ctrl.filterType.value = 'found'),
                        ],
                      )),
                  const SizedBox(height: 8),

                  // Category filter
                  Obx(() => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: <Widget>[
                            _FilterChip(label: 'كل التصنيفات', isSelected: ctrl.filterCategoryId.value == null,
                                onTap: () => ctrl.filterCategoryId.value = null),
                            ...ctrl.categories.map((CategoryModel c) => Padding(
                                  padding: const EdgeInsetsDirectional.only(start: 8),
                                  child: _FilterChip(label: c.name,
                                      isSelected: ctrl.filterCategoryId.value == c.id,
                                      onTap: () => ctrl.filterCategoryId.value = c.id),
                                )),
                          ],
                        ),
                      )),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            Expanded(
              child: Obx(() {
                final bool showLost = ctrl.filterType.value != 'found';
                final bool showFound = ctrl.filterType.value != 'lost';
                final int? catFilter = ctrl.filterCategoryId.value;

                final List<LostItemModel> lost = showLost
                    ? (catFilter != null ? ctrl.lostItems.where((LostItemModel l) => l.categoryId == catFilter).toList() : ctrl.lostItems.toList())
                    : <LostItemModel>[];
                final List<FoundItemModel> found = showFound
                    ? (catFilter != null ? ctrl.foundItems.where((FoundItemModel f) => f.categoryId == catFilter).toList() : ctrl.foundItems.toList())
                    : <FoundItemModel>[];

                final int total = lost.length + found.length;

                if (ctrl.lostLoading.value || ctrl.foundLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (total == 0) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.search_off_rounded, size: 64, color: AppColors.grey.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        const Text('لا توجد نتائج', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ctrl.fetchLostItems();
                    await ctrl.fetchFoundItems();
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    children: <Widget>[
                      ...lost.map((LostItemModel l) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ItemCard(
                              title: l.itemName, category: l.categoryName ?? '', location: l.mapLocation,
                              imageUrl: l.imageUrl, isLost: true,
                            ),
                          )),
                      ...found.map((FoundItemModel f) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ItemCard(
                              title: f.finderName.isNotEmpty ? f.finderName : f.description,
                              category: f.categoryName ?? '', location: f.mapLocation,
                              imageUrl: f.imageUrl, isLost: false,
                            ),
                          )),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isSelected, required this.onTap, this.color});
  final String label; final bool isSelected; final VoidCallback onTap; final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? c : AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? c : Colors.grey.shade300),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.textSecondary)),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.title, required this.category, required this.location,
      this.imageUrl, required this.isLost});
  final String title; final String category; final String location;
  final String? imageUrl; final bool isLost;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isLost ? AppColors.error : AppColors.success;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? ClipRRect(borderRadius: BorderRadius.circular(14),
                    child: Image.network(imageUrl!, fit: BoxFit.cover,
                        errorBuilder: (Object a, Object b, Object? c) => Icon(isLost ? Icons.search_rounded : Icons.handshake_rounded, color: statusColor)))
                : Icon(isLost ? Icons.search_rounded : Icons.handshake_rounded, color: statusColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('$category • $location', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(isLost ? 'مفقود' : 'موجود',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
          ),
        ],
      ),
    );
  }
}

