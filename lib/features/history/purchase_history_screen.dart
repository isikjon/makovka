import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/format/money_format.dart';
import '../../core/loyalty/loyalty_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../shared/widgets/status_views.dart';

const _monthNames = [
  'января',
  'февраля',
  'марта',
  'апреля',
  'мая',
  'июня',
  'июля',
  'августа',
  'сентября',
  'октября',
  'ноября',
  'декабря',
];

String _formatDay(DateTime date) {
  final day = '${date.day} ${_monthNames[date.month - 1]}';
  return date.year == DateTime.now().year ? day : '$day ${date.year}';
}

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  final _store = LoyaltyStore.instance;

  @override
  void initState() {
    super.initState();
    _store.loadHistory();
  }

  Future<void> _refresh() async {
    await _store.refresh();
    await _store.loadHistory();
    final error = _store.historyError;
    if (!mounted || error == null || _store.history == null) return;
    showErrorSnackBar(context, error);
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.extentAfter < 400 && _store.historyError == null) {
      _store.loadMoreHistory();
    }
    return false;
  }

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
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'История покупок',
                        style: AppTextStyles.h1().copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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
                  child: RefreshIndicator(
                    color: AppColors.orange,
                    onRefresh: _refresh,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _onScroll,
                      child: ListenableBuilder(
                        listenable: _store,
                        builder: (context, _) => ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          children: [
                            const _InfoBanner(
                              'Начисление и списание баллов могут '
                              'отображаться с задержкой до 24 часов',
                            ),
                            const SizedBox(height: 16),
                            ..._buildBody(),
                            SizedBox(height: AppBottomNav.barHeight + 20),
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

  List<Widget> _buildBody() {
    final items = _store.history;
    final error = _store.historyError;

    if (items == null) {
      if (error != null && !_store.isHistoryLoading) {
        return [
          StatusCard(
            title: 'Не удалось загрузить историю',
            subtitle: error,
            onRetry: _store.loadHistory,
          ),
        ];
      }
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: LoadingSpinner()),
        ),
      ];
    }

    if (items.isEmpty) {
      return const [
        StatusCard(
          title: 'Покупок пока нет',
          subtitle: 'Покажите QR-код на кассе, и покупки появятся здесь',
        ),
      ];
    }

    return [
      for (final purchase in items) ...[
        _HistoryCard(purchase: purchase),
        const SizedBox(height: 12),
      ],
      if (_store.isHistoryLoadingMore)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: LoadingSpinner(size: 24)),
        )
      else if (error != null && _store.hasMoreHistory)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(child: RetryButton(onTap: _store.loadMoreHistory)),
        ),
    ];
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;
  const _InfoBanner(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E1DE), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/icons/history_info.svg',
            width: 22,
            height: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body().copyWith(
                fontSize: 13,
                height: 18 / 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Purchase purchase;
  const _HistoryCard({required this.purchase});

  @override
  Widget build(BuildContext context) {
    final bakery = purchase.bakery;
    final orderedAt = purchase.orderedAt;
    final paid = formatRub(purchase.paidSum);
    final trailing = [
      if (purchase.discountSum > 0)
        Text(
          '−${formatRub(purchase.discountSum)}',
          style: AppTextStyles.body().copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.orange,
          ),
        ),
      if (purchase.bonusAccrued > 0)
        _BonusLine(
          text: '+${formatAmount(purchase.bonusAccrued)}',
          color: AppColors.orange,
        ),
      if (purchase.bonusSpent > 0)
        _BonusLine(
          text: '−${formatAmount(purchase.bonusSpent)}',
          color: AppColors.textPrimary,
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          Image.asset(
            'assets/images/history_shop_icon.png',
            width: 44,
            height: 44,
            filterQuality: FilterQuality.high,
            isAntiAlias: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bakery == null ? 'Покупка' : 'Покупка — $bakery',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body().copyWith(
                    fontSize: 15,
                    height: 20 / 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  orderedAt == null ? paid : '${_formatDay(orderedAt)} • $paid',
                  style: AppTextStyles.body().copyWith(
                    fontSize: 13,
                    height: 18 / 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (trailing.isNotEmpty) ...[
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < trailing.length; i++) ...[
                  if (i > 0) const SizedBox(height: 2),
                  trailing[i],
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BonusLine extends StatelessWidget {
  final String text;
  final Color color;
  const _BonusLine({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: AppTextStyles.body().copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        SvgPicture.asset(
          'assets/icons/history_point.svg',
          width: 14,
          height: 16,
        ),
      ],
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
