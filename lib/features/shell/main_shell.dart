import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_drawer.dart';
import '../home/home_screen.dart';
import '../promo/promo_screen.dart';

class MainShell extends StatefulWidget {
  final int initialTab;
  const MainShell({super.key, this.initialTab = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialTab;

  void _goToTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      PromoScreen(onBack: () => _goToTab(0)),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      drawer: const AppDrawer(),
      drawerScrimColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              children: [
                for (var i = 0; i < screens.length; i++)
                  AnimatedOpacity(
                    key: ValueKey('tab-$i'),
                    opacity: _index == i ? 1 : 0,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                    child: IgnorePointer(
                      ignoring: _index != i,
                      child: screens[i],
                    ),
                  ),
              ],
            ),
          ),
          // Floats over content instead of reserving its own opaque slot,
          // so no background color shows through around the logo bump.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNav(
              currentIndex: _index,
              onTap: _goToTab,
              onLogoTap: () => context.push('/qr'),
            ),
          ),
        ],
      ),
    );
  }
}
