import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bottom_nav.dart';

enum _Gender { male, female }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController(text: 'Андрей');
  final _surnameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _birthdateCtrl = TextEditingController();
  final _promoCtrl = TextEditingController();

  final _phoneMask = MaskTextInputFormatter(
    mask: '+7 (###) ###-##-##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.eager,
  );
  final _dateMask = MaskTextInputFormatter(
    mask: '##.##.####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.eager,
  );

  _Gender? _gender = _Gender.female;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _nameCtrl,
      _surnameCtrl,
      _phoneCtrl,
      _emailCtrl,
      _birthdateCtrl,
      _promoCtrl,
    ]) {
      c.addListener(() => setState(() {}));
    }
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _birthdateCtrl.dispose();
    _promoCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _nameCtrl.text = prefs.getString('profile_name') ?? _nameCtrl.text;
      _surnameCtrl.text = prefs.getString('profile_surname') ?? '';
      _phoneCtrl.text = prefs.getString('profile_phone') ?? '';
      _emailCtrl.text = prefs.getString('profile_email') ?? '';
      _birthdateCtrl.text = prefs.getString('profile_birthdate') ?? '';
      _promoCtrl.text = prefs.getString('profile_promo') ?? '';
      final genderRaw = prefs.getString('profile_gender');
      if (genderRaw == 'male') _gender = _Gender.male;
      if (genderRaw == 'female') _gender = _Gender.female;
    });
  }

  Future<void> _saveProfile() async {
    if (_saving) return;

    final missing = <String>[];
    if (_nameCtrl.text.trim().isEmpty) missing.add('Имя');
    if (_phoneCtrl.text.trim().isEmpty) missing.add('Номер телефона');
    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Заполните обязательные поля: ${missing.join(', ')}'),
          backgroundColor: const Color(0xFFE05656),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_name', _nameCtrl.text.trim());
      await prefs.setString('profile_surname', _surnameCtrl.text.trim());
      await prefs.setString('profile_phone', _phoneCtrl.text.trim());
      await prefs.setString('profile_email', _emailCtrl.text.trim());
      await prefs.setString('profile_birthdate', _birthdateCtrl.text.trim());
      await prefs.setString('profile_promo', _promoCtrl.text.trim());
      await prefs.setString(
        'profile_gender',
        _gender == _Gender.male ? 'male' : 'female',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Профиль сохранён'),
          backgroundColor: AppColors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => const _LogoutDialog(),
    );
    if (confirmed == true && mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F9),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 230,
                width: double.infinity,
                child: SvgPicture.asset(
                  'assets/images/auth_phone_bg.svg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),

            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          'Профиль',
                          style: AppTextStyles.h1().copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          left: 16,
                          child: _CircleIconButton(
                            asset: 'assets/icons/back.svg',
                            onTap: () => context.pop(),
                          ),
                        ),
                        Positioned(
                          right: 16,
                          child: _CircleIconButton(
                            asset: 'assets/icons/exit.svg',
                            onTap: _confirmLogout,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel(text: 'Имя', required: true),
                          const SizedBox(height: 8),
                          _ProfileInput(
                            controller: _nameCtrl,
                            hint: 'Введите имя',
                          ),
                          const SizedBox(height: 20),
                          const _FieldLabel(text: 'Фамилия'),
                          const SizedBox(height: 8),
                          _ProfileInput(
                            controller: _surnameCtrl,
                            hint: 'Введите фамилию',
                          ),
                          const SizedBox(height: 20),
                          const _FieldLabel(
                            text: 'Номер телефона',
                            required: true,
                          ),
                          const SizedBox(height: 8),
                          _ProfileInput(
                            controller: _phoneCtrl,
                            hint: '+7',
                            keyboardType: TextInputType.phone,
                            formatters: [_phoneMask],
                          ),
                          const SizedBox(height: 20),
                          const _FieldLabel(text: 'Электронная почта'),
                          const SizedBox(height: 8),
                          _ProfileInput(
                            controller: _emailCtrl,
                            hint: 'Введите вашу почту',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          const _FieldLabel(text: 'Дата Рождения'),
                          const SizedBox(height: 8),
                          _ProfileInput(
                            controller: _birthdateCtrl,
                            hint: 'ДД.ММ.ГГГГ',
                            keyboardType: TextInputType.number,
                            formatters: [_dateMask],
                          ),
                          const SizedBox(height: 20),
                          const _FieldLabel(text: 'Пол'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _GenderChip(
                                label: 'Мужской',
                                selected: _gender == _Gender.male,
                                onTap: () =>
                                    setState(() => _gender = _Gender.male),
                              ),
                              const SizedBox(width: 12),
                              _GenderChip(
                                label: 'Женский',
                                selected: _gender == _Gender.female,
                                onTap: () =>
                                    setState(() => _gender = _Gender.female),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const _FieldLabel(text: 'Промокод'),
                          const SizedBox(height: 8),
                          _ProfileInput(
                            controller: _promoCtrl,
                            hint: 'Введите промокод друга',
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '* Поля обязательные для заполнения',
                            style: AppTextStyles.body().copyWith(
                              fontSize: 13,
                              height: 18 / 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _SaveButton(
                            saving: _saving,
                            onTap: _saveProfile,
                          ),
                          SizedBox(height: AppBottomNav.barHeight + 24),
                        ],
                      ),
                    ),
                  ),
                ],
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
      ),
    );
  }
}

class _CircleIconButton extends StatefulWidget {
  final String asset;
  final VoidCallback onTap;
  const _CircleIconButton({required this.asset, required this.onTap});

  @override
  State<_CircleIconButton> createState() => _CircleIconButtonState();
}

class _CircleIconButtonState extends State<_CircleIconButton> {
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
          child: SvgPicture.asset(widget.asset),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _FieldLabel({required this.text, this.required = false});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: AppTextStyles.body().copyWith(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          if (required)
            TextSpan(
              text: '*',
              style: AppTextStyles.body().copyWith(
                fontSize: 14,
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

class _ProfileInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;

  const _ProfileInput({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.formatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE5E1DE), width: 1.4),
      ),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        cursorColor: AppColors.orange,
        style: AppTextStyles.body().copyWith(
          fontSize: 15,
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
            fontSize: 15,
            height: 20 / 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.orange : const Color(0xFFE5E1DE),
            width: 1.4,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body().copyWith(
            fontSize: 15,
            height: 20 / 15,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.orange : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  final bool saving;
  final VoidCallback onTap;
  const _SaveButton({
    required this.saving,
    required this.onTap,
  });

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.saving ? null : (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.saving ? null : widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          height: 56,
          width: double.infinity,
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
          child: widget.saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  'Сохранить',
                  style: AppTextStyles.button().copyWith(fontSize: 18),
                ),
        ),
      ),
    );
  }
}

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              children: [
                Text(
                  'Выход',
                  style: AppTextStyles.h1().copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Выйти из приложения?',
                  style: AppTextStyles.body().copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E1DE)),
          SizedBox(
            height: 48,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Center(
                      child: Text(
                        'Да',
                        style: AppTextStyles.body().copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: double.infinity,
                  child: VerticalDivider(width: 1, color: Color(0xFFE5E1DE)),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Center(
                      child: Text(
                        'Нет',
                        style: AppTextStyles.body().copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.orange,
                        ),
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
