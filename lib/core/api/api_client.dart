import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_store.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const _baseUrl = 'https://app.top1makovka.ru/api';

  Future<Map<String, dynamic>> get(String path, {bool auth = true}) {
    return _send('GET', path, auth: auth);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) {
    return _send('POST', path, body: body, auth: auth);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) {
    return _send('PUT', path, body: body, auth: auth);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    required bool auth,
    bool retriedAfterRefresh = false,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = {'Content-Type': 'application/json'};
    if (auth && AuthStore.instance.accessToken != null) {
      headers['Authorization'] = 'Bearer ${AuthStore.instance.accessToken}';
    }

    late http.Response response;
    final encoded = body != null ? jsonEncode(body) : null;
    switch (method) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(uri, headers: headers, body: encoded);
        break;
      case 'PUT':
        response = await http.put(uri, headers: headers, body: encoded);
        break;
      default:
        throw ApiException('Unsupported method $method');
    }

    if (response.statusCode == 401 && auth && !retriedAfterRefresh) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        return _send(method, path, body: body, auth: auth, retriedAfterRefresh: true);
      }
    }

    Map<String, dynamic> decoded = {};
    if (response.body.isNotEmpty) {
      try {
        final parsed = jsonDecode(response.body);
        if (parsed is Map<String, dynamic>) decoded = parsed;
      } catch (_) {}
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final message = decoded['detail']?.toString() ?? 'Ошибка сети (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<bool> _tryRefresh() async {
    final refreshToken = AuthStore.instance.refreshToken;
    if (refreshToken == null) return false;
    try {
      final uri = Uri.parse('$_baseUrl/auth/refresh');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );
      if (response.statusCode != 200) {
        await AuthStore.instance.clear();
        return false;
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await AuthStore.instance.setTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
