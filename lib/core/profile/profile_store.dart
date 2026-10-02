import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/auth_store.dart';

class ProfileData {
  final String name;
  final String surname;
  final String phone;
  final String email;
  final String birthdate;
  final String promo;
  final String gender;

  const ProfileData({
    this.name = '',
    this.surname = '',
    this.phone = '',
    this.email = '',
    this.birthdate = '',
    this.promo = '',
    this.gender = '',
  });

  ProfileData copyWith({
    String? name,
    String? surname,
    String? phone,
    String? email,
    String? birthdate,
    String? promo,
    String? gender,
  }) {
    return ProfileData(
      name: name ?? this.name,
      surname: surname ?? this.surname,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      birthdate: birthdate ?? this.birthdate,
      promo: promo ?? this.promo,
      gender: gender ?? this.gender,
    );
  }
}

class ProfileStore extends ChangeNotifier {
  ProfileStore._() {
    AuthStore.instance.addListener(_onAuthChanged);
  }
  static final ProfileStore instance = ProfileStore._();

  static const _prefKeys = [
    'profile_name',
    'profile_surname',
    'profile_phone',
    'profile_email',
    'profile_birthdate',
    'profile_promo',
    'profile_gender',
  ];

  ProfileData _data = const ProfileData();
  ProfileData get data => _data;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  String get displayName => _data.name.isNotEmpty ? _data.name : 'Гость';

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _data = ProfileData(
      name: prefs.getString('profile_name') ?? '',
      surname: prefs.getString('profile_surname') ?? '',
      phone: prefs.getString('profile_phone') ?? '',
      email: prefs.getString('profile_email') ?? '',
      birthdate: prefs.getString('profile_birthdate') ?? '',
      promo: prefs.getString('profile_promo') ?? '',
      gender: prefs.getString('profile_gender') ?? '',
    );
    _loaded = true;
    notifyListeners();
  }

  Future<void> save(ProfileData next) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', next.name);
    await prefs.setString('profile_surname', next.surname);
    await prefs.setString('profile_phone', next.phone);
    await prefs.setString('profile_email', next.email);
    await prefs.setString('profile_birthdate', next.birthdate);
    await prefs.setString('profile_promo', next.promo);
    await prefs.setString('profile_gender', next.gender);
    _data = next;
    _loaded = true;
    notifyListeners();
  }

  void _onAuthChanged() {
    if (!AuthStore.instance.isAuthenticated) _clear();
  }

  Future<void> _clear() async {
    _data = const ProfileData();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await Future.wait(_prefKeys.map(prefs.remove));
  }
}
