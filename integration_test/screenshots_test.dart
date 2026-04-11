import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:badgeup_mobile/models/album.dart';
import 'package:badgeup_mobile/models/sticker.dart';
import 'package:badgeup_mobile/theme/app_theme.dart';
import 'package:badgeup_mobile/theme/theme_provider.dart';

import 'package:badgeup_mobile/screens/login_screen.dart';
import 'package:badgeup_mobile/screens/main_shell.dart';
import 'package:badgeup_mobile/screens/home_screen.dart';
import 'package:badgeup_mobile/screens/albums_screen.dart';
import 'package:badgeup_mobile/screens/album_detail_screen.dart';
import 'package:badgeup_mobile/screens/sticker_detail_screen.dart';
import 'package:badgeup_mobile/screens/capture_screen.dart';
import 'package:badgeup_mobile/screens/ranking_screen.dart';
import 'package:badgeup_mobile/screens/profile_screen.dart';
import 'package:badgeup_mobile/screens/settings_screen.dart';
import 'package:badgeup_mobile/screens/friends_screen.dart';
import 'package:badgeup_mobile/screens/map_screen.dart';
import 'package:badgeup_mobile/screens/calendar_screen.dart';
import 'package:badgeup_mobile/screens/chat_screen.dart';
import 'package:badgeup_mobile/screens/create_sticker_screen.dart';
import 'package:badgeup_mobile/screens/edit_album_screen.dart';

const String kScreenshotDir =
    '/Users/ferreirafc1133/Documents/Iteso/Semestre 8/proyecto_final/badgeup_mobile/screenshots';

Future<void> _saveScreenshot(WidgetTester tester, String name) async {
  for (int i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await Future.delayed(const Duration(milliseconds: 2000));
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  final renderView = tester.binding.renderViews.first;
  final OffsetLayer layer = renderView.debugLayer! as OffsetLayer;
  final ui.Image image = await layer.toImage(
    Offset.zero & tester.view.physicalSize,
    pixelRatio: 1.0,
  );
  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) return;

  final Directory dir = Directory(kScreenshotDir);
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final File file = File('$kScreenshotDir/$name.png');
  await file.writeAsBytes(byteData.buffer.asUint8List());
  // ignore: avoid_print
  print('Saved: ${file.path}');
}

Widget _wrap(Widget child, {bool dark = false}) {
  AppTheme.syncBrightness(dark ? Brightness.dark : Brightness.light);
  return ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      builder: (context, inner) {
        AppTheme.syncBrightness(Theme.of(context).brightness);
        return Builder(
          builder: (ctx) {
            AppTheme.syncBrightness(Theme.of(ctx).brightness);
            return inner ?? const SizedBox.shrink();
          },
        );
      },
      home: child,
    ),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture all screens', (WidgetTester tester) async {
    const sticker = Sticker(
      id: 1,
      name: 'Stub',
      description: 'Sticker de prueba.',
      rarity: Rarity.raro,
      points: 10,
      unlocked: true,
      imageUrl: '',
    );
    final album = Album(
      id: 1,
      title: 'Album de prueba',
      theme: 'Demo',
      description: 'Album stub para capturas.',
      coverUrl: '',
      stickers: const [sticker],
      stickersCount: 1,
    );

    final screens = <(String, Widget)>[
      ('01_login', const LoginScreen()),
      ('02_main_shell_home', const MainShell()),
      ('03_home', const HomeScreen()),
      ('04_albums', const AlbumsScreen()),
      ('05_album_detail', AlbumDetailScreen(album: album)),
      ('06_sticker_detail', StickerDetailScreen(sticker: sticker)),
      ('07_capture', const CaptureScreen()),
      ('08_map', const MapScreen()),
      ('09_ranking', const RankingScreen()),
      ('10_profile', const ProfileScreen()),
      ('11_settings', const SettingsScreen()),
      ('12_friends', const FriendsScreen()),
      ('13_calendar', const CalendarScreen()),
      ('14_chat', const ChatScreen()),
      ('15_create_sticker', const CreateStickerScreen()),
      ('16_edit_album', EditAlbumScreen(album: album)),
    ];

    // Dark mode first (diagnostic: avoid any static state contamination).
    final darkScreens = <(String, Widget)>[
      ('17_home_dark', const HomeScreen()),
      ('18_albums_dark', const AlbumsScreen()),
      ('19_profile_dark', const ProfileScreen()),
    ];

    for (final (name, screen) in darkScreens) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpWidget(_wrap(screen, dark: true));
      await _saveScreenshot(tester, name);
    }

    for (final (name, screen) in screens) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpWidget(_wrap(screen));
      await _saveScreenshot(tester, name);
    }
  });
}
