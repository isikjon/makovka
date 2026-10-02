import 'dart:async';

import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/auth_store.dart';
import 'json_values.dart';

class Novelty {
  final String id;
  final String title;
  final String? imageUrl;

  const Novelty({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  static Novelty? tryParse(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    return Novelty(
      id: jsonString(json['id']) ?? '',
      title: jsonString(json['title']) ?? '',
      imageUrl: jsonHttpUrl(json['image_url']),
    );
  }
}

enum PromotionKind { generic, coffeeStamps, referral, happyHours, combo }

class Promotion {
  final String id;
  final PromotionKind kind;
  final String title;
  final String? subtitle;
  final String? description;
  final String? badge;
  final double? price;
  final double? oldPrice;
  final String? timeText;
  final String? imageUrl;
  final bool showOnHome;
  final bool personal;
  final DateTime? endsAt;

  const Promotion({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.badge,
    required this.price,
    required this.oldPrice,
    required this.timeText,
    required this.imageUrl,
    required this.showOnHome,
    required this.personal,
    required this.endsAt,
  });

  String? get summary => subtitle ?? description;

  static Promotion? tryParse(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    return Promotion(
      id: jsonString(json['id']) ?? '',
      kind: _kind(json['kind']),
      title: jsonString(json['title']) ?? '',
      subtitle: jsonString(json['subtitle']),
      description: jsonString(json['description']),
      badge: jsonString(json['badge']),
      price: jsonDoubleOrNull(json['price']),
      oldPrice: jsonDoubleOrNull(json['old_price']),
      timeText: jsonString(json['time_text']),
      imageUrl: jsonHttpUrl(json['image_url']),
      showOnHome: jsonBool(json['show_on_home']),
      personal: jsonBool(json['personal']),
      endsAt: jsonDate(json['ends_at']),
    );
  }

  static PromotionKind _kind(Object? value) {
    return switch (value) {
      'coffee_stamps' => PromotionKind.coffeeStamps,
      'referral' => PromotionKind.referral,
      'happy_hours' => PromotionKind.happyHours,
      'combo' => PromotionKind.combo,
      _ => PromotionKind.generic,
    };
  }
}

class Bakery {
  final String id;
  final String name;
  final String address;
  final String? metro;
  final String? hoursText;
  final double? latitude;
  final double? longitude;

  const Bakery({
    required this.id,
    required this.name,
    required this.address,
    required this.metro,
    required this.hoursText,
    required this.latitude,
    required this.longitude,
  });

  static Bakery? tryParse(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    return Bakery(
      id: jsonString(json['id']) ?? '',
      name: jsonString(json['name']) ?? '',
      address: jsonString(json['address']) ?? '',
      metro: jsonString(json['metro']),
      hoursText: jsonString(json['hours_text']),
      latitude: _coordinate(json['latitude'], 90),
      longitude: _coordinate(json['longitude'], 180),
    );
  }

  static double? _coordinate(Object? value, double limit) {
    final parsed = jsonDoubleOrNull(value);
    return parsed != null && parsed.abs() <= limit ? parsed : null;
  }
}

class ContentData {
  final List<Novelty> novelties;
  final List<Promotion> promotions;
  final List<Bakery> bakeries;

  const ContentData({
    required this.novelties,
    required this.promotions,
    required this.bakeries,
  });

  factory ContentData.fromJson(Map<String, dynamic> json) {
    return ContentData(
      novelties: jsonList(
        json['novelties'],
      ).map(Novelty.tryParse).whereType<Novelty>().toList(),
      promotions: jsonList(
        json['promotions'],
      ).map(Promotion.tryParse).whereType<Promotion>().toList(),
      bakeries: jsonList(
        json['bakeries'],
      ).map(Bakery.tryParse).whereType<Bakery>().toList(),
    );
  }

  List<Promotion> get homePromotions =>
      promotions.where((promotion) => promotion.showOnHome).toList();
}

class ContentStore extends ChangeNotifier {
  ContentStore._() {
    AuthStore.instance.addListener(_onAuthChanged);
  }
  static final ContentStore instance = ContentStore._();

  static const _freshFor = Duration(minutes: 2);

  ContentData? _data;
  DateTime? _fetchedAt;
  String? _error;
  int _pending = 0;
  int _issued = 0;
  int _accepted = 0;
  Future<void>? _loadInFlight;

  ContentData? get data => _data;
  String? get error => _error;
  bool get isLoading => _pending > 0;

  bool get _isFresh {
    final fetchedAt = _fetchedAt;
    return _data != null &&
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

  Future<void> refresh() => load(force: true);

  Future<void> _fetch() async {
    final ticket = ++_issued;
    _pending++;
    _error = null;
    _notifySoon();
    try {
      final data = await guardRequest(
        () async =>
            ContentData.fromJson(await ApiClient.instance.get('/content')),
      );
      if (ticket <= _accepted) return;
      _accepted = ticket;
      _data = data;
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
    _data = null;
    _fetchedAt = null;
    _error = null;
    notifyListeners();
  }
}
