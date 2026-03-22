import 'package:flutter_test/flutter_test.dart';
import 'package:manoveda/main.dart';

void main() {
  testWidgets('shows Manoveda splash branding', (WidgetTester tester) async {
    await tester.pumpWidget(const Manoveda());

    expect(find.text('Manoveda'), findsOneWidget);
    expect(find.text('Designed by team Manoveda'), findsOneWidget);
  });
}
