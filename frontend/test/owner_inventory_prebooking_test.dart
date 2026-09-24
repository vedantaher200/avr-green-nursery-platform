import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avrgreen/features/catalog/data/models/product_model.dart';
import 'package:avrgreen/features/customer/presentation/widgets/farmer_prebooking_modal.dart';
import 'package:avrgreen/features/inventory/data/models/owner_inventory_models.dart';

void main() {
  group('Owner Inventory & Stock States Model Tests', () {
    test('5 Stock States & Pricing Tiers on Product Model', () {
      const readyProduct = Product(
        id: 'prod-tomato-1',
        sku: 'TOM-HYB-01',
        commonName: 'Tomato Hybrid',
        crop: 'Tomato',
        variety: 'Abhinav Hybrid',
        categoryId: 'vegetables',
        categoryName: 'Vegetable Plants',
        price: 2.50,
        plantPrice: 2.50,
        trayPrice: 260.0,
        bulkPrice: 2.10,
        trayCapacity: 104,
        availableStock: 20000,
        readyStock: 20000,
        futureStock: 50000,
        readyDate: '10 Oct 2026',
        stockState: 'ready_now',
        care: CareInstructions(
          sunlight: 'Full Sun',
          watering: 'Regular',
          fertilizer: 'NPK',
          temperature: '20-30°C',
        ),
      );

      // Verify ready state & isolation
      expect(readyProduct.stockBadgeLabel, equals('READY NOW'));
      expect(readyProduct.isReadyStock, isTrue);
      expect(readyProduct.readyStock, equals(20000));
      expect(readyProduct.futureStock, equals(50000));
      expect(readyProduct.effectiveTrayPrice, equals(260.0));
      expect(readyProduct.effectiveBulkPrice, equals(2.10));
      expect(readyProduct.trayCapacity, equals(104));

      // Test all 5 stock states
      const limitedProduct = Product(
        id: 'prod-marigold-1',
        sku: 'MAR-01',
        commonName: 'Marigold',
        categoryId: 'flowers',
        categoryName: 'Flower Plants',
        price: 3.0,
        stockState: 'limited_stock',
        care: CareInstructions(sunlight: '', watering: '', fertilizer: '', temperature: ''),
      );
      expect(limitedProduct.stockBadgeLabel, equals('LIMITED STOCK'));
      expect(limitedProduct.isLimitedStock, isTrue);

      const comingSoonProduct = Product(
        id: 'prod-capsicum-1',
        sku: 'CAP-01',
        commonName: 'Capsicum',
        categoryId: 'vegetables',
        categoryName: 'Vegetable Plants',
        price: 3.5,
        stockState: 'coming_soon',
        care: CareInstructions(sunlight: '', watering: '', fertilizer: '', temperature: ''),
      );
      expect(comingSoonProduct.stockBadgeLabel, equals('COMING SOON'));
      expect(comingSoonProduct.isComingSoon, isTrue);

      const prebookProduct = Product(
        id: 'prod-chilli-1',
        sku: 'CHL-01',
        commonName: 'Chilli Teja',
        categoryId: 'vegetables',
        categoryName: 'Vegetable Plants',
        price: 2.8,
        stockState: 'prebook_available',
        care: CareInstructions(sunlight: '', watering: '', fertilizer: '', temperature: ''),
      );
      expect(prebookProduct.stockBadgeLabel, equals('PRE-BOOK AVAILABLE'));
      expect(prebookProduct.isPrebookAvailable, isTrue);

      const soldOutProduct = Product(
        id: 'prod-brinjal-1',
        sku: 'BRN-01',
        commonName: 'Brinjal Ravaiya',
        categoryId: 'vegetables',
        categoryName: 'Vegetable Plants',
        price: 2.2,
        stockState: 'sold_out',
        care: CareInstructions(sunlight: '', watering: '', fertilizer: '', temperature: ''),
      );
      expect(soldOutProduct.stockBadgeLabel, equals('SOLD OUT'));
      expect(soldOutProduct.isSoldOut, isTrue);
    });

    test('Owner Dashboard Overview KPIs Verification', () {
      const overview = OwnerDashboardOverview(
        totalReadyStock: 25480,
        totalReservedStock: 1200,
        totalPrebookedQuantity: 18500,
        totalFutureProduction: 180000,
        expectedProductionDate: '10 Oct 2026',
        pendingPrebookingsCount: 3,
        activeAnnouncementsCount: 1,
        products: [],
        recentPrebookings: [],
        announcements: [],
      );

      expect(overview.totalReadyStock, equals(25480));
      expect(overview.totalReservedStock, equals(1200));
      expect(overview.totalPrebookedQuantity, equals(18500));
      expect(overview.totalFutureProduction, equals(180000));
      expect(overview.expectedProductionDate, equals('10 Oct 2026'));
      expect(overview.pendingPrebookingsCount, equals(3));
    });

    test('Owner Announcement Broadcast Model Verification', () {
      const announcement = NurseryAnnouncementModel(
        id: 'ann-1',
        nurseryName: 'AVR Green Nursery',
        title: 'Tomato Hybrid Ready & Pre-Booking',
        content: 'Tomato Hybrid — 20,000 plants ready. Next batch of 50,000 plants expected in 10 days.',
        crop: 'Tomato',
        variety: 'Abhinav Hybrid',
        readyQuantity: 20000,
        futureQuantity: 50000,
        expectedDays: 10,
        unit: 'plants',
        publishedAt: '2026-09-24',
      );

      expect(announcement.readyQuantity, equals(20000));
      expect(announcement.futureQuantity, equals(50000));
      expect(announcement.expectedDays, equals(10));
      expect(announcement.content, contains('20,000 plants ready'));
      expect(announcement.content, contains('50,000 plants expected in 10 days'));
    });

    test('Pre-Booking Advance and Zero Ready Stock Deduction Rule', () {
      const preBooking = PreBookingModel(
        id: 'pre-1',
        bookingNumber: 'PRE-AVR-004812',
        farmerName: 'Suresh Patil',
        farmerPhone: '9822011223',
        unit: 'tray',
        quantity: 10,
        totalPlants: 1040,
        unitPrice: 260.0,
        totalAmount: 2600.0,
        advanceAmount: 520.0,
        expectedReadyDate: '10 Oct 2026',
        status: 'pending',
      );

      expect(preBooking.totalPlants, equals(1040));
      expect(preBooking.advanceAmount, equals(520.0));
      expect(preBooking.totalAmount - preBooking.advanceAmount, equals(2080.0));
      expect(preBooking.bookingNumber, startsWith('PRE-AVR-'));
    });
  });

  group('Farmer Pre-Booking Modal Widget Tests', () {
    testWidgets('Farmer can select unit, adjust quantity, and see advance cost calculation', (tester) async {
      const testProduct = Product(
        id: 'prod-tomato-test',
        sku: 'TOM-01',
        commonName: 'Tomato Hybrid',
        crop: 'Tomato',
        variety: 'Abhinav Hybrid',
        categoryId: 'vegetables',
        categoryName: 'Vegetable Plants',
        price: 2.50,
        plantPrice: 2.50,
        trayPrice: 260.0,
        bulkPrice: 2.10,
        trayCapacity: 104,
        availableStock: 20000,
        readyStock: 20000,
        futureStock: 50000,
        readyDate: '10 Oct 2026',
        stockState: 'prebook_available',
        care: CareInstructions(sunlight: '', watering: '', fertilizer: '', temperature: ''),
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FarmerPreBookingModal(product: testProduct),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header and batch info
      expect(find.text('⏳ ADVANCE PRE-BOOKING'), findsOneWidget);
      expect(find.text('Tomato — Abhinav Hybrid'), findsOneWidget);
      expect(find.text('Expected Batch Readiness Date'), findsOneWidget);
      expect(find.text('10 Oct 2026'), findsOneWidget);

      // Verify unit choices
      expect(find.text('Pro-Tray'), findsOneWidget);
      expect(find.text('Bulk Lot'), findsOneWidget);
      expect(find.text('Per Plant'), findsOneWidget);

      // Initial default: 5 trays * 104 = 520 plants, total = 5 * 260 = ₹1300, advance = 20% = ₹260
      expect(find.text('Total Plants Reserved:'), findsOneWidget);
      expect(find.text('520 Plants'), findsOneWidget);
      expect(find.text('₹1300.00'), findsOneWidget);
      expect(find.text('₹260.00'), findsOneWidget);

      // Tap + to increment quantity to 6
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // 6 trays * 104 = 624 plants, total = 6 * 260 = ₹1560, advance = 20% = ₹312
      expect(find.text('624 Plants'), findsOneWidget);
      expect(find.text('₹1560.00'), findsOneWidget);
      expect(find.text('₹312.00'), findsOneWidget);
    });
  });
}
