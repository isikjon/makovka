import 'package:flutter/material.dart';
import '../../core/loyalty/loyalty_store.dart';
import '../../core/theme/app_theme.dart';

/// "Скидка 99% на каждый 8 кофе" coffee-stamp promo card.
class CoffeeStampCard extends StatelessWidget {
  final CoffeeProgress? progress;
  const CoffeeStampCard({super.key, this.progress});

  static const _designW = 355.0;
  static const _designH = 169.0;
  static const _defaultCups = 7;

  @override
  Widget build(BuildContext context) {
    final collected = progress?.collected;
    final cups = progress?.goal ?? _defaultCups;
    final rewardNumber = cups + 1;
    return AspectRatio(
      aspectRatio: _designW / _designH,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final s = constraints.maxWidth / _designW;
          return ClipRRect(
            borderRadius: BorderRadius.circular(20 * s),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/coffee_promo_bg.png',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    isAntiAlias: true,
                  ),
                ),

                // Title
                Positioned(
                  top: 17 * s,
                  left: 20 * s,
                  right: 20 * s,
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.h1().copyWith(
                        fontSize: 16 * s,
                        height: 20 / 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        const TextSpan(text: 'Скидка '),
                        const TextSpan(
                          text: '99%',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const TextSpan(text: ' на каждый '),
                        TextSpan(
                          text: '$rewardNumber',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const TextSpan(text: ' кофе'),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 52 * s,
                  left: 20 * s,
                  right: 20 * s,
                  child: SizedBox(
                    height: 56 * s,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          for (var i = 0; i < cups; i++) ...[
                            _StampCup(
                              filled: collected != null && i < collected,
                              scale: s,
                            ),
                            if (i != cups - 1) SizedBox(width: 4 * s),
                          ],
                          SizedBox(width: 8 * s),
                          Text(
                            '=',
                            style: AppTextStyles.h1().copyWith(
                              fontSize: 20 * s,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 8 * s),
                          _HighlightCup(scale: s),
                        ],
                      ),
                    ),
                  ),
                ),

                // Description
                Positioned(
                  top: 117 * s,
                  left: 20 * s,
                  right: 90 * s,
                  child: Text(
                    'Копите чашки в приложении:\nкаждый $rewardNumber-й кофе — за 1% стоимости!',
                    style: AppTextStyles.body().copyWith(
                      fontSize: 12 * s,
                      height: 16 / 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                if (collected != null)
                  Positioned(
                    right: 20 * s,
                    bottom: 16 * s,
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.h1().copyWith(
                          fontSize: 22 * s,
                          fontWeight: FontWeight.w800,
                          color: AppColors.orange,
                        ),
                        children: [
                          TextSpan(text: '$collected'),
                          TextSpan(
                            text: '/$cups',
                            style: TextStyle(
                              fontSize: 16 * s,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StampCup extends StatelessWidget {
  final bool filled;
  final double scale;
  const _StampCup({required this.filled, required this.scale});

  @override
  Widget build(BuildContext context) {
    final s = scale;
    // Empty cup 28:37, filled cup 31:37 — keep each icon's own aspect ratio.
    final aspect = filled ? 31 / 37 : 28 / 37;
    final height = 34 * s;
    return Image.asset(
      filled
          ? 'assets/images/coffee_stamp_filled.png'
          : 'assets/images/coffee_stamp_empty.png',
      height: height,
      width: height * aspect,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
    );
  }
}

class _HighlightCup extends StatelessWidget {
  final double scale;
  const _HighlightCup({required this.scale});

  @override
  Widget build(BuildContext context) {
    final s = scale;
    // Already includes the "-99%" badge baked into the artwork.
    const aspect = 77 / 67;
    final height = 54 * s;
    return Image.asset(
      'assets/images/coffee_stamp_prize.png',
      height: height,
      width: height * aspect,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
    );
  }
}

/// "Пригласи друга - получи бонус!" referral promo card.
class ReferralBanner extends StatelessWidget {
  final VoidCallback onInvite;
  const ReferralBanner({super.key, required this.onInvite});

  static const _designW = 359.0;
  static const _designH = 130.0;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _designW / _designH,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final s = constraints.maxWidth / _designW;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16 * s),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20 * s,
                  offset: Offset(0, 8 * s),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16 * s),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/referral_card_bg.png',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      isAntiAlias: true,
                    ),
                  ),
                  Positioned(
                    top: 16 * s,
                    left: 20 * s,
                    right: 30 * s,
                    child: Text(
                      'Пригласи друга - получи бонус!',
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      style: AppTextStyles.h1().copyWith(
                        fontSize: 14 * s,
                        height: 18 / 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40 * s,
                    left: 20 * s,
                    right: 110 * s,
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.body().copyWith(
                          fontSize: 11 * s,
                          height: 15 / 11,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          const TextSpan(text: 'За каждого друга - до '),
                          TextSpan(
                            text: '500',
                            style: AppTextStyles.body().copyWith(
                              fontSize: 11 * s,
                              height: 15 / 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const TextSpan(text: ' бонусов!'),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 76 * s,
                    left: 20 * s,
                    child: _InviteButton(onTap: onInvite, scale: s),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InviteButton extends StatefulWidget {
  final VoidCallback onTap;
  final double scale;
  const _InviteButton({required this.onTap, required this.scale});

  @override
  State<_InviteButton> createState() => _InviteButtonState();
}

class _InviteButtonState extends State<_InviteButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 10 * s),
          decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(24 * s),
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withValues(alpha: 0.35),
                blurRadius: 16 * s,
                offset: Offset(0, 6 * s),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Пригласить друга',
                style: AppTextStyles.button().copyWith(
                  fontSize: 14 * s,
                  height: 18 / 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4 * s),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 18 * s,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Скидка 10% в счастливые часы" promo card.
class HappyHoursCard extends StatelessWidget {
  final String timeRange;
  const HappyHoursCard({super.key, required this.timeRange});

  static const _designW = 359.0;
  static const _designH = 190.0;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _designW / _designH,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final s = constraints.maxWidth / _designW;
          return ClipRRect(
            borderRadius: BorderRadius.circular(20 * s),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/happy_hours_bg.png',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    isAntiAlias: true,
                  ),
                ),

                // Title
                Positioned(
                  top: 22 * s,
                  left: 20 * s,
                  right: 20 * s,
                  child: Text(
                    'Скидка 10% в счастливые часы',
                    style: AppTextStyles.h1().copyWith(
                      fontSize: 15 * s,
                      height: 19 / 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                // Time range pill
                Positioned(
                  top: 60 * s,
                  left: 20 * s,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18 * s,
                      vertical: 9 * s,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20 * s),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10 * s,
                          offset: Offset(0, 3 * s),
                        ),
                      ],
                    ),
                    child: Text(
                      timeRange,
                      style: AppTextStyles.h1().copyWith(
                        fontSize: 15 * s,
                        height: 19 / 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orange,
                      ),
                    ),
                  ),
                ),

                // Description
                Positioned(
                  top: 121 * s,
                  left: 20 * s,
                  right: 90 * s,
                  child: Text(
                    'Каждый день вечером — получите скидку на любимые лакомства',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body().copyWith(
                      fontSize: 12 * s,
                      height: 16 / 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// "Комбо: Круассан + Американо" promo card.
class ComboPromoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String oldPrice;

  const ComboPromoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.oldPrice,
  });

  static const _designW = 359.0;
  static const _designH = 139.0;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _designW / _designH,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final s = constraints.maxWidth / _designW;
          return ClipRRect(
            borderRadius: BorderRadius.circular(20 * s),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/combo_promo_bg.png',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    isAntiAlias: true,
                  ),
                ),

                // Title
                Positioned(
                  top: 16 * s,
                  left: 20 * s,
                  right: 20 * s,
                  child: Text(
                    title,
                    style: AppTextStyles.h1().copyWith(
                      fontSize: 15 * s,
                      height: 19 / 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                // Subtitle
                Positioned(
                  top: 42 * s,
                  left: 20 * s,
                  right: 130 * s,
                  child: Text(
                    subtitle,
                    style: AppTextStyles.body().copyWith(
                      fontSize: 12 * s,
                      height: 16 / 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                // Price row
                Positioned(
                  left: 20 * s,
                  bottom: 18 * s,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        price,
                        style: AppTextStyles.h1().copyWith(
                          fontSize: 20 * s,
                          fontWeight: FontWeight.w800,
                          color: AppColors.orange,
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      Text(
                        oldPrice,
                        style: AppTextStyles.body().copyWith(
                          fontSize: 14 * s,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
