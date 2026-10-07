enum OtpChannel { call }

class OtpChallenge {
  static const _callCodeLength = 4;

  final String phone;
  final OtpChannel channel;
  final int codeLength;

  const OtpChallenge({
    required this.phone,
    this.channel = OtpChannel.call,
    this.codeLength = _callCodeLength,
  });

  factory OtpChallenge.fromResponse(String phone, Map<String, dynamic> data) {
    return OtpChallenge(
      phone: phone,
      // The backend intentionally has one production authentication mode.
      // Ignore legacy `channel=sms`/`code_length=6` responses from old
      // sessions so the UI can never fall back to the retired flow.
      channel: OtpChannel.call,
      codeLength: _callCodeLength,
    );
  }
}
