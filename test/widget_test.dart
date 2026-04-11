import 'package:badgeup_mobile/main.dart';
import 'package:badgeup_mobile/services/user_session.dart';
import 'package:badgeup_mobile/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('BadgeUp app renders login screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider<UserSession>.value(value: UserSession()),
        ],
        child: const BadgeUpApp(),
      ),
    );
    await tester.pump();
    expect(find.text('BadgeUp'), findsOneWidget);
  });
}
