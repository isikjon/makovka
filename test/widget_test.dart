import 'package:flutter_test/flutter_test.dart';
import 'package:makovka/main.dart';

void main() {
  testWidgets('App boots without crashing', (tester) async {
    await tester.pumpWidget(const MakovkaApp());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
