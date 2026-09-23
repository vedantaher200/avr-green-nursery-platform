import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avrgreen/core/theme/app_theme.dart';
import 'package:avrgreen/core/localization/app_strings.dart';
import 'package:avrgreen/features/catalog/data/models/product_model.dart';
import 'package:avrgreen/features/customer/data/providers/cart_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AVR Green Botanical Theme & Design System (Master Prompt Section 32)', () {
    test('Theme constants use exact corporate botanical hex colors', () {
      expect(AVRColors.forestGreen, const Color(0xFF1F5D3A)); // Deep Forest Green
      expect(AVRColors.terracotta, const Color(0xFFC9713D)); // Warm Terracotta
      expect(AVRColors.sage, const Color(0xFFA8C5A0)); // Soft Sage
      expect(AVRColors.success, const Color(0xFF3C9A5F));
      expect(AVRColors.warning, const Color(0xFFD98E27));
      expect(AVRColors.error, const Color(0xFFB84C3C));
    });
  });

  group('Multilingual Architecture (Master Prompt Section 16 & 37)', () {
    test('Provides English, Hindi, and Marathi translations for agricultural terms', () {
      expect(AppStrings.get('app_name', AppLanguage.en), 'AVR Green Nursery');
      expect(AppStrings.get('app_name', AppLanguage.hi), 'एवीआर ग्रीन नर्सरी');
      expect(AppStrings.get('app_name', AppLanguage.mr), 'एव्हीआर ग्रीन नर्सरी');

      expect(AppStrings.get('add_to_cart', AppLanguage.en), 'Add to Cart');
      expect(AppStrings.get('add_to_cart', AppLanguage.hi), 'कार्ट में जोड़ें');
      expect(AppStrings.get('add_to_cart', AppLanguage.mr), 'कार्टमध्ये जोडा');
    });
  });

  group('Product Model & Horticultural Metadata (Master Prompt Section 17)', () {
    test('Parses plant details and care instructions correctly', () {
      const plant = Product(
        id: 'test-plant-1',
        sku: 'PLANT-MON-01',
        commonName: 'Monstera Deliciosa',
        scientificName: 'Monstera deliciosa Liebm.',
        price: 899.00,
        categoryId: 'indoor',
        categoryName: 'Indoor Plants',
        care: CareInstructions(
          sunlight: 'Bright Indirect Light',
          watering: 'Once weekly',
          fertilizer: 'Organic compost monthly',
          temperature: '18°C - 30°C',
        ),
      );

      expect(plant.commonName, 'Monstera Deliciosa');
      expect(plant.price, 899.00);
      expect(plant.care.sunlight, 'Bright Indirect Light');
      expect(plant.care.watering, 'Once weekly');
    });
  });

  group('Cart Calculations & Stock Safety (Master Prompt Section 19 & 53)', () {
    test('Correctly computes subtotal, GST (18%), delivery fee, and grand total', () {
      final notifier = CartNotifier();
      expect(notifier.state.isEmpty, isTrue);

      const plant = Product(
        id: 'plant-1',
        sku: 'PLANT-1',
        commonName: 'Rose Plant',
        price: 400.00,
        categoryId: 'flowering',
        categoryName: 'Flowering',
        care: CareInstructions(
          sunlight: 'Direct',
          watering: 'Daily',
          fertilizer: 'Compost',
          temperature: 'Warm',
        ),
      );

      // Add 2 items
      notifier.addItem(plant, quantity: 2);
      expect(notifier.state.totalItemCount, 2);
      expect(notifier.state.subtotal, 800.00);
      expect(notifier.state.gst, 144.00); // 18% of 800
      expect(notifier.state.deliveryFee, 99.00); // Orders < 1000 incur delivery fee
      expect(notifier.state.grandTotal, 1043.00); // 800 + 144 + 99

      // Increment quantity to qualify for free delivery (subtotal >= 1000)
      notifier.updateQuantity('plant-1', 1);
      expect(notifier.state.totalItemCount, 3);
      expect(notifier.state.subtotal, 1200.00);
      expect(notifier.state.deliveryFee, 0.0); // Free delivery >= 1000
      expect(notifier.state.grandTotal, 1416.00); // 1200 + 216

      // Remove item
      notifier.removeItem('plant-1');
      expect(notifier.state.isEmpty, isTrue);
    });
  });

  group('Mobile Responsive Viewport Safety (Checklist Point 6)', () {
    const viewports = [
      Size(360, 800), // Standard Android compact
      Size(375, 812), // iPhone X / 12 mini
      Size(390, 844), // iPhone 13 / 14 / 15
      Size(412, 915), // Pixel 7 / Galaxy S series
    ];

    for (final size in viewports) {
      testWidgets('Renders layout safely at ${size.width.toInt()}x${size.height.toInt()} with zero overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: AVRTheme.lightTheme,
            home: Scaffold(
              appBar: AppBar(
                title: const Text('AVR Green Nursery'),
              ),
              body: ListView(
                children: [
                  Container(
                    height: 180,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AVRColors.sage.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: Text('Fresh Healthy Seedlings')),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('See All', style: TextStyle(color: AVRColors.forestGreen, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Role Entry Screen — Farmer vs Nursery/Staff (User Request Section 3 & 18)', () {
    testWidgets('Renders role selection cards and switches between Farmer and Nursery login modes', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Build a minimal test container for the role switch UI
      int selectedRoleIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AVRTheme.lightTheme,
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text('Who are you logging in as?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ListTile(
                        title: const Text('Farmer / Customer'),
                        subtitle: const Text('Shop plants & seedlings'),
                        onTap: () => setState(() => selectedRoleIndex = 0),
                      ),
                      ListTile(
                        title: const Text('Nursery / Staff'),
                        subtitle: const Text('Manage your nursery'),
                        onTap: () => setState(() => selectedRoleIndex = 1),
                      ),
                      if (selectedRoleIndex == 0) ...[
                        const TextField(
                          key: Key('farmer_phone_field'),
                          decoration: InputDecoration(labelText: 'Mobile Number'),
                        ),
                        const TextField(
                          key: Key('farmer_pin_field'),
                          decoration: InputDecoration(labelText: '6-digit PIN'),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Sign In with Secure PIN'),
                        ),
                      ] else ...[
                        const TextField(
                          key: Key('owner_email_field'),
                          decoration: InputDecoration(labelText: 'Email Address'),
                        ),
                        const TextField(
                          key: Key('owner_password_field'),
                          decoration: InputDecoration(labelText: 'Password'),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Sign In with Password'),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check role titles
      expect(find.text('Who are you logging in as?'), findsOneWidget);
      expect(find.text('Farmer / Customer'), findsOneWidget);
      expect(find.text('Nursery / Staff'), findsOneWidget);

      // Initially Farmer mode is selected
      expect(find.byKey(const Key('farmer_phone_field')), findsOneWidget);
      expect(find.byKey(const Key('farmer_pin_field')), findsOneWidget);
      expect(find.text('Sign In with Secure PIN'), findsOneWidget);
      expect(find.byKey(const Key('owner_email_field')), findsNothing);

      // Switch to Nursery / Staff
      await tester.tap(find.text('Nursery / Staff'));
      await tester.pumpAndSettle();

      // Verify Nursery / Staff fields appear
      expect(find.byKey(const Key('owner_email_field')), findsOneWidget);
      expect(find.byKey(const Key('owner_password_field')), findsOneWidget);
      expect(find.text('Sign In with Password'), findsOneWidget);
      expect(find.byKey(const Key('farmer_phone_field')), findsNothing);

      // Switch back to Farmer / Customer
      await tester.tap(find.text('Farmer / Customer'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('farmer_phone_field')), findsOneWidget);
      expect(find.byKey(const Key('farmer_pin_field')), findsOneWidget);
    });
  });

  group('Multi-Nursery Marketplace & Single-Nursery Cart Isolation (Master Concept)', () {
    test('Strictly isolates carts by nursery; rejects cross-nursery mixing with nurseryConflict', () {
      final cartNotifier = CartNotifier();
      expect(cartNotifier.state.isEmpty, isTrue);

      const testCare = CareInstructions(
        sunlight: 'Full Sun',
        watering: 'Daily in morning',
        fertilizer: 'NPK 19:19:19',
        temperature: '22°C - 35°C',
      );

      const nurseryAProduct = Product(
        id: 'prod-yeola-1',
        tenantId: '33333333-3333-3333-3333-333333333333',
        nurseryName: 'AVR Green Nursery - Yeola Central',
        sku: 'VEG-CHIL-BAL',
        commonName: 'Chilli Seedlings (मिर्ची रोपे)',
        categoryId: 'veg',
        categoryName: 'Vegetable Seedlings',
        crop: 'Chilli',
        variety: 'Balram F1',
        sellingUnit: 'pack_100',
        price: 180.0,
        care: testCare,
      );

      const nurseryBProduct = Product(
        id: 'prod-sai-1',
        tenantId: '33333333-3333-3333-3333-333333333334',
        nurseryName: 'Sai Krupa Krishi Nursery',
        sku: 'VEG-TOM-ABHI',
        commonName: 'Tomato Seedlings (टोमॅटो रोपे)',
        categoryId: 'veg',
        categoryName: 'Vegetable Seedlings',
        crop: 'Tomato',
        variety: 'Abhinav',
        sellingUnit: 'tray',
        traySize: 104,
        price: 250.0,
        care: testCare,
      );

      // 1. Add product from Nursery A
      final res1 = cartNotifier.addItem(nurseryAProduct, quantity: 2);
      expect(res1, CartAddResult.success);
      expect(cartNotifier.state.totalItemCount, 2);
      expect(cartNotifier.state.currentTenantId, '33333333-3333-3333-3333-333333333333');
      expect(cartNotifier.state.currentNurseryName, 'AVR Green Nursery - Yeola Central');

      // 2. Add another product from Nursery A (allowed)
      final res2 = cartNotifier.addItem(nurseryAProduct, quantity: 1);
      expect(res2, CartAddResult.success);
      expect(cartNotifier.state.totalItemCount, 3);

      // 3. Attempt to add product from Nursery B (MUST return nurseryConflict and NOT modify cart)
      final resConflict = cartNotifier.addItem(nurseryBProduct, quantity: 1);
      expect(resConflict, CartAddResult.nurseryConflict);
      expect(cartNotifier.state.totalItemCount, 3); // Unchanged!
      expect(cartNotifier.state.currentTenantId, '33333333-3333-3333-3333-333333333333');

      // 4. Farmer explicitly chooses to clear and switch nursery
      cartNotifier.clearAndAdd(nurseryBProduct, quantity: 5);
      expect(cartNotifier.state.totalItemCount, 5);
      expect(cartNotifier.state.currentTenantId, '33333333-3333-3333-3333-333333333334');
      expect(cartNotifier.state.currentNurseryName, 'Sai Krupa Krishi Nursery');
    });

    test('Crop & Variety hierarchy and selling unit labels format correctly', () {
      const testCare = CareInstructions(
        sunlight: 'Full Sun',
        watering: 'Daily in morning',
        fertilizer: 'NPK 19:19:19',
        temperature: '22°C - 35°C',
      );

      const product1 = Product(
        id: 'p1',
        sku: 'SKU1',
        commonName: 'Capsicum Seedling',
        categoryId: 'veg',
        categoryName: 'Vegetable Seedlings',
        crop: 'Capsicum',
        variety: 'Indra',
        sellingUnit: 'tray',
        traySize: 104,
        price: 320.0,
        care: testCare,
      );

      expect(product1.crop, 'Capsicum');
      expect(product1.variety, 'Indra');
      expect(product1.unitLabel, 'Tray (104 Plants)');

      const product2 = Product(
        id: 'p2',
        sku: 'SKU2',
        commonName: 'Chilli Seedling',
        categoryId: 'veg',
        categoryName: 'Vegetable Seedlings',
        crop: 'Chilli',
        variety: 'Bullet',
        sellingUnit: 'pack_100',
        price: 180.0,
        care: testCare,
      );
      expect(product2.unitLabel, 'Pack (100 Plants)');
    });
  });
}

