import '../api/api_client.dart';

const _networkError =
    'Нет соединения с сервером. Проверьте интернет и попробуйте ещё раз';

final _zoneSuffix = RegExp(r'(z|[+-]\d{2}:?\d{2})$', caseSensitive: false);

Future<T> guardRequest<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on ApiException {
    rethrow;
  } catch (_) {
    throw ApiException(_networkError);
  }
}

String? jsonString(Object? value) {
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  if (value is num) return value.toString();
  return null;
}

double? jsonDoubleOrNull(Object? value) {
  if (value is num) return value.isFinite ? value.toDouble() : null;
  if (value is String) {
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    return parsed != null && parsed.isFinite ? parsed : null;
  }
  return null;
}

double jsonDouble(Object? value) => jsonDoubleOrNull(value) ?? 0;

int jsonInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.isFinite ? value.round() : 0;
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

bool jsonBool(Object? value) => value == true;

List<Object?> jsonList(Object? value) => value is List ? value : const [];

DateTime? jsonDate(Object? value) {
  final text = jsonString(value);
  if (text == null) return null;
  final zoned = _zoneSuffix.hasMatch(text) ? text : '${text}Z';
  return DateTime.tryParse(zoned)?.toLocal();
}

String? jsonHttpUrl(Object? value) {
  final text = jsonString(value);
  if (text == null) return null;
  final uri = Uri.tryParse(text);
  if (uri == null || uri.host.isEmpty) return null;
  return uri.scheme == 'https' || uri.scheme == 'http' ? text : null;
}
