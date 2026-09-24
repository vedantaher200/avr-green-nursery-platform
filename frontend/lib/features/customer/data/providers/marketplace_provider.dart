import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/providers/auth_provider.dart';
import '../models/nursery_model.dart';

class FarmerLocation {
  final String city;
  final String district;
  final String state;
  final double lat;
  final double lng;

  const FarmerLocation({
    required this.city,
    required this.district,
    required this.state,
    required this.lat,
    required this.lng,
  });

  String get displayName => '$city, $district';
}

final supportedLocations = <FarmerLocation>[
  const FarmerLocation(city: 'Chandwad', district: 'Nashik', state: 'Maharashtra', lat: 20.3275, lng: 74.2419),
  const FarmerLocation(city: 'Yeola', district: 'Nashik', state: 'Maharashtra', lat: 20.0421, lng: 74.4892),
  const FarmerLocation(city: 'Angangaon', district: 'Yeola / Nashik', state: 'Maharashtra', lat: 20.0154, lng: 74.5210),
  const FarmerLocation(city: 'Nashik', district: 'Nashik', state: 'Maharashtra', lat: 20.0110, lng: 73.7900),
  const FarmerLocation(city: 'Lasalgaon', district: 'Nashik', state: 'Maharashtra', lat: 20.1472, lng: 74.2253),
  const FarmerLocation(city: 'Niphad', district: 'Nashik', state: 'Maharashtra', lat: 20.0811, lng: 74.1106),
  const FarmerLocation(city: 'Kopargaon', district: 'Ahmednagar', state: 'Maharashtra', lat: 19.8856, lng: 74.4815),
];

// Current location selected by farmer (default: Chandwad, Nashik)
final selectedLocationProvider = StateProvider<FarmerLocation>((ref) {
  return supportedLocations.first; // Chandwad, Nashik
});

// Currently selected nursery for browsing products & ordering (null means browsing full marketplace)
final selectedNurseryProvider = StateProvider<NurseryModel?>((ref) => null);

// Search query for nurseries in marketplace discovery
final nurserySearchQueryProvider = StateProvider<String>((ref) => '');

// Sort criteria for nurseries: 'rank' (default multi-factor), 'distance', 'rating', 'varieties'
final nurserySortByProvider = StateProvider<String>((ref) => 'rank');
final allowOfflineDemoNurseriesProvider = StateProvider<bool>((ref) => false);

// Fetches nurseries near the selected location with transparent ranking from backend
final nearbyNurseriesProvider = FutureProvider<List<NurseryModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final location = ref.watch(selectedLocationProvider);
  final search = ref.watch(nurserySearchQueryProvider);
  final sortBy = ref.watch(nurserySortByProvider);
  final allowDemo = ref.watch(allowOfflineDemoNurseriesProvider);

  try {
    final response = await apiClient.dio.get(
      '/marketplace/nurseries',
      queryParameters: {
        'city': location.city,
        if (search.trim().isNotEmpty) 'search': search.trim(),
        'lat': location.lat,
        'lng': location.lng,
        'sortBy': sortBy,
      },
    );

    if (response.statusCode == 200 && response.data['data'] is List) {
      final List raw = response.data['data'];
      return raw.map((json) => NurseryModel.fromJson(json)).toList();
    }
  } catch (e) {
    if (allowDemo) {
      // Return offline fallback demo data if explicitly permitted
    } else {
      rethrow;
    }
  }

  // Fallback data when backend is not reached — explicitly labeled as demo
  final allFallback = [
    const NurseryModel(
      id: '44444444-4444-4444-4444-444444444447',
      tenantId: '33333333-3333-3333-3333-333333333336',
      name: 'Chandwad Agro Nursery Hub',
      code: 'CHD-NSK-01',
      isVerified: true,
      deliveryAvailable: true,
      pickupAvailable: true,
      rating: 4.8,
      reviewCount: 156,
      imageUrl: 'assets/images/nursery_hero_banner.jpg',
      openingTime: '07:00 AM',
      closingTime: '07:00 PM',
      isOpen: true,
      locationName: 'Chandwad Kisan Center',
      street: 'Lasalgaon Road, Chandwad',
      city: 'Chandwad',
      state: 'Maharashtra',
      pincode: '423101',
      contactPhone: '+91 9900000041',
      geoLat: 20.3275,
      geoLng: 74.2419,
      distanceKm: 1.2,
      activeVarietiesCount: 8,
      availableCrops: ['Tomato', 'Chilli', 'Capsicum', 'Brinjal', 'Cabbage', 'Cauliflower', 'Marigold', 'Lemon'],
      rankingScore: 92,
      rankingBadge: 'Nearest Hub (1.2 km)',
      rankingReason: 'Ranked #1 for Chandwad based on 1.2 km distance, verified status, and 8 active seedling varieties.',
      isExactCityMatch: true,
      isDemoData: true,
    ),
    const NurseryModel(
      id: '44444444-4444-4444-4444-444444444448',
      tenantId: '33333333-3333-3333-3333-333333333337',
      name: 'Shree Samarth Agro Seedlings',
      code: 'SAM-CHD-02',
      isVerified: true,
      deliveryAvailable: true,
      pickupAvailable: true,
      rating: 4.6,
      reviewCount: 72,
      imageUrl: 'assets/images/nursery_hero_banner.jpg',
      openingTime: '07:00 AM',
      closingTime: '06:30 PM',
      isOpen: true,
      locationName: 'Samarth Seedling Facility',
      street: 'Lasalgaon-Chandwad Link Highway',
      city: 'Chandwad',
      state: 'Maharashtra',
      pincode: '423101',
      contactPhone: '+91 9900000051',
      geoLat: 20.3120,
      geoLng: 74.2510,
      distanceKm: 2.1,
      activeVarietiesCount: 6,
      availableCrops: ['Tomato', 'Chilli', 'Onion', 'Brinjal'],
      rankingScore: 84,
      rankingBadge: 'Local Chandwad Grower',
      rankingReason: 'Ranked based on 2.1 km distance and local seedling production.',
      isExactCityMatch: true,
      isDemoData: true,
    ),
    const NurseryModel(
      id: '44444444-4444-4444-4444-444444444444',
      tenantId: '33333333-3333-3333-3333-333333333333',
      name: 'AVR Green Yeola Central Facility',
      code: 'AVR-YLA-01',
      isVerified: true,
      deliveryAvailable: true,
      pickupAvailable: true,
      rating: 4.9,
      reviewCount: 184,
      imageUrl: 'assets/images/nursery_hero_banner.jpg',
      openingTime: '06:30 AM',
      closingTime: '07:30 PM',
      isOpen: true,
      locationName: 'Yeola Central Highway Branch',
      street: 'Manmad-Yeola Highway, Near Market Yard',
      city: 'Yeola',
      state: 'Maharashtra',
      pincode: '423401',
      contactPhone: '+91 9900000002',
      geoLat: 20.0421,
      geoLng: 74.4892,
      distanceKm: 31.5,
      activeVarietiesCount: 18,
      availableCrops: ['Chilli', 'Tomato', 'Capsicum', 'Brinjal', 'Lemon', 'Mango'],
      rankingScore: 86,
      rankingBadge: 'Top Rated (⭐ 4.9)',
      rankingReason: 'Ranked based on 4.9 star rating and highest volume of verified farmer reviews.',
      isExactCityMatch: false,
      isDemoData: true,
    ),
    const NurseryModel(
      id: '44444444-4444-4444-4444-444444444445',
      tenantId: '33333333-3333-3333-3333-333333333334',
      name: 'Sai Krupa Seedling Farm',
      code: 'SKK-ANG-01',
      isVerified: true,
      deliveryAvailable: true,
      pickupAvailable: true,
      rating: 4.8,
      reviewCount: 128,
      imageUrl: 'assets/images/nursery_hero_banner.jpg',
      openingTime: '07:00 AM',
      closingTime: '07:00 PM',
      isOpen: true,
      locationName: 'Angangaon Farm Center',
      street: 'Angangaon Road, Taluka Yeola',
      city: 'Angangaon',
      state: 'Maharashtra',
      pincode: '423401',
      contactPhone: '+91 9900000021',
      geoLat: 20.0154,
      geoLng: 74.5210,
      distanceKm: 34.0,
      activeVarietiesCount: 9,
      availableCrops: ['Chilli', 'Tomato', 'Marigold', 'Sugarcane'],
      rankingScore: 78,
      rankingBadge: 'Specialist: Sugarcane & Marigold',
      rankingReason: 'Specialized seedling producer with 128 verified customer reviews.',
      isExactCityMatch: false,
      isDemoData: true,
    ),
    const NurseryModel(
      id: '44444444-4444-4444-4444-444444444446',
      tenantId: '33333333-3333-3333-3333-333333333335',
      name: 'Godavari Polyhouse Center',
      code: 'GDV-NSK-01',
      isVerified: true,
      deliveryAvailable: true,
      pickupAvailable: false,
      rating: 4.7,
      reviewCount: 95,
      imageUrl: 'assets/images/nursery_hero_banner.jpg',
      openingTime: '07:30 AM',
      closingTime: '06:30 PM',
      isOpen: true,
      locationName: 'Panchavati Hi-Tech Nursery',
      street: 'Dindori Road, Panchavati',
      city: 'Nashik',
      state: 'Maharashtra',
      pincode: '422003',
      contactPhone: '+91 9900000031',
      geoLat: 20.0110,
      geoLng: 73.7900,
      distanceKm: 64.0,
      activeVarietiesCount: 12,
      availableCrops: ['Capsicum', 'Chilli', 'Brinjal', 'Chrysanthemum'],
      rankingScore: 72,
      rankingBadge: 'Hi-Tech Polyhouse Seeds',
      rankingReason: 'High-tech climate-controlled nursery facility.',
      isExactCityMatch: false,
      isDemoData: true,
    ),
  ];

  // If farmer selected a specific location, prioritize that city's nurseries
  final c = location.city.toLowerCase();
  final inCity = allFallback.where((n) => n.city.toLowerCase() == c).toList();
  final outside = allFallback.where((n) => n.city.toLowerCase() != c).toList();

  return [...inCity, ...outside];
});
