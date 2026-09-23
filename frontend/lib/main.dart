import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AVRGREEN App Root
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: AVRGREENApp(),
    ),
  );
}

class AVRGREENApp extends ConsumerWidget {
  const AVRGREENApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'AVRGREEN — Nursery Management',
      debugShowCheckedModeBanner: false,
      theme: AVRTheme.lightTheme,
      darkTheme: AVRTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
