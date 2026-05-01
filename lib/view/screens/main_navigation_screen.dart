import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // 🔥
import 'package:get/get.dart';
import 'package:rajeali_app/core/shared/app_theme.dart';
import 'package:rajeali_app/view/Screen/all_items_screen.dart';
import 'package:rajeali_app/view/Screen/chat_list_screen.dart';
import 'package:rajeali_app/view/Screen/profile_screen.dart';
import 'package:rajeali_app/view/screens/home_tab.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RxInt currentIndex = 0.obs;

    final List<Widget> pages = const <Widget>[
      HomeTab(),
      AllItemsScreen(),
      ChatListScreen(),
      ProfileScreen(),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(index: currentIndex.value, children: pages),

        /// 🔥 Floating Nav (Cupertino Style)
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavItem(
                        icon: CupertinoIcons.home,
                        activeIcon: CupertinoIcons.hare_fill,
                        label: 'الرئيسية',
                        isActive: currentIndex.value == 0,
                        onTap: () => currentIndex.value = 0,
                      ),
                      _NavItem(
                        icon: CupertinoIcons.square_grid_2x2,
                        activeIcon: CupertinoIcons.square_grid_2x2_fill,
                        label: 'العناصر',
                        isActive: currentIndex.value == 1,
                        onTap: () => currentIndex.value = 1,
                      ),
                      _NavItem(
                        icon: CupertinoIcons.chat_bubble,
                        activeIcon: CupertinoIcons.chat_bubble_fill,
                        label: 'المحادثات',
                        isActive: currentIndex.value == 2,
                        onTap: () => currentIndex.value = 2,
                      ),
                      _NavItem(
                        icon: CupertinoIcons.person,
                        activeIcon: CupertinoIcons.person_fill,
                        label: 'حسابي',
                        isActive: currentIndex.value == 3,
                        onTap: () => currentIndex.value = 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  double scale = 1.0;

  void _onTapDown(_) => setState(() => scale = 0.92); // 🔥 ضغط
  void _onTapUp(_) => setState(() => scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => setState(() => scale = 1.0),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.primary.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🔥 indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(bottom: 3),
                height: 2.5,
                width: widget.isActive ? 16 : 0,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              /// 🔥 icon
              Icon(
                widget.isActive ? widget.activeIcon : widget.icon,
                color: widget.isActive ? AppColors.primary : AppColors.grey,
                size: 22,
              ),

              const SizedBox(height: 3),

              /// 🔥 text
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: widget.isActive
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: widget.isActive
                      ? AppColors.primary
                      : AppColors.grey.withValues(alpha: 0.75),
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
