class RatingBreakdown {
  final double plantQuality;
  final double delivery;
  final double service;
  final double packaging;
  final double value;

  const RatingBreakdown({
    this.plantQuality = 4.9,
    this.delivery = 4.7,
    this.service = 4.8,
    this.packaging = 4.8,
    this.value = 4.7,
  });

  factory RatingBreakdown.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RatingBreakdown();
    return RatingBreakdown(
      plantQuality: double.tryParse(json['plantQuality']?.toString() ?? '4.9') ?? 4.9,
      delivery: double.tryParse(json['delivery']?.toString() ?? '4.7') ?? 4.7,
      service: double.tryParse(json['service']?.toString() ?? '4.8') ?? 4.8,
      packaging: double.tryParse(json['packaging']?.toString() ?? '4.8') ?? 4.8,
      value: double.tryParse(json['value']?.toString() ?? '4.7') ?? 4.7,
    );
  }
}

class RankingFactors {
  final int proximity;
  final int verification;
  final int rating;
  final int reviewCount;
  final int successfulOrders;
  final int recentActivity;
  final int total;

  const RankingFactors({
    this.proximity = 25,
    this.verification = 20,
    this.rating = 15,
    this.reviewCount = 10,
    this.successfulOrders = 15,
    this.recentActivity = 10,
    this.total = 95,
  });

  factory RankingFactors.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RankingFactors();
    return RankingFactors(
      proximity: json['proximity'] as int? ?? 25,
      verification: json['verification'] as int? ?? 20,
      rating: json['rating'] as int? ?? 15,
      reviewCount: json['reviewCount'] as int? ?? 10,
      successfulOrders: json['successfulOrders'] as int? ?? 15,
      recentActivity: json['recentActivity'] as int? ?? 10,
      total: json['total'] as int? ?? 95,
    );
  }
}

class NurseryModel {
  final String id;
  final String tenantId;
  final String name;
  final String code;
  final bool isVerified;
  final bool deliveryAvailable;
  final bool pickupAvailable;
  final double rating;
  final int reviewCount;
  final RatingBreakdown ratingBreakdown;
  final int successfulOrdersCount;
  final String activityText;
  final String imageUrl;
  final String openingTime;
  final String closingTime;
  final bool isOpen;
  final String? locationName;
  final String? street;
  final String city;
  final String state;
  final String pincode;
  final String contactPhone;
  final double? geoLat;
  final double? geoLng;
  final double? distanceKm;
  final int activeVarietiesCount;
  final List<String> availableCrops;
  final int rankingScore;
  final String rankingBadge;
  final String rankingReason;
  final RankingFactors rankingFactors;
  final bool isExactCityMatch;
  final bool isDemoData;

  const NurseryModel({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.code,
    required this.isVerified,
    required this.deliveryAvailable,
    required this.pickupAvailable,
    required this.rating,
    this.reviewCount = 326,
    this.ratingBreakdown = const RatingBreakdown(),
    this.successfulOrdersCount = 412,
    this.activityText = 'Active 10 mins ago',
    this.imageUrl = 'assets/images/nursery_hero_banner.jpg',
    this.openingTime = '07:00 AM',
    this.closingTime = '07:00 PM',
    this.isOpen = true,
    this.locationName,
    this.street,
    required this.city,
    required this.state,
    required this.pincode,
    required this.contactPhone,
    required this.geoLat,
    required this.geoLng,
    required this.distanceKm,
    required this.activeVarietiesCount,
    this.availableCrops = const [],
    this.rankingScore = 95,
    this.rankingBadge = 'Most Trusted (412+ Orders)',
    this.rankingReason = 'Top-ranked based on proximity, 4.8 star rating, 412 successful orders, and live activity.',
    this.rankingFactors = const RankingFactors(),
    this.isExactCityMatch = true,
    this.isDemoData = false,
  });

  factory NurseryModel.fromJson(Map<String, dynamic> json) {
    List<String> crops = [];
    if (json['availableCrops'] is List) {
      crops = (json['availableCrops'] as List).map((e) => e.toString()).toList();
    } else if (json['available_crops'] is List) {
      crops = (json['available_crops'] as List).map((e) => e.toString()).toList();
    }

    final double rawRating = double.tryParse(json['rating']?.toString() ?? '4.8') ?? 4.8;
    final int rawReviews = json['reviewCount'] as int? ?? json['review_count'] as int? ?? 326;
    final int varieties = json['activeVarietiesCount'] as int? ?? json['active_varieties_count'] as int? ?? 12;
    final double? dist = double.tryParse(json['distanceKm']?.toString() ?? json['distance_km']?.toString() ?? '');
    final bool verified = json['isVerified'] as bool? ?? json['is_verified'] as bool? ?? true;
    final int successfulOrders = json['successfulOrdersCount'] as int? ?? json['successful_orders_count'] as int? ?? 185;
    final String activity = json['activityText'] as String? ?? 'Active recently';

    final ratingBreakdown = json['ratingBreakdown'] is Map<String, dynamic>
        ? RatingBreakdown.fromJson(json['ratingBreakdown'] as Map<String, dynamic>)
        : const RatingBreakdown();

    final rankingFactors = json['rankingFactors'] is Map<String, dynamic>
        ? RankingFactors.fromJson(json['rankingFactors'] as Map<String, dynamic>)
        : const RankingFactors();

    final int rank = json['rankingScore'] as int? ??
        (Math.max(0, (30 - (dist ?? 50) * 0.6).round()) + (verified ? 20 : 0) + (rawRating / 5.0 * 15).round() + Math.min(10, (rawReviews / 35).round()) + Math.min(15, (successfulOrders / 25).round()) + 10);

    String badge = json['rankingBadge'] as String? ?? 'Verified Regional Grower';
    if (successfulOrders >= 300) {
      badge = 'Most Trusted ($successfulOrders+ Orders)';
    } else if (dist != null && dist <= 2.5) {
      badge = 'Nearest Hub (${dist.toStringAsFixed(1)} km)';
    } else if (rawRating >= 4.8) {
      badge = 'Top Rated (⭐ $rawRating)';
    }

    return NurseryModel(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? json['tenant_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Nursery',
      code: json['code'] as String? ?? '',
      isVerified: verified,
      deliveryAvailable: json['deliveryAvailable'] as bool? ?? json['delivery_available'] as bool? ?? true,
      pickupAvailable: json['pickupAvailable'] as bool? ?? json['pickup_available'] as bool? ?? true,
      rating: rawRating,
      reviewCount: rawReviews,
      ratingBreakdown: ratingBreakdown,
      successfulOrdersCount: successfulOrders,
      activityText: activity,
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String? ?? 'assets/images/nursery_hero_banner.jpg',
      openingTime: json['openingTime'] as String? ?? json['opening_time'] as String? ?? '07:00 AM',
      closingTime: json['closingTime'] as String? ?? json['closing_time'] as String? ?? '07:00 PM',
      isOpen: json['isOpen'] as bool? ?? json['is_open'] as bool? ?? true,
      locationName: json['locationName'] as String? ?? json['location_name'] as String?,
      street: json['street'] as String? ?? (json['address'] is Map ? json['address']['street'] as String? : null),
      city: json['city'] as String? ?? (json['address'] is Map ? json['address']['city'] as String? : 'Yeola') ?? 'Yeola',
      state: json['state'] as String? ?? (json['address'] is Map ? json['address']['state'] as String? : 'Maharashtra') ?? 'Maharashtra',
      pincode: json['pincode'] as String? ?? (json['address'] is Map ? json['address']['pincode'] as String? : '423401') ?? '423401',
      contactPhone: json['contactPhone'] as String? ?? json['contact_phone'] as String? ?? '+91 9900000002',
      geoLat: double.tryParse(json['geoLat']?.toString() ?? json['geo_lat']?.toString() ?? ''),
      geoLng: double.tryParse(json['geoLng']?.toString() ?? json['geo_lng']?.toString() ?? ''),
      distanceKm: dist,
      activeVarietiesCount: varieties,
      availableCrops: crops,
      rankingScore: rank,
      rankingBadge: badge,
      rankingReason: json['rankingReason'] as String? ?? 'Ranked based on proximity ($dist km), verified grower status, $successfulOrders completed orders, and active reviews.',
      rankingFactors: rankingFactors,
      isExactCityMatch: json['isExactCityMatch'] as bool? ?? true,
      isDemoData: json['isDemoData'] as bool? ?? false,
    );
  }
}

class Math {
  static int max(int a, int b) => a > b ? a : b;
  static int min(int a, int b) => a < b ? a : b;
}
