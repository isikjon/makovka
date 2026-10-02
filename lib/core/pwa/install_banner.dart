import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'pwa_install.dart';

/// Floating "Установить приложение" banner shown app-wide on web when the
/// browser has a native install prompt ready (Chrome/Edge/Android), or a
/// short manual-install hint on iOS Safari, where no such prompt exists.
class InstallBanner extends StatefulWidget {
  const InstallBanner({super.key});

  @override
  State<InstallBanner> createState() => _InstallBannerState();
}

class _InstallBannerState extends State<InstallBanner> {
  bool _dismissed = false;
  bool _installing = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) PwaInstall.startWatching();
  }

  Future<void> _install() async {
    setState(() => _installing = true);
    final outcome = await PwaInstall.promptInstall();
    if (!mounted) return;
    setState(() {
      _installing = false;
      if (outcome == 'accepted') _dismissed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || _dismissed || PwaInstall.isStandalone) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ValueListenableBuilder<bool>(
          valueListenable: PwaInstall.canInstall,
          builder: (context, canInstall, _) {
            final showIosHint = !canInstall && PwaInstall.isIOS;
            if (!canInstall && !showIosHint) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: showIosHint
                  ? _IosHintCard(onClose: () => setState(() => _dismissed = true))
                  : _InstallCard(
                      installing: _installing,
                      onInstall: _install,
                      onClose: () => setState(() => _dismissed = true),
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _InstallCard extends StatelessWidget {
  final bool installing;
  final VoidCallback onInstall;
  final VoidCallback onClose;

  const _InstallCard({
    required this.installing,
    required this.onInstall,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1E4),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.download_rounded,
              color: AppColors.orange,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Установите приложение',
                  style: AppTextStyles.body().copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Добавьте приложение на рабочий стол — откроется как обычная программа',
                  style: AppTextStyles.body().copyWith(
                    fontSize: 12,
                    height: 16 / 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: installing ? null : onInstall,
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: installing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(
                            'Установить',
                            style: AppTextStyles.button().copyWith(fontSize: 13),
                          ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _IosHintCard extends StatelessWidget {
  final VoidCallback onClose;
  const _IosHintCard({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1E4),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.ios_share_rounded,
              color: AppColors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Установите приложение',
                  style: AppTextStyles.body().copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Нажмите «Поделиться» внизу браузера → «На экран «Домой»',
                  style: AppTextStyles.body().copyWith(
                    fontSize: 12,
                    height: 16 / 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
