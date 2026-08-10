/// No-op implementation used on non-web platforms (iOS/Android/desktop
/// native builds), where there is no browser to install a PWA into.
class PwaInstallPlatform {
  static bool get isInstallAvailable => false;
  static bool get isStandalone => false;
  static bool get isIOS => false;
  static Future<String> promptInstall() async => 'unavailable';
}
