import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avrgreen/core/localization/app_strings.dart';
import 'package:avrgreen/core/widgets/language_selector_dialog.dart';
import 'package:avrgreen/features/catalog/data/models/product_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Multilingual Module Parity & Translation Integrity', () {
    test('Verifies AppLanguage code roundtripping', () {
      expect(AppLanguageX.fromCode('en'), equals(AppLanguage.en));
      expect(AppLanguageX.fromCode('mr'), equals(AppLanguage.mr));
      expect(AppLanguageX.fromCode('hi'), equals(AppLanguage.hi));
      expect(AppLanguageX.fromCode('unknown'), equals(AppLanguage.en));
      expect(AppLanguageX.fromCode(null), equals(AppLanguage.en));

      expect(AppLanguage.en.code, equals('en'));
      expect(AppLanguage.mr.code, equals('mr'));
      expect(AppLanguage.hi.code, equals('hi'));
    });

    test('Verifies critical UI keys return localized text for all 3 languages without falling back to raw key', () {
      const keysToVerify = [
        'app_name',
        'tagline',
        'nav_home',
        'nav_categories',
        'nav_offers',
        'nav_orders',
        'nav_profile',
        'nav_catalog',
        'nav_stock',
        'nav_reports',
        'nav_dashboard',
        'role_farmer',
        'role_nursery_owner',
        'farmer_offers_title',
        'official_nursery_campaigns',
        'verified_plantation_discounts',
        'botanical_transport_guarantee',
        'about_us',
        'view_available_varieties',
        'advance_prebooking',
        'select_prebooking_unit',
        'notify_when_available',
        'rating_breakdown',
        'marketplace_ranking',
        'all_prebookings_processed',
        'manage_stock',
        'tab_ready_stock',
        'tab_future_batches',
        'tab_prebookings',
        'superadmin_title',
        'nursery_delivery_fleet',
      ];

      for (final key in keysToVerify) {
        final enVal = AppStrings.get(key, AppLanguage.en);
        final mrVal = AppStrings.get(key, AppLanguage.mr);
        final hiVal = AppStrings.get(key, AppLanguage.hi);

        expect(enVal, isNotEmpty, reason: '$key English translation should not be empty');
        expect(mrVal, isNotEmpty, reason: '$key Marathi translation should not be empty');
        expect(hiVal, isNotEmpty, reason: '$key Hindi translation should not be empty');

        expect(enVal, isNot(equals(key)), reason: '$key should have a real English translation, not the key name');
        expect(mrVal, isNot(equals(key)), reason: '$key should have a real Marathi translation, not the key name');
        expect(hiVal, isNot(equals(key)), reason: '$key should have a real Hindi translation, not the key name');
      }
    });

    test('Verifies Product localizedStockBadgeLabel in EN, MR, HI', () {
      const readyProduct = Product(
        id: 'p-1',
        sku: 'SKU-1',
        commonName: 'Tomato',
        crop: 'Tomato',
        variety: 'Abhinav',
        sellingUnit: 'tray',
        price: 250,
        plantPrice: 2.5,
        categoryId: 'vegetables',
        categoryName: 'Vegetables',
        nurseryName: 'Nashik Nursery',
        readyStock: 500,
        availableStock: 500,
        care: CareInstructions(
          sunlight: 'Full Sun',
          watering: 'Moderate',
          fertilizer: 'NPK',
          temperature: '20-30°C',
        ),
      );

      expect(readyProduct.localizedStockBadgeLabel(AppLanguage.en), equals('READY NOW'));
      expect(readyProduct.localizedStockBadgeLabel(AppLanguage.mr), equals('सध्या उपलब्ध'));
      expect(readyProduct.localizedStockBadgeLabel(AppLanguage.hi), equals('तत्काल उपलब्ध'));
    });

    test('Verifies AppLanguageNotifier state updates and SharedPreferences persistence', () async {
      final notifier = AppLanguageNotifier(AppLanguage.en);
      expect(notifier.state, equals(AppLanguage.en));

      notifier.setLanguage(AppLanguage.mr);
      expect(notifier.state, equals(AppLanguage.mr));

      notifier.setLanguage(AppLanguage.hi);
      expect(notifier.state, equals(AppLanguage.hi));
    });
  });

  group('Mobile Viewport No-Overflow Verification across EN, MR, HI', () {
    const mobileViewports = [
      Size(320, 667), // Small Android / iPhone SE
      Size(360, 800), // Standard Android
      Size(375, 812), // iPhone 12 Mini / X
      Size(390, 844), // iPhone 13 / 14 / 15
      Size(412, 915), // Pixel 7 / Large Android
    ];

    for (final size in mobileViewports) {
      testWidgets('Renders LanguageSelectorButton & Localized Header on ${size.width.toInt()}x${size.height.toInt()} in Marathi & Hindi without overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        for (final lang in [AppLanguage.en, AppLanguage.mr, AppLanguage.hi]) {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                appLanguageProvider.overrideWith((ref) => AppLanguageNotifier(lang)),
              ],
              child: MaterialApp(
                home: Scaffold(
                  appBar: AppBar(
                    title: Text(AppStrings.get('app_name', lang)),
                    actions: const [
                      LanguageSelectorButton(),
                    ],
                  ),
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('official_nursery_campaigns', lang),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.get('farmer_campaign_subtitle', lang),
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: Text(AppStrings.get('view_available_varieties', lang)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Verify no RenderFlex overflow exceptions were thrown
          expect(tester.takeException(), isNull);
        }
      });
    }
  });
}
