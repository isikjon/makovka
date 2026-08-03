import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: 300,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF9C9C9C), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 10.2,
              spreadRadius: 0,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Center(
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  isAntiAlias: true,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _DrawerItem(
              asset: 'assets/icons/menu_profile.svg',
              label: 'Профиль',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/profile');
              },
            ),
            _DrawerItem(
              asset: 'assets/icons/menu_pin.svg',
              label: 'Календарь подарков',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/gift-calendar');
              },
            ),
            _DrawerItem(
              asset: 'assets/icons/menu_cart.svg',
              label: 'История покупок',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/history');
              },
            ),
            _DrawerItem(
              asset: 'assets/icons/menu_pin.svg',
              label: 'Пекарни',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/locations');
              },
            ),
            _DrawerItem(
              asset: 'assets/icons/menu_pin.svg',
              label: 'Реферальная програма',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/promo/referral');
              },
            ),
            _DrawerItem(
              asset: 'assets/icons/menu_document.svg',
              label: 'Политика\nконфиденциальности',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/legal/privacy');
              },
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Center(
                child: Text(
                  'Маковка App Версия 1.0',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
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

class _DrawerItem extends StatelessWidget {
  final String asset;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 13, bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  asset,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.body().copyWith(
                      fontSize: 18,
                      height: 22 / 18,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomPaint(
              size: const Size(double.infinity, 1),
              painter: _DashedLinePainter(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..strokeWidth = 1;
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
