import 'package:flutter_test/flutter_test.dart';
import 'package:badgeup_mobile/main.dart';

void main() {
  testWidgets('BadgeUp app renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BadgeUpApp());
    expect(find.text('BadgeUp'), findsOneWidget);
  });
}
