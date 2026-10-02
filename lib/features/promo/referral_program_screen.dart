import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/format/money_format.dart';
import '../../core/referral/referral_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../shared/widgets/status_views.dart';

class ReferralProgramScreen extends StatefulWidget {
  const ReferralProgramScreen({super.key});

  @override
  State<ReferralProgramScreen> createState() => _ReferralProgramScreenState();
}

class _ReferralProgramScreenState extends State<ReferralProgramScreen>
    with SingleTickerProviderStateMixin {
  final _store = ReferralStore.instance;

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

  void _copy(String text, String confirmation) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(confirmation),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F9),
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slideUp,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final headerH =
                            constraints.maxWidth / _Header.aspectRatio;
                        final contentTop = headerH * _Header.whiteStartFrac;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _Header(onBack: () => context.pop()),
                            Positioned(
                              top: contentTop,
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  24,
                                  24,
                                  0,
                                ),
                                child: ListenableBuilder(
                                  listenable: _store,
                                  builder: (context, _) => Column(
                                    children: [
                                      ..._buildBody(),
                                      SizedBox(
                                        height: AppBottomNav.barHeight + 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNav(
              currentIndex: 1,
              onTap: (i) {
                if (i == 0) {
                  context.go('/home');
                } else {
                  context.pop();
                }
              },
              onLogoTap: () => context.push('/qr'),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBody() {
    final info = _store.info;
    if (info == null) {
      final error = _store.error;
      if (error != null && !_store.isLoading) {
        return [
          StatusMessage(
            title: 'Не удалось загрузить промокод',
            subtitle: error,
            onRetry: () => _store.load(force: true),
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
    final bodyStyle = AppTextStyles.body().copyWith(
      fontSize: 14,
      height: 20 / 14,
      color: AppColors.textSecondary,
    );
    final bonus = info.hasBonus
        ? '${formatAmount(info.bonusPerFriend)} ${_bonusWord(info.bonusPerFriend)}'
        : null;
    return [
      Text(
        bonus == null
            ? 'Вместе вкуснее!\nПриглашайте друзей'
            : 'Вместе вкуснее!\n$bonus вам и другу',
        textAlign: TextAlign.center,
        style: AppTextStyles.h1().copyWith(
          fontSize: 20,
          height: 26 / 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 20),
      _PromoCodeField(
        code: info.code,
        onCopy: () => _copy(info.code, 'Промокод скопирован'),
      ),
      const SizedBox(height: 20),
      Text(
        'Или отправьте другу приглашение: он сможет указать ваш промокод '
        'при регистрации или в профиле.',
        style: bodyStyle,
      ),
      const SizedBox(height: 12),
      Text(
        bonus == null
            ? 'Бонусы за приглашения появятся позже.'
            : 'После первой покупки друга вы оба получите по $bonus. '
                  'Больше друзей — больше бонусов на вашем счету.',
        style: bodyStyle,
      ),
      const SizedBox(height: 24),
      _SendButton(
        onTap: () => _copy(
          info.shareText,
          'Приглашение скопировано — отправьте его другу',
        ),
      ),
      const SizedBox(height: 24),
      Text(
        _statsLine(info),
        textAlign: TextAlign.center,
        style: AppTextStyles.body().copyWith(
          fontSize: 11,
          height: 16 / 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 0.2,
        ),
      ),
    ];
  }

  String _statsLine(ReferralInfo info) {
    return 'ПРИГЛАШЕНО ДРУЗЕЙ: ${info.invitedCount} · '
        'НАГРАД ПОЛУЧЕНО: ${info.rewardedCount}';
  }

  String _bonusWord(double amount) {
    if (amount != amount.roundToDouble()) return 'бонуса';
    final n = amount.round().abs();
    final lastTwo = n % 100;
    final last = n % 10;
    if (lastTwo >= 11 && lastTwo <= 14) return 'бонусов';
    if (last == 1) return 'бонус';
    if (last >= 2 && last <= 4) return 'бонуса';
    return 'бонусов';
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  static const aspectRatio = 1572 / 3408;
  static const whiteStartFrac = 1024 / 3408;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/referral_page_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.high,
              isAntiAlias: true,
            ),
          ),
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.infinity,
              height: 68,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Text(
                      'Реферальная\nпрограмма',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: AppTextStyles.h1().copyWith(
                        fontSize: 20,
                        height: 24 / 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    top: 0,
                    child: _BackButton(onTap: onBack),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

class _PromoCodeField extends StatelessWidget {
  final String code;
  final VoidCallback onCopy;
  const _PromoCodeField({required this.code, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E1DE), width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ваш промокод',
                  style: AppTextStyles.body().copyWith(
                    fontSize: 12,
                    height: 16 / 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  code,
                  style: AppTextStyles.h1().copyWith(
                    fontSize: 18,
                    height: 22 / 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          _CopyButton(onTap: onCopy),
        ],
      ),
    );
  }
}

class _CopyButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CopyButton({required this.onTap});

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
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
        child: SvgPicture.asset('assets/icons/copy.svg', width: 44, height: 44),
      ),
    );
  }
}

class _SendButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SendButton({required this.onTap});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
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
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Отправить другу',
                style: AppTextStyles.button().copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
