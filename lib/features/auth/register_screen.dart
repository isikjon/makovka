import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_client.dart';
import '../../core/content/json_values.dart';
import '../../core/profile/profile_store.dart';
import '../../core/referral/referral_store.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/status_views.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  static const _designW = 393.0;

  final _nameCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  final _promoCtrl = TextEditingController();
  final _promoFocus = FocusNode();

  bool _showPromo = false;
  bool _submitting = false;
  String? _error;

  late final AnimationController _enter;
  late final Animation<double> _fade;
  late final Animation<Offset> _slideUp;

  bool get _canSubmit => _nameCtrl.text.trim().isNotEmpty;

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

    _nameCtrl.addListener(() => setState(() {}));
    _nameFocus.addListener(() => setState(() {}));
    _promoFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _enter.dispose();
    _nameCtrl.dispose();
    _nameFocus.dispose();
    _promoCtrl.dispose();
    _promoFocus.dispose();
    super.dispose();
  }

  void _togglePromo() {
    setState(() => _showPromo = true);
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      _promoFocus.requestFocus();
    });
  }

  Future<void> _submit() async {
    if (!_canSubmit || _submitting) return;
    final name = _nameCtrl.text.trim();
    final promo = _showPromo ? _promoCtrl.text.trim() : '';
    setState(() {
      _submitting = true;
      _error = null;
    });
    final error = await _putProfile({'name': name});
    if (error != null) {
      if (mounted) {
        setState(() {
          _error = error;
          _submitting = false;
        });
      }
      return;
    }
    final referral = promo.isEmpty
        ? null
        : await ReferralStore.instance.apply(promo);
    final applied = referral?.applied ?? false;
    final promoSaved =
        applied &&
        await _putProfile({'name': name, 'promo_code': promo}) == null;
    await ProfileStore.instance.save(
      ProfileData(
        name: name,
        phone: ProfileStore.instance.data.phone,
        promo: promoSaved ? promo : '',
      ),
    );
    if (!mounted) return;
    if (referral != null) {
      if (applied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(referral.message),
            backgroundColor: AppColors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        showErrorSnackBar(context, referral.message);
      }
    }
    context.go('/home');
  }

  Future<String?> _putProfile(Map<String, dynamic> body) async {
    try {
      await guardRequest(() => ApiClient.instance.put('/profile', body: body));
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
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
                          child: _StepChip(text: 'Шаг 2 из 2', scale: s),
                        ),
                        SizedBox(height: 36 * s),
                        Text(
                          'Как вас зовут?',
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
                          'Осталась пара деталей, чтобы начать\nполучать вкусные бонусы.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body().copyWith(
                            fontSize: 14 * s,
                            height: 20 / 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 40 * s),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel(text: 'Имя', required: true, scale: s),
                            SizedBox(height: 8 * s),
                            _TextInput(
                              controller: _nameCtrl,
                              focusNode: _nameFocus,
                              hint: 'Текст',
                              scale: s,
                            ),
                            SizedBox(height: 20 * s),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutCubic,
                              alignment: Alignment.topCenter,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 280),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                transitionBuilder: (child, anim) =>
                                    FadeTransition(opacity: anim, child: child),
                                child: _showPromo
                                    ? Column(
                                        key: const ValueKey('promo-field'),
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _FieldLabel(
                                            text: 'Промокод друга',
                                            required: false,
                                            scale: s,
                                          ),
                                          SizedBox(height: 8 * s),
                                          _TextInput(
                                            controller: _promoCtrl,
                                            focusNode: _promoFocus,
                                            hint: 'Введите промокод друга',
                                            scale: s,
                                          ),
                                        ],
                                      )
                                    : GestureDetector(
                                        key: const ValueKey('promo-link'),
                                        behavior: HitTestBehavior.opaque,
                                        onTap: _togglePromo,
                                        child: Row(
                                          children: [
                                            Text(
                                              '✨ ',
                                              style: TextStyle(
                                                fontSize: 14 * s,
                                              ),
                                            ),
                                            Text(
                                              'У меня есть промокод друга',
                                              style: AppTextStyles.body().copyWith(
                                                fontSize: 14 * s,
                                                height: 20 / 14,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textPrimary,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor:
                                                    AppColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        if (_error != null) ...[
                          SizedBox(height: 12 * s),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body().copyWith(
                              fontSize: 13 * s,
                              color: const Color(0xFFE05656),
                            ),
                          ),
                        ],
                        SizedBox(height: 32 * s),
                        _SubmitButton(
                          enabled: _canSubmit && !_submitting,
                          loading: _submitting,
                          onTap: _submit,
                          scale: s,
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

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  final double scale;
  const _FieldLabel({
    required this.text,
    required this.required,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: AppTextStyles.body().copyWith(
              fontSize: 14 * scale,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          if (required)
            TextSpan(
              text: '*',
              style: AppTextStyles.body().copyWith(
                fontSize: 14 * scale,
                height: 20 / 14,
                fontWeight: FontWeight.w500,
                color: AppColors.orange,
              ),
            ),
        ],
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final double scale;

  const _TextInput({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 52 * scale,
      padding: EdgeInsets.symmetric(horizontal: 18 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26 * scale),
        border: Border.all(
          color: focusNode.hasFocus
              ? AppColors.orange
              : const Color(0xFFE5E1DE),
          width: 1.4,
        ),
      ),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        cursorColor: AppColors.orange,
        style: AppTextStyles.body().copyWith(
          fontSize: 15 * scale,
          height: 20 / 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
          hintText: hint,
          hintStyle: AppTextStyles.body().copyWith(
            fontSize: 15 * scale,
            height: 20 / 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatefulWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;
  final double scale;

  const _SubmitButton({
    required this.enabled,
    this.loading = false,
    required this.onTap,
    required this.scale,
  });

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
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
          child: widget.loading
              ? SizedBox(
                  width: 22 * s,
                  height: 22 * s,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  'Завершить регистрацию',
                  style: AppTextStyles.button().copyWith(
                    fontSize: 18 * s,
                    color: widget.enabled
                        ? Colors.white
                        : const Color(0xFFF3F1EF),
                  ),
                ),
        ),
      ),
    );
  }
}
