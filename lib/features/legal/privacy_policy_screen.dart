import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bottom_nav.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                          'Политика конфиденциальности',
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
                      child: SelectionArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Политика конфиденциальности мобильного '
                              'приложения «Пекарня»',
                              style: AppTextStyles.h1().copyWith(
                                fontSize: 20,
                                height: 26 / 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Редакция от 2 октября 2026 г.',
                              style: AppTextStyles.body().copyWith(
                                fontSize: 13,
                                height: 18 / 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const _Section('1. Общие положения', [
                              _Paragraph(
                                'Настоящая Политика конфиденциальности '
                                '(далее — Политика) описывает, какие '
                                'персональные данные собирает мобильное '
                                'приложение «Пекарня» (далее — Приложение), '
                                'с какой целью они обрабатываются, кому '
                                'передаются и как пользователь может ими '
                                'управлять.',
                              ),
                              _Paragraph(
                                'Оператором персональных данных является '
                                'ИП Каменев А.Н. (далее — Оператор), '
                                'владелец программы лояльности пекарни. '
                                'Обработка персональных данных '
                                'осуществляется в соответствии с '
                                'Федеральным законом от 27.07.2006 '
                                '№ 152-ФЗ «О персональных данных».',
                              ),
                              _Paragraph(
                                'Устанавливая Приложение и проходя '
                                'регистрацию, пользователь подтверждает, '
                                'что ознакомлен с настоящей Политикой и '
                                'даёт согласие на обработку своих '
                                'персональных данных на описанных в ней '
                                'условиях.',
                              ),
                            ]),
                            const _Section('2. Какие данные мы собираем', [
                              _Paragraph(
                                'Данные, которые пользователь указывает сам:',
                              ),
                              _Bullet(
                                '*Номер мобильного телефона* — обязателен, '
                                'используется для входа в Приложение по '
                                'одноразовому SMS-коду и для идентификации '
                                'карты лояльности;',
                              ),
                              _Bullet(
                                '*Имя, фамилия, адрес электронной почты, '
                                'дата рождения, пол* — указываются по '
                                'желанию в профиле пользователя.',
                              ),
                              _Paragraph(
                                'Данные, которые формируются при '
                                'использовании программы лояльности:',
                              ),
                              _Bullet(
                                '*Номер карты лояльности*, привязанной к '
                                'номеру телефона пользователя;',
                              ),
                              _Bullet(
                                '*История покупок по карте лояльности*: '
                                'дата покупки, сумма чека, размер '
                                'предоставленной скидки и пекарня, в '
                                'которой совершена покупка. Состав чека '
                                '(перечень товаров) в Приложении не '
                                'собирается и не отображается.',
                              ),
                              _Paragraph('Технические данные:'),
                              _Bullet(
                                'Версия Приложения и операционной системы, '
                                'сведения об ошибках работы Приложения — '
                                'только для обеспечения его стабильной '
                                'работы.',
                              ),
                              _Paragraph(
                                'Приложение *не собирает* данные о '
                                'местоположении устройства, не получает '
                                'доступ к контактам, камере, микрофону, '
                                'фотографиям и файлам пользователя, не '
                                'использует рекламные идентификаторы и '
                                'сторонние сервисы аналитики.',
                              ),
                            ]),
                            const _Section('3. Цели обработки', [
                              _Bullet(
                                'Регистрация и авторизация пользователя в '
                                'Приложении;',
                              ),
                              _Bullet(
                                'Выпуск и обслуживание карты лояльности, '
                                'идентификация пользователя на кассе по '
                                'QR-коду;',
                              ),
                              _Bullet(
                                'Предоставление скидок и иных преимуществ '
                                'программы лояльности;',
                              ),
                              _Bullet(
                                'Отображение истории покупок и информации '
                                'о скидках в Приложении;',
                              ),
                              _Bullet(
                                'Информирование об акциях и предложениях '
                                'пекарни внутри Приложения;',
                              ),
                              _Bullet(
                                'Обработка обращений пользователей и '
                                'поддержка.',
                              ),
                            ]),
                            const _Section('4. Передача данных третьим лицам', [
                              _Paragraph(
                                'Оператор передаёт персональные данные '
                                'только в объёме, необходимом для работы '
                                'программы лояльности:',
                              ),
                              _Bullet(
                                '*Учётная система iiko* (ООО «АЙКО») — '
                                'используется пекарней для учёта продаж и '
                                'ведения карт лояльности. В систему iiko '
                                'передаются номер телефона и, при наличии, '
                                'имя, фамилия и дата рождения пользователя; '
                                'из неё '
                                'Приложение получает номер карты '
                                'лояльности и историю покупок по ней.',
                              ),
                              _Bullet(
                                '*Сервис доставки SMS-сообщений* — '
                                'используется исключительно для отправки '
                                'одноразового кода входа. Сервису '
                                'передаётся только номер телефона '
                                'пользователя.',
                              ),
                              _Paragraph(
                                'Оператор не продаёт персональные данные и '
                                'не передаёт их третьим лицам в рекламных '
                                'целях. Персональные данные могут быть '
                                'раскрыты по законному требованию '
                                'уполномоченных государственных органов.',
                              ),
                            ]),
                            const _Section('5. Хранение и защита данных', [
                              _Paragraph(
                                'Персональные данные хранятся на серверах '
                                'Оператора. Обмен данными между '
                                'Приложением и сервером осуществляется по '
                                'защищённому протоколу HTTPS. Доступ к '
                                'данным имеют только уполномоченные '
                                'сотрудники Оператора, которым он '
                                'необходим для выполнения служебных '
                                'обязанностей.',
                              ),
                              _Paragraph(
                                'Персональные данные хранятся до момента '
                                'удаления аккаунта пользователя, если иной '
                                'срок не установлен законодательством.',
                              ),
                            ]),
                            const _Section('6. Права пользователя', [
                              _Paragraph('Пользователь вправе:'),
                              _Bullet(
                                'получить сведения о том, какие его '
                                'персональные данные обрабатываются;',
                              ),
                              _Bullet(
                                'изменить или уточнить данные профиля '
                                'непосредственно в Приложении;',
                              ),
                              _Bullet(
                                'отозвать согласие на обработку '
                                'персональных данных и потребовать '
                                'удаления аккаунта;',
                              ),
                              _Bullet(
                                'обжаловать действия Оператора в '
                                'уполномоченном органе по защите прав '
                                'субъектов персональных данных.',
                              ),
                            ]),
                            _Section('7. Удаление аккаунта', [
                              const _Paragraph(
                                'Пользователь может запросить удаление '
                                'аккаунта и связанных с ним персональных '
                                'данных, написав на адрес '
                                's99071484@gmail.com или позвонив по '
                                'номеру +7 921 367 78 97, с указанием '
                                'номера телефона, на который '
                                'зарегистрирован аккаунт. Запрос '
                                'обрабатывается в течение 30 дней.',
                              ),
                              const _Paragraph(
                                'При удалении аккаунта удаляются номер '
                                'телефона, имя, фамилия, электронная '
                                'почта, дата рождения, пол и связь '
                                'аккаунта с картой лояльности. История '
                                'покупок может сохраняться в обезличенном '
                                'виде в течение срока, установленного '
                                'законодательством о бухгалтерском и '
                                'налоговом учёте. Подробнее:',
                              ),
                              _Link(
                                'Инструкция по удалению аккаунта',
                                onTap: () =>
                                    context.push('/legal/delete-account'),
                              ),
                            ]),
                            const _Section('8. Дети', [
                              _Paragraph(
                                'Приложение не предназначено для лиц '
                                'младше 18 лет. Оператор сознательно не '
                                'собирает персональные данные детей. Если '
                                'вам стало известно, что ребёнок '
                                'предоставил нам свои данные, свяжитесь с '
                                'нами по контактам ниже, и данные будут '
                                'удалены.',
                              ),
                            ]),
                            const _Section('9. Изменения Политики', [
                              _Paragraph(
                                'Оператор вправе вносить изменения в '
                                'настоящую Политику. Актуальная редакция '
                                'всегда доступна по адресу '
                                'https://app.top1makovka.ru/privacy.html. '
                                'Дата последнего обновления указана в '
                                'начале документа.',
                              ),
                            ]),
                            const _Section('10. Контакты', [
                              _Paragraph(
                                'По вопросам обработки персональных '
                                'данных: электронная почта '
                                's99071484@gmail.com, телефон '
                                '+7 921 367 78 97.',
                              ),
                            ]),
                            SizedBox(height: AppBottomNav.barHeight + 32),
                          ],
                        ),
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

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h1().copyWith(
              fontSize: 18,
              height: 24 / 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          for (final child in children)
            Padding(padding: const EdgeInsets.only(top: 12), child: child),
        ],
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  const _Paragraph(this.text);

  static const _strong = TextStyle(
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    final parts = text.split('*');
    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < parts.length; i++)
            TextSpan(text: parts[i], style: i.isOdd ? _strong : null),
        ],
      ),
      style: AppTextStyles.body().copyWith(
        fontSize: 14,
        height: 22 / 14,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

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

class _Link extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _Link(this.text, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: AppTextStyles.body().copyWith(
          fontSize: 14,
          height: 22 / 14,
          fontWeight: FontWeight.w600,
          color: AppColors.orange,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.orange,
        ),
      ),
    );
  }
}
