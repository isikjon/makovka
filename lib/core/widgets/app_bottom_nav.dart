import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onLogoTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onLogoTap,
  });

  static const double barHeight = 72;
  static const double logoSize = 64;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: barHeight + logoSize / 2,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Bar
          Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _NavTab(
                    label: 'Главная',
                    activeAsset: 'assets/icons/nav_home_on.svg',
                    inactiveAsset: 'assets/icons/nav_home_off.svg',
                    active: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                ),
                const SizedBox(width: logoSize - 12),
                Expanded(
                  child: _NavTab(
                    label: 'Акции',
                    activeAsset: 'assets/icons/nav_promo_on.svg',
                    inactiveAsset: 'assets/icons/nav_promo_off.svg',
                    active: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                ),
              ],
            ),
          ),

          // Floating logo button, centered above the bar
          Positioned(
            top: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onLogoTap ?? () => onTap(0),
              child: Container(
                width: logoSize,
                height: logoSize,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    isAntiAlias: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final String label;
  final String activeAsset;
  final String inactiveAsset;
  final bool active;
  final VoidCallback onTap;

  const _NavTab({
    required this.label,
    required this.activeAsset,
    required this.inactiveAsset,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: SvgPicture.asset(
              active ? activeAsset : inactiveAsset,
              key: ValueKey(active),
              width: 22,
              height: 22,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: AppTextStyles.body().copyWith(
              fontSize: 12,
              height: 15 / 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              color: active ? AppColors.orange : AppColors.textMuted,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
