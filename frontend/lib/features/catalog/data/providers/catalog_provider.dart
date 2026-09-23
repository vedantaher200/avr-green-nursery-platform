import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../../../auth/data/providers/auth_provider.dart';
import '../../../customer/data/providers/marketplace_provider.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => 'all');
final searchQueryProvider = StateProvider<String>((ref) => '');

// Comprehensive preloaded botanical catalog matching AVR Green Nursery inventory
const List<Product> defaultBotanicalCatalog = [
  // ── Vegetables & Seedlings ──────────────────────────────────────────────────
  Product(
    id: '88888888-8888-8888-8888-888888888816',
    sku: 'VEG-CHIL-16',
    commonName: 'Green Chilli (Hari Mirch)',
    scientificName: 'Capsicum annuum',
    description: 'High-yield commercial vegetable seedling with spicy green chillies. Ready for farm planting and kitchen gardens.',
    price: 49.00,
    costPrice: 20.00,
    categoryId: 'vegetables',
    categoryName: 'Vegetables & Seedlings',
    availableStock: 350,
    care: CareInstructions(
      sunlight: 'Full Direct Sun (6+ hours)',
      watering: 'Moderate (alternate days)',
      fertilizer: 'Mustard cake liquid manure bi-weekly',
      temperature: '20°C - 35°C',
    ),
  ),
  Product(
    id: '88888888-8888-8888-8888-888888888817',
    sku: 'VEG-CAP-17',
    commonName: 'Shimla Mirchi / Capsicum',
    scientificName: 'Capsicum annuum var. grossum',
    description: 'Premium healthy nursery seedling for sweet, crisp bell peppers. Thrives in farm beds, polyhouses and home terrace containers.',
    price: 59.00,
    costPrice: 25.00,
    categoryId: 'vegetables',
    categoryName: 'Vegetables & Seedlings',
    availableStock: 200,
    care: CareInstructions(
      sunlight: 'Bright Sunlight (5-6 hours)',
      watering: 'Keep soil evenly moist',
      fertilizer: 'Organic compost + bone meal monthly',
      temperature: '18°C - 30°C',
    ),
  ),
  Product(
    id: '88888888-8888-8888-8888-888888888818',
    sku: 'VEG-TOM-18',
    commonName: 'Hybrid Tomato (Tamatar)',
    scientificName: 'Solanum lycopersicum',
    description: 'Disease-resistant F1 hybrid tomato seedling producing heavy clusters of juicy firm tomatoes. Sturdy root ball.',
    price: 45.00,
    costPrice: 18.00,
    categoryId: 'vegetables',
    categoryName: 'Vegetables & Seedlings',
    availableStock: 500,
    care: CareInstructions(
      sunlight: 'Full Direct Sun (6-8 hours)',
      watering: 'Deep watering 2-3 times per week',
      fertilizer: 'Potassium-rich organic compost on flowering',
      temperature: '18°C - 32°C',
    ),
  ),
  Product(
    id: '88888888-8888-8888-8888-888888888819',
    sku: 'VEG-BRIN-19',
    commonName: 'Brinjal / Eggplant (Baingan)',
    scientificName: 'Solanum melongena',
    description: 'Vigorous seedling with broad healthy foliage. Produces glossy purple fruits with tender flesh throughout the season.',
    price: 45.00,
    costPrice: 18.00,
    categoryId: 'vegetables',
    categoryName: 'Vegetables & Seedlings',
    availableStock: 280,
    care: CareInstructions(
      sunlight: 'Full Sun (6 hours)',
      watering: 'Regular watering, avoid dry soil',
      fertilizer: 'Vermicompost every 3 weeks',
      temperature: '22°C - 35°C',
    ),
  ),
  Product(
    id: '88888888-8888-8888-8888-888888888820',
    sku: 'VEG-CAB-20',
    commonName: 'Cabbage Seedling (Band Gobhi)',
    scientificName: 'Brassica oleracea var. capitata',
    description: 'Compact, firm heading cabbage seedling for cool season farming with crisp tender sweet leaves.',
    price: 39.00,
    costPrice: 15.00,
    categoryId: 'vegetables',
    categoryName: 'Vegetables & Seedlings',
    availableStock: 300,
    care: CareInstructions(
      sunlight: 'Full Sunlight (4-6 hours)',
      watering: 'Maintain uniform soil moisture',
      fertilizer: 'Nitrogen-rich bio fertilizer early stage',
      temperature: '15°C - 25°C',
    ),
  ),
  Product(
    id: '88888888-8888-8888-8888-888888888821',
    sku: 'VEG-CAUL-21',
    commonName: 'Cauliflower Seedling (Phool Gobhi)',
    scientificName: 'Brassica oleracea var. botrytis',
    description: 'High quality pure white curd variety seedling. Excellent farm crop yield and rapid head formation.',
    price: 39.00,
    costPrice: 15.00,
    categoryId: 'vegetables',
    categoryName: 'Vegetables & Seedlings',
    availableStock: 250,
    care: CareInstructions(
      sunlight: 'Full Sunlight (5 hours)',
      watering: 'Regular gentle watering',
      fertilizer: 'Organic compost every 2 weeks',
      temperature: '15°C - 24°C',
    ),
  ),
  Product(
    id: '88888888-8888-8888-8888-888888888823',
    sku: 'VEG-CUC-23',
    commonName: 'Cucumber Plant (Desi Kheera)',
    scientificName: 'Cucumis sativus',
    description: 'Fast growing crisp cucumber vine seedling for high summer hydration and prolific daily harvests.',
    price: 49.00,
    costPrice: 20.00,
    categoryId: 'vegetables',
    categoryName: 'Vegetables & Seedlings',
    availableStock: 220,
    care: CareInstructions(
      sunlight: 'Full Sun (6 hours)',
      watering: 'High water requirement (daily)',
      fertilizer: 'Balanced organic fertilizer monthly',
      temperature: '22°C - 35°C',
    ),
  ),
  Product(
    id: '88888888-8888-8888-8888-888888888824',
    sku: 'VEG-OKRA-24',
    commonName: 'Bhendi / Okra (Ladyfinger)',
    scientificName: 'Abelmoschus esculentus',
    description: 'Sturdy okra seedling producing tender dark green pods with minimal fiber and high commercial viability.',
    price: 35.00,
    costPrice: 14.00,
    categoryId: 'vegetables',
    categoryName: 'Vegetables & Seedlings',
    availableStock: 400,
    care: CareInstructions(
      sunlight: 'Full Direct Sun (6+ hours)',
      watering: 'Moderate watering',
      fertilizer: 'Neem cake + compost every 3 weeks',
      temperature: '25°C - 38°C',
    ),
  ),

  // ── Fruit Plants & Trees ────────────────────────────────────────────────────
  Product(
    id: '88888888-8888-8888-8888-888888888825',
    sku: 'FRUIT-MAN-25',
    commonName: 'Grafted Amrapali Mango Plant',
    scientificName: 'Mangifera indica',
    description: 'Genuine grafted dwarfing mango variety. Yields sweet fiberless deep orange mangoes from Year 2 onwards.',
    price: 399.00,
    costPrice: 180.00,
    categoryId: 'fruits',
    categoryName: 'Fruit Plants & Trees',
    availableStock: 90,
    care: CareInstructions(
      sunlight: 'Full Direct Sun (6-8 hours)',
      watering: 'Deep watering once weekly',
      fertilizer: 'Farmyard manure + bone meal twice yearly',
      temperature: '20°C - 42°C',
    ),
  ),
  Product(
    id: '88888888-8888-8888-8888-888888888826',
    sku: 'FRUIT-GUA-26',
    commonName: 'Guava Plant (Allahabad Safeda)',
    scientificName: 'Psidium guajava',
    description: 'High-bearing sweet white-fleshed guava sapling. Adaptable to multiple soil types with heavy fruit production.',
    price: 249.00,
    costPrice: 100.00,
    categoryId: 'fruits',
    categoryName: 'Fruit Plants & Trees',
    availableStock: 110,
    care: CareInstructions(
      sunlight: 'Full Sunlight (6 hours)',
      watering: 'Moderate, drought tolerant once established',
      fertilizer: 'Organic compost quarterly',
      temperature: '18°C - 38°C',
    ),
  ),
  Product(
    id: '88888888-8888-8888-8888-888888888827',
    sku: 'FRUIT-LEM-27',
    commonName: 'Kagzi Lemon Plant (Baramasi)',
    scientificName: 'Citrus limon',
    description: 'Ever-bearing thin-skinned juicy lemon plant. Prolific flowering and fruiting for home balconies and orchard farms.',
    price: 199.00,
    costPrice: 85.00,
    categoryId: 'fruits',
    categoryName: 'Fruit Plants & Trees',
    availableStock: 140,
    care: CareInstructions(
      sunlight: 'Full Direct Sun (5-6 hours)',
      watering: 'Water when top soil is dry',
      fertilizer: 'Epsom salt + micronutrient spray monthly',
      temperature: '18°C - 35°C',
    ),
  ),

  // ── Flower Plants ───────────────────────────────────────────────────────────
  Product(
    id: '88888888-8888-8888-8888-888888888808',
    sku: 'PLANT-ROS-08',
    commonName: 'Desi Rose (Indian Fragrant Rose)',
    scientificName: 'Rosa indica',
    description: 'Traditional highly fragrant Indian rose producing deep crimson blooms year-round. Perfect for gardens and sunny balconies.',
    price: 399.00,
    costPrice: 170.00,
    categoryId: 'flowering',
    categoryName: 'Flowering Plants',
    availableStock: 65,
    care: CareInstructions(
      sunlight: 'Full Direct Sunlight (5-6 hours)',
      watering: 'Daily in summer, alternate days in winter',
      fertilizer: 'Mustard cake + vermicompost every 15 days',
      temperature: '18°C - 35°C',
    ),
  ),
  Product(
    id: '88888888-8888-8888-8888-888888888810',
    sku: 'PLANT-JAS-10',
    commonName: 'Mogra Jasmine (Beli)',
    scientificName: 'Jasminum sambac',
    description: 'Intensely fragrant white star flowers blooming in abundance throughout spring and summer. Essential for festive garlands.',
    price: 299.00,
    costPrice: 115.00,
    categoryId: 'flowering',
    categoryName: 'Flowering Plants',
    availableStock: 75,
    care: CareInstructions(
      sunlight: 'Direct Morning Sunlight (4-5 hours)',
      watering: 'Moderate, moist soil',
      fertilizer: 'Cow dung manure monthly',
      temperature: '20°C - 35°C',
    ),
  ),

  // ── Medicinal & Herbs ───────────────────────────────────────────────────────
  Product(
    id: '88888888-8888-8888-8888-888888888811',
    sku: 'PLANT-TUL-11',
    commonName: 'Holy Basil Tulsi (Krishna Tulsi)',
    scientificName: 'Ocimum tenuiflorum',
    description: 'Sacred medicinal plant with aromatic leaves. Renowned in Ayurveda for its antioxidant, immunity-boosting and air-purifying qualities.',
    price: 149.00,
    costPrice: 55.00,
    categoryId: 'medicinal',
    categoryName: 'Medicinal & Herbs',
    availableStock: 90,
    care: CareInstructions(
      sunlight: 'Bright Direct Sunlight (4+ hours)',
      watering: 'Keep soil moist, avoid waterlogging',
      fertilizer: 'Organic compost monthly',
      temperature: '20°C - 35°C',
    ),
  ),
  Product(
    id: '88888888-8888-8888-8888-888888888807',
    sku: 'PLANT-ALO-07',
    commonName: 'Aloe Vera Barbadensis',
    scientificName: 'Aloe barbadensis Miller',
    description: 'Thick gel-filled medicinal succulent. Renowned for soothing skin care, burns, digestive health and air purification.',
    price: 249.00,
    costPrice: 95.00,
    categoryId: 'medicinal',
    categoryName: 'Medicinal & Herbs',
    availableStock: 115,
    care: CareInstructions(
      sunlight: 'Bright Indirect to Direct Sun',
      watering: 'Low (once every 10-14 days)',
      fertilizer: 'Not required frequently',
      temperature: '15°C - 38°C',
    ),
  ),

  // ── Indoor Plants ───────────────────────────────────────────────────────────
  Product(
    id: '88888888-8888-8888-8888-888888888801',
    sku: 'PLANT-MON-01',
    commonName: 'Monstera Deliciosa',
    scientificName: 'Monstera deliciosa Liebm.',
    description: 'Vibrant tropical indoor plant with iconic natural leaf holes. Purifies indoor air and thrives in bright living spaces.',
    price: 899.00,
    costPrice: 450.00,
    categoryId: 'indoor',
    categoryName: 'Indoor Plants',
    availableStock: 45,
    care: CareInstructions(
      sunlight: 'Bright Indirect Light',
      watering: 'Once weekly when top soil feels dry',
      fertilizer: 'Balanced organic liquid fertilizer monthly',
      temperature: '18°C - 30°C',
    ),
  ),
  Product(
    id: '88888888-8888-8888-8888-888888888802',
    sku: 'PLANT-SNK-02',
    commonName: 'Snake Plant Golden Hahnii',
    scientificName: 'Dracaena trifasciata',
    description: 'Exceptional air-purifying succulent. Releases oxygen during the night and tolerates low-light, making it perfect for bedrooms.',
    price: 449.00,
    costPrice: 200.00,
    categoryId: 'indoor',
    categoryName: 'Indoor Plants',
    availableStock: 120,
    care: CareInstructions(
      sunlight: 'Low to Bright Light',
      watering: 'Every 2-3 weeks (do not overwater)',
      fertilizer: 'Diluted seaweed extract once in spring',
      temperature: '15°C - 32°C',
    ),
  ),
];

final selectedCropProvider = StateProvider<String>((ref) => 'all');

final catalogListProvider = FutureProvider<List<Product>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final selectedNursery = ref.watch(selectedNurseryProvider);

  try {
    final Map<String, dynamic> params = {'limit': 50};
    if (selectedNursery != null) {
      params['tenantId'] = selectedNursery.tenantId;
    }

    final response = await apiClient.dio.get('/products', queryParameters: params);
    if (response.statusCode == 200 && response.data != null) {
      final raw = response.data['data'];
      if (raw is List && raw.isNotEmpty) {
        return raw.map((json) {
          final p = Product.fromJson(json as Map<String, dynamic>);
          if (selectedNursery != null) {
            return Product(
              id: p.id,
              tenantId: selectedNursery.tenantId,
              nurseryName: selectedNursery.name,
              sku: p.sku,
              commonName: p.commonName,
              scientificName: p.scientificName,
              crop: p.crop,
              variety: p.variety,
              sellingUnit: p.sellingUnit,
              traySize: p.traySize,
              minOrderQty: p.minOrderQty,
              description: p.description,
              price: p.price,
              costPrice: p.costPrice,
              categoryId: p.categoryId,
              categoryName: p.categoryName,
              images: p.images,
              availableStock: p.availableStock,
              care: p.care,
            );
          }
          return p;
        }).toList();
      }
    }
  } catch (_) {
    // Gracefully fall back to preloaded botanical catalog
  }

  return defaultBotanicalCatalog;
});

final filteredCatalogProvider = Provider<List<Product>>((ref) {
  final catalogAsync = ref.watch(catalogListProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final selectedCrop = ref.watch(selectedCropProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase().trim();

  final list = catalogAsync.value ?? defaultBotanicalCatalog;

  return list.where((p) {
    // 1. Crop Filter
    if (selectedCrop != 'all' && !p.crop.toLowerCase().contains(selectedCrop.toLowerCase())) {
      return false;
    }

    // 2. Category Filter
    bool matchesCategory = selectedCategory == 'all';
    if (!matchesCategory) {
      final pCat = p.categoryId.toLowerCase();
      final pName = p.categoryName.toLowerCase();
      final sel = selectedCategory.toLowerCase();

      if (sel == 'vegetables') {
        matchesCategory = pCat.contains('veg') || pName.contains('veg') || p.sku.startsWith('VEG') || p.sku.contains('CHI') || p.sku.contains('TOM') || p.sku.contains('CAP') || p.sku.contains('BRIN');
      } else if (sel == 'fruits') {
        matchesCategory = pCat.contains('fruit') || pName.contains('fruit') || p.sku.startsWith('FRUIT') || p.sku.contains('MAN') || p.sku.contains('LEM');
      } else if (sel == 'flowering') {
        matchesCategory = pCat.contains('flower') || pName.contains('flower') || p.sku.contains('ROS') || p.sku.contains('JAS') || p.sku.contains('MAR') || p.sku.contains('CHR');
      } else if (sel == 'medicinal') {
        matchesCategory = pCat.contains('med') || pName.contains('med') || p.sku.contains('TUL') || p.sku.contains('ALO');
      } else if (sel == 'indoor') {
        matchesCategory = pCat.contains('indoor') || pName.contains('indoor') || p.sku.contains('MON') || p.sku.contains('SNK') || p.sku.contains('POT') || p.sku.contains('FIC');
      } else if (sel == 'fertilizers') {
        matchesCategory = pCat.contains('fert') || pName.contains('fert') || p.sku.startsWith('FERT');
      } else {
        matchesCategory = pCat == sel || pName.contains(sel);
      }
    }

    // 3. Search Query
    final matchesSearch = searchQuery.isEmpty ||
        p.commonName.toLowerCase().contains(searchQuery) ||
        (p.scientificName?.toLowerCase().contains(searchQuery) ?? false) ||
        p.crop.toLowerCase().contains(searchQuery) ||
        p.variety.toLowerCase().contains(searchQuery) ||
        p.sku.toLowerCase().contains(searchQuery);

    return matchesCategory && matchesSearch;
  }).toList();
});
