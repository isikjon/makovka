import 'dart:async';

import 'package:flutter/foundation.dart';

import 'pwa_install_stub.dart'
    if (dart.library.js_interop) 'pwa_install_web.dart'
    as platform;

/// App-wide handle for the "Add to Home Screen" / native install prompt.
///
/// `beforeinstallprompt` only fires on Chromium-based browsers (Chrome,
/// Edge, Android). iOS Safari never fires it — there is no programmatic
/// install API there, only the manual Share -> "On Home Screen" flow, so
/// [isIOS] exists for the UI to show instructions instead of a button.
class PwaInstall {
  PwaInstall._();

  static final ValueNotifier<bool> canInstall = ValueNotifier<bool>(
    platform.PwaInstallPlatform.isInstallAvailable,
  );

  static Timer? _pollTimer;

  static bool get isStandalone => platform.PwaInstallPlatform.isStandalone;
  static bool get isIOS => platform.PwaInstallPlatform.isIOS;

  /// The `beforeinstallprompt` event is captured by a plain JS listener
  /// (registered before Flutter even loads, see web/index.html) since it
  /// can fire at any time and Dart has no direct hook into it. Polling a
  /// cheap JS boolean a couple times a second is simple and reliable.
  static void startWatching() {
    if (_pollTimer != null) return;
    _pollTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      final available = platform.PwaInstallPlatform.isInstallAvailable;
      if (available != canInstall.value) {
        canInstall.value = available;
      }
    });
  }

  /// Returns 'accepted', 'dismissed', or 'unavailable'.
  static Future<String> promptInstall() {
    return platform.PwaInstallPlatform.promptInstall();
  }
}
