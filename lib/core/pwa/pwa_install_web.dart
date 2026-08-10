import 'dart:js_interop';

@JS('pwaIsInstallAvailable')
external JSBoolean _isInstallAvailable();

@JS('pwaIsStandalone')
external JSBoolean _isStandalone();

@JS('pwaIsIOS')
external JSBoolean _isIOS();

@JS('pwaPromptInstall')
external JSPromise<JSString> _promptInstall();

/// Bridges the `beforeinstallprompt` glue registered in web/index.html
/// (loaded before Flutter starts) into Dart.
class PwaInstallPlatform {
  static bool get isInstallAvailable => _isInstallAvailable().toDart;
  static bool get isStandalone => _isStandalone().toDart;
  static bool get isIOS => _isIOS().toDart;

  static Future<String> promptInstall() async {
    final outcome = await _promptInstall().toDart;
    return outcome.toDart;
  }
}
