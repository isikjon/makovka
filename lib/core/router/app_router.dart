import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/phone_auth_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/promo/referral_program_screen.dart';
import '../../features/qr/qr_code_screen.dart';
import '../../features/legal/privacy_policy_screen.dart';
import '../../features/history/purchase_history_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/locations/locations_screen.dart';
import '../../features/loyalty/loyalty_screen.dart';
import '../../features/gift_calendar/gift_calendar_screen.dart';

/// Every route in the app is wrapped with this so navigation always
/// animates the same way, whether triggered by push, pop, or go.
CustomTransitionPage<void> _fadeThroughPage(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.035),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            _fadeThroughPage(state, const WelcomeScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            _fadeThroughPage(state, const OnboardingScreen()),
      ),
      GoRoute(
        path: '/auth/phone',
        pageBuilder: (context, state) =>
            _fadeThroughPage(state, const PhoneAuthScreen()),
      ),
      GoRoute(
        path: '/auth/otp',
        pageBuilder: (context, state) =>
            _fadeThroughPage(state, const OtpScreen()),
      ),
      GoRoute(
        path: '/auth/register',
        pageBuilder: (context, state) =>
            _fadeThroughPage(state, const RegisterScreen()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) {
          final tab =
              int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
          return _fadeThroughPage(state, MainShell(initialTab: tab));
        },
      ),
      GoRoute(
        path: '/promo/referral',
        pageBuilder: (context, state) =>
            _fadeThroughPage(state, const ReferralProgramScreen()),
      ),
      GoRoute(
        path: '/qr',
        pageBuilder: (context, state) =>
            _fadeThroughPage(state, const QrCodeScreen()),
      ),
      GoRoute(
        path: '/legal/privacy',
        pageBuilder: (context, state) =>
            _fadeThroughPage(state, const PrivacyPolicyScreen()),
      ),
      GoRoute(
        path: '/history',
        pageBuilder: (context, state) =>
            _fadeThroughPage(state, const PurchaseHistoryScreen()),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) =>
            _fadeThroughPage(state, const ProfileScreen()),
      ),
      GoRoute(
        path: '/locations',
        pageBuilder: (context, state) =>
            _fadeThroughPage(state, const LocationsScreen()),
      ),
      GoRoute(
        path: '/loyalty',
        pageBuilder: (context, state) =>
            _fadeThroughPage(state, const LoyaltyScreen()),
      ),
      GoRoute(
        path: '/gift-calendar',
        pageBuilder: (context, state) =>
            _fadeThroughPage(state, const GiftCalendarScreen()),
      ),
    ],
  );
}
