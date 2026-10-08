import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avrgreen/core/localization/app_strings.dart';
import 'package:avrgreen/core/widgets/language_selector_dialog.dart';
import 'package:avrgreen/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:avrgreen/features/customer/presentation/screens/farmer_offers_screen.dart';
import 'package:avrgreen/features/inventory/presentation/screens/inventory_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'selected_app_language': 'en'});
  });

  testWidgets('Full Interactive Language Switch: English -> Marathi -> Hindi -> English + Persistence', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial state: English
    expect(container.read(appLanguageProvider), equals(AppLanguage.en));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: Consumer(builder: (context, ref, _) {
                return Text(ref.tr('farmer_offers_title'));
              }),
              actions: const [
                LanguageSelectorButton(),
              ],
            ),
            body: Consumer(builder: (context, ref, _) {
              return Column(
                children: [
                  Text(ref.tr('official_nursery_campaigns')),
                  Text(ref.tr('verified_plantation_discounts')),
                  Text(ref.tr('tab_ready_stock')),
                ],
              );
            }),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify English
    expect(find.text('Farmer Offers & Campaigns'), findsOneWidget);
    expect(find.text('OFFICIAL NURSERY CAMPAIGNS'), findsOneWidget);
    expect(find.text('Verified Plantation Discounts'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);

    // 2. Switch to Marathi (मराठी)
    container.read(appLanguageProvider.notifier).setLanguage(AppLanguage.mr);
    await tester.pumpAndSettle();

    // Verify current screen updates immediately to Marathi
    expect(find.text('शेतकरी ऑफर्स आणि मोहिमा'), findsOneWidget);
    expect(find.text('अधिकृत रोपवाटिका मोहिमा'), findsOneWidget);
    expect(find.text('प्रमाणित लागवड सवलत'), findsOneWidget);
    expect(find.text('मराठी'), findsOneWidget);

    // 3. Switch to Hindi (हिन्दी)
    container.read(appLanguageProvider.notifier).setLanguage(AppLanguage.hi);
    await tester.pumpAndSettle();

    // Verify current screen updates immediately to Hindi
    expect(find.text('किसान ऑफर्स और अभियान'), findsOneWidget);
    expect(find.text('आधिकारिक नर्सरी अभियान'), findsOneWidget);
    expect(find.text('सत्यापित रोपण छूट'), findsOneWidget);
    expect(find.text('हिंदी'), findsOneWidget);

    // 4. Switch back to English
    container.read(appLanguageProvider.notifier).setLanguage(AppLanguage.en);
    await tester.pumpAndSettle();

    expect(find.text('Farmer Offers & Campaigns'), findsOneWidget);
    expect(find.text('OFFICIAL NURSERY CAMPAIGNS'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);

    // 5. Test Persistence on Simulated Restart
    // Set language to Marathi and simulate fresh app restart
    container.read(appLanguageProvider.notifier).setLanguage(AppLanguage.mr);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selected_app_language'), equals('mr'));

    // Cold restart simulation:
    final persistedCode = prefs.getString('selected_app_language');
    final initialLang = AppLanguageX.fromCode(persistedCode);
    expect(initialLang, equals(AppLanguage.mr));

    final restartContainer = ProviderContainer(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguageNotifier(initialLang)),
      ],
    );
    addTearDown(restartContainer.dispose);

    expect(restartContainer.read(appLanguageProvider), equals(AppLanguage.mr));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: restartContainer,
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: Consumer(builder: (context, ref, _) {
                return Text(ref.tr('farmer_offers_title'));
              }),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Marathi booted immediately on simulated restart
    expect(find.text('शेतकरी ऑफर्स आणि मोहिमा'), findsOneWidget);
  });
}
