class NurseryOffer {
  final String id;
  final String tenantId;
  final String? nurseryId;
  final String title;
  final String? shortDescription;
  final String? bannerImageUrl;
  final String offerType;
  final String discountType;
  final double discountValue;
  final String discountLabel;
  final String? applicableCrop;
  final String? applicableVariety;
  final int minQuantity;
  final double minOrderValue;
  final DateTime startDate;
  final DateTime endDate;
  final bool isPrebookingOffer;
  final int? maxRedemptions;
  final int currentRedemptions;
  final String status;
  final String? termsConditions;
  final String eventLabel;
  final String validityText;
  final int remainingHours;
  final String nurseryName;
  final String nurseryCode;
  final bool nurseryIsVerified;
  final double nurseryRating;
  final int nurseryReviews;
  final String nurseryCity;
  final List<String> sampleProducts;

  const NurseryOffer({
    required this.id,
    required this.tenantId,
    this.nurseryId,
    required this.title,
    this.shortDescription,
    this.bannerImageUrl,
    required this.offerType,
    required this.discountType,
    required this.discountValue,
    required this.discountLabel,
    this.applicableCrop,
    this.applicableVariety,
    this.minQuantity = 1,
    this.minOrderValue = 0,
    required this.startDate,
    required this.endDate,
    this.isPrebookingOffer = false,
    this.maxRedemptions,
    this.currentRedemptions = 0,
    required this.status,
    this.termsConditions,
    required this.eventLabel,
    required this.validityText,
    required this.remainingHours,
    required this.nurseryName,
    required this.nurseryCode,
    this.nurseryIsVerified = true,
    this.nurseryRating = 4.8,
    this.nurseryReviews = 100,
    required this.nurseryCity,
    this.sampleProducts = const [],
  });

  factory NurseryOffer.fromJson(Map<String, dynamic> json) {
    return NurseryOffer(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? json['tenant_id'] as String? ?? '',
      nurseryId: json['nurseryId'] as String? ?? json['nursery_id'] as String?,
      title: json['title'] as String? ?? 'Nursery Special Offer',
      shortDescription: json['shortDescription'] as String? ?? json['short_description'] as String?,
      bannerImageUrl: json['bannerImageUrl'] as String? ?? json['banner_image_url'] as String?,
      offerType: json['offerType'] as String? ?? json['offer_type'] as String? ?? 'percentage_discount',
      discountType: json['discountType'] as String? ?? json['discount_type'] as String? ?? 'percentage',
      discountValue: (json['discountValue'] ?? json['discount_value'] ?? 0).toDouble(),
      discountLabel: json['discountLabel'] as String? ??
          (json['discountType'] == 'percentage'
              ? '${json['discountValue'] ?? 10}% OFF'
              : '₹${json['discountValue'] ?? 50} OFF'),
      applicableCrop: json['applicableCrop'] as String? ?? json['applicable_crop'] as String?,
      applicableVariety: json['applicableVariety'] as String? ?? json['applicable_variety'] as String?,
      minQuantity: (json['minQuantity'] ?? json['min_quantity'] ?? 1) as int,
      minOrderValue: (json['minOrderValue'] ?? json['min_order_value'] ?? 0).toDouble(),
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? json['start_date']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? json['end_date']?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 10)),
      isPrebookingOffer: (json['isPrebookingOffer'] ?? json['is_prebooking_offer'] ?? false) as bool,
      maxRedemptions: json['maxRedemptions'] as int? ?? json['max_redemptions'] as int?,
      currentRedemptions: (json['currentRedemptions'] ?? json['current_redemptions'] ?? 0) as int,
      status: json['status'] as String? ?? 'active',
      termsConditions: json['termsConditions'] as String? ?? json['terms_conditions'] as String?,
      eventLabel: json['eventLabel'] as String? ?? json['event_label'] as String? ?? '🌿 Farmer Special Offer',
      validityText: json['validityText'] as String? ?? 'Limited Time',
      remainingHours: (json['remainingHours'] ?? 72) as int,
      nurseryName: json['nurseryName'] as String? ?? json['nursery_name'] as String? ?? 'Regional Nursery',
      nurseryCode: json['nurseryCode'] as String? ?? json['nursery_code'] as String? ?? '',
      nurseryIsVerified: (json['nurseryIsVerified'] ?? json['nursery_is_verified'] ?? true) as bool,
      nurseryRating: (json['nurseryRating'] ?? json['nursery_rating'] ?? 4.8).toDouble(),
      nurseryReviews: (json['nurseryReviews'] ?? json['nursery_reviews'] ?? 120) as int,
      nurseryCity: json['nurseryCity'] as String? ?? json['nursery_city'] as String? ?? 'Maharashtra',
      sampleProducts: (json['sampleProducts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  String get discountBadgeText => discountLabel;
  String? get festivalEventLabel => eventLabel.isNotEmpty ? eventLabel : null;
  bool get isPrebooking => isPrebookingOffer;
  List<String> get applicableCrops => [
        if (applicableCrop != null && applicableCrop!.isNotEmpty) applicableCrop!,
        if (applicableVariety != null && applicableVariety!.isNotEmpty) applicableVariety!,
      ];
}
