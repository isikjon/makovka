import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'core/profile/profile_store.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProfileStore.instance.load();
  runApp(const MakovkaApp());
}

class MakovkaApp extends StatelessWidget {
  const MakovkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Маковка',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      scrollBehavior: _AppScrollBehavior(),
      routerConfig: AppRouter.router,
    );
  }
}

/// Enables drag-to-scroll with a mouse (not just touch/trackpad) —
/// needed so lists are scrollable by mouse drag in the web/desktop build.
class _AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
