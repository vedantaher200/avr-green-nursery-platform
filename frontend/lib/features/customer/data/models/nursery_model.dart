class NurseryModel {
  final String id;
  final String tenantId;
  final String name;
  final String code;
  final bool isVerified;
  final bool deliveryAvailable;
  final bool pickupAvailable;
  final double rating;
  final String? locationName;
  final String city;
  final String state;
  final String pincode;
  final String contactPhone;
  final double geoLat;
  final double geoLng;
  final double distanceKm;
  final int activeVarietiesCount;
  final List<String> availableCrops;

  const NurseryModel({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.code,
    required this.isVerified,
    required this.deliveryAvailable,
    required this.pickupAvailable,
    required this.rating,
    this.locationName,
    required this.city,
    required this.state,
    required this.pincode,
    required this.contactPhone,
    required this.geoLat,
    required this.geoLng,
    required this.distanceKm,
    required this.activeVarietiesCount,
    this.availableCrops = const [],
  });

  factory NurseryModel.fromJson(Map<String, dynamic> json) {
    List<String> crops = [];
    if (json['availableCrops'] is List) {
      crops = (json['availableCrops'] as List).map((e) => e.toString()).toList();
    }

    return NurseryModel(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? json['tenant_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Nursery',
      code: json['code'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? json['is_verified'] as bool? ?? true,
      deliveryAvailable: json['deliveryAvailable'] as bool? ?? json['delivery_available'] as bool? ?? true,
      pickupAvailable: json['pickupAvailable'] as bool? ?? json['pickup_available'] as bool? ?? true,
      rating: double.tryParse(json['rating']?.toString() ?? '4.8') ?? 4.8,
      locationName: json['locationName'] as String? ?? json['location_name'] as String?,
      city: json['city'] as String? ?? 'Yeola',
      state: json['state'] as String? ?? 'Maharashtra',
      pincode: json['pincode'] as String? ?? '423401',
      contactPhone: json['contactPhone'] as String? ?? json['contact_phone'] as String? ?? '+91 9900000002',
      geoLat: double.tryParse(json['geoLat']?.toString() ?? json['geo_lat']?.toString() ?? '20.0421') ?? 20.0421,
      geoLng: double.tryParse(json['geoLng']?.toString() ?? json['geo_lng']?.toString() ?? '74.4892') ?? 74.4892,
      distanceKm: double.tryParse(json['distanceKm']?.toString() ?? '3.5') ?? 3.5,
      activeVarietiesCount: json['activeVarietiesCount'] as int? ?? json['active_varieties_count'] as int? ?? 12,
      availableCrops: crops,
    );
  }
}
