import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/auth_store.dart';

enum LoyaltyMode { flat, tiers }

class LoyaltyTier {
  final String code;
  final String name;
  final double minSpend;
  final double discountPercent;
  final double cashbackPercent;
  final List<String> perks;

  const LoyaltyTier({
    required this.code,
    required this.name,
    required this.minSpend,
    required this.discountPercent,
    required this.cashbackPercent,
    required this.perks,
  });

  factory LoyaltyTier.fromJson(Map<String, dynamic> json) {
    return LoyaltyTier(
      code: _string(json['code']) ?? '',
      name: _string(json['name']) ?? '',
      minSpend: _double(json['min_spend']),
      discountPercent: _double(json['discount_percent']),
      cashbackPercent: _double(json['cashback_percent']),
      perks: _list(json['perks']).map(_string).whereType<String>().toList(),
    );
  }

  static LoyaltyTier? tryParse(Object? json) {
    return json is Map<String, dynamic> ? LoyaltyTier.fromJson(json) : null;
  }
}

class CoffeeProgress {
  final int collected;
  final int goal;

  const CoffeeProgress({required this.collected, required this.goal});

  static CoffeeProgress? tryParse(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final goal = _int(json['goal']);
    if (goal <= 0) return null;
    return CoffeeProgress(
      collected: _int(json['collected']).clamp(0, goal),
      goal: goal,
    );
  }
}

class LoyaltyInfo {
  final LoyaltyMode mode;
  final String? syncStatus;
  final String? cardNumber;
  final LoyaltyTier currentTier;
  final LoyaltyTier? nextTier;
  final double totalSpend;
  final double? remainingToNext;
  final double progress;
  final double bonusBalance;
  final double totalSavings;
  final CoffeeProgress? coffee;
  final List<LoyaltyTier> tiers;
  final DateTime? updatedAt;
  final bool stale;

  const LoyaltyInfo({
    required this.mode,
    required this.syncStatus,
    required this.cardNumber,
    required this.currentTier,
    required this.nextTier,
    required this.totalSpend,
    required this.remainingToNext,
    required this.progress,
    required this.bonusBalance,
    required this.totalSavings,
    required this.coffee,
    required this.tiers,
    required this.updatedAt,
    required this.stale,
  });

  factory LoyaltyInfo.fromJson(Map<String, dynamic> json) {
    final tiers =
        _list(
            json['tiers'],
          ).map(LoyaltyTier.tryParse).whereType<LoyaltyTier>().toList()
          ..sort((a, b) => a.minSpend.compareTo(b.minSpend));
    return LoyaltyInfo(
      mode: json['mode'] == 'tiers' ? LoyaltyMode.tiers : LoyaltyMode.flat,
      syncStatus: _string(json['sync_status']),
      cardNumber: _string(json['card_number']),
      currentTier:
          LoyaltyTier.tryParse(json['current_tier']) ??
          const LoyaltyTier(
            code: 'base',
            name: '',
            minSpend: 0,
            discountPercent: 0,
            cashbackPercent: 0,
            perks: [],
          ),
      nextTier: LoyaltyTier.tryParse(json['next_tier']),
      totalSpend: _double(json['total_spend']),
      remainingToNext: _doubleOrNull(json['remaining_to_next']),
      progress: _double(json['progress']).clamp(0.0, 1.0),
      bonusBalance: _double(json['bonus_balance']),
      totalSavings: _double(json['total_savings']),
      coffee: CoffeeProgress.tryParse(json['coffee']),
      tiers: tiers,
      updatedAt: _date(json['updated_at']),
      stale: json['stale'] == true,
    );
  }
}

class Purchase {
  final String id;
  final DateTime? orderedAt;
  final int? orderNumber;
  final double orderSum;
  final double paidSum;
  final double discountSum;
  final double bonusAccrued;
  final double bonusSpent;
  final String? bakery;

  const Purchase({
    required this.id,
    required this.orderedAt,
    required this.orderNumber,
    required this.orderSum,
    required this.paidSum,
    required this.discountSum,
    required this.bonusAccrued,
    required this.bonusSpent,
    required this.bakery,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: _string(json['id']) ?? '',
      orderedAt: _date(json['ordered_at']),
      orderNumber: _intOrNull(json['order_number']),
      orderSum: _double(json['order_sum']),
      paidSum: _double(json['paid_sum']),
      discountSum: _double(json['discount_sum']),
      bonusAccrued: _double(json['bonus_accrued']),
      bonusSpent: _double(json['bonus_spent']),
      bakery: _string(json['bakery']),
    );
  }
}

class LoyaltyStore extends ChangeNotifier {
  LoyaltyStore._() {
    AuthStore.instance.addListener(_onAuthChanged);
  }
  static final LoyaltyStore instance = LoyaltyStore._();

  static const _freshFor = Duration(seconds: 30);
  static const _staleRecheckDelays = [
    Duration(seconds: 3),
    Duration(seconds: 6),
    Duration(seconds: 12),
    Duration(seconds: 24),
    Duration(seconds: 30),
    Duration(seconds: 30),
  ];
  static const _historyPageSize = 50;

  LoyaltyInfo? _info;
  DateTime? _fetchedAt;
  String? _error;
  int _pending = 0;
  int _issued = 0;
  int _accepted = 0;
  Future<void>? _loadInFlight;
  Timer? _staleRecheck;
  int _staleRechecks = 0;
  DateTime? _staleUpdatedAt;

  List<Purchase>? _history;
  int _historyTotal = 0;
  bool _historyLoading = false;
  bool _historyLoadingMore = false;
  String? _historyError;
  int _historyEpoch = 0;

  LoyaltyInfo? get info => _info;
  String? get error => _error;
  bool get isLoading => _pending > 0;

  List<Purchase>? get history => _history;
  bool get isHistoryLoading => _historyLoading;
  bool get isHistoryLoadingMore => _historyLoadingMore;
  String? get historyError => _historyError;
  bool get hasMoreHistory {
    final items = _history;
    return items != null && items.length < _historyTotal;
  }

  bool get _isFresh {
    final fetchedAt = _fetchedAt;
    return _info != null &&
        fetchedAt != null &&
        DateTime.now().difference(fetchedAt) < _freshFor;
  }

  Future<void> load({bool force = false}) {
    if (!force && _isFresh) return Future.value();
    final running = _loadInFlight;
    if (running != null) return running;
    final future = _fetch(() => ApiClient.instance.get('/loyalty'));
    _loadInFlight = future;
    future.whenComplete(() {
      if (identical(_loadInFlight, future)) _loadInFlight = null;
    });
    return future;
  }

  Future<void> refresh() {
    return _fetch(() async {
      try {
        return await ApiClient.instance.post('/loyalty/refresh');
      } on ApiException catch (e) {
        if (e.statusCode != 429) rethrow;
        return ApiClient.instance.get('/loyalty');
      }
    });
  }

  Future<String?> resolveCardNumber({bool force = false}) async {
    await (force ? refresh() : load());
    final card = _info?.cardNumber;
    if (card != null) return card;
    final profile = await _guard(() => ApiClient.instance.get('/profile'));
    final iiko = profile['iiko'];
    return iiko is Map<String, dynamic> ? _string(iiko['card_number']) : null;
  }

  Future<void> loadHistory() async {
    final epoch = ++_historyEpoch;
    _historyLoading = true;
    _historyLoadingMore = false;
    _historyError = null;
    _notifySoon();
    try {
      final page = await _guard(() => _fetchHistoryPage(0));
      if (epoch != _historyEpoch) return;
      _history = page.items;
      _historyTotal = page.total;
    } on ApiException catch (e) {
      if (epoch == _historyEpoch) _historyError = e.message;
    } finally {
      if (epoch == _historyEpoch) {
        _historyLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMoreHistory() async {
    final items = _history;
    if (items == null ||
        _historyLoading ||
        _historyLoadingMore ||
        items.length >= _historyTotal) {
      return;
    }
    final epoch = _historyEpoch;
    _historyLoadingMore = true;
    _historyError = null;
    _notifySoon();
    try {
      final page = await _guard(() => _fetchHistoryPage(items.length));
      if (epoch != _historyEpoch) return;
      final known = {for (final purchase in items) purchase.id};
      final fresh = page.items
          .where((purchase) => !known.contains(purchase.id))
          .toList();
      final merged = [...items, ...fresh];
      _history = merged;
      _historyTotal = fresh.isEmpty ? merged.length : page.total;
    } on ApiException catch (e) {
      if (epoch == _historyEpoch) _historyError = e.message;
    } finally {
      if (epoch == _historyEpoch) {
        _historyLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> _fetch(
    Future<Map<String, dynamic>> Function() request, {
    bool recheck = false,
  }) async {
    final ticket = ++_issued;
    _pending++;
    _error = null;
    _notifySoon();
    try {
      final info = await _guard(
        () async => LoyaltyInfo.fromJson(await request()),
      );
      if (ticket <= _accepted) return;
      _accepted = ticket;
      _info = info;
      _fetchedAt = DateTime.now();
      _error = null;
      _planStaleRecheck(info, recheck);
    } on ApiException catch (e) {
      if (ticket > _accepted) _error = e.message;
    } finally {
      _pending--;
      notifyListeners();
    }
  }

  void _planStaleRecheck(LoyaltyInfo info, bool recheck) {
    _staleRecheck?.cancel();
    _staleRecheck = null;
    if (!recheck) {
      _staleRechecks = 0;
      _staleUpdatedAt = info.updatedAt;
    }
    if (!info.stale ||
        info.updatedAt != _staleUpdatedAt ||
        _staleRechecks >= _staleRecheckDelays.length) {
      return;
    }
    _staleRecheck = Timer(_staleRecheckDelays[_staleRechecks++], () {
      _staleRecheck = null;
      _fetch(() => ApiClient.instance.get('/loyalty'), recheck: true);
    });
  }

  Future<({List<Purchase> items, int total})> _fetchHistoryPage(
    int offset,
  ) async {
    final json = await ApiClient.instance.get(
      '/loyalty/history?limit=$_historyPageSize&offset=$offset',
    );
    final items = _list(
      json['items'],
    ).whereType<Map<String, dynamic>>().map(Purchase.fromJson).toList();
    return (
      items: items,
      total: max(_int(json['total']), offset + items.length),
    );
  }

  void _notifySoon() => scheduleMicrotask(notifyListeners);

  void _onAuthChanged() {
    if (!AuthStore.instance.isAuthenticated) _clear();
  }

  void _clear() {
    _staleRecheck?.cancel();
    _staleRecheck = null;
    _accepted = _issued;
    _loadInFlight = null;
    _info = null;
    _fetchedAt = null;
    _error = null;
    _historyEpoch++;
    _history = null;
    _historyTotal = 0;
    _historyLoading = false;
    _historyLoadingMore = false;
    _historyError = null;
    notifyListeners();
  }
}

const _networkError =
    'Нет соединения с сервером. Проверьте интернет и попробуйте ещё раз';

final _zoneSuffix = RegExp(r'(z|[+-]\d{2}:?\d{2})$', caseSensitive: false);

Future<T> _guard<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on ApiException {
    rethrow;
  } catch (_) {
    throw ApiException(_networkError);
  }
}

String? _string(Object? value) {
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  if (value is num) return value.toString();
  return null;
}

double? _doubleOrNull(Object? value) {
  if (value is num) return value.isFinite ? value.toDouble() : null;
  if (value is String) return double.tryParse(value.replaceAll(',', '.'));
  return null;
}

double _double(Object? value) => _doubleOrNull(value) ?? 0;

int? _intOrNull(Object? value) {
  if (value is int) return value;
  if (value is num) return value.isFinite ? value.round() : null;
  if (value is String) return int.tryParse(value);
  return null;
}

int _int(Object? value) => _intOrNull(value) ?? 0;

List<Object?> _list(Object? value) => value is List ? value : const [];

DateTime? _date(Object? value) {
  final text = _string(value);
  if (text == null) return null;
  final zoned = _zoneSuffix.hasMatch(text) ? text : '${text}Z';
  return DateTime.tryParse(zoned)?.toLocal();
}
