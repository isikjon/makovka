import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: const Color(0xFFE05656),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

class LoadingSpinner extends StatelessWidget {
  final double size;
  const LoadingSpinner({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CircularProgressIndicator(
        strokeWidth: 2.6,
        valueColor: AlwaysStoppedAnimation(AppColors.orange),
      ),
    );
  }
}

class StatusMessage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;

  const StatusMessage({
    super.key,
    required this.title,
    this.subtitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final onRetry = this.onRetry;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.body().copyWith(
            fontSize: 15,
            height: 20 / 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.body().copyWith(
              fontSize: 13,
              height: 18 / 13,
              color: AppColors.textMuted,
            ),
          ),
        ],
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          RetryButton(onTap: onRetry),
        ],
      ],
    );
  }
}

class StatusCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;

  const StatusCard({
    super.key,
    required this.title,
    this.subtitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: StatusMessage(title: title, subtitle: subtitle, onRetry: onRetry),
    );
  }
}

class RetryButton extends StatefulWidget {
  final VoidCallback onTap;
  const RetryButton({super.key, required this.onTap});

  @override
  State<RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<RetryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            'Повторить',
            style: AppTextStyles.button().copyWith(
              fontSize: 14,
              height: 18 / 14,
            ),
          ),
        ),
      ),
    );
  }
}
