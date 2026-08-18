import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khakhi_diary/main.dart';
import 'package:khakhi_diary/providers/auth_provider.dart';
import 'package:khakhi_diary/providers/case_provider.dart';
import 'package:khakhi_diary/providers/module_registry.dart';
import 'package:khakhi_diary/providers/news_provider.dart';
import 'package:khakhi_diary/providers/settings_provider.dart';
import 'package:khakhi_diary/providers/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'test-api-key',
          appId: '1:1:android:test',
          messagingSenderId: '1',
          projectId: 'test-project',
          storageBucket: 'test-project.appspot.com',
        ),
      );
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') rethrow;
    }
  });

  testWidgets('App should start without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => NewsProvider()),
          ChangeNotifierProvider(create: (_) => CaseProvider()),
          ...moduleProviders,
        ],
        child: const PoliceMgmtApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
