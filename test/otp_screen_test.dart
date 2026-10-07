import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:makovka/features/auth/otp_challenge.dart';
import 'package:makovka/features/auth/otp_screen.dart';

const _phone = '+79990001122';

typedef _Handler = FutureOr<http.Response> Function(Map<String, dynamic> body);

http.Response _json(Object body, int status) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

http.Response _challenge(String channel, int codeLength) => _json({
  'phone': _phone,
  'expires_in_seconds': 300,
  'dev_code': null,
  'channel': channel,
  'code_length': codeLength,
}, 200);

Iterable<String> _cells(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((t) => t.data ?? '')
    .where((d) => RegExp(r'^\d$').hasMatch(d));

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pump();
}

Future<void> _withScreen(
  WidgetTester tester,
  Map<String, _Handler> handlers,
  Future<void> Function() body,
) async {
  tester.view.physicalSize = const Size(1179, 2556);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final client = MockClient((request) async {
    final handler = handlers[request.url.path.split('/api').last];
    if (handler == null) return http.Response('', 404);
    return handler(jsonDecode(request.body) as Map<String, dynamic>);
  });
  await http.runWithClient(() async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OtpScreen(challenge: OtpChallenge(phone: _phone)),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await body();
  }, () => client);
  await tester.pumpWidget(const SizedBox());
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('challenge parses response with safe defaults', () {
    final call = OtpChallenge.fromResponse(_phone, {
      'channel': 'call',
      'code_length': 4,
    });
    expect(call.channel, OtpChannel.call);
    expect(call.codeLength, 4);
    final fallback = OtpChallenge.fromResponse(_phone, {});
    expect(fallback.channel, OtpChannel.call);
    expect(fallback.codeLength, 4);
  });

  testWidgets('starts in call mode and submits four digits', (tester) async {
    final requests = <Map<String, dynamic>>[];
    final verifies = <Map<String, dynamic>>[];
    await _withScreen(tester, {
      '/auth/otp/request': (body) {
        requests.add(body);
        return _challenge('call', 4);
      },
      '/auth/otp/verify': (body) {
        verifies.add(body);
        return _json({'detail': 'Неверный код'}, 400);
      },
    }, () async {
      expect(find.text('Вам поступит звонок'), findsOneWidget);
      expect(_cells(tester).length, 4);
      expect(find.textContaining('последние 4 цифры'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '4321');
      await _settle(tester);

      expect(verifies.single, {'phone': _phone, 'code': '4321'});
      expect(requests, isEmpty);
      expect(find.text('Неверный код'), findsOneWidget);
    });
  });

  testWidgets('shows call request error and stays in call mode', (tester) async {
    await _withScreen(tester, {
      '/auth/otp/request': (_) =>
          _json({'detail': 'Не удалось отправить код: нет маршрута'}, 502),
    }, () async {
      await tester.pump(const Duration(seconds: 58));
      await tester.tap(find.text('Получить звонок'));
      await _settle(tester);

      expect(
        find.text('Не удалось отправить код: нет маршрута'),
        findsOneWidget,
      );
      expect(find.text('Вам поступит звонок'), findsOneWidget);
      expect(_cells(tester).length, 4);
    });
  });

  testWidgets('resend requests another call while in call mode', (
    tester,
  ) async {
    final requests = <Map<String, dynamic>>[];
    await _withScreen(tester, {
      '/auth/otp/request': (body) {
        requests.add(body);
        return _challenge('call', 4);
      },
    }, () async {
      await tester.pump(const Duration(seconds: 57));
      await tester.tap(find.text('Получить звонок'));
      await _settle(tester);

      expect(requests.last, {'phone': _phone, 'channel': 'call'});
      expect(find.text('Вам поступит звонок'), findsOneWidget);
      expect(find.text('0:58'), findsOneWidget);

      await tester.pump(const Duration(seconds: 58));
      await tester.tap(find.text('Получить звонок'));
      await _settle(tester);

      expect(requests.length, 2);
      expect(requests.last, {'phone': _phone, 'channel': 'call'});
    });
  });

  testWidgets('ignores digits typed while a code is being requested', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    final verifies = <Map<String, dynamic>>[];
    await _withScreen(tester, {
      '/auth/otp/request': (_) => pending.future,
      '/auth/otp/verify': (body) {
        verifies.add(body);
        return _json({'detail': 'Неверный код'}, 400);
      },
    }, () async {
      await tester.pump(const Duration(seconds: 58));
      await tester.tap(find.text('Получить звонок'));
      await _settle(tester);
      await tester.enterText(find.byType(TextField), '1234');
      await tester.pump();

      expect(_cells(tester).every((c) => c == '0'), isTrue);

      pending.complete(_challenge('call', 4));
      await _settle(tester);

      expect(_cells(tester).length, 4);
      expect(_cells(tester).every((c) => c == '0'), isTrue);
      expect(verifies, isEmpty);

      await tester.enterText(find.byType(TextField), '4321');
      await _settle(tester);

      expect(verifies.single, {'phone': _phone, 'code': '4321'});
    });
  });

  testWidgets('shows network error when verify cannot reach the server', (
    tester,
  ) async {
    await _withScreen(tester, {
      '/auth/otp/verify': (_) => throw http.ClientException('offline'),
    }, () async {
      await tester.enterText(find.byType(TextField), '1234');
      await _settle(tester);

      expect(find.textContaining('Нет соединения с сервером'), findsOneWidget);
      expect(_cells(tester).every((c) => c == '0'), isTrue);
    });
  });
}
