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

class Product {
  final String id;
  final String tenantId;
  final String nurseryName;
  final String sku;
  final String commonName;
  final String? scientificName;
  final String crop;
  final String variety;
  final String sellingUnit; // 'seedling', 'tray', 'pack_50', 'pack_100', 'bulk'
  final int traySize;       // 104, 70, etc.
  final int minOrderQty;
  final String? description;
  final double price;
  final double? costPrice;
  final String categoryId;
  final String categoryName;
  final List<String> images;
  final int availableStock;
  final CareInstructions care;

  const Product({
    required this.id,
    this.tenantId = '33333333-3333-3333-3333-333333333333',
    this.nurseryName = 'AVR Green Nursery',
    required this.sku,
    required this.commonName,
    this.scientificName,
    this.crop = 'Vegetables',
    this.variety = 'Standard',
    this.sellingUnit = 'seedling',
    this.traySize = 104,
    this.minOrderQty = 1,
    this.description,
    required this.price,
    this.costPrice,
    required this.categoryId,
    required this.categoryName,
    this.images = const [],
    this.availableStock = 50,
    required this.care,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> imgList = [];
    if (json['images'] is List) {
      imgList = (json['images'] as List).map((e) => e.toString()).toList();
    }

    final cName = json['common_name'] as String? ?? json['name'] as String? ?? 'Plant';
    final detectedCrop = json['crop'] as String? ?? _deriveCrop(cName);
    final detectedVariety = json['variety'] as String? ?? _deriveVariety(cName);

    return Product(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String? ?? json['tenantId'] as String? ?? '33333333-3333-3333-3333-333333333333',
      nurseryName: json['nursery_name'] as String? ?? json['nurseryName'] as String? ?? 'AVR Green Nursery',
      sku: json['sku'] as String? ?? '',
      commonName: cName,
      scientificName: json['scientific_name'] as String?,
      crop: detectedCrop,
      variety: detectedVariety,
      sellingUnit: json['selling_unit'] as String? ?? 'seedling',
      traySize: json['tray_size'] as int? ?? 104,
      minOrderQty: json['min_order_qty'] as int? ?? 1,
      description: json['description'] as String?,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      costPrice: double.tryParse(json['cost_price']?.toString() ?? '0'),
      categoryId: json['category_id'] as String? ?? 'all',
      categoryName: json['category_name'] as String? ?? 'Plants',
      images: imgList,
      availableStock: json['quantity_available'] as int? ?? json['total_stock'] as int? ?? 50,
      care: CareInstructions.fromJson(json['care_instructions'] as Map<String, dynamic>?),
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
    if (s.contains('sugarcane') || s.contains('cane')) return 'Sugarcane';
    if (s.contains('lemon') || s.contains('nimbu')) return 'Lemon';
    if (s.contains('mango') || s.contains('aam')) return 'Mango';
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
    return 'Commercial Seedling';
  }

  /// Selling unit display label (Seedling, 104-Cell Tray, Pack)
  String get unitLabel {
    if (sellingUnit == 'tray') return 'Tray ($traySize Plants)';
    if (sellingUnit == 'pack_50') return 'Pack (50 Plants)';
    if (sellingUnit == 'pack_100') return 'Pack (100 Plants)';
    if (sellingUnit == 'bulk') return 'Bulk (per plant)';
    return 'Per Seedling';
  }

  /// Maps the plant to real nursery photography assets created for commercial presentation
  String get primaryImageAsset {
    if (images.isNotEmpty && !images.first.startsWith('http')) {
      return images.first;
    }
    final s = '${sku.toLowerCase()} ${commonName.toLowerCase()}';
    if (s.contains('chil') || s.contains('mirch')) {
      return 'assets/images/products/green_chilli.jpg';
    }
    if (s.contains('tomat') || s.contains('tamat')) {
      return 'assets/images/products/tomato.jpg';
    }
    if (s.contains('capsicum') || s.contains('pepper') || s.contains('shimla')) {
      return 'assets/images/products/capsicum.jpg';
    }
    if (s.contains('brinjal') || s.contains('eggplant') || s.contains('baingan')) {
      return 'assets/images/products/brinjal.jpg';
    }
    if (s.contains('cabbage') || s.contains('band')) {
      return 'assets/images/products/cabbage.jpg';
    }
    if (s.contains('cauliflower') || s.contains('phool')) {
      return 'assets/images/products/cauliflower.jpg';
    }
    if (s.contains('broccoli')) {
      return 'assets/images/products/broccoli.jpg';
    }
    if (s.contains('cucum') || s.contains('kheera')) {
      return 'assets/images/products/cucumber.jpg';
    }
    if (s.contains('okra') || s.contains('bhendi') || s.contains('ladyfinger')) {
      return 'assets/images/products/bhendi.jpg';
    }
    if (s.contains('mango') || s.contains('aam')) {
      return 'assets/images/products/mango.jpg';
    }
    if (s.contains('guava') || s.contains('amrood')) {
      return 'assets/images/products/guava.jpg';
    }
    if (s.contains('lemon') || s.contains('nimbu')) {
      return 'assets/images/products/lemon.jpg';
    }
    if (s.contains('rose') || s.contains('gulab')) {
      return 'assets/images/products/rose.jpg';
    }
    if (s.contains('jasmine') || s.contains('mogra') || s.contains('chameli')) {
      return 'assets/images/products/jasmine.jpg';
    }
    if (s.contains('aloe')) {
      return 'assets/images/products/aloe_vera.jpg';
    }
    if (s.contains('tulsi') || s.contains('basil')) {
      return 'assets/images/products/tulsi.jpg';
    }
    if (s.contains('monstera') || s.contains('snake') || s.contains('pothos') || s.contains('palm')) {
      return 'assets/images/products/aloe_vera.jpg';
    }
    return 'assets/images/products/green_chilli.jpg';
  }

  /// Farmer-friendly product badge
  String get badgeText {
    final s = '${sku.toLowerCase()} ${commonName.toLowerCase()}';
    if (s.contains('graft') || s.contains('mango') || s.contains('guava') || s.contains('lemon')) {
      return '🌳 Grafted Sapling';
    }
    if (s.contains('chil') || s.contains('tomat') || s.contains('capsicum') || s.contains('brinjal') || s.contains('cabbage') || s.contains('bhendi')) {
      return '🌱 Healthy Seedling';
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
    if (s.contains('pot') || s.contains('planter')) {
      return '🪴 Breathable Clay';
    }
    return '🌱 Premium Variety';
  }

  /// Farmer-friendly sunlight icon & label
  String get sunlightLabel => care.sunlight.contains('Direct') ? 'Full Sun ☀' : 'Bright Shade 🌤';

  /// Farmer-friendly watering label
  String get wateringLabel => care.watering.contains('Daily') ? 'Daily 💧' : 'Moderate 💧';

  /// Farmer-friendly growth season
  String get seasonLabel {
    final s = '${sku.toLowerCase()} ${commonName.toLowerCase()}';
    if (s.contains('cabbage') || s.contains('cauliflower') || s.contains('broccoli')) {
      return 'Rabi / Winter 🌱';
    }
    if (s.contains('okra') || s.contains('cucumber')) {
      return 'Summer / Zaid ☀';
    }
    return 'All Seasons 🌿';
  }

  /// Farmer/regional local name
  String get localName {
    final s = '${sku.toLowerCase()} ${commonName.toLowerCase()}';
    if (s.contains('chil') || s.contains('mirch')) return 'हरी मिर्च / Teja Mirchi';
    if (s.contains('tomat') || s.contains('tamat')) return 'लाल टमाटर / Abhinav';
    if (s.contains('capsicum') || s.contains('pepper') || s.contains('shimla')) return 'शिमला मिर्च / Bell Pepper';
    if (s.contains('brinjal') || s.contains('baingan')) return 'बैंगन / Round Brinjal';
    if (s.contains('cabbage') || s.contains('band')) return 'पत्ता गोभी / Golden Acre';
    if (s.contains('cauliflower') || s.contains('phool')) return 'फूल गोभी / Snowball';
    if (s.contains('broccoli')) return 'हरी ब्रोकली / Broccoli';
    if (s.contains('cucum') || s.contains('kheera')) return 'खीरा ककड़ी / Cucumber';
    if (s.contains('okra') || s.contains('bhendi')) return 'भिंडी / Bhendi Okra';
    if (s.contains('mango') || s.contains('aam')) return 'हापूस आंबा / Alphonso';
    if (s.contains('guava') || s.contains('amrood')) return 'अमरूद / L-49 Guava';
    if (s.contains('lemon') || s.contains('nimbu')) return 'कागज़ी नींबू / Lemon';
    if (s.contains('rose') || s.contains('gulab')) return 'देशी गुलाब / Desi Rose';
    if (s.contains('jasmine') || s.contains('mogra')) return 'मोगरा चमेली / Jasmine';
    if (s.contains('tulsi')) return 'कृष्ण तुलसी / Holy Basil';
    if (s.contains('aloe')) return 'घृतकुमारी / Aloe Vera';
    return commonName;
  }
}

typedef ProductModel = Product;
