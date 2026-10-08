import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/localization/app_strings.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AVRGREEN App Root
// ─────────────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLanguage initialLanguage = AppLanguage.en;
  try {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('selected_app_language');
    if (savedCode != null) {
      initialLanguage = AppLanguageX.fromCode(savedCode);
    }
  } catch (_) {}

  runApp(
    ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguageNotifier(initialLanguage)),
      ],
      child: const AVRGREENApp(),
    ),
  );
}

class AVRGREENApp extends ConsumerWidget {
  const AVRGREENApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final language = ref.watch(appLanguageProvider);

    return MaterialApp.router(
      title: AppStrings.get('app_name', language),
      debugShowCheckedModeBanner: false,
      locale: language.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('mr'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AVRTheme.lightTheme,
      darkTheme: AVRTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
