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

// Fetches only participating nurseries returned by the backend. API failures remain
// visible to the screen's AsyncValue error state; no marketplace demo data is shown.
final nearbyNurseriesProvider = FutureProvider<List<NurseryModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final location = ref.watch(selectedLocationProvider);
  final search = ref.watch(nurserySearchQueryProvider);
  final sortBy = ref.watch(nurserySortByProvider);

  final response = await apiClient.dio.get(
    '/marketplace/nurseries',
    queryParameters: {
      'city': location.city,
      if (search.trim().isNotEmpty) 'search': search.trim(),
      'sortBy': sortBy,
    },
  );
  final data = response.data?['data'];
  if (response.statusCode != 200 || data is! List) {
    throw StateError('The nursery service returned an unexpected response.');
  }
  return data.map((json) => NurseryModel.fromJson(json)).toList();
});