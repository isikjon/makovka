const _groupSeparator = '\u202F';
const _currencySeparator = '\u00A0';
const _minus = '\u2212';

String formatAmount(double value) {
  final cents = value.isFinite ? (value * 100).round() : 0;
  final absolute = cents.abs();
  final whole = _groupDigits(absolute ~/ 100);
  final fraction = absolute % 100;
  final text = fraction == 0
      ? whole
      : '$whole,${fraction.toString().padLeft(2, '0')}';
  return cents < 0 ? '$_minus$text' : text;
}

String formatRub(double value) => '${formatAmount(value)}$_currencySeparator₽';

String formatPercent(double value) {
  final hundredths = value.isFinite ? (value * 100).round().abs() : 0;
  final whole = hundredths ~/ 100;
  final fraction = (hundredths % 100)
      .toString()
      .padLeft(2, '0')
      .replaceFirst(RegExp(r'0+$'), '');
  final sign = value < 0 && hundredths > 0 ? _minus : '';
  return fraction.isEmpty ? '$sign$whole%' : '$sign$whole,$fraction%';
}

String _groupDigits(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(_groupSeparator);
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
