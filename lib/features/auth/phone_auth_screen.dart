import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../core/theme/app_theme.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen>
    with SingleTickerProviderStateMixin {
  static const _designW = 393.0;

  final _phoneCtrl = TextEditingController();
  final _phoneFocus = FocusNode();
  final _mask = MaskTextInputFormatter(
    mask: '+7 (###) ###-##-##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.eager,
  );

  bool _agreedTerms = false;
  bool _agreedPrivacy = false;

  late final AnimationController _enter;
  late final Animation<double> _fade;
  late final Animation<Offset> _slideUp;

  bool get _phoneValid => _mask.getUnmaskedText().length == 10;
  bool get _canProceed => _phoneValid && _agreedTerms && _agreedPrivacy;

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
    _phoneCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _enter.dispose();
    _phoneCtrl.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_canProceed) return;
    context.go('/auth/otp');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final s = width / _designW;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F9),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SizedBox.expand(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Orange gradient bg (top blob), fills entire screen
              Positioned.fill(
                child: SvgPicture.asset(
                  'assets/images/auth_phone_bg.svg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),

                // Step chip top-right
                Positioned(
                  top: 44 * s,
                  right: 24 * s,
                  child: FadeTransition(
                    opacity: _fade,
                    child: _StepChip(text: 'Шаг 1 из 2', scale: s),
                  ),
                ),

                // "Вход в систему" title on orange
                Positioned(
                  top: 108 * s,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slideUp,
                      child: Text(
                        'Вход в систему',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h1().copyWith(
                          fontSize: 24 * s,
                          height: 30 / 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                // Subtitle
                Positioned(
                  top: 236 * s,
                  left: 24 * s,
                  right: 24 * s,
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slideUp,
                      child: Text(
                        'Введите свой номер телефона для\nвхода/регистрации',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body().copyWith(
                          fontSize: 14 * s,
                          height: 20 / 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),

                // Phone input
                Positioned(
                  top: 300 * s,
                  left: 24 * s,
                  right: 24 * s,
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slideUp,
                      child: _PhoneField(
                        controller: _phoneCtrl,
                        focusNode: _phoneFocus,
                        mask: _mask,
                        scale: s,
                      ),
                    ),
                  ),
                ),

                // Checkbox: terms
                Positioned(
                  top: 384 * s,
                  left: 24 * s,
                  right: 24 * s,
                  child: FadeTransition(
                    opacity: _fade,
                    child: _AgreementRow(
                      checked: _agreedTerms,
                      scale: s,
                      onToggle: () =>
                          setState(() => _agreedTerms = !_agreedTerms),
                      textSpans: [
                        TextSpan(
                          text: 'При входе/регистрации вы принимаете\nусловия ',
                          style: AppTextStyles.body().copyWith(
                            fontSize: 12 * s,
                            height: 16 / 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextSpan(
                          text: 'пользовательского соглашения',
                          style: AppTextStyles.body().copyWith(
                            fontSize: 12 * s,
                            height: 16 / 12,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.push('/legal/privacy'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Checkbox: privacy
                Positioned(
                  top: 448 * s,
                  left: 24 * s,
                  right: 24 * s,
                  child: FadeTransition(
                    opacity: _fade,
                    child: _AgreementRow(
                      checked: _agreedPrivacy,
                      scale: s,
                      onToggle: () =>
                          setState(() => _agreedPrivacy = !_agreedPrivacy),
                      textSpans: [
                        TextSpan(
                          text: 'Согласны с ',
                          style: AppTextStyles.body().copyWith(
                            fontSize: 12 * s,
                            height: 16 / 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextSpan(
                          text: 'политикой конфиденциальности',
                          style: AppTextStyles.body().copyWith(
                            fontSize: 12 * s,
                            height: 16 / 12,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.push('/legal/privacy'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Далее button
                Positioned(
                  bottom: 40 * s,
                  left: 24 * s,
                  right: 24 * s,
                  child: FadeTransition(
                    opacity: _fade,
                    child: _ContinueButton(
                      enabled: _canProceed,
                      onTap: _submit,
                      scale: s,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}

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

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final MaskTextInputFormatter mask;
  final double scale;

  const _PhoneField({
    required this.controller,
    required this.focusNode,
    required this.mask,
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
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.phone,
        inputFormatters: [mask],
        textAlign: TextAlign.center,
        cursorColor: AppColors.orange,
        style: AppTextStyles.body().copyWith(
          fontSize: 16 * scale,
          height: 20 / 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
          hintText: '+7 (xxx) xxx-xx-xx',
          hintStyle: AppTextStyles.body().copyWith(
            fontSize: 16 * scale,
            height: 20 / 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _AgreementRow extends StatelessWidget {
  final bool checked;
  final VoidCallback onToggle;
  final List<InlineSpan> textSpans;
  final double scale;

  const _AgreementRow({
    required this.checked,
    required this.onToggle,
    required this.textSpans,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AnimatedCheckbox(checked: checked, scale: scale),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2 * scale),
              child: RichText(
                text: TextSpan(children: textSpans),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCheckbox extends StatelessWidget {
  final bool checked;
  final double scale;
  const _AnimatedCheckbox({required this.checked, required this.scale});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: 20 * scale,
      height: 20 * scale,
      decoration: BoxDecoration(
        color: checked ? AppColors.orange : Colors.white,
        borderRadius: BorderRadius.circular(5 * scale),
        border: Border.all(
          color: checked ? AppColors.orange : const Color(0xFFD9D5D2),
          width: 1.4,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: checked
            ? Icon(
                Icons.check_rounded,
                key: const ValueKey('check'),
                size: 14 * scale,
                color: Colors.white,
              )
            : const SizedBox.shrink(key: ValueKey('empty')),
      ),
    );
  }
}

class _ContinueButton extends StatefulWidget {
  final bool enabled;
  final VoidCallback onTap;
  final double scale;

  const _ContinueButton({
    required this.enabled,
    required this.onTap,
    required this.scale,
  });

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final enabled = widget.enabled;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          height: 56 * s,
          decoration: BoxDecoration(
            color: enabled ? AppColors.orange : const Color(0xFFD9D5D2),
            borderRadius: BorderRadius.circular(30 * s),
            boxShadow: enabled
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
            'Далее',
            style: AppTextStyles.button().copyWith(
              fontSize: 18 * s,
              color: enabled ? Colors.white : const Color(0xFFF3F1EF),
            ),
          ),
        ),
      ),
    );
  }
}
