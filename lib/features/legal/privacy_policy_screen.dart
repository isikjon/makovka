import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bottom_nav.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _terms = [
    'автоматизированная обработка персональных данных — обработка '
        'персональных данных с помощью средств вычислительной техники;',
    'блокирование персональных данных — временное прекращение обработки '
        'персональных данных (за исключением случаев, если обработка '
        'необходима для уточнения персональных данных);',
    'информационная система персональных данных — совокупность '
        'содержащихся в базах данных персональных данных, и обеспечивающих '
        'их обработку информационных технологий и технических средств;',
    'обезличивание персональных данных — действия, в результате которых '
        'невозможно определить без использования дополнительной информации '
        'принадлежность персональных данных конкретному субъекту '
        'персональных данных;',
    'обработка персональных данных — любое действие (операция) или '
        'совокупность действий (операций), совершаемых с использованием '
        'средств автоматизации или без использования таких средств с '
        'персональными данными, включая сбор, запись, систематизацию, '
        'накопление, хранение, уточнение (обновление, изменение), '
        'извлечение, использование, передачу (распространение, '
        'предоставление, доступ), обезличивание, блокирование, удаление, '
        'уничтожение персональных данных;',
    'оператор — государственный орган, муниципальный орган, юридическое '
        'или физическое лицо, самостоятельно или совместно с другими '
        'лицами организующие и (или) осуществляющие обработку '
        'персональных данных, а также определяющие цели обработки '
        'персональных данных, состав персональных данных, подлежащих '
        'обработке, действия (операции), совершаемые с персональными '
        'данными;',
    'персональные данные — любая информация, относящаяся к прямо или '
        'косвенно определенному или определяемому физическому лицу '
        '(субъекту персональных данных);',
    'предоставление персональных данных — действия, направленные на '
        'раскрытие персональных данных определенному лицу или '
        'определенному кругу лиц;',
    'распространение персональных данных — действия, направленные на '
        'раскрытие персональных данных неопределенному кругу лиц '
        '(передача персональных данных) или на ознакомление с '
        'персональными данными неограниченного круга лиц, в том числе '
        'обнародование персональных данных в средствах массовой '
        'информации, размещение в информационно-телекоммуникационных '
        'сетях или предоставление доступа к персональным данным '
        'каким-либо иным способом;',
    'трансграничная передача персональных данных — передача '
        'персональных данных на территорию иностранного государства '
        'органу власти иностранного государства, иностранному '
        'физическому или иностранному юридическому лицу.',
    'уничтожение персональных данных — действия, в результате которых '
        'невозможно восстановить содержание персональных данных в '
        'информационной системе персональных данных и (или) результате '
        'которых уничтожаются материальные носители персональных данных.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F9),
      body: Stack(
        children: [
          // Decorative header background, sits behind the title and the
          // top of the scrollable content — same pattern as the promo page.
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
                          'Соглашение об обработке персональных данных',
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
                          const _SectionTitle('1. Общие положения'),
                          const SizedBox(height: 14),
                          const _Paragraph(
                            'Политика обработки персональных данных '
                            '(далее – Политика) разработана в соответствии '
                            'с Федеральным законом от 27.07.2006. №152-ФЗ '
                            '«О персональных данных» (далее – ФЗ-152).',
                          ),
                          const SizedBox(height: 16),
                          const _Paragraph(
                            'Настоящая Политика определяет порядок '
                            'обработки персональных данных и меры по '
                            'обеспечению безопасности персональных данных '
                            'в ООО «ВАН ГРУП КОМПАНИ» (далее – Оператор) '
                            'с целью защиты прав и свобод человека и '
                            'гражданина при обработке его персональных '
                            'данных, в том числе защиты прав на '
                            'неприкосновенность частной жизни, личную и '
                            'семейную тайну.',
                          ),
                          const SizedBox(height: 24),
                          const _Paragraph(
                            'В ПОЛИТИКЕ ИСПОЛЬЗУЮТСЯ СЛЕДУЮЩИЕ ОСНОВНЫЕ '
                            'ПОНЯТИЯ:',
                            weight: FontWeight.w700,
                          ),
                          const SizedBox(height: 16),
                          for (final term in _terms) ...[
                            _BulletItem(term),
                            const SizedBox(height: 14),
                          ],
                          const SizedBox(height: 8),
                          const _Paragraph(
                            'Компания обязана опубликовать или иным '
                            'образом обеспечить неограниченный доступ к '
                            'настоящей Политике обработки персональных '
                            'данных в соответствии с ч. 2 ст. 18.1. '
                            'ФЗ-152.',
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
  final FontWeight weight;
  const _Paragraph(this.text, {this.weight = FontWeight.w400});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.body().copyWith(
        fontSize: 14,
        height: 22 / 14,
        fontWeight: weight,
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
