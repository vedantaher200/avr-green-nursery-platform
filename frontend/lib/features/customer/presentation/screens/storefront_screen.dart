import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../catalog/data/providers/catalog_provider.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../data/models/nursery_model.dart';
import '../../data/providers/cart_provider.dart';
import '../../data/providers/marketplace_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Customer / Farmer Multi-Nursery Marketplace & Storefront Screen
// ─────────────────────────────────────────────────────────────────────────────

class StorefrontScreen extends ConsumerWidget {
  const StorefrontScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final selectedLocation = ref.watch(selectedLocationProvider);
    final selectedNursery = ref.watch(selectedNurseryProvider);
    final nearbyNurseriesAsync = ref.watch(nearbyNurseriesProvider);
    final products = ref.watch(filteredCatalogProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);
    final selectedCrop = ref.watch(selectedCropProvider);
    final cart = ref.watch(cartProvider);

    final categories = [
      {'id': 'all', 'label': 'All Plants', 'emoji': '🌿'},
      {'id': 'vegetables', 'label': 'Vegetables', 'emoji': '🌶'},
      {'id': 'fruits', 'label': 'Fruit Plants', 'emoji': '🌱'},
      {'id': 'flowering', 'label': 'Flowers', 'emoji': '🌸'},
      {'id': 'medicinal', 'label': 'Medicinal', 'emoji': '🌿'},
      {'id': 'indoor', 'label': 'Indoor Plants', 'emoji': '🪴'},
      {'id': 'fertilizers', 'label': 'Fertilizers', 'emoji': '🌾'},
    ];

    final cropFilters = ['all', 'Chilli', 'Tomato', 'Capsicum', 'Brinjal', 'Marigold', 'Sugarcane', 'Lemon'];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Top Header: Brand, Location Bar & Cart ─────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AVRColors.forestGreenSurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(Icons.eco_rounded, color: AVRColors.forestGreen, size: 24),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    AppStrings.get('app_name', language),
                                    style: const TextStyle(
                                      color: AVRColors.forestGreenDark,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, color: AVRColors.forestGreen, size: 14),
                                ],
                              ),
                              // Location Picker Pill
                              InkWell(
                                onTap: () => _showLocationSelector(context, ref),
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_on, color: AVRColors.terracotta, size: 13),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${selectedLocation.city}, ${selectedLocation.district}',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down, color: AVRColors.forestGreen, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Language switcher
                        PopupMenuButton<AppLanguage>(
                          icon: const Icon(Icons.translate_rounded, color: AVRColors.forestGreen, size: 22),
                          tooltip: 'Language / भाषा',
                          onSelected: (lang) => ref.read(appLanguageProvider.notifier).state = lang,
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: AppLanguage.en, child: Text('English')),
                            PopupMenuItem(value: AppLanguage.hi, child: Text('हिन्दी (Hindi)')),
                            PopupMenuItem(value: AppLanguage.mr, child: Text('मराठी (Marathi)')),
                          ],
                        ),
                        // Cart Icon with badge
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shopping_bag_outlined, color: AVRColors.forestGreen, size: 24),
                              onPressed: () => context.push('/cart'),
                            ),
                            if (cart.totalItemCount > 0)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AVRColors.terracotta,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                  child: Text(
                                    '${cart.totalItemCount}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Search Bar ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
                child: TextField(
                  onChanged: (val) {
                    ref.read(searchQueryProvider.notifier).state = val;
                    ref.read(nurserySearchQueryProvider.notifier).state = val;
                  },
                  style: const TextStyle(fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: selectedNursery == null
                        ? 'Search nurseries, crops (Chilli, Tomato), varieties...'
                        : 'Search varieties in ${selectedNursery.name}...',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: AVRColors.forestGreen, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F2),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            // ── Selected Nursery Mode Banner OR Marketplace Discovery ────────
            if (selectedNursery != null) ...[
              // Active Selected Nursery Banner
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AVRColors.forestGreen.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AVRColors.forestGreenSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(Icons.storefront_rounded, color: AVRColors.forestGreen, size: 24),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    selectedNursery.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.5,
                                      color: AVRColors.forestGreenDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, color: AVRColors.forestGreen, size: 14),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${selectedNursery.city} • ${selectedNursery.distanceKm} km away',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          visualDensity: VisualDensity.compact,
                          side: const BorderSide(color: AVRColors.forestGreen),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.swap_horiz, size: 16, color: AVRColors.forestGreen),
                        label: const Text('Change Nursery', style: TextStyle(fontSize: 11, color: AVRColors.forestGreen, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          ref.read(selectedNurseryProvider.notifier).state = null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // ── Marketplace Nearby Nurseries Section ────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.store_rounded, color: AVRColors.forestGreen, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Nearby Nurseries (${selectedLocation.city})',
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: AVRColors.forestGreenDark,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => _showLocationSelector(context, ref),
                        child: const Text('Change City', style: TextStyle(fontSize: 12, color: AVRColors.forestGreen, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),

              // Horizontal Nearby Nursery Cards
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 155,
                  child: nearbyNurseriesAsync.when(
                    data: (nurseries) {
                      if (nurseries.isEmpty) {
                        return Center(
                          child: Text('No nurseries found near ${selectedLocation.city}', style: TextStyle(color: Colors.grey.shade600)),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: nurseries.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final n = nurseries[index];
                          return _buildNurseryDiscoveryCard(context, ref, n);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Center(child: Text('Failed to load nurseries')),
                  ),
                ),
              ),
            ],

            // ── Crop Hierarchy Selector ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Popular Crops & Varieties',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AVRColors.forestGreenDark),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: cropFilters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final crop = cropFilters[index];
                          final isSelected = selectedCrop == crop;
                          return ChoiceChip(
                            label: Text(crop == 'all' ? 'All Crops' : crop),
                            selected: isSelected,
                            selectedColor: AVRColors.forestGreen,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AVRColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            onSelected: (_) {
                              ref.read(selectedCropProvider.notifier).state = crop;
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Categories Horizontal Bar ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                height: 48,
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = selectedCat == cat['id'];
                    return ChoiceChip(
                      label: Text('${cat['emoji']} ${cat['label']}'),
                      selected: isSelected,
                      selectedColor: AVRColors.forestGreenDark,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AVRColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      onSelected: (_) {
                        ref.read(selectedCategoryProvider.notifier).state = cat['id'] as String;
                      },
                    );
                  },
                ),
              ),
            ),

            // ── Section Title & Product Count ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedNursery != null
                          ? '${selectedNursery.name} (${products.length} Varieties)'
                          : 'Available Seedlings & Varieties (${products.length})',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AVRColors.forestGreenDark,
                      ),
                    ),
                    if (selectedNursery != null)
                      Text(
                        selectedNursery.city,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
            ),

            // ── Compact 2-Column Mobile Product Grid (Sections 10 & 21) ───────
            products.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.grass_rounded, size: 52, color: Colors.grey.shade400),
                          const SizedBox(height: 10),
                          Text(
                            'No plant varieties found matching your filters',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = products[index];
                          return _buildCompactProductCard(context, ref, product);
                        },
                        childCount: products.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // ── Nursery Discovery Card ──────────────────────────────────────────────────
  Widget _buildNurseryDiscoveryCard(BuildContext context, WidgetRef ref, NurseryModel n) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            n.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AVRColors.forestGreenDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (n.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: AVRColors.forestGreen, size: 14),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${n.city} • ${n.distanceKm} km away',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AVRColors.forestGreenSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '⭐ ${n.rating}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AVRColors.forestGreenDark),
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 4,
            children: [
              if (n.deliveryAvailable)
                _buildTag('🚚 Delivery Available', const Color(0xFFE8F6ED), AVRColors.forestGreen),
              if (n.pickupAvailable)
                _buildTag('📦 Farm Pickup', const Color(0xFFFFF3E0), AVRColors.terracotta),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${n.activeVarietiesCount}+ Varieties',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AVRColors.textPrimary),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AVRColors.forestGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  ref.read(selectedNurseryProvider.notifier).state = n;
                },
                child: const Text('Visit Storefront', style: TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: textCol)),
    );
  }

  // ── Compact 2-Column Mobile Product Card (Sections 10 & 21) ─────────────────
  Widget _buildCompactProductCard(BuildContext context, WidgetRef ref, Product product) {
    return GestureDetector(
      onTap: () => context.push('/catalog/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bounded aspect ratio image (no oversized stretch)
            AspectRatio(
              aspectRatio: 1.25,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: Image.asset(
                      product.primaryImageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AVRColors.sageSurface,
                        child: const Icon(Icons.eco_rounded, size: 40, color: AVRColors.forestGreen),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.crop,
                        style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.commonName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AVRColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.variety,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AVRColors.forestGreenDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.unitLabel,
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${product.price.toStringAsFixed(product.price % 1 == 0 ? 0 : 2)}',
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: AVRColors.forestGreen,
                              ),
                            ),
                            Text(
                              product.availableStock > 0 ? '${product.availableStock} in stock' : 'Out of stock',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: product.availableStock > 0 ? AVRColors.success : AVRColors.error,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AVRColors.forestGreen,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => _handleAddToCart(context, ref, product),
                            child: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Single-Nursery Cart Isolation Add Handler ───────────────────────────────
  void _handleAddToCart(BuildContext context, WidgetRef ref, Product product) {
    final result = ref.read(cartProvider.notifier).addItem(product);

    if (result == CartAddResult.nurseryConflict) {
      final cart = ref.read(cartProvider);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AVRColors.warning),
              SizedBox(width: 8),
              Text('Switch Nursery Cart?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Your cart currently contains plants from "${cart.currentNurseryName}".\n\nTo order from "${product.nurseryName}", would you like to clear your current cart and start an order with this nursery?',
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep Current Cart'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AVRColors.forestGreen),
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(cartProvider.notifier).clearAndAdd(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AVRColors.forestGreen,
                    content: Text('Switched to ${product.nurseryName} and added ${product.commonName}'),
                  ),
                );
              },
              child: const Text('Clear & Switch Nursery', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          backgroundColor: AVRColors.forestGreen,
          content: Text('Added ${product.commonName} (${product.variety}) to Cart'),
        ),
      );
    }
  }

  // ── Manual Location Selector Modal (No Fake GPS) ───────────────────────────
  void _showLocationSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, color: AVRColors.forestGreen),
                SizedBox(width: 8),
                Text(
                  'Select Farming Location',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AVRColors.forestGreenDark),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Select your nearest agricultural cluster in Maharashtra to discover verified local nurseries.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: supportedLocations.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final loc = supportedLocations[index];
                  final isSelected = ref.watch(selectedLocationProvider).city == loc.city;
                  return ListTile(
                    dense: true,
                    title: Text(loc.displayName, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                    subtitle: Text(loc.state, style: const TextStyle(fontSize: 11)),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: AVRColors.forestGreen, size: 20) : null,
                    onTap: () {
                      ref.read(selectedLocationProvider.notifier).state = loc;
                      ref.invalidate(nearbyNurseriesProvider);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
