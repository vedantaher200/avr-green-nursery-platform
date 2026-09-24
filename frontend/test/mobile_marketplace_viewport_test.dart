import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avrgreen/features/catalog/presentation/screens/catalog_screen.dart';
import 'package:avrgreen/features/catalog/presentation/screens/product_detail_screen.dart';
import 'package:avrgreen/features/catalog/presentation/widgets/compact_product_card.dart';
import 'package:avrgreen/features/catalog/data/models/product_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Amazon-Style Compact Marketplace Mobile Viewport Verification', () {
    testWidgets('Validates CompactProductCard displays required fields without overflow on mobile width',
        (tester) async {
      // Set typical Android / iPhone mobile screen dimensions (390 x 844)
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const testProduct = Product(
        id: 'test-tomato-01',
        sku: 'TOM-ABH-104',
        commonName: 'Hybrid Tomato',
        scientificName: 'Solanum lycopersicum F1',
        crop: 'Tomato',
        variety: 'Abhinav F1 Hybrid Tomato',
        sellingUnit: 'tray',
        traySize: 104,
        trayCapacity: 104,
        price: 260.00,
        plantPrice: 2.50,
        trayPrice: 260.00,
        bulkPrice: 2.10,
        categoryId: 'vegetables',
        categoryName: 'Vegetable Plants',
        nurseryName: 'Chandwad Agro Nursery Hub',
        nurseryRating: 4.8,
        productRating: 4.9,
        reviewCount: 164,
        readyStock: 850,
        availableStock: 850,
        care: CareInstructions(
          sunlight: 'Full Sun',
          watering: 'Moderate',
          fertilizer: 'NPK',
          temperature: '18-32°C',
        ),
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 175,
                height: 290,
                child: CompactProductCard(product: testProduct),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Variety Name, Nursery Name, Rating, Review Count, Prices, and Add Cart button
      expect(find.text('Abhinav F1 Hybrid Tomato'), findsOneWidget);
      expect(find.text('Chandwad Agro Nursery Hub'), findsOneWidget);
      expect(find.textContaining('4.8'), findsOneWidget);
      expect(find.textContaining('(164)'), findsOneWidget);
      expect(find.text('₹2.50 / plant'), findsOneWidget);
      expect(find.textContaining('₹260 / tray (104 plants)'), findsOneWidget);
      expect(find.text('READY NOW'), findsOneWidget);
      expect(find.text('+ Add Cart'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Validates CatalogScreen renders 2-column grid and categories on mobile viewport',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CatalogScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Title and Category Rails
      expect(find.text('Farmer Marketplace'), findsOneWidget);
      expect(find.text('All Plants'), findsOneWidget);
      expect(find.text('Vegetable Plants'), findsOneWidget);

      // Scroll horizontal category rail to verify remaining categories
      await tester.drag(find.byType(ListView).first, const Offset(-150, 0));
      await tester.pumpAndSettle();
      expect(find.text('Flower Plants'), findsOneWidget);

      // Verify multiple CompactProductCards are rendered in the grid
      expect(find.byType(CompactProductCard), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Validates ProductDetailScreen renders pricing tiers and field agronomy on mobile viewport',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductDetailScreen(productId: '88888888-8888-8888-8888-888888888801'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Title & Nursery
      expect(find.text('Abhinav F1 Hybrid Tomato'), findsOneWidget);
      expect(find.text('Chandwad Agro Nursery Hub'), findsOneWidget);

      // Verify Pricing Tiers
      expect(find.text('Commercial Pricing Tiers'), findsOneWidget);
      expect(find.text('Per Plant'), findsOneWidget);
      expect(find.text('Pro-Tray'), findsOneWidget);
      expect(find.text('Bulk Quantity'), findsOneWidget);

      // Verify Configurable Tray Capacity Banner
      expect(find.textContaining('104 Plants / Pro-Tray'), findsOneWidget);

      // Verify Field Agronomy section
      expect(find.text('Field Agronomy & Growing Information'), findsOneWidget);
      expect(find.text('Season'), findsOneWidget);
      expect(find.text('Water Requirement'), findsOneWidget);
      expect(find.text('Expected Yield'), findsOneWidget);

      // Verify CTAs
      expect(find.text('Add to Cart'), findsOneWidget);
      expect(find.text('Buy Now'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
