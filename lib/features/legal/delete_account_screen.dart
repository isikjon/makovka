import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bottom_nav.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Text(
                          'Удаление аккаунта',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: AppTextStyles.h1().copyWith(
                            fontSize: 18,
                            height: 22 / 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
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
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('Как удалить аккаунт'),
                          const SizedBox(height: 14),
                          const _Paragraph(
                            'Чтобы удалить свой аккаунт в приложении '
                            '«Маковка» и связанные с ним данные, '
                            'напишите нам на почту s99071484@gmail.com '
                            'или позвоните по номеру +7 921 367 78 97, '
                            'указав номер телефона, на который '
                            'зарегистрирован аккаунт.',
                          ),
                          const SizedBox(height: 16),
                          const _Paragraph(
                            'Мы обрабатываем запрос и удаляем аккаунт в '
                            'течение 30 дней с момента обращения.',
                          ),
                          const SizedBox(height: 24),
                          const _SectionTitle('Какие данные удаляются'),
                          const SizedBox(height: 14),
                          const _BulletItem(
                            'Номер телефона, имя, фамилия, email, дата '
                            'рождения и пол, указанные в профиле.',
                          ),
                          const SizedBox(height: 12),
                          const _BulletItem(
                            'Связь аккаунта с картой лояльности в '
                            'системе iiko, используемой пекарней.',
                          ),
                          const SizedBox(height: 24),
                          const _SectionTitle('Какие данные сохраняются'),
                          const SizedBox(height: 14),
                          const _Paragraph(
                            'История покупок и начисленных скидок может '
                            'сохраняться в обезличенном виде в течение '
                            'срока, установленного законодательством о '
                            'бухгалтерском и налоговом учёте, без '
                            'привязки к удалённому аккаунту.',
                          ),
                          SizedBox(height: AppBottomNav.barHeight + 32),
                        ],
                      ),
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.h1().copyWith(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  const _Paragraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.body().copyWith(
        fontSize: 14,
        height: 22 / 14,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: const BoxDecoration(
              color: AppColors.orange,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(child: _Paragraph(text)),
        ],
      ),
    );
  }
}
