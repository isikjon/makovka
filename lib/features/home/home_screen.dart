import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/format/money_format.dart';
import '../../core/loyalty/loyalty_store.dart';
import '../../core/profile/profile_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../shared/widgets/promo_cards.dart';
import '../../shared/widgets/status_views.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _loyalty = LoyaltyStore.instance;
  late final _heroData = Listenable.merge([ProfileStore.instance, _loyalty]);

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
    WidgetsBinding.instance.addObserver(this);
    _loyalty.load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _enter.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loyalty.load();
  }

  Future<void> _refresh() async {
    await _loyalty.refresh();
    final error = _loyalty.error;
    if (!mounted || error == null || _loyalty.info == null) return;
    showErrorSnackBar(context, error);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.orange,
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slideUp,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedBuilder(
                    animation: _heroData,
                    builder: (context, _) => _HeroBlock(
                      userName: ProfileStore.instance.displayName,
                      discountLabel: _discountLabel(_loyalty.info),
                      savedAmount: _savedAmount(_loyalty.info),
                      onMenu: () => Scaffold.of(context).openDrawer(),
                      onLocation: () => context.push('/locations'),
                      onInfo: () => context.push('/loyalty'),
                    ),
                  ),
                  ListenableBuilder(
                    listenable: _loyalty,
                    builder: (context, _) => _buildLoyaltyError(),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ReferralBanner(
                      onInvite: () => context.push('/promo/referral'),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const _NewItemsSection(),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListenableBuilder(
                      listenable: _loyalty,
                      builder: (context, _) =>
                          CoffeeStampCard(progress: _loyalty.info?.coffee),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: HappyHoursCard(
                      timeRange: 'С 20:30 до 00:00',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ComboPromoCard(
                      title: 'Комбо: Круассан + Американо',
                      subtitle: 'Идеальное утреннее сочетание',
                      price: '299 ₽',
                      oldPrice: '420 ₽',
                    ),
                  ),
                  SizedBox(height: AppBottomNav.barHeight + 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoyaltyError() {
    final error = _loyalty.error;
    if (error == null || _loyalty.info != null || _loyalty.isLoading) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: StatusCard(
        title: 'Не удалось загрузить данные',
        subtitle: error,
        onRetry: () => _loyalty.load(force: true),
      ),
    );
  }

  String _discountLabel(LoyaltyInfo? info) {
    if (info == null) return 'Скидка —';
    return 'Скидка ${formatPercent(info.currentTier.discountPercent)}';
  }

  String _savedAmount(LoyaltyInfo? info) {
    if (info == null) return '—';
    return formatRub(info.totalSavings);
  }
}

class _HeroBlock extends StatelessWidget {
  final String userName;
  final String discountLabel;
  final String savedAmount;
  final VoidCallback onMenu;
  final VoidCallback onLocation;
  final VoidCallback onInfo;

  const _HeroBlock({
    required this.userName,
    required this.discountLabel,
    required this.savedAmount,
    required this.onMenu,
    required this.onLocation,
    required this.onInfo,
  });

  static const _designW = 393.0;
  static const _designH = 460.0;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _designW / _designH,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final s = constraints.maxWidth / _designW;
          return Stack(
          children: [
            // Cropped illustration: keep top (girl + peach), cut white bottom.
            Positioned.fill(
              child: Image.asset(
                'assets/images/home_hero_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
              ),
            ),

            // Top-left burger
            Positioned(
              top: 18 * s,
              left: 18 * s,
              child: _CircleIconButton(
                asset: 'assets/icons/burger.svg',
                onTap: onMenu,
                scale: s,
              ),
            ),

            // Top-right GPS
            Positioned(
              top: 18 * s,
              right: 18 * s,
              child: _CircleIconButton(
                asset: 'assets/icons/location.svg',
                onTap: onLocation,
                scale: s,
              ),
            ),

            // Greeting
            Positioned(
              top: 100 * s,
              left: 20 * s,
              right: 20 * s,
              child: Text(
                'Привет, $userName',
                style: AppTextStyles.h1().copyWith(
                  fontSize: 26 * s,
                  height: 30 / 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),

            // Discount pill under title
            Positioned(
              top: 148 * s,
              left: 20 * s,
              child: _DiscountPill(label: discountLabel, scale: s),
            ),

            // Saved-amount label + pill, overlapping the illustration
            Positioned(
              left: 20 * s,
              bottom: 46 * s,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Сэкономлено',
                    style: AppTextStyles.body().copyWith(
                      fontSize: 13 * s,
                      height: 16 / 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6 * s),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22 * s,
                      vertical: 10 * s,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30 * s),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 14 * s,
                          offset: Offset(0, 5 * s),
                        ),
                      ],
                    ),
                    child: Text(
                      savedAmount,
                      style: AppTextStyles.h1().copyWith(
                        fontSize: 26 * s,
                        height: 30 / 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info button, bare icon
            Positioned(
              right: 20 * s,
              bottom: 52 * s,
              child: _InfoButton(onTap: onInfo, scale: s),
            ),
          ],
        );
        },
        ),
    );
  }
}

/// Snaps horizontal scrolling to one card at a time, like a carousel,
/// instead of letting the list settle anywhere (`itemExtent` = card width + gap).
class _CardSnapPhysics extends ScrollPhysics {
  final double itemExtent;
  const _CardSnapPhysics({required this.itemExtent, super.parent});

  @override
  _CardSnapPhysics applyTo(ScrollPhysics? ancestor) {
    return _CardSnapPhysics(
      itemExtent: itemExtent,
      parent: buildParent(ancestor),
    );
  }

  double _getPage(ScrollMetrics position) => position.pixels / itemExtent;

  double _getPixels(double page) => page * itemExtent;

  double _getTargetPixels(
    ScrollMetrics position,
    Tolerance tolerance,
    double velocity,
  ) {
    var page = _getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return _getPixels(page.roundToDouble());
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final tolerance = toleranceFor(position);
    final target = _getTargetPixels(position, tolerance, velocity).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => true;
}

class _ProductItem {
  final String image;
  final String name;
  const _ProductItem({required this.image, required this.name});
}

class _NewItemsSection extends StatelessWidget {
  const _NewItemsSection();

  // Only 3 distinct product photos are available so far; the rest cycle
  // through them with placeholder names until more assets are supplied.
  static const _items = [
    _ProductItem(
      image: 'assets/images/products/pizza_bbq.png',
      name: 'Пицца цыпленок\nбарбекю',
    ),
    _ProductItem(
      image: 'assets/images/products/pechusha_ham_cheese.png',
      name: 'Печуша с ветчиной\nи сыром',
    ),
    _ProductItem(
      image: 'assets/images/products/croissant_chocolate.png',
      name: 'Круассан с\nшоколадом',
    ),
    _ProductItem(
      image: 'assets/images/products/pizza_bbq.png',
      name: 'Пицца\nпепперони',
    ),
    _ProductItem(
      image: 'assets/images/products/pechusha_ham_cheese.png',
      name: 'Печуша с\nгрибами',
    ),
    _ProductItem(
      image: 'assets/images/products/croissant_chocolate.png',
      name: 'Круассан с\nминдалем',
    ),
    _ProductItem(
      image: 'assets/images/products/pizza_bbq.png',
      name: 'Пицца\nмаргарита',
    ),
    _ProductItem(
      image: 'assets/images/products/pechusha_ham_cheese.png',
      name: 'Печуша с\nсыром',
    ),
    _ProductItem(
      image: 'assets/images/products/croissant_chocolate.png',
      name: 'Круассан\nклассический',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'Новинки',
            style: AppTextStyles.h1().copyWith(
              fontSize: 22,
              height: 28 / 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 12.0;
            const outerPadding = 16.0;
            final cardWidth =
                (constraints.maxWidth - outerPadding * 2 - gap * 2) / 3;
            return SizedBox(
              height: 172,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: _CardSnapPhysics(
                  itemExtent: cardWidth + gap,
                  parent: const BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: outerPadding,
                ),
                itemCount: _items.length,
                separatorBuilder: (context, i) => const SizedBox(width: gap),
                itemBuilder: (context, i) => _ProductCard(
                  item: _items[i],
                  width: cardWidth,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ProductCard extends StatefulWidget {
  final _ProductItem item;
  final double width;
  const _ProductCard({required this.item, required this.width});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () {},
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          width: widget.width,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 78,
                child: Image.asset(
                  widget.item.image,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  isAntiAlias: true,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.item.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: AppTextStyles.body().copyWith(
                  fontSize: 13,
                  height: 17 / 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _CircleIconButton extends StatefulWidget {
  final String asset;
  final VoidCallback onTap;
  final double scale;
  const _CircleIconButton({
    required this.asset,
    required this.onTap,
    required this.scale,
  });

  @override
  State<_CircleIconButton> createState() => _CircleIconButtonState();
}

class _CircleIconButtonState extends State<_CircleIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final size = 44 * widget.scale;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: SvgPicture.asset(
          widget.asset,
          width: size,
          height: size,
        ),
      ),
    );
  }
}

class _DiscountPill extends StatelessWidget {
  final String label;
  final double scale;
  const _DiscountPill({required this.label, required this.scale});

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 10 * s),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10 * s),
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.button().copyWith(
          fontSize: 15 * s,
          height: 20 / 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _InfoButton extends StatefulWidget {
  final VoidCallback onTap;
  final double scale;
  const _InfoButton({required this.onTap, required this.scale});

  @override
  State<_InfoButton> createState() => _InfoButtonState();
}

class _InfoButtonState extends State<_InfoButton> {
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
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          width: 32 * s,
          height: 32 * s,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8 * s,
                offset: Offset(0, 2 * s),
              ),
            ],
          ),
          padding: EdgeInsets.all(4 * s),
          child: SvgPicture.asset('assets/icons/info.svg'),
        ),
      ),
    );
  }
}
