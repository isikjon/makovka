import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/content/content_store.dart';
import '../../core/format/money_format.dart';
import '../../core/loyalty/loyalty_store.dart';
import '../../core/referral/referral_store.dart';
import '../../core/theme/app_theme.dart';

class PromotionCard extends StatelessWidget {
  final Promotion promotion;
  const PromotionCard({super.key, required this.promotion});

  @override
  Widget build(BuildContext context) {
    final card = switch (promotion.kind) {
      PromotionKind.coffeeStamps => ListenableBuilder(
        listenable: LoyaltyStore.instance,
        builder: (context, _) => CoffeeStampCard(
          promotion: promotion,
          progress: LoyaltyStore.instance.info?.coffee,
        ),
      ),
      PromotionKind.referral => _ReferralPromotion(promotion: promotion),
      PromotionKind.happyHours => HappyHoursCard(promotion: promotion),
      PromotionKind.combo => ComboPromoCard(promotion: promotion),
      PromotionKind.generic => GenericPromoCard(promotion: promotion),
    };
    if (!promotion.personal) return card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [const _PersonalLabel(), const SizedBox(height: 8), card],
    );
  }
}

class _ReferralPromotion extends StatefulWidget {
  final Promotion promotion;
  const _ReferralPromotion({required this.promotion});

  @override
  State<_ReferralPromotion> createState() => _ReferralPromotionState();
}

class _ReferralPromotionState extends State<_ReferralPromotion> {
  final _store = ReferralStore.instance;

  @override
  void initState() {
    super.initState();
    _store.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) => ReferralBanner(
        promotion: widget.promotion,
        rewardsEnabled: _store.info?.hasBonus ?? false,
        onInvite: () => context.push('/promo/referral'),
      ),
    );
  }
}

class CoffeeStampCard extends StatelessWidget {
  final Promotion promotion;
  final CoffeeProgress? progress;
  const CoffeeStampCard({super.key, required this.promotion, this.progress});

  static const _designW = 355.0;
  static const _designH = 169.0;
  static const _defaultCups = 7;

  @override
  Widget build(BuildContext context) {
    final collected = progress?.collected;
    final cups = progress?.goal ?? _defaultCups;
    final summary = promotion.summary;
    final endsAt = promotion.endsAt;
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
                Positioned(
                  top: 17 * s,
                  left: 20 * s,
                  right: 20 * s,
                  child: _TitleRow(
                    badge: promotion.badge,
                    scale: s,
                    title: RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: AppTextStyles.h1().copyWith(
                          fontSize: 16 * s,
                          height: 20 / 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        children: _emphasizeNumbers(
                          promotion.title,
                          const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
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
                if (summary != null || endsAt != null)
                  Positioned(
                    top: 117 * s,
                    left: 20 * s,
                    right: 90 * s,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (summary != null)
                          Text(
                            summary,
                            maxLines: endsAt == null ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body().copyWith(
                              fontSize: 12 * s,
                              height: 16 / 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        if (summary != null && endsAt != null)
                          SizedBox(height: 4 * s),
                        if (endsAt != null) _UntilText(date: endsAt, scale: s),
                      ],
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

class ReferralBanner extends StatelessWidget {
  final Promotion promotion;
  final bool rewardsEnabled;
  final VoidCallback onInvite;
  const ReferralBanner({
    super.key,
    required this.promotion,
    required this.rewardsEnabled,
    required this.onInvite,
  });

  static const _designW = 359.0;
  static const _designH = 130.0;
  static const _neutralTitle = 'Приглашайте друзей';
  static const _neutralSummary = 'Делитесь своим промокодом с друзьями';

  @override
  Widget build(BuildContext context) {
    final title = rewardsEnabled ? promotion.title : _neutralTitle;
    final summary = rewardsEnabled ? promotion.summary : _neutralSummary;
    final badge = rewardsEnabled ? promotion.badge : null;
    final endsAt = promotion.endsAt;
    return AspectRatio(
      aspectRatio: _designW / _designH,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final s = constraints.maxWidth / _designW;
          final summaryStyle = AppTextStyles.body().copyWith(
            fontSize: 11 * s,
            height: 15 / 11,
            color: AppColors.textSecondary,
          );
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
                    child: _CardArt(
                      asset: 'assets/images/referral_card_bg.png',
                      imageUrl: promotion.imageUrl,
                      plain: _creamGradient,
                      imageSize: 76 * s,
                      scale: s,
                    ),
                  ),
                  Positioned(
                    top: 16 * s,
                    left: 20 * s,
                    right: 30 * s,
                    child: _TitleRow(
                      badge: badge,
                      scale: s,
                      title: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h1().copyWith(
                          fontSize: 14 * s,
                          height: 18 / 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  if (summary != null || endsAt != null)
                    Positioned(
                      top: 40 * s,
                      left: 20 * s,
                      right: 110 * s,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (summary != null)
                            RichText(
                              maxLines: endsAt == null ? 2 : 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                style: summaryStyle,
                                children: _emphasizeNumbers(
                                  summary,
                                  summaryStyle.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          if (summary != null && endsAt != null)
                            SizedBox(height: 3 * s),
                          if (endsAt != null)
                            _UntilText(date: endsAt, scale: s),
                        ],
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

class HappyHoursCard extends StatelessWidget {
  final Promotion promotion;
  const HappyHoursCard({super.key, required this.promotion});

  static const _designW = 359.0;
  static const _designH = 190.0;

  @override
  Widget build(BuildContext context) {
    final timeText = promotion.timeText;
    final summary = promotion.summary;
    final hasDeal = _DealFooter.hasContent(promotion);
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
                  child: _CardArt(
                    asset: 'assets/images/happy_hours_bg.png',
                    imageUrl: promotion.imageUrl,
                    plain: _peachGradient,
                    imageSize: 76 * s,
                    scale: s,
                  ),
                ),
                Positioned(
                  top: 22 * s,
                  left: 20 * s,
                  right: 20 * s,
                  child: _TitleRow(
                    badge: promotion.badge,
                    scale: s,
                    title: Text(
                      promotion.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h1().copyWith(
                        fontSize: 15 * s,
                        height: 19 / 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                if (timeText != null)
                  Positioned(
                    top: 60 * s,
                    left: 20 * s,
                    child: _TimePill(text: timeText, scale: s),
                  ),
                if (summary != null || hasDeal)
                  Positioned(
                    top: 121 * s,
                    left: 20 * s,
                    right: 90 * s,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (summary != null)
                          Text(
                            summary,
                            maxLines: hasDeal ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body().copyWith(
                              fontSize: 12 * s,
                              height: 16 / 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        if (summary != null && hasDeal) SizedBox(height: 6 * s),
                        if (hasDeal)
                          _DealFooter(promotion: promotion, scale: s),
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

class ComboPromoCard extends StatelessWidget {
  final Promotion promotion;
  const ComboPromoCard({super.key, required this.promotion});

  static const _designW = 359.0;
  static const _designH = 139.0;

  @override
  Widget build(BuildContext context) {
    final summary = promotion.summary;
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
                  child: _CardArt(
                    asset: 'assets/images/combo_promo_bg.png',
                    imageUrl: promotion.imageUrl,
                    plain: _creamGradient,
                    imageSize: 82 * s,
                    scale: s,
                  ),
                ),
                Positioned(
                  top: 16 * s,
                  left: 20 * s,
                  right: 20 * s,
                  child: _TitleRow(
                    badge: promotion.badge,
                    scale: s,
                    title: Text(
                      promotion.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h1().copyWith(
                        fontSize: 15 * s,
                        height: 19 / 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                if (summary != null)
                  Positioned(
                    top: 42 * s,
                    left: 20 * s,
                    right: 130 * s,
                    child: Text(
                      summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body().copyWith(
                        fontSize: 12 * s,
                        height: 16 / 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                if (_DealFooter.hasContent(promotion))
                  Positioned(
                    left: 20 * s,
                    right: 130 * s,
                    bottom: 18 * s,
                    child: _DealFooter(promotion: promotion, scale: s),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GenericPromoCard extends StatelessWidget {
  final Promotion promotion;
  const GenericPromoCard({super.key, required this.promotion});

  @override
  Widget build(BuildContext context) {
    final badge = promotion.badge;
    final subtitle = promotion.subtitle;
    final description = promotion.description;
    final timeText = promotion.timeText;
    final price = promotion.price;
    final oldPrice = promotion.oldPrice;
    final endsAt = promotion.endsAt;
    final imageUrl = promotion.imageUrl;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 139),
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF1E6), Colors.white],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (badge != null) ...[
                  _Badge(text: badge, scale: 1),
                  const SizedBox(height: 10),
                ],
                Text(
                  promotion.title,
                  style: AppTextStyles.h1().copyWith(
                    fontSize: 15,
                    height: 19 / 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: AppTextStyles.body().copyWith(
                      fontSize: 12,
                      height: 16 / 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.body().copyWith(
                      fontSize: 12,
                      height: 16 / 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
                if (timeText != null) ...[
                  const SizedBox(height: 12),
                  _TimePill(text: timeText, scale: 0.9),
                ],
                if (price != null || oldPrice != null) ...[
                  const SizedBox(height: 12),
                  _PriceRow(price: price, oldPrice: oldPrice, scale: 1),
                ],
                if (endsAt != null) ...[
                  const SizedBox(height: 10),
                  _UntilText(date: endsAt, scale: 1),
                ],
              ],
            ),
          ),
          if (imageUrl != null) ...[
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 104,
                height: 104,
                child: RemoteImage(url: imageUrl),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class RemoteImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  const RemoteImage({super.key, required this.url, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    if (url == null) return const _ImagePlaceholder();
    return Image.network(
      url,
      fit: fit,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
          wasSynchronouslyLoaded || frame != null
          ? child
          : const _ImagePlaceholder(),
      errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F1EF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Icon(
            Icons.bakery_dining_outlined,
            size: 28,
            color: Color(0xFFD9D5D2),
          ),
        ),
      ),
    );
  }
}

class _PersonalLabel extends StatelessWidget {
  const _PersonalLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 13,
            color: AppColors.orange,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              'Персональное предложение',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body().copyWith(
                fontSize: 11,
                height: 14 / 11,
                fontWeight: FontWeight.w600,
                color: AppColors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _creamGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.5, 1],
  colors: [Color(0xFFFAF9F9), Color(0xFFFCE08A)],
);

const _peachGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFFD1AA), Color(0xFFFFBE93)],
);

class _CardArt extends StatelessWidget {
  final String asset;
  final String? imageUrl;
  final Gradient plain;
  final double imageSize;
  final double scale;
  const _CardArt({
    required this.asset,
    required this.imageUrl,
    required this.plain,
    required this.imageSize,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = this.imageUrl;
    if (imageUrl == null) {
      return Image.asset(
        asset,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(gradient: plain),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.all(14 * scale),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14 * scale),
            child: SizedBox.square(
              dimension: imageSize,
              child: RemoteImage(url: imageUrl),
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  final String? badge;
  final double scale;
  final Widget title;
  const _TitleRow({
    required this.badge,
    required this.scale,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final badge = this.badge;
    if (badge == null) return title;
    return Row(
      children: [
        _Badge(text: badge, scale: scale),
        SizedBox(width: 8 * scale),
        Flexible(child: title),
      ],
    );
  }
}

class _DealFooter extends StatelessWidget {
  final Promotion promotion;
  final double scale;
  const _DealFooter({required this.promotion, required this.scale});

  static bool hasContent(Promotion promotion) =>
      promotion.price != null ||
      promotion.oldPrice != null ||
      promotion.endsAt != null;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final price = promotion.price;
    final oldPrice = promotion.oldPrice;
    final endsAt = promotion.endsAt;
    final hasPrice = price != null || oldPrice != null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (hasPrice) _PriceRow(price: price, oldPrice: oldPrice, scale: s),
        if (hasPrice && endsAt != null) SizedBox(width: 10 * s),
        if (endsAt != null)
          Flexible(
            child: _UntilText(date: endsAt, scale: s),
          ),
      ],
    );
  }
}

class _UntilText extends StatelessWidget {
  final DateTime date;
  final double scale;
  const _UntilText({required this.date, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatUntil(date),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.body().copyWith(
        fontSize: 11 * scale,
        height: 14 / 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final double scale;
  const _Badge({required this.text, required this.scale});

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(10 * s),
      ),
      child: Text(
        text,
        maxLines: 1,
        style: AppTextStyles.button().copyWith(
          fontSize: 11 * s,
          height: 14 / 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  final String text;
  final double scale;
  const _TimePill({required this.text, required this.scale});

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 9 * s),
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
        text,
        style: AppTextStyles.h1().copyWith(
          fontSize: 15 * s,
          height: 19 / 15,
          fontWeight: FontWeight.w700,
          color: AppColors.orange,
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final double? price;
  final double? oldPrice;
  final double scale;
  const _PriceRow({
    required this.price,
    required this.oldPrice,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final price = this.price;
    final oldPrice = this.oldPrice;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (price != null)
          Text(
            formatRub(price),
            style: AppTextStyles.h1().copyWith(
              fontSize: 20 * s,
              fontWeight: FontWeight.w800,
              color: AppColors.orange,
            ),
          ),
        if (price != null && oldPrice != null) SizedBox(width: 8 * s),
        if (oldPrice != null)
          Text(
            formatRub(oldPrice),
            style: AppTextStyles.body().copyWith(
              fontSize: 14 * s,
              color: AppColors.textMuted,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.textMuted,
            ),
          ),
      ],
    );
  }
}

final _numberToken = RegExp(r'\d+(?:[.,]\d+)?%?');

List<InlineSpan> _emphasizeNumbers(String text, TextStyle emphasis) {
  final spans = <InlineSpan>[];
  var cursor = 0;
  for (final match in _numberToken.allMatches(text)) {
    if (match.start > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, match.start)));
    }
    spans.add(TextSpan(text: match[0], style: emphasis));
    cursor = match.end;
  }
  if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
  return spans;
}

const _monthsGenitive = [
  'января',
  'февраля',
  'марта',
  'апреля',
  'мая',
  'июня',
  'июля',
  'августа',
  'сентября',
  'октября',
  'ноября',
  'декабря',
];

String _formatUntil(DateTime date) {
  final day = 'До ${date.day} ${_monthsGenitive[date.month - 1]}';
  return date.year == DateTime.now().year ? day : '$day ${date.year}';
}
