import '../../core/content/json_values.dart';

enum OtpChannel { sms, call }

class OtpChallenge {
  static const _defaultCodeLength = 6;
  static const _maxCodeLength = 8;

  final String phone;
  final OtpChannel channel;
  final int codeLength;

  const OtpChallenge({
    required this.phone,
    this.channel = OtpChannel.sms,
    this.codeLength = _defaultCodeLength,
  });

  factory OtpChallenge.fromResponse(String phone, Map<String, dynamic> data) {
    final length = jsonInt(data['code_length']);
    return OtpChallenge(
      phone: phone,
      channel: jsonString(data['channel']) == OtpChannel.call.name
          ? OtpChannel.call
          : OtpChannel.sms,
      codeLength: length > 0 && length <= _maxCodeLength
          ? length
          : _defaultCodeLength,
    );
  }
}
