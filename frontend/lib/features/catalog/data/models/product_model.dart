class CareInstructions {
  final String sunlight;
  final String watering;
  final String fertilizer;
  final String temperature;

  const CareInstructions({
    required this.sunlight,
    required this.watering,
    required this.fertilizer,
    required this.temperature,
  });

  factory CareInstructions.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CareInstructions(
        sunlight: 'Bright Indirect Light',
        watering: 'Moderate (when top 1 inch is dry)',
        fertilizer: 'Monthly Organic Compost',
        temperature: '18°C - 32°C',
      );
    }
    return CareInstructions(
      sunlight: json['sunlight'] as String? ?? 'Bright Indirect Light',
      watering: json['watering'] as String? ?? 'Moderate',
      fertilizer: json['fertilizer'] as String? ?? 'Monthly Organic',
      temperature: json['temperature'] as String? ?? '18°C - 30°C',
    );
  }
}

/// Commercial Agricultural Growing & Field Agronomy Information
class AgronomyInfo {
  final String season;
  final String temperature;
  final String waterRequirement;
  final String sunlight;
  final String soil;
  final String transplanting;
  final String spacing;
  final String basicCare;
  final String expectedYield;
  final String harvestDays;

  const AgronomyInfo({
    required this.season,
    required this.temperature,
    required this.waterRequirement,
    required this.sunlight,
    required this.soil,
    required this.transplanting,
    required this.spacing,
    required this.basicCare,
    this.expectedYield = '30-40 MT / acre',
    this.harvestDays = '65-75 days from transplanting',
  });

  factory AgronomyInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AgronomyInfo(
        season: 'Kharif, Rabi & Summer (All Season)',
        temperature: '18°C - 32°C optimal',
        waterRequirement: 'Drip irrigation 2-3 Litres/plant/day',
        sunlight: 'Full Sun (6-8 hours daily)',
        soil: 'Well-drained fertile loam / black soil (pH 6.2 - 7.5)',
        transplanting: '21-25 days aged nursery seedling',
        spacing: '3.5 ft row-to-row × 1.5 ft plant-to-plant',
        basicCare: 'Apply basal NPK, silver-black mulching, regular scouting for sucking pests.',
        expectedYield: '30-40 MT / acre',
        harvestDays: '65-75 days from transplanting',
      );
    }
    return AgronomyInfo(
      season: json['season'] as String? ?? 'Kharif, Rabi & Summer',
      temperature: json['temperature'] as String? ?? '18°C - 32°C',
      waterRequirement: json['water_requirement'] as String? ?? json['waterRequirement'] as String? ?? 'Drip irrigation 2-3 L/day',
      sunlight: json['sunlight'] as String? ?? 'Full Sun (6-8 hours daily)',
      soil: json['soil'] as String? ?? 'Well-drained loamy soil (pH 6.0 - 7.5)',
      transplanting: json['transplanting'] as String? ?? '21-25 days old seedling',
      spacing: json['spacing'] as String? ?? '3.5 ft × 1.5 ft (7,500 plants/acre)',
      basicCare: json['basic_care'] as String? ?? json['basicCare'] as String? ?? 'Regular fertigation & prophylactic pest management',
      expectedYield: json['expected_yield'] as String? ?? json['expectedYield'] as String? ?? '30-40 MT / acre',
      harvestDays: json['harvest_days'] as String? ?? json['harvestDays'] as String? ?? '65-75 days',
    );
  }
}

class Product {
  final String id;
  final String tenantId;
  final String nurseryName;
  final String sku;
  final String commonName;
  final String? scientificName;
  final String crop;
  final String variety;
  final String sellingUnit; // 'plant', 'tray', 'pack', 'bulk'
  final int traySize;       // alias for trayCapacity (e.g. 70, 100, 104, 125, 150)
  final int trayCapacity;   // Configurable plants per tray: 70, 98, 100, 104, 125, 150
  final int minOrderQty;
  final String? description;
  final double price;       // base price
  final double plantPrice;  // per-plant rate (e.g. ₹2.50)
  final double? trayPrice;  // tray rate (e.g. ₹250.00)
  final double? bulkPrice;  // 1,000+ commercial bulk rate (e.g. ₹2.00)
  final double? costPrice;
  final String categoryId;
  final String categoryName;
  final List<String> images;
  final int availableStock;
  final int readyStock;     // immediately ready stock count
  final int futureStock;    // future nursery batch count
  final String readyDate;   // batch dispatch timeline
  final String stockState;  // 'ready_now', 'limited_stock', 'coming_soon', 'prebook_available', 'sold_out'
  final bool isPrebookable;
  final double nurseryRating;
  final double? productRating;
  final int reviewCount;
  final DateTime? stockUpdatedAt;
  final DateTime? priceUpdatedAt;
  final CareInstructions care;
  final AgronomyInfo agronomy;

  const Product({
    required this.id,
    this.tenantId = '33333333-3333-3333-3333-333333333333',
    this.nurseryName = 'AVR Green Nursery',
    required this.sku,
    required this.commonName,
    this.scientificName,
    this.crop = 'Vegetables',
    this.variety = 'Standard',
    this.sellingUnit = 'plant',
    this.traySize = 104,
    int? trayCapacity,
    this.minOrderQty = 1,
    this.description,
    required this.price,
    double? plantPrice,
    this.trayPrice,
    this.bulkPrice,
    this.costPrice,
    required this.categoryId,
    required this.categoryName,
    this.images = const [],
    this.availableStock = 50,
    int? readyStock,
    this.futureStock = 2500,
    this.readyDate = 'Ready for Dispatch',
    this.stockState = 'ready_now',
    this.isPrebookable = true,
    this.nurseryRating = 4.8,
    this.productRating = 4.7,
    this.reviewCount = 128,
    this.stockUpdatedAt,
    this.priceUpdatedAt,
    required this.care,
    this.agronomy = const AgronomyInfo(
      season: 'Kharif, Rabi & Summer (All Season)',
      temperature: '18°C - 32°C optimal',
      waterRequirement: 'Drip irrigation 2-3 Litres/plant/day',
      sunlight: 'Full Sun (6-8 hours daily)',
      soil: 'Well-drained fertile loam / black soil (pH 6.2 - 7.5)',
      transplanting: '21-25 days aged nursery seedling',
      spacing: '3.5 ft row-to-row × 1.5 ft plant-to-plant',
      basicCare: 'Apply basal NPK, silver-black mulching, regular scouting for sucking pests.',
      expectedYield: '30-40 MT / acre',
      harvestDays: '65-75 days from transplanting',
    ),
  })  : trayCapacity = trayCapacity ?? traySize,
        plantPrice = plantPrice ?? price,
        readyStock = readyStock ?? availableStock;

  String? get stockFreshnessText {
    if (stockUpdatedAt == null) return null;
    final diff = DateTime.now().difference(stockUpdatedAt!);
    if (diff.inMinutes < 1) return 'Stock updated just now';
    if (diff.inMinutes < 60) return 'Stock updated ${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return 'Stock updated today';
    if (diff.inDays == 1) return 'Stock updated yesterday';
    return 'Stock updated ${diff.inDays} days ago';
  }

  String? get priceFreshnessText {
    if (priceUpdatedAt == null) return null;
    final diff = DateTime.now().difference(priceUpdatedAt!);
    if (diff.inHours < 24) return 'Price updated today';
    if (diff.inDays == 1) return 'Price updated yesterday';
    return 'Price verified recently';
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> imgList = [];
    if (json['images'] is List) {
      imgList = (json['images'] as List).map((e) => e.toString()).toList();
    }

    final cName = json['common_name'] as String? ?? json['name'] as String? ?? 'Plant';
    final detectedCrop = json['crop'] as String? ?? _deriveCrop(cName);
    final detectedVariety = json['variety'] as String? ?? _deriveVariety(cName);

    final rawPrice = double.tryParse(json['price']?.toString() ?? '0') ?? 0.0;
    final parsedTrayCap = json['tray_capacity'] as int? ?? json['tray_size'] as int? ?? 104;
    final parsedPlantPrice = double.tryParse(json['plant_price']?.toString() ?? '') ?? rawPrice;
    final parsedTrayPrice = double.tryParse(json['tray_price']?.toString() ?? '');
    final parsedBulkPrice = double.tryParse(json['bulk_price']?.toString() ?? '');
    final parsedAvail = json['quantity_available'] as int? ?? json['total_stock'] as int? ?? 50;
    final parsedReady = json['ready_stock'] as int? ?? parsedAvail;

    return Product(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String? ?? json['tenantId'] as String? ?? '33333333-3333-3333-3333-333333333333',
      nurseryName: json['nursery_name'] as String? ?? json['nurseryName'] as String? ?? 'AVR Green Nursery',
      sku: json['sku'] as String? ?? '',
      commonName: cName,
      scientificName: json['scientific_name'] as String?,
      crop: detectedCrop,
      variety: detectedVariety,
      sellingUnit: json['selling_unit'] as String? ?? 'plant',
      traySize: parsedTrayCap,
      trayCapacity: parsedTrayCap,
      minOrderQty: json['min_order_qty'] as int? ?? 1,
      description: json['description'] as String?,
      price: rawPrice,
      plantPrice: parsedPlantPrice,
      trayPrice: parsedTrayPrice,
      bulkPrice: parsedBulkPrice,
      costPrice: double.tryParse(json['cost_price']?.toString() ?? ''),
      categoryId: json['category_id'] as String? ?? 'vegetables',
      categoryName: json['category_name'] as String? ?? 'Vegetable Plants',
      images: imgList,
      availableStock: parsedAvail,
      readyStock: parsedReady,
      futureStock: json['future_stock'] as int? ?? 3000,
      readyDate: json['ready_date'] as String? ?? 'Ready for Dispatch',
      stockState: json['stock_state'] as String? ?? json['stockState'] as String? ?? 'ready_now',
      isPrebookable: json['is_prebookable'] as bool? ?? json['isPrebookable'] as bool? ?? true,
      nurseryRating: double.tryParse(json['nursery_rating']?.toString() ?? '4.8') ?? 4.8,
      productRating: double.tryParse(json['product_rating']?.toString() ?? '4.7'),
      reviewCount: json['review_count'] as int? ?? 128,
      stockUpdatedAt: json['stock_updated_at'] != null
          ? DateTime.tryParse(json['stock_updated_at'].toString())
          : (json['stockUpdatedAt'] != null ? DateTime.tryParse(json['stockUpdatedAt'].toString()) : null),
      priceUpdatedAt: json['price_updated_at'] != null
          ? DateTime.tryParse(json['price_updated_at'].toString())
          : (json['priceUpdatedAt'] != null ? DateTime.tryParse(json['priceUpdatedAt'].toString()) : null),
      care: CareInstructions.fromJson(json['care_instructions'] as Map<String, dynamic>?),
      agronomy: AgronomyInfo.fromJson(json['agronomy'] as Map<String, dynamic>?),
    );
  }

  static String _deriveCrop(String name) {
    final s = name.toLowerCase();
    if (s.contains('chil') || s.contains('mirch')) return 'Chilli';
    if (s.contains('tomat') || s.contains('tamat')) return 'Tomato';
    if (s.contains('capsicum') || s.contains('shimla')) return 'Capsicum';
    if (s.contains('brinjal') || s.contains('baingan')) return 'Brinjal';
    if (s.contains('cabbage') || s.contains('band')) return 'Cabbage';
    if (s.contains('cauliflower') || s.contains('phool')) return 'Cauliflower';
    if (s.contains('marigold') || s.contains('genda')) return 'Marigold';
    if (s.contains('rose') || s.contains('gulab')) return 'Rose';
    if (s.contains('jasmine') || s.contains('mogra')) return 'Jasmine';
    if (s.contains('sugarcane') || s.contains('cane')) return 'Sugarcane';
    if (s.contains('lemon') || s.contains('nimbu')) return 'Lemon';
    if (s.contains('mango') || s.contains('aam')) return 'Mango';
    if (s.contains('guava') || s.contains('amrood')) return 'Guava';
    if (s.contains('tulsi')) return 'Tulsi';
    if (s.contains('aloe')) return 'Aloe Vera';
    return 'Seedlings';
  }

  static String _deriveVariety(String name) {
    final s = name.toLowerCase();
    if (s.contains('balram')) return 'Balram F1';
    if (s.contains('bullet')) return 'Bullet Teja';
    if (s.contains('nandita')) return 'Nandita F1';
    if (s.contains('nandini')) return 'Nandini Heavy';
    if (s.contains('abhinav')) return 'Abhinav Hybrid';
    if (s.contains('desi')) return 'Desi Traditional';
    if (s.contains('cherry')) return 'Sugar Cherry';
    if (s.contains('indra')) return 'Indra Green';
    if (s.contains('ravaiya')) return 'Ravaiya Purple';
    if (s.contains('calcutta')) return 'Calcutta Orange';
    if (s.contains('86032')) return 'Co 86032';
    return name;
  }

  /// Selling unit display label (e.g. "Per Plant", "Tray (104 plants)", "Bulk Quantity")
  String get unitLabel {
    if (sellingUnit == 'tray') return 'Tray ($trayCapacity Plants)';
    if (sellingUnit == 'pack_100') return 'Pack (100 Plants)';
    if (sellingUnit.startsWith('pack_')) {
      final count = sellingUnit.replaceFirst('pack_', '');
      return 'Pack ($count Plants)';
    }
    if (sellingUnit == 'pack') return 'Pack';
    if (sellingUnit == 'bulk') return 'Bulk Quantity';
    return 'Per Plant';
  }

  /// Configurable pricing getters
  double get effectivePlantPrice => plantPrice > 0 ? plantPrice : price;
  double? get effectiveTrayPrice => trayPrice ?? (effectivePlantPrice * trayCapacity);
  double? get effectiveBulkPrice => bulkPrice ?? (effectivePlantPrice * 0.85);

  double get perPlantPrice => effectivePlantPrice;
  String get perPlantPriceText => '₹${effectivePlantPrice.toStringAsFixed(effectivePlantPrice % 1 == 0 ? 0 : 2)} / plant';

  bool get isReadyStock => stockState == 'ready_now' || (readyStock > 0 && stockState != 'sold_out' && stockState != 'coming_soon');
  bool get isPrebooking => stockState == 'prebook_available' || stockState == 'coming_soon' || (readyStock == 0 && isPrebookable);
  bool get isReadyNow => stockState == 'ready_now';
  bool get isLimitedStock => stockState == 'limited_stock';
  bool get isComingSoon => stockState == 'coming_soon';
  bool get isPrebookAvailable => stockState == 'prebook_available';
  bool get isSoldOut => stockState == 'sold_out';
  bool get nurseryVerified => nurseryRating >= 4.0;
  bool get isHot => (productRating ?? nurseryRating) >= 4.7 || reviewCount >= 100;
  bool get isBestseller => reviewCount >= 80;

  String get stockBadgeLabel {
    switch (stockState) {
      case 'limited_stock':
        return 'LIMITED STOCK';
      case 'coming_soon':
        return 'COMING SOON';
      case 'prebook_available':
        return 'PRE-BOOK AVAILABLE';
      case 'sold_out':
        return 'SOLD OUT';
      case 'ready_now':
      default:
        return readyStock > 0 ? 'READY NOW' : (isPrebookable ? 'PRE-BOOK AVAILABLE' : 'SOLD OUT');
    }
  }

  String get dispatchEstimate => isReadyStock ? '✓ Ready Stock' : '⏳ Pre-book • Dispatch $readyDate';

  /// Maps the plant to real nursery photography assets created for commercial presentation
  String get primaryImageAsset {
    if (images.isNotEmpty && !images.first.startsWith('http')) {
      return images.first;
    }
    final s = '${sku.toLowerCase()} ${commonName.toLowerCase()} ${crop.toLowerCase()} ${variety.toLowerCase()} ${categoryId.toLowerCase()}';
    if (s.contains('capsicum') || s.contains('pepper') || s.contains('shimla') || s.contains('indra') || s.contains('bachata')) {
      return 'assets/images/products/capsicum.jpg';
    }
    if (s.contains('chil') || s.contains('mirch') || s.contains('teja') || s.contains('sitara') || s.contains('armoor')) {
      return 'assets/images/products/green_chilli.jpg';
    }
    if (s.contains('tomat') || s.contains('tamat') || s.contains('abhinav') || s.contains('saaho') || s.contains('lakshmi') || s.contains('us 440')) {
      return 'assets/images/products/tomato.jpg';
    }
    if (s.contains('brinjal') || s.contains('eggplant') || s.contains('baingan') || s.contains('ravaiya') || s.contains('panchganga') || s.contains('kalpataru')) {
      return 'assets/images/products/brinjal.jpg';
    }
    if (s.contains('cabbage') || s.contains('band') || s.contains('golden acre') || s.contains('green hero')) {
      return 'assets/images/products/cabbage.jpg';
    }
    if (s.contains('cauliflower') || s.contains('phool') || s.contains('snowball') || s.contains('girija')) {
      return 'assets/images/products/cauliflower.jpg';
    }
    if (s.contains('broccoli')) {
      return 'assets/images/products/broccoli.jpg';
    }
    if (s.contains('cucum') || s.contains('kheera') || s.contains('malini')) {
      return 'assets/images/products/cucumber.jpg';
    }
    if (s.contains('okra') || s.contains('bhendi') || s.contains('ladyfinger') || s.contains('radhika') || s.contains('singham')) {
      return 'assets/images/products/bhendi.jpg';
    }
    if (s.contains('marigold') || s.contains('genda') || s.contains('zendu') || s.contains('calcutta')) {
      return 'assets/images/products/marigold.jpg';
    }
    if (s.contains('chrysanthemum') || s.contains('shevanti') || s.contains('guldaudi')) {
      return 'assets/images/products/chrysanthemum.jpg';
    }
    if (s.contains('rose') || s.contains('gulab') || s.contains('taj mahal') || s.contains('dutch')) {
      return 'assets/images/products/rose.jpg';
    }
    if (s.contains('jasmine') || s.contains('mogra') || s.contains('chameli') || s.contains('bhatkal')) {
      return 'assets/images/products/jasmine.jpg';
    }
    if (s.contains('pomegranate') || s.contains('dalimb') || s.contains('bhagwa') || s.contains('anar')) {
      return 'assets/images/products/pomegranate.jpg';
    }
    if (s.contains('mango') || s.contains('aam') || s.contains('kesar') || s.contains('alphonso') || s.contains('dasheri')) {
      return 'assets/images/products/mango.jpg';
    }
    if (s.contains('guava') || s.contains('amrood') || s.contains('taiwan pink') || s.contains('lucknow 49')) {
      return 'assets/images/products/guava.jpg';
    }
    if (s.contains('lemon') || s.contains('nimbu') || s.contains('kagzi') || s.contains('balaji')) {
      return 'assets/images/products/lemon.jpg';
    }
    if (s.contains('ashwagandha') || s.contains('withania') || s.contains('nagori')) {
      return 'assets/images/products/ashwagandha.jpg';
    }
    if (s.contains('aloe') || s.contains('korpad')) {
      return 'assets/images/products/aloe_vera.jpg';
    }
    if (s.contains('tulsi') || s.contains('basil') || s.contains('krishna')) {
      return 'assets/images/products/tulsi.jpg';
    }
    if (s.contains('areca') || s.contains('palm') || s.contains('snake') || s.contains('money') || s.contains('indoor')) {
      return 'assets/images/products/areca_palm.jpg';
    }
    if (s.contains('tray') || s.contains('pro-tray') || s.contains('plug') || s.contains('cavity')) {
      return 'assets/images/products/nursery_trays.jpg';
    }
    if (s.contains('fertilizer') || s.contains('vermicompost') || s.contains('compost') || s.contains('nutrient') || s.contains('neem')) {
      return 'assets/images/products/organic_fertilizer.jpg';
    }
    return 'assets/images/products/green_chilli.jpg';
  }

  /// Multi-perspective authentic gallery for detailed farmer inspection
  List<String> get galleryImages {
    if (images.isNotEmpty) {
      return images;
    }
    // Return primary variety photo, tray plug view, and polyhouse nursery environment
    return [
      primaryImageAsset,
      'assets/images/products/nursery_trays.jpg',
      'assets/images/nursery_hero_banner.jpg',
    ];
  }

  /// Farmer-friendly product badge
  String get badgeText {
    final s = '${sku.toLowerCase()} ${commonName.toLowerCase()}';
    if (s.contains('graft') || s.contains('mango') || s.contains('guava') || s.contains('lemon')) {
      return '🌳 Grafted Sapling';
    }
    if (s.contains('chil') || s.contains('tomat') || s.contains('capsicum') || s.contains('brinjal') || s.contains('cabbage') || s.contains('bhendi')) {
      return '🌱 F1 Hybrid Seedling';
    }
    if (s.contains('rose') || s.contains('jasmin') || s.contains('hibisc')) {
      return '🌸 Heavy Bloomer';
    }
    if (s.contains('tulsi') || s.contains('aloe')) {
      return '🌿 Ayurvedic Herb';
    }
    if (s.contains('verm') || s.contains('neem') || s.contains('seaweed')) {
      return '🌾 100% Organic';
    }
    if (s.contains('pot') || s.contains('planter') || s.contains('tray')) {
      return '🪴 Pro-Grade Tray';
    }
    return '🌱 Premium Variety';
  }

  /// Farmer-friendly sunlight icon & label
  String get sunlightLabel => care.sunlight.contains('Direct') ? 'Full Sun ☀' : 'Bright Shade 🌤';

  /// Farmer-friendly watering label
  String get wateringLabel => care.watering.contains('Daily') ? 'Daily 💧' : 'Moderate 💧';

  /// Farmer-friendly growth season
  String get seasonLabel => agronomy.season;

  /// Farmer/regional local name
  String get localName {
    final s = '${sku.toLowerCase()} ${commonName.toLowerCase()}';
    if (s.contains('chil') || s.contains('mirch')) return 'हिरवी मिरची / Teja Mirchi';
    if (s.contains('tomat') || s.contains('tamat')) return 'टोमॅटो / Abhinav F1';
    if (s.contains('capsicum') || s.contains('pepper') || s.contains('shimla')) return 'ढोबळी मिरची / Bell Pepper';
    if (s.contains('brinjal') || s.contains('baingan')) return 'वांगी / Ravaiya Brinjal';
    if (s.contains('cabbage') || s.contains('band')) return 'कोबी / Cabbage';
    if (s.contains('cauliflower') || s.contains('phool')) return 'फ्लॉवर / Cauliflower';
    if (s.contains('broccoli')) return 'ब्रोकली / Green Broccoli';
    if (s.contains('cucum') || s.contains('kheera')) return 'काकडी / Cucumber';
    if (s.contains('okra') || s.contains('bhendi')) return 'भेंडी / Bhendi Okra';
    if (s.contains('mango') || s.contains('aam')) return 'हापूस / केशर आंबा';
    if (s.contains('guava') || s.contains('amrood')) return 'पेरू / L-49 Guava';
    if (s.contains('lemon') || s.contains('nimbu')) return 'कागदी लिंबू / Lemon';
    if (s.contains('rose') || s.contains('gulab')) return 'गुलाब / Desi Rose';
    if (s.contains('jasmine') || s.contains('mogra')) return 'मोगरा / Jasmine';
    if (s.contains('tulsi')) return 'कृष्ण तुळस / Holy Basil';
    if (s.contains('aloe')) return 'कोरफड / Aloe Vera';
    return commonName;
  }
}

typedef ProductModel = Product;
