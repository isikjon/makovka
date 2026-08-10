import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  static const _designW = 393.0;
  static const _codeLen = 6;
  static const _resendSeconds = 58;

  final _codeCtrl = TextEditingController();
  final _codeFocus = FocusNode();

  Timer? _timer;
  int _secondsLeft = _resendSeconds;

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
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic));

    _codeCtrl.addListener(_onCodeChanged);
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _codeFocus.requestFocus();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _onCodeChanged() {
    setState(() {});
    if (_codeCtrl.text.length == _codeLen) {
      _verify();
    }
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    context.go('/auth/register');
  }

  void _resend() {
    if (_secondsLeft > 0) return;
    _codeCtrl.clear();
    _startTimer();
    _codeFocus.requestFocus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _enter.dispose();
    _codeCtrl.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  String _fmtTimer() {
    final m = (_secondsLeft ~/ 60).toString();
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final s = width / _designW;
    final canResend = _secondsLeft == 0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F9),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/auth_phone_bg.svg',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slideUp,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 20 * s),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _StepChip(text: 'Шаг 1 из 2', scale: s),
                        ),
                        SizedBox(height: 36 * s),
                        Text(
                          'Вход в систему',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h1().copyWith(
                            fontSize: 24 * s,
                            height: 30 / 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 24 * s),
                        Text(
                          'Введите код из SMS',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body().copyWith(
                            fontSize: 14 * s,
                            height: 20 / 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 40 * s),
                        _CodeField(
                          controller: _codeCtrl,
                          focusNode: _codeFocus,
                          length: _codeLen,
                          scale: s,
                        ),
                        SizedBox(height: 24 * s),
                        _ResendButton(
                          enabled: canResend,
                          onTap: _resend,
                          scale: s,
                        ),
                        SizedBox(height: 24 * s),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Получить новый код: ',
                                style: AppTextStyles.body().copyWith(
                                  fontSize: 14 * s,
                                  height: 20 / 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                _fmtTimer(),
                                style: AppTextStyles.body().copyWith(
                                  fontSize: 14 * s,
                                  height: 20 / 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32 * s),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- shared widgets (kept local to this file for simplicity) ----

class _StepChip extends StatelessWidget {
  final String text;
  final double scale;
  const _StepChip({required this.text, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 6 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Text(
        text,
        style: AppTextStyles.body().copyWith(
          fontSize: 12 * scale,
          height: 16 / 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _CodeField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final double scale;

  const _CodeField({
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 56 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30 * scale),
        border: Border.all(
          color: focusNode.hasFocus
              ? AppColors.orange
              : const Color(0xFFE5E1DE),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Visible digits with placeholder styling
          IgnorePointer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(length, (i) {
                final entered = i < controller.text.length;
                final ch = entered ? controller.text[i] : '0';
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6 * scale),
                  child: Text(
                    ch,
                    style: AppTextStyles.body().copyWith(
                      fontSize: 18 * scale,
                      height: 22 / 18,
                      fontWeight: FontWeight.w600,
                      color: entered
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                );
              }),
            ),
          ),
          // Invisible text field capturing input
          Opacity(
            opacity: 0.0,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(length),
              ],
              autofillHints: const [AutofillHints.oneTimeCode],
              cursorColor: AppColors.orange,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18 * scale),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResendButton extends StatefulWidget {
  final bool enabled;
  final VoidCallback onTap;
  final double scale;
  const _ResendButton({
    required this.enabled,
    required this.onTap,
    required this.scale,
  });

  @override
  State<_ResendButton> createState() => _ResendButtonState();
}

class _ResendButtonState extends State<_ResendButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          height: 56 * s,
          decoration: BoxDecoration(
            color: widget.enabled ? AppColors.orange : const Color(0xFFD9D5D2),
            borderRadius: BorderRadius.circular(30 * s),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: 0.35),
                      blurRadius: 24 * s,
                      offset: Offset(0, 8 * s),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            'Получить код',
            style: AppTextStyles.button().copyWith(
              fontSize: 18 * s,
              color: widget.enabled ? Colors.white : const Color(0xFFF3F1EF),
            ),
          ),
        ),
      ),
    );
  }
}
