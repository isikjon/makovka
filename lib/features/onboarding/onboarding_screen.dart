import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  static const _designW = 393.0;

  late final AnimationController _enter;
  late final Animation<double> _fade;
  late final Animation<Offset> _slideUp;
  late final Animation<double> _illScale;

  final _pageCtrl = PageController();
  int _page = 0;

  static const _pages = <_OnboardingPageData>[
    _OnboardingPageData(
      illustration: 'assets/images/onboarding_1_ava.png',
      background: 'assets/images/onboarding_1_bg.svg',
      title: 'Карта лояльности\nвсегда с собой',
      description:
          'Просто покажите QR-код из приложения кассиру при покупке. Копите баллы за каждый визит и оплачивайте ими любимые булочки!',
    ),
    _OnboardingPageData(
      illustration: 'assets/images/onboarding_2_ava.png',
      background: 'assets/images/onboarding_2_bg.svg',
      title: 'Растите в уровнях\nи получайте больше',
      description:
          'Бронза, серебро, золото — чем чаще заходите, тем выгоднее покупки. Каждый уровень открывает новые бонусы и подарки.',
    ),
    _OnboardingPageData(
      illustration: 'assets/images/onboarding_3_ava.png',
      background: 'assets/images/onboarding_3_bg.svg',
      title: 'Находите пекарни\nрядом с вами',
      description:
          'Смотрите ближайшие точки на карте, узнавайте о свежих акциях и скидках до 15% в любимой пекарне.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic));
    _illScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _enter, curve: Curves.easeOutBack),
    );
    _enter.forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    context.go('/auth/phone');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final s = width / _designW;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Cross-fading background per page, fills entire screen
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: SvgPicture.asset(
                _pages[_page].background,
                key: ValueKey(_pages[_page].background),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // Flowing layout: nothing here uses absolute top/bottom offsets,
          // so nothing can ever overlap regardless of screen size.
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 12 * s),
                Align(
                  alignment: Alignment.centerRight,
                  child: FadeTransition(
                    opacity: _fade,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _finish,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(6, 6, 24 * s, 6),
                        child: Text(
                          'Пропустить',
                          style: AppTextStyles.bodyMedium().copyWith(
                            fontSize: 14 * s,
                            height: 20 / 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) {
                      final p = _pages[i];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 340 * s,
                                  maxHeight: 340 * s,
                                ),
                                child: FadeTransition(
                                  opacity: _fade,
                                  child: ScaleTransition(
                                    scale: _illScale,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: SizedBox(
                                        width: 340,
                                        height: 340,
                                        child: Image.asset(
                                          p.illustration,
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.high,
                                          isAntiAlias: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24 * s,
                            ),
                            child: FadeTransition(
                              opacity: _fade,
                              child: SlideTransition(
                                position: _slideUp,
                                child: Text(
                                  p.title,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.h1().copyWith(
                                    fontSize: 24 * s,
                                    height: 30 / 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12 * s),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24 * s,
                            ),
                            child: FadeTransition(
                              opacity: _fade,
                              child: SlideTransition(
                                position: _slideUp,
                                child: Text(
                                  p.description,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.body().copyWith(
                                    fontSize: 14 * s,
                                    height: 20 / 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 20 * s),
                FadeTransition(
                  opacity: _fade,
                  child: _PageDots(
                    count: _pages.length,
                    current: _page,
                    scale: s,
                  ),
                ),
                SizedBox(height: 20 * s),
                Padding(
                  padding: EdgeInsets.fromLTRB(24 * s, 0, 24 * s, 16 * s),
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slideUp,
                      child: _PrimaryButton(
                        label:
                            _page == _pages.length - 1 ? 'Начать' : 'Далее',
                        onTap: _next,
                        scale: s,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  final String illustration;
  final String background;
  final String title;
  final String description;
  const _OnboardingPageData({
    required this.illustration,
    required this.background,
    required this.title,
    required this.description,
  });
}

class _PageDots extends StatelessWidget {
  final int count;
  final int current;
  final double scale;
  const _PageDots({
    required this.count,
    required this.current,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(horizontal: 4 * scale),
          width: (isActive ? 10 : 8) * scale,
          height: (isActive ? 10 : 8) * scale,
          decoration: BoxDecoration(
            color: isActive ? AppColors.orange : AppColors.dotInactive,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: 0.4),
                      blurRadius: 8 * scale,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final double scale;
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    required this.scale,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
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
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          height: 56 * s,
          decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(30 * s),
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withValues(alpha: 0.35),
                blurRadius: 24 * s,
                offset: Offset(0, 8 * s),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: AppTextStyles.button().copyWith(fontSize: 18 * s),
          ),
        ),
      ),
    );
  }
}
