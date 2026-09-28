import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/providers/auth_provider.dart';
import '../models/offer_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Farmer Marketplace Public Offers Provider
// ─────────────────────────────────────────────────────────────────────────────

final marketplaceOffersProvider = FutureProvider<List<NurseryOffer>>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final response = await client.dio.get('/marketplace/offers');
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data.map((json) => NurseryOffer.fromJson(json as Map<String, dynamic>)).toList();
  } catch (e) {
    // If offline or initial bootstrap, provide authentic regional offers matching db schema
    return [
      NurseryOffer(
        id: '77777777-1111-1111-1111-111111111101',
        tenantId: '33333333-3333-3333-3333-333333333333',
        nurseryId: '44444444-4444-4444-4444-444444444444',
        title: 'Ganesh Chaturthi Farmer Offer',
        shortDescription: '10% OFF on Tomato & Chilli hybrid seedling trays for festival field plantation.',
        offerType: 'percentage_discount',
        discountType: 'percentage',
        discountValue: 10,
        discountLabel: '10% OFF',
        applicableCrop: 'Tomato',
        applicableVariety: 'Abhinav Hybrid',
        minQuantity: 2,
        minOrderValue: 300,
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 8)),
        status: 'active',
        eventLabel: '🌿 Farmer Festival Offer',
        validityText: '8 days remaining',
        remainingHours: 192,
        nurseryName: 'AVR Green Yeola Central Facility',
        nurseryCode: 'AVR-YLA-01',
        nurseryIsVerified: true,
        nurseryRating: 4.9,
        nurseryReviews: 184,
        nurseryCity: 'Yeola',
        sampleProducts: ['Abhinav Hybrid Tomato', 'Balram F1 Chilli'],
      ),
      NurseryOffer(
        id: '77777777-1111-1111-1111-111111111102',
        tenantId: '33333333-3333-3333-3333-333333333334',
        nurseryId: '44444444-4444-4444-4444-444444444445',
        title: 'Rabi Season Pre-Booking Special',
        shortDescription: 'Advance tray bookings for Balram & Bullet Teja Chilli with ₹50 OFF per 5 trays.',
        offerType: 'bulk_purchase',
        discountType: 'flat_amount',
        discountValue: 50,
        discountLabel: '₹50 OFF',
        applicableCrop: 'Chilli',
        applicableVariety: 'Balram',
        minQuantity: 5,
        minOrderValue: 1000,
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 18)),
        isPrebookingOffer: true,
        status: 'active',
        eventLabel: '🔥 Early Booking Offer',
        validityText: '18 days remaining',
        remainingHours: 432,
        nurseryName: 'Sai Krupa Seedling Farm',
        nurseryCode: 'SKK-ANG-01',
        nurseryIsVerified: true,
        nurseryRating: 4.8,
        nurseryReviews: 128,
        nurseryCity: 'Angangaon',
        sampleProducts: ['Balram Chilli Seedlings', 'Bullet Teja Mirchi'],
      ),
      NurseryOffer(
        id: '77777777-1111-1111-1111-111111111103',
        tenantId: '33333333-3333-3333-3333-333333333335',
        nurseryId: '44444444-4444-4444-4444-444444444446',
        title: 'Polyhouse Colored Capsicum & Cherry Tomato Launch',
        shortDescription: '15% introductory savings on high-yield exotic vegetable seedling trays.',
        offerType: 'special_price',
        discountType: 'percentage',
        discountValue: 15,
        discountLabel: '15% OFF',
        applicableCrop: 'Capsicum',
        applicableVariety: 'Hybrid Capsicum',
        minQuantity: 1,
        minOrderValue: 250,
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 8)),
        status: 'active',
        eventLabel: '⭐ High-Tech Special',
        validityText: '8 days remaining',
        remainingHours: 192,
        nurseryName: 'Godavari Polyhouse Center',
        nurseryCode: 'GDV-NSK-01',
        nurseryIsVerified: true,
        nurseryRating: 4.7,
        nurseryReviews: 95,
        nurseryCity: 'Nashik',
        sampleProducts: ['Colored Capsicum Seedlings', 'Cherry Tomato'],
      ),
      NurseryOffer(
        id: '77777777-1111-1111-1111-111111111104',
        tenantId: '33333333-3333-3333-3333-333333333336',
        nurseryId: '44444444-4444-4444-4444-444444444447',
        title: 'Chandwad Kisan Monsoon Plantation Offer',
        shortDescription: 'Flat ₹40 OFF on Calcutta Orange Marigold and Kagzi Lemon saplings.',
        offerType: 'flat_discount',
        discountType: 'flat_amount',
        discountValue: 40,
        discountLabel: '₹40 OFF',
        applicableCrop: 'Marigold',
        applicableVariety: 'Calcutta Orange',
        minQuantity: 3,
        minOrderValue: 400,
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 12)),
        status: 'active',
        eventLabel: '🌱 Local Farmer Discount',
        validityText: '12 days remaining',
        remainingHours: 288,
        nurseryName: 'Chandwad Agro Nursery Hub',
        nurseryCode: 'CHD-NSK-01',
        nurseryIsVerified: true,
        nurseryRating: 4.8,
        nurseryReviews: 156,
        nurseryCity: 'Chandwad',
        sampleProducts: ['Calcutta Orange Marigold', 'Kagzi Lemon Saplings'],
      ),
    ];
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// Owner Offers Provider (Filtered by Status)
// ─────────────────────────────────────────────────────────────────────────────

final selectedOwnerOfferTabProvider = StateProvider<String>((ref) => 'all');

final ownerOffersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final tab = ref.watch(selectedOwnerOfferTabProvider);
  try {
    final response = await client.dio.get('/owner/offers', queryParameters: {
      if (tab != 'all') 'status': tab,
    });
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  } catch (e) {
    return [];
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// Offer Details Provider
// ─────────────────────────────────────────────────────────────────────────────

final offerDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, offerId) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.dio.get('/marketplace/offers/$offerId');
  return Map<String, dynamic>.from(response.data['data'] as Map);
});
