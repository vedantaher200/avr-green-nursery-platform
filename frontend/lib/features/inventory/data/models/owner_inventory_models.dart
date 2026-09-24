library;

/// Models for Nursery Owner Inventory, Future Stock, Pre-Bookings & Announcements

class DemandSignalModel {
  final String productId;
  final String commonName;
  final String? crop;
  final String? variety;
  final int interestedFarmersCount;
  final int notifyDesiredQuantity;
  final int prebookedPlantsCount;
  final int prebookOrdersCount;

  const DemandSignalModel({
    required this.productId,
    required this.commonName,
    this.crop,
    this.variety,
    required this.interestedFarmersCount,
    required this.notifyDesiredQuantity,
    required this.prebookedPlantsCount,
    required this.prebookOrdersCount,
  });

  factory DemandSignalModel.fromJson(Map<String, dynamic> json) {
    return DemandSignalModel(
      productId: json['product_id'] as String? ?? json['productId'] as String? ?? '',
      commonName: json['common_name'] as String? ?? json['commonName'] as String? ?? '',
      crop: json['crop'] as String?,
      variety: json['variety'] as String?,
      interestedFarmersCount: int.tryParse(json['interested_farmers_count']?.toString() ?? '0') ?? 0,
      notifyDesiredQuantity: int.tryParse(json['notify_desired_quantity']?.toString() ?? '0') ?? 0,
      prebookedPlantsCount: int.tryParse(json['prebooked_plants_count']?.toString() ?? '0') ?? 0,
      prebookOrdersCount: int.tryParse(json['prebook_orders_count']?.toString() ?? '0') ?? 0,
    );
  }
}

class OwnerDashboardOverview {
  final int totalReadyStock;
  final int totalReservedStock;
  final int totalPrebookedQuantity;
  final int totalFutureProduction;
  final String? expectedProductionDate;
  final int pendingPrebookingsCount;
  final int activeAnnouncementsCount;
  final int totalInterestedFarmers;
  final List<DemandSignalModel> demandSignals;
  final List<OwnerProductModel> products;
  final List<PreBookingModel> recentPrebookings;
  final List<NurseryAnnouncementModel> announcements;

  const OwnerDashboardOverview({
    required this.totalReadyStock,
    required this.totalReservedStock,
    required this.totalPrebookedQuantity,
    required this.totalFutureProduction,
    this.expectedProductionDate,
    required this.pendingPrebookingsCount,
    required this.activeAnnouncementsCount,
    this.totalInterestedFarmers = 0,
    this.demandSignals = const [],
    required this.products,
    required this.recentPrebookings,
    required this.announcements,
  });

  factory OwnerDashboardOverview.fromJson(Map<String, dynamic> json) {
    return OwnerDashboardOverview(
      totalReadyStock: json['totalReadyStock'] as int? ?? 0,
      totalReservedStock: json['totalReservedStock'] as int? ?? 0,
      totalPrebookedQuantity: json['totalPrebookedQuantity'] as int? ?? 0,
      totalFutureProduction: json['totalFutureProduction'] as int? ?? 0,
      expectedProductionDate: json['expectedProductionDate'] as String?,
      pendingPrebookingsCount: json['pendingPrebookingsCount'] as int? ?? 0,
      activeAnnouncementsCount: json['activeAnnouncementsCount'] as int? ?? 0,
      totalInterestedFarmers: json['totalInterestedFarmers'] as int? ?? 0,
      demandSignals: (json['demandSignals'] as List? ?? [])
          .map((s) => DemandSignalModel.fromJson(s as Map<String, dynamic>))
          .toList(),
      products: (json['products'] as List? ?? [])
          .map((p) => OwnerProductModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      recentPrebookings: (json['recentPrebookings'] as List? ?? [])
          .map((b) => PreBookingModel.fromJson(b as Map<String, dynamic>))
          .toList(),
      announcements: (json['announcements'] as List? ?? [])
          .map((a) => NurseryAnnouncementModel.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OwnerProductModel {
  final String id;
  final String tenantId;
  final String sku;
  final String commonName;
  final String? scientificName;
  final String crop;
  final String variety;
  final double price;
  final double plantPrice;
  final double? trayPrice;
  final double? bulkPrice;
  final int trayCapacity;
  final int readyStock;
  final int reservedStock;
  final int futureStock;
  final String? expectedReadyDate;
  final int minOrderQty;
  final String stockState; // 'ready_now', 'limited_stock', 'coming_soon', 'prebook_available', 'sold_out'
  final bool isPrebookable;
  final List<String> images;

  const OwnerProductModel({
    required this.id,
    required this.tenantId,
    required this.sku,
    required this.commonName,
    this.scientificName,
    required this.crop,
    required this.variety,
    required this.price,
    required this.plantPrice,
    this.trayPrice,
    this.bulkPrice,
    this.trayCapacity = 104,
    required this.readyStock,
    this.reservedStock = 0,
    required this.futureStock,
    this.expectedReadyDate,
    this.minOrderQty = 1,
    this.stockState = 'ready_now',
    this.isPrebookable = true,
    this.images = const [],
  });

  factory OwnerProductModel.fromJson(Map<String, dynamic> json) {
    List<String> imgList = [];
    if (json['images'] is List) {
      imgList = (json['images'] as List).map((e) => e.toString()).toList();
    }

    final rawPrice = double.tryParse(json['price']?.toString() ?? '0') ?? 0.0;
    final parsedPlant = double.tryParse(json['plant_price']?.toString() ?? '') ?? rawPrice;
    final parsedTray = double.tryParse(json['tray_price']?.toString() ?? '');
    final parsedBulk = double.tryParse(json['bulk_price']?.toString() ?? '');

    return OwnerProductModel(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      commonName: json['common_name'] as String? ?? 'Plant',
      scientificName: json['scientific_name'] as String?,
      crop: json['crop'] as String? ?? 'Seedlings',
      variety: json['variety'] as String? ?? 'Standard Variety',
      price: rawPrice,
      plantPrice: parsedPlant,
      trayPrice: parsedTray,
      bulkPrice: parsedBulk,
      trayCapacity: json['tray_capacity'] as int? ?? 104,
      readyStock: json['ready_stock'] as int? ?? json['quantity_available'] as int? ?? 0,
      reservedStock: json['reserved_stock'] as int? ?? json['quantity_reserved'] as int? ?? 0,
      futureStock: json['future_stock'] as int? ?? 0,
      expectedReadyDate: json['expected_ready_date'] as String?,
      minOrderQty: json['min_order_qty'] as int? ?? 1,
      stockState: json['stock_state'] as String? ?? 'ready_now',
      isPrebookable: json['is_prebookable'] as bool? ?? true,
      images: imgList,
    );
  }

  /// Display label for stock state
  String get stockStateLabel {
    switch (stockState) {
      case 'ready_now':
        return 'READY NOW';
      case 'limited_stock':
        return 'LIMITED STOCK';
      case 'coming_soon':
        return 'COMING SOON';
      case 'prebook_available':
        return 'PRE-BOOK AVAILABLE';
      case 'sold_out':
        return 'SOLD OUT';
      default:
        return 'READY NOW';
    }
  }

  /// Primary photographic asset
  String get primaryImageAsset {
    if (images.isNotEmpty && !images.first.startsWith('http')) {
      return images.first;
    }
    final s = '${sku.toLowerCase()} ${commonName.toLowerCase()} ${crop.toLowerCase()} ${variety.toLowerCase()}';
    if (s.contains('capsicum') || s.contains('shimla')) return 'assets/images/products/capsicum.jpg';
    if (s.contains('chil') || s.contains('mirch')) return 'assets/images/products/green_chilli.jpg';
    if (s.contains('tomat') || s.contains('tamat')) return 'assets/images/products/tomato.jpg';
    if (s.contains('brinjal') || s.contains('baingan')) return 'assets/images/products/brinjal.jpg';
    if (s.contains('cabbage')) return 'assets/images/products/cabbage.jpg';
    if (s.contains('cauliflower')) return 'assets/images/products/cauliflower.jpg';
    if (s.contains('marigold') || s.contains('zendu')) return 'assets/images/products/marigold.jpg';
    if (s.contains('chrysanthemum') || s.contains('shevanti')) return 'assets/images/products/chrysanthemum.jpg';
    if (s.contains('rose') || s.contains('gulab')) return 'assets/images/products/rose.jpg';
    if (s.contains('mango') || s.contains('kesar')) return 'assets/images/products/mango.jpg';
    if (s.contains('guava') || s.contains('amrood')) return 'assets/images/products/guava.jpg';
    if (s.contains('lemon') || s.contains('nimbu')) return 'assets/images/products/lemon.jpg';
    if (s.contains('pomegranate') || s.contains('dalimb')) return 'assets/images/products/pomegranate.jpg';
    if (s.contains('ashwagandha')) return 'assets/images/products/ashwagandha.jpg';
    if (s.contains('aloe')) return 'assets/images/products/aloe_vera.jpg';
    if (s.contains('tulsi')) return 'assets/images/products/tulsi.jpg';
    if (s.contains('areca') || s.contains('palm')) return 'assets/images/products/areca_palm.jpg';
    return 'assets/images/products/tomato.jpg';
  }
}

class PreBookingModel {
  final String id;
  final String bookingNumber;
  final String farmerName;
  final String farmerPhone;
  final String? farmerLocation;
  final String unit; // 'plant', 'tray', 'bulk'
  final int quantity;
  final int totalPlants;
  final double unitPrice;
  final double totalAmount;
  final double advanceAmount;
  final String expectedReadyDate;
  final String status; // 'pending', 'confirmed', 'ready_for_pickup', 'fulfilled', 'cancelled'
  final String? notes;
  final String? commonName;
  final String? crop;
  final String? variety;
  final String? nurseryName;
  final List<String> images;

  const PreBookingModel({
    required this.id,
    required this.bookingNumber,
    required this.farmerName,
    required this.farmerPhone,
    this.farmerLocation,
    this.unit = 'tray',
    required this.quantity,
    required this.totalPlants,
    required this.unitPrice,
    required this.totalAmount,
    this.advanceAmount = 0.0,
    required this.expectedReadyDate,
    this.status = 'pending',
    this.notes,
    this.commonName,
    this.crop,
    this.variety,
    this.nurseryName,
    this.images = const [],
  });

  factory PreBookingModel.fromJson(Map<String, dynamic> json) {
    List<String> imgList = [];
    if (json['images'] is List) {
      imgList = (json['images'] as List).map((e) => e.toString()).toList();
    }

    return PreBookingModel(
      id: json['id'] as String? ?? '',
      bookingNumber: json['booking_number'] as String? ?? json['bookingNumber'] as String? ?? 'PRE-000',
      farmerName: json['farmer_name'] as String? ?? json['farmerName'] as String? ?? 'Farmer',
      farmerPhone: json['farmer_phone'] as String? ?? json['farmerPhone'] as String? ?? '',
      farmerLocation: json['farmer_location'] as String? ?? json['farmerLocation'] as String?,
      unit: json['unit'] as String? ?? 'tray',
      quantity: json['quantity'] as int? ?? 1,
      totalPlants: json['total_plants'] as int? ?? json['totalPlants'] as int? ?? 104,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? json['unitPrice']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? json['totalAmount']?.toString() ?? '0') ?? 0.0,
      advanceAmount: double.tryParse(json['advance_amount']?.toString() ?? json['advanceAmount']?.toString() ?? '0') ?? 0.0,
      expectedReadyDate: json['expected_ready_date']?.toString().split('T')[0] ?? json['expectedReadyDate']?.toString() ?? 'Coming Soon',
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      commonName: json['common_name'] as String? ?? json['productName'] as String?,
      crop: json['crop'] as String?,
      variety: json['variety'] as String?,
      nurseryName: json['nursery_name'] as String? ?? json['nurseryName'] as String?,
      images: imgList,
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'ready_for_pickup':
        return 'Ready for Pickup';
      case 'fulfilled':
        return 'Fulfilled';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
      default:
        return 'Pending Approval';
    }
  }
}

class NurseryAnnouncementModel {
  final String id;
  final String? nurseryName;
  final String? nurseryImage;
  final String? nurseryCity;
  final String title;
  final String content;
  final String? crop;
  final String? variety;
  final int? readyQuantity;
  final int? futureQuantity;
  final int? expectedDays;
  final String unit;
  final bool isActive;
  final String? publishedAt;

  const NurseryAnnouncementModel({
    required this.id,
    this.nurseryName,
    this.nurseryImage,
    this.nurseryCity,
    required this.title,
    required this.content,
    this.crop,
    this.variety,
    this.readyQuantity,
    this.futureQuantity,
    this.expectedDays,
    this.unit = 'plants',
    this.isActive = true,
    this.publishedAt,
  });

  factory NurseryAnnouncementModel.fromJson(Map<String, dynamic> json) {
    return NurseryAnnouncementModel(
      id: json['id'] as String? ?? '',
      nurseryName: json['nursery_name'] as String? ?? json['nurseryName'] as String?,
      nurseryImage: json['nursery_image'] as String? ?? json['nurseryImage'] as String?,
      nurseryCity: json['nursery_city'] as String? ?? json['nurseryCity'] as String?,
      title: json['title'] as String? ?? 'Nursery Production Announcement',
      content: json['content'] as String? ?? '',
      crop: json['crop'] as String?,
      variety: json['variety'] as String?,
      readyQuantity: json['ready_quantity'] as int? ?? json['readyQuantity'] as int?,
      futureQuantity: json['future_quantity'] as int? ?? json['futureQuantity'] as int?,
      expectedDays: json['expected_days'] as int? ?? json['expectedDays'] as int?,
      unit: json['unit'] as String? ?? 'plants',
      isActive: json['is_active'] as bool? ?? true,
      publishedAt: json['published_at']?.toString().split('T')[0] ?? json['publishedAt']?.toString(),
    );
  }
}
