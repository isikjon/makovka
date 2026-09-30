import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/format/money_format.dart';
import '../../core/loyalty/loyalty_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../shared/widgets/status_views.dart';

class _TierPalette {
  final List<Color> badge;
  final List<Color> progress;
  final Color pillBg;
  final Color pillText;
  final Color border;

  const _TierPalette({
    required this.badge,
    required this.progress,
    required this.pillBg,
    required this.pillText,
    required this.border,
  });

  static _TierPalette of(String code) => _tierPalettes[code] ?? _neutralPalette;
}

const _tierPalettes = <String, _TierPalette>{
  'bronze': _TierPalette(
    badge: [Color(0xFF8C5A2B), Color(0xFFC08A4E)],
    progress: [Color(0xFF6E4420), Color(0xFFB98A50)],
    pillBg: Color(0xFFF1E3D3),
    pillText: Color(0xFF8C5A2B),
    border: Color(0xFFE3CBB0),
  ),
  'silver': _TierPalette(
    badge: [Color(0xFF5A5A5A), Color(0xFFA8A8A8)],
    progress: [Color(0xFF5A5A5A), Color(0xFFBDBDBD)],
    pillBg: Color(0xFFDEDEDE),
    pillText: Color(0xFF5A5A5A),
    border: Color(0xFFDAD9AA),
  ),
  'gold': _TierPalette(
    badge: [Color(0xFFC08A1A), Color(0xFFF5C242)],
    progress: [Color(0xFF7A5200), Color(0xFFF5C242)],
    pillBg: Color(0xFFF5C242),
    pillText: Color(0xFF7A5200),
    border: Color(0xFFE8CE7A),
  ),
  'platinum': _TierPalette(
    badge: [Color(0xFF3D5A8A), Color(0xFF8FA6D1)],
    progress: [Color(0xFF3D5A8A), Color(0xFFA9BCE0)],
    pillBg: Color(0xFFDCE4F7),
    pillText: Color(0xFF3D5A8A),
    border: Color(0xFFC9D3E8),
  ),
  'diamond': _TierPalette(
    badge: [Color(0xFF7A3FA0), Color(0xFFB784D9)],
    progress: [Color(0xFF7A3FA0), Color(0xFFC9A2E6)],
    pillBg: Color(0xFFEAD8F7),
    pillText: Color(0xFF7A3FA0),
    border: Color(0xFFDCC7EE),
  ),
};

const _neutralPalette = _TierPalette(
  badge: [Color(0xFF66605C), Color(0xFF9C9C9C)],
  progress: [Color(0xFF66605C), Color(0xFFB7B2AC)],
  pillBg: Color(0xFFF2F0ED),
  pillText: Color(0xFF66605C),
  border: Color(0xFFE5E1DE),
);

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen>
    with SingleTickerProviderStateMixin {
  final _store = LoyaltyStore.instance;

  late final AnimationController _enter;
  late final Animation<double> _fade;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fade = CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic));
    _store.load();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await _store.refresh();
    final error = _store.error;
    if (!mounted || error == null || _store.info == null) return;
    showErrorSnackBar(context, error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F9),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AspectRatio(
              aspectRatio: 1572 / 1200,
              child: Image.asset(
                'assets/images/page_promo_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: ListenableBuilder(
              listenable: _store,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          _store.info?.mode == LoyaltyMode.tiers
                              ? 'Уровни лояльности'
                              : 'Ваша скидка',
                          style: AppTextStyles.h1().copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          left: 16,
                          child: _BackButton(onTap: () => context.pop()),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.orange,
                      onRefresh: _refresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: FadeTransition(
                          opacity: _fade,
                          child: SlideTransition(
                            position: _slideUp,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildContent(),
                                SizedBox(height: AppBottomNav.barHeight + 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNav(
              currentIndex: -1,
              onTap: (i) {
                context.go(i == 0 ? '/home' : '/home?tab=1');
              },
              onLogoTap: () => context.push('/qr'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final info = _store.info;
    if (info == null) {
      final error = _store.error;
      if (error != null && !_store.isLoading) {
        return StatusCard(
          title: 'Не удалось загрузить данные',
          subtitle: error,
          onRetry: () => _store.load(force: true),
        );
      }
      return const _LoadingPlaceholder();
    }

    final tiersMode = info.mode == LoyaltyMode.tiers;
    final current = info.currentTier;
    final otherTiers = tiersMode
        ? info.tiers.where((tier) => tier.code != current.code).toList()
        : const <LoyaltyTier>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tiersMode)
          _CurrentTierCard(info: info)
        else
          _DiscountCard(discountPercent: current.discountPercent),
        const SizedBox(height: 16),
        _SavingsBanner(amount: info.totalSavings),
        if (info.bonusBalance > 0) ...[
          const SizedBox(height: 12),
          _BonusBanner(balance: info.bonusBalance),
        ],
        if (otherTiers.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text(
            'Уровни лояльности',
            style: AppTextStyles.h1().copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          for (final tier in otherTiers) ...[
            _TierCard(tier: tier, reached: tier.minSpend <= current.minSpend),
            const SizedBox(height: 14),
          ],
        ],
      ],
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const LoadingSpinner(),
        ),
        const SizedBox(height: 16),
        Container(
          height: 66,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFFBF1D6),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -18,
              right: -20,
              child: Opacity(
                opacity: 0.9,
                child: Image.asset(
                  'assets/images/loyalty_croissant.png',
                  width: 170,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.all(20), child: child),
          ],
        ),
      ),
    );
  }
}

class _DiscountCard extends StatelessWidget {
  final double discountPercent;
  const _DiscountCard({required this.discountPercent});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GradientPill(
            label: 'Скидка ${formatPercent(discountPercent)}',
            colors: _TierPalette.of('bronze').badge,
          ),
          const SizedBox(height: 16),
          Text(
            'Скидка действует на все покупки в пекарне',
            style: AppTextStyles.body().copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Просто покажите QR-код из приложения на кассе',
            style: AppTextStyles.body().copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentTierCard extends StatelessWidget {
  final LoyaltyInfo info;
  const _CurrentTierCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final tier = info.currentTier;
    final next = info.nextTier;
    final palette = _TierPalette.of(tier.code);
    final mutedStyle = AppTextStyles.body().copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.textMuted,
    );

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  tier.name,
                  style: AppTextStyles.h1().copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _GradientPill(
                      label: 'Скидка ${formatPercent(tier.discountPercent)}',
                      colors: palette.badge,
                    ),
                    if (tier.cashbackPercent > 0)
                      _SoftPill(
                        label: 'Кэшбэк ${formatPercent(tier.cashbackPercent)}',
                        palette: palette,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ProgressBar(
            value: next == null ? 1.0 : info.progress,
            colors: palette.progress,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatRub(info.totalSpend), style: mutedStyle),
              if (next != null)
                Text(formatRub(next.minSpend), style: mutedStyle),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            next == null
                ? 'Вы достигли максимального уровня'
                : 'Осталось ${formatRub(_remaining(next))} до уровня ${next.name}',
            style: AppTextStyles.body().copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          for (final perk in tier.perks) ...[
            const SizedBox(height: 8),
            _PerkRow(
              text: perk,
              iconColor: AppColors.orange,
              textColor: AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  double _remaining(LoyaltyTier next) {
    final remaining = info.remainingToNext ?? next.minSpend - info.totalSpend;
    return remaining < 0 ? 0 : remaining;
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final List<Color> colors;
  const _ProgressBar({required this.value, required this.colors});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        children: [
          Container(height: 10, color: const Color(0xFFECE9E4)),
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientPill extends StatelessWidget {
  final String label;
  final List<Color> colors;
  const _GradientPill({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.body().copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SoftPill extends StatelessWidget {
  final String label;
  final _TierPalette palette;
  final bool outlined;
  const _SoftPill({
    required this.label,
    required this.palette,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: outlined ? Colors.white : palette.pillBg,
        borderRadius: BorderRadius.circular(16),
        border: outlined ? Border.all(color: palette.pillBg, width: 1.2) : null,
      ),
      child: Text(
        label,
        style: AppTextStyles.body().copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: palette.pillText,
        ),
      ),
    );
  }
}

class _SavingsBanner extends StatelessWidget {
  final double amount;
  const _SavingsBanner({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF1D6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/loyalty_coin.png',
            width: 34,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(width: 10),
          Text(
            'Сэкономлено ${formatRub(amount)}',
            style: AppTextStyles.body().copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BonusBanner extends StatelessWidget {
  final double balance;
  const _BonusBanner({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E1DE), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/history_point.svg',
            width: 14,
            height: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Бонусы: ${formatAmount(balance)}',
            style: AppTextStyles.body().copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final LoyaltyTier tier;
  final bool reached;
  const _TierCard({required this.tier, required this.reached});

  @override
  Widget build(BuildContext context) {
    final palette = _TierPalette.of(tier.code);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      tier.name,
                      style: AppTextStyles.h1().copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _SoftPill(
                      label: 'Скидка ${formatPercent(tier.discountPercent)}',
                      palette: palette,
                    ),
                    if (tier.cashbackPercent > 0)
                      _SoftPill(
                        label: 'Кэшбэк ${formatPercent(tier.cashbackPercent)}',
                        palette: palette,
                        outlined: true,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: reached ? palette.pillBg : const Color(0xFFF2F0ED),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  reached ? Icons.check_rounded : Icons.lock_outline_rounded,
                  size: 18,
                  color: reached ? palette.pillText : const Color(0xFFB7B2AC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Сумма покупок от ${formatRub(tier.minSpend)}',
            style: AppTextStyles.body().copyWith(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          for (final perk in tier.perks) ...[
            const SizedBox(height: 8),
            _PerkRow(
              text: perk,
              iconColor: reached ? palette.pillText : AppColors.textMuted,
              textColor: reached
                  ? AppColors.textSecondary
                  : AppColors.textMuted,
            ),
          ],
        ],
      ),
    );
  }
}

class _PerkRow extends StatelessWidget {
  final String text;
  final Color iconColor;
  final Color textColor;
  const _PerkRow({
    required this.text,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(Icons.star_outline_rounded, size: 15, color: iconColor),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body().copyWith(
              fontSize: 13,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: SvgPicture.asset('assets/icons/back.svg'),
        ),
      ),
    );
  }
}
