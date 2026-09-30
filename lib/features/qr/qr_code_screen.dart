import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/api/api_client.dart';
import '../../core/loyalty/loyalty_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../shared/widgets/status_views.dart';

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen>
    with SingleTickerProviderStateMixin {
  final _store = LoyaltyStore.instance;
  String? _fallbackCard;
  late bool _busy = _store.info?.cardNumber == null;
  String? _error;

  late final AnimationController _enter;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fade = CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _enter, curve: Curves.easeOutBack),
    );
    if (_busy) _resolveCard();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Future<void> _resolveCard({bool force = false}) async {
    try {
      final card = await _store.resolveCardNumber(force: force);
      if (!mounted) return;
      setState(() {
        _fallbackCard = card;
        _busy = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _busy = false;
      });
    }
  }

  void _retry() {
    setState(() {
      _busy = true;
      _error = null;
    });
    _resolveCard(force: true);
  }

  Widget _buildCardContent() {
    final info = _store.info;
    final card = info?.cardNumber ?? _fallbackCard;
    if (card != null) return _QrCode(code: card);
    if (_busy) return const _CardPlaceholder(child: LoadingSpinner());
    final error = _error ?? (info == null ? _store.error : null);
    if (error != null) {
      return _CardPlaceholder(
        child: StatusMessage(
          title: 'Не удалось загрузить код',
          subtitle: error,
          onRetry: _retry,
        ),
      );
    }
    if (info?.syncStatus == 'failed') {
      return _CardPlaceholder(
        child: StatusMessage(
          title: 'Не удалось оформить карту',
          subtitle:
              'Нажмите «Повторить». Если не получится, '
              'обратитесь к сотруднику пекарни',
          onRetry: _retry,
        ),
      );
    }
    return _CardPlaceholder(
      child: StatusMessage(
        title: 'Карта оформляется, попробуйте через минуту',
        onRetry: _retry,
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
              child: LayoutBuilder(
                builder: (context, outerConstraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      // Fills at least the full viewport height (like
                      // min-height: 100vh), so the background never looks
                      // like it's floating in a too-short page.
                      constraints: BoxConstraints(
                        minHeight: outerConstraints.maxHeight,
                      ),
                      child: FadeTransition(
                        opacity: _fade,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Fixed 852px design height — the same
                            // 393x852 mobile frame used across the rest
                            // of the app, so this never scales with the
                            // browser window and can't "float".
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: SizedBox(
                                height: _designHeight,
                                child: Image.asset(
                                  'assets/images/qr_page_bg.png',
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                  filterQuality: FilterQuality.high,
                                  isAntiAlias: true,
                                ),
                              ),
                            ),
                            // Fills any leftover space below the 852px
                            // frame (e.g. on a taller viewport) with the
                            // flat page color.
                            Positioned(
                              top: _designHeight,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: const ColoredBox(
                                color: Color(0xFFFAF9F9),
                              ),
                            ),

                            // Close button
                            Positioned(
                              top: 20,
                              right: 20,
                              child: _CloseButton(
                                onTap: () => context.pop(),
                              ),
                            ),

                            // Title + subtitle, inside the top wave
                            const Positioned(
                              top: 70,
                              left: 24,
                              right: 24,
                              child: _HeaderText(),
                            ),

                            // QR code card, overlapping the top wave
                            Positioned(
                              top: 190,
                              left: 24,
                              right: 24,
                              child: Center(
                                child: ScaleTransition(
                                  scale: _scale,
                                  child: ListenableBuilder(
                                    listenable: _store,
                                    builder: (context, _) =>
                                        _QrCard(child: _buildCardContent()),
                                  ),
                                ),
                              ),
                            ),

                            // Reserves room below the card so the bottom
                            // nav never overlaps it.
                            SizedBox(
                              height: _designHeight + AppBottomNav.barHeight,
                              width: double.infinity,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
              onLogoTap: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fixed design frame height.
const _designHeight = 832.0;

class _HeaderText extends StatelessWidget {
  const _HeaderText();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Ваш персональный код',
          textAlign: TextAlign.center,
          style: AppTextStyles.h1().copyWith(
            fontSize: 20,
            height: 24 / 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Покажите QR-код сотруднику пекарни',
          textAlign: TextAlign.center,
          style: AppTextStyles.body().copyWith(
            fontSize: 14,
            height: 18 / 14,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

class _CloseButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
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
        child: SvgPicture.asset(
          'assets/icons/close.svg',
          width: 44,
          height: 44,
        ),
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  final Widget child;
  const _QrCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 247,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _QrCode extends StatelessWidget {
  final String code;
  const _QrCode({required this.code});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QrImageView(
          data: code,
          version: QrVersions.auto,
          size: 200,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: AppColors.textPrimary,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          code,
          style: AppTextStyles.body().copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _CardPlaceholder extends StatelessWidget {
  final Widget child;
  const _CardPlaceholder({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 237,
      child: Center(child: child),
    );
  }
}
