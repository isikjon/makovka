import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/auth_store.dart';
import '../content/json_values.dart';

class ReferralInfo {
  final String code;
  final int invitedCount;
  final int rewardedCount;
  final double bonusPerFriend;
  final bool rewardsEnabled;
  final String shareText;

  const ReferralInfo({
    required this.code,
    required this.invitedCount,
    required this.rewardedCount,
    required this.bonusPerFriend,
    required this.rewardsEnabled,
    required this.shareText,
  });

  factory ReferralInfo.fromJson(Map<String, dynamic> json) {
    final code = jsonString(json['code']) ?? '';
    return ReferralInfo(
      code: code,
      invitedCount: max(0, jsonInt(json['invited_count'])),
      rewardedCount: max(0, jsonInt(json['rewarded_count'])),
      bonusPerFriend: jsonDouble(json['bonus_per_friend']),
      rewardsEnabled: jsonBool(json['rewards_enabled']),
      shareText: jsonString(json['share_text']) ?? code,
    );
  }

  bool get hasBonus => rewardsEnabled && bonusPerFriend > 0;
}

class ReferralApplyResult {
  final bool applied;
  final String message;

  const ReferralApplyResult({required this.applied, required this.message});
}

class ReferralStore extends ChangeNotifier {
  ReferralStore._() {
    AuthStore.instance.addListener(_onAuthChanged);
  }
  static final ReferralStore instance = ReferralStore._();

  static const _freshFor = Duration(seconds: 30);

  ReferralInfo? _info;
  DateTime? _fetchedAt;
  String? _error;
  int _pending = 0;
  int _issued = 0;
  int _accepted = 0;
  Future<void>? _loadInFlight;

  ReferralInfo? get info => _info;
  String? get error => _error;
  bool get isLoading => _pending > 0;

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
    final future = _fetch();
    _loadInFlight = future;
    future.whenComplete(() {
      if (identical(_loadInFlight, future)) _loadInFlight = null;
    });
    return future;
  }

  Future<ReferralApplyResult> apply(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      return const ReferralApplyResult(
        applied: false,
        message: 'Введите промокод',
      );
    }
    try {
      final json = await guardRequest(
        () =>
            ApiClient.instance.post('/referral/apply', body: {'code': trimmed}),
      );
      if (json['applied'] != true) {
        return const ReferralApplyResult(
          applied: false,
          message: 'Не удалось применить промокод',
        );
      }
      return const ReferralApplyResult(
        applied: true,
        message: 'Промокод друга применён',
      );
    } on ApiException catch (e) {
      return ReferralApplyResult(
        applied: false,
        message: e.statusCode == 422 ? 'Проверьте промокод' : e.message,
      );
    }
  }

  Future<void> _fetch() async {
    final ticket = ++_issued;
    _pending++;
    _error = null;
    _notifySoon();
    try {
      final info = await guardRequest(
        () async =>
            ReferralInfo.fromJson(await ApiClient.instance.get('/referral')),
      );
      if (ticket <= _accepted) return;
      _accepted = ticket;
      _info = info;
      _fetchedAt = DateTime.now();
      _error = null;
    } on ApiException catch (e) {
      if (ticket > _accepted) _error = e.message;
    } finally {
      _pending--;
      notifyListeners();
    }
  }

  void _notifySoon() => scheduleMicrotask(notifyListeners);

  void _onAuthChanged() {
    if (!AuthStore.instance.isAuthenticated) _clear();
  }

  void _clear() {
    _accepted = _issued;
    _loadInFlight = null;
    _info = null;
    _fetchedAt = null;
    _error = null;
    notifyListeners();
  }
}
