import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/content/content_store.dart';
import '../../core/loyalty/loyalty_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../shared/widgets/promo_cards.dart';
import '../../shared/widgets/status_views.dart';

class PromoScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const PromoScreen({super.key, this.onBack});

  @override
  State<PromoScreen> createState() => _PromoScreenState();
}

class _PromoScreenState extends State<PromoScreen>
    with SingleTickerProviderStateMixin {
  final _content = ContentStore.instance;

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
    LoyaltyStore.instance.load();
    _content.load();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait([_content.refresh(), LoyaltyStore.instance.load()]);
    final error = _content.error;
    if (!mounted || error == null || _content.data == null) return;
    showErrorSnackBar(context, error);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              FadeTransition(
                opacity: _fade,
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'Акции',
                        style: AppTextStyles.h1().copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        left: 16,
                        child: _BackButton(onTap: widget.onBack ?? () {}),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slideUp,
                    child: RefreshIndicator(
                      color: AppColors.orange,
                      onRefresh: _refresh,
                      child: ListenableBuilder(
                        listenable: _content,
                        builder: (context, _) => ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          children: [
                            ..._buildBody(),
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
      ],
    );
  }

  List<Widget> _buildBody() {
    final data = _content.data;
    if (data == null) {
      final error = _content.error;
      if (error != null && !_content.isLoading) {
        return [
          StatusCard(
            title: 'Не удалось загрузить акции',
            subtitle: error,
            onRetry: () => _content.load(force: true),
          ),
        ];
      }
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: LoadingSpinner()),
        ),
      ];
    }
    if (data.promotions.isEmpty) {
      return const [
        StatusCard(
          title: 'Сейчас нет активных акций',
          subtitle: 'Загляните позже — здесь появятся новые предложения',
        ),
      ];
    }
    return [
      for (var i = 0; i < data.promotions.length; i++) ...[
        if (i > 0) const SizedBox(height: 20),
        PromotionCard(promotion: data.promotions[i]),
      ],
    ];
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
