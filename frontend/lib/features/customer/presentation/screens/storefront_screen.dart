import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/network_retry_dialog.dart';
import '../../../../core/widgets/app_product_image.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../../catalog/data/providers/catalog_provider.dart';
import '../../../catalog/presentation/widgets/compact_product_card.dart';
import '../../../inventory/data/models/owner_inventory_models.dart';
import '../../../inventory/data/providers/owner_inventory_provider.dart';
import '../widgets/farmer_prebooking_modal.dart';
import '../widgets/nursery_trust_modal.dart';
import '../../data/models/nursery_model.dart';
import '../../data/models/offer_model.dart';
import '../../data/providers/cart_provider.dart';
import '../../data/providers/marketplace_provider.dart';
import '../../data/providers/offers_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/widgets/realtime_calendar_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Commercial Multi-Nursery Farmer Marketplace Home & Discovery
// ─────────────────────────────────────────────────────────────────────────────

class StorefrontScreen extends ConsumerWidget {
  const StorefrontScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final selectedLocation = ref.watch(selectedLocationProvider);
    final selectedNursery = ref.watch(selectedNurseryProvider);
    final nearbyNurseriesAsync = ref.watch(nearbyNurseriesProvider);
    final allProducts = ref.watch(filteredCatalogProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);
    final selectedCrop = ref.watch(selectedCropProvider);
    final cart = ref.watch(cartProvider);
    final currentSort = ref.watch(nurserySortByProvider);
    final announcementsAsync = ref.watch(marketplaceAnnouncementsProvider);
    final offersAsync = ref.watch(marketplaceOffersProvider);

    // Derived product collections for Farmer Home sections
    final readyStockProducts = allProducts.where((p) => p.isReadyStock).toList();
    final prebookingProducts = allProducts.where((p) => p.isPrebooking).toList();
    final searchQuery = ref.watch(searchQueryProvider);
    final featuredVarieties = selectedCrop != 'all'
        ? allProducts
        : (selectedCat != 'all' ? allProducts : allProducts.take(8).toList());
    final bestSellers = allProducts.where((p) => p.isHot || p.isBestseller).isNotEmpty
        ? allProducts.where((p) => p.isHot || p.isBestseller).toList()
        : allProducts.take(6).toList();

    final categories = marketplaceCategories;
    final popularCrops = ref.watch(categoryCropsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Section 1: Location Selector & Brand Header ───────────────────
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AVRColors.forestGreenSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(Icons.eco_rounded, color: AVRColors.forestGreen, size: 22),
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
                                  fontSize: 15,
                                  letterSpacing: 0.3,
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
                                    selectedLocation.displayName,
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
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
                      icon: const Icon(Icons.translate_rounded, color: AVRColors.forestGreen, size: 20),
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
                          icon: const Icon(Icons.shopping_bag_outlined, color: AVRColors.forestGreen, size: 22),
                          onPressed: () => context.push('/cart'),
                        ),
                        if (cart.totalItemCount > 0)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AVRColors.terracotta,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              child: Text(
                                '${cart.totalItemCount}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Section 2: Commercial Search Bar ──────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                child: TextField(
                  onChanged: (val) {
                    ref.read(searchQueryProvider.notifier).state = val;
                    ref.read(nurserySearchQueryProvider.notifier).state = val;
                  },
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: selectedNursery == null
                        ? 'Search nurseries, crops (Chilli, Tomato), varieties, seedling trays...'
                        : 'Search varieties in ${selectedNursery.name}...',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12.5),
                    prefixIcon: const Icon(Icons.search_rounded, color: AVRColors.forestGreen, size: 19),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F2),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            // ── Section 2.1: Categorized Multi-Type Search Breakdown (Section 13)
            if (searchQuery.trim().isNotEmpty)
              _buildCategorizedSearchResults(context, ref, language, searchQuery, allProducts, nearbyNurseriesAsync),

            // ── Section 2.2: Farmer Special Offers & Campaigns (Section 7) ─────
            _buildFarmerSpecialOffersSection(context, offersAsync),

            // ── Section 2.5: Live Nursery Production Broadcasts & Announcements ─
            _buildLiveAnnouncementsBanner(context, ref, announcementsAsync, allProducts),

            // ── Active Selected Nursery Banner (If a nursery is chosen) ───────
            if (selectedNursery != null) ...[
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AVRColors.forestGreen.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      AppProductImage.nurseryAvatar(
                        imageUrl: selectedNursery.imageUrl,
                        size: 48,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(width: 10),
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
                                      fontSize: 13.5,
                                      color: AVRColors.forestGreenDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, color: AVRColors.forestGreen, size: 13),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${selectedNursery.city}${selectedNursery.distanceKm == null ? '' : ' • ${selectedNursery.distanceKm!.toStringAsFixed(1)} km away'} • ⭐ ${selectedNursery.rating} (${selectedNursery.reviewCount})',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          visualDensity: VisualDensity.compact,
                          side: const BorderSide(color: AVRColors.forestGreen),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.swap_horiz, size: 14, color: AVRColors.forestGreen),
                        label: const Text('Change Nursery', style: TextStyle(fontSize: 10.5, color: AVRColors.forestGreen, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          ref.read(selectedNurseryProvider.notifier).state = null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // ── Section 3: Nearby / Local Nurseries (Discovery & Ranking) ─────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.store_rounded, color: AVRColors.forestGreen, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Participating Nurseries (${selectedLocation.city})',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AVRColors.forestGreenDark,
                            ),
                          ),
                        ],
                      ),
                      // Transparent Ranking Explainer Button
                      InkWell(
                        onTap: () => _showRankingExplanationDialog(context),
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 13, color: AVRColors.forestGreen),
                              SizedBox(width: 2),
                              Text(
                                'Ranking Info',
                                style: TextStyle(fontSize: 11, color: AVRColors.forestGreen, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sorting & Filter bar for nurseries
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      _buildSortChip(ref, 'Multi-Factor Rank', 'rank', currentSort),
                      const SizedBox(width: 6),
                      _buildSortChip(ref, 'Nearest Distance', 'distance', currentSort),
                      const SizedBox(width: 6),
                      _buildSortChip(ref, 'Highest Rating', 'rating', currentSort),
                      const SizedBox(width: 6),
                      _buildSortChip(ref, 'Most Varieties', 'varieties', currentSort),
                    ],
                  ),
                ),
              ),

              // Horizontal Discovery Cards for Nurseries in Selected Location
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 195,
                  child: nearbyNurseriesAsync.when(
                    data: (nurseries) {
                      if (nurseries.isEmpty) {
                        return Center(
                          child: Text(
                            'No registered nurseries found in ${selectedLocation.city}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: nurseries.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final nursery = nurseries[index];
                          return _buildNurseryDiscoveryCard(context, ref, nursery);
                        },
                      );
                    },
                    loading: () => const Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AVRColors.forestGreen),
                      ),
                    ),
                    error: (err, _) => _buildNurseryNetworkErrorCard(context, ref, err),
                  ),
                ),
              ),
            ],

            // ── Section 4: Categories Horizontal Rail ─────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Text(
                  'Explore Plant Categories',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AVRColors.forestGreenDark),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = selectedCat == cat.id;
                    return ChoiceChip(
                      avatar: Text(cat.emoji, style: const TextStyle(fontSize: 12)),
                      label: Text(cat.label),
                      selected: isSelected,
                      selectedColor: AVRColors.forestGreen,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AVRColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 11,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(
                        color: isSelected ? AVRColors.forestGreen : Colors.grey.shade200,
                      ),
                      onSelected: (_) {
                        ref.read(selectedCategoryProvider.notifier).state = cat.id;
                        ref.read(selectedCropProvider.notifier).state = 'all';
                      },
                    );
                  },
                ),
              ),
            ),

            // ── Section 5: Popular Crops ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Text(
                  selectedCat != 'all'
                      ? 'Crops for ${categories.firstWhere((c) => c.id == selectedCat, orElse: () => categories.first).label}'
                      : 'Popular Agricultural Crops (Nashik Region)',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AVRColors.forestGreenDark),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: popularCrops.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final c = popularCrops[index];
                    final isSelected = selectedCrop == c['crop'];
                    return InkWell(
                      onTap: () {
                        final chosenCrop = c['crop']!;
                        ref.read(selectedCropProvider.notifier).state = chosenCrop;
                        if (chosenCrop != 'all') {
                          ref.read(searchQueryProvider.notifier).state = '';
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AVRColors.forestGreen : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? AVRColors.forestGreen : Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(c['emoji'] ?? '🌱', style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c['label'] ?? c['crop'] ?? 'Crop',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : AVRColors.textPrimary,
                                  ),
                                ),
                                if (c['local'] != null && c['local']!.isNotEmpty)
                                  Text(
                                    c['local']!,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: isSelected ? Colors.white70 : Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Section 6: Featured Hybrid Varieties (Compact Marketplace Grid)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          selectedCrop != 'all'
                              ? '$selectedCrop Varieties'
                              : (selectedCat != 'all'
                                  ? categories.firstWhere((c) => c.id == selectedCat, orElse: () => categories.first).label
                                  : AppStrings.get('featured_varieties', language)),
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AVRColors.forestGreenDark),
                        ),
                        if (selectedCrop != 'all' || selectedCat != 'all') ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              ref.read(selectedCropProvider.notifier).state = 'all';
                              ref.read(selectedCategoryProvider.notifier).state = 'all';
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AVRColors.terracotta.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    AppStrings.get('clear_filter', language),
                                    style: const TextStyle(fontSize: 10, color: AVRColors.terracotta, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.close_rounded, size: 12, color: AVRColors.terracotta),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${featuredVarieties.length} available',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

            // Responsive Compact Marketplace Grid (Sections 14, 15, 16, 17)
            featuredVarieties.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(child: Text(AppStrings.get('no_varieties_found', language))),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.crossAxisExtent;
                        final crossAxisCount = width >= 1200
                            ? 5
                            : width >= 900
                                ? 4
                                : width >= 600
                                    ? 3
                                    : 2;
                        final childAspectRatio = crossAxisCount >= 4
                            ? 0.73
                            : crossAxisCount == 3
                                ? 0.71
                                : 0.67;
                        return SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: childAspectRatio,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = featuredVarieties[index];
                              return CompactProductCard(product: product);
                            },
                            childCount: featuredVarieties.length,
                          ),
                        );
                      },
                    ),
                  ),

            // ── Section 7: Ready Stock (Immediate Dispatch Trays) ─────────────
            if (readyStockProducts.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AVRColors.success, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Ready Stock Trays (Farm Pickup / Delivery)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AVRColors.forestGreenDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 275,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    scrollDirection: Axis.horizontal,
                    itemCount: readyStockProducts.take(8).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final p = readyStockProducts[index];
                      return SizedBox(
                        width: 165,
                        child: CompactProductCard(product: p),
                      );
                    },
                  ),
                ),
              ),
            ],

            // ── Section 8: Coming Soon / Pre-book (Polyhouse Production Batches)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: AVRColors.warning, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Coming Soon • Advance Pre-Booking',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AVRColors.forestGreenDark),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    if (prebookingProducts.isNotEmpty)
                      ...prebookingProducts.take(3).map((p) => Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: SizedBox(
                              width: 165,
                              child: CompactProductCard(product: p),
                            ),
                          )),
                    _buildPrebookingCard(
                      context,
                      ref,
                      crop: 'Hybrid Tomato',
                      variety: 'Abhinav F1 Hybrid',
                      readyDate: '15-18 Oct 2026',
                      traySize: 104,
                      price: '₹180 / Tray',
                      nursery: 'Chandwad Agro Nursery',
                      image: 'assets/images/products/tomato.jpg',
                    ),
                    const SizedBox(width: 10),
                    _buildPrebookingCard(
                      context,
                      ref,
                      crop: 'Green Chilli',
                      variety: 'Balram F1 Mirchi',
                      readyDate: '20-24 Oct 2026',
                      traySize: 104,
                      price: '₹220 / Tray',
                      nursery: 'AVR Green Yeola Central',
                      image: 'assets/images/products/green_chilli.jpg',
                    ),
                    const SizedBox(width: 10),
                    _buildPrebookingCard(
                      context,
                      ref,
                      crop: 'Capsicum',
                      variety: 'Indra Green Polyhouse',
                      readyDate: '25-28 Oct 2026',
                      traySize: 104,
                      price: '₹290 / Tray',
                      nursery: 'Godavari Hi-Tech Polyhouse',
                      image: 'assets/images/products/capsicum.jpg',
                    ),
                  ],
                ),
              ),
            ),

            // ── Section 9: Best Sellers ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: AVRColors.terracotta, size: 18),
                    const SizedBox(width: 4),
                    const Text(
                      'Farmer Best Sellers',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AVRColors.forestGreenDark),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 275,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  scrollDirection: Axis.horizontal,
                  itemCount: bestSellers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final p = bestSellers[index];
                    return SizedBox(
                      width: 165,
                      child: CompactProductCard(product: p, showHotBadge: true),
                    );
                  },
                ),
              ),
            ),

            // ── Section 10: Farmer Nursery Guides ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, color: AVRColors.forestGreen, size: 18),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Commercial Farming & Nursery Guides',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AVRColors.forestGreenDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 28),
                child: Column(
                  children: [
                    _buildGuideItem(
                      title: 'Transplanting 104-Cell Seedling Trays for Maximum Survival',
                      desc: 'Ideal soil moisture, evening planting, and initial root drenching to achieve 98% plant survival in fields.',
                      icon: Icons.spa_rounded,
                      readTime: '3 min read',
                    ),
                    const SizedBox(height: 8),
                    _buildGuideItem(
                      title: 'Hardening Off Polyhouse Plants Before Open Field Sowing',
                      desc: 'Acclimatizing tender seedlings from climate-controlled nurseries to ambient farm sunlight.',
                      icon: Icons.wb_sunny_rounded,
                      readTime: '4 min read',
                    ),
                    const SizedBox(height: 8),
                    _buildGuideItem(
                      title: 'Drip Fertigation & Spacing Table for Chilli and Tomato',
                      desc: 'Standard bed width, row-to-row spacing, and 19:19:19 bio-fertilizer dosage for high yields.',
                      icon: Icons.water_drop_rounded,
                      readTime: '5 min read',
                    ),
                  ],
                ),
              ),
            ),

            // ── Section 11: Real-time Agricultural Calendar & Dispatch Schedule (Section 32)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(14, 0, 14, 16),
                child: RealtimeCalendarWidget(mode: CalendarViewMode.farmer),
              ),
            ),
            // Comfortable bottom padding to ensure zero overlap with mobile navigation bar
            const SliverToBoxAdapter(
              child: SizedBox(height: 72),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section 3: Nursery Discovery Card ───────────────────────────────────────
  Widget _buildNurseryDiscoveryCard(BuildContext context, WidgetRef ref, NurseryModel n) {
    return Container(
      width: 275,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            ref.read(selectedNurseryProvider.notifier).state = n;
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Real Nursery Image Header with Badges
              Stack(
                children: [
                  AppProductImage.nurseryCover(
                    imageUrl: n.imageUrl,
                    height: 75,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
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
                        n.rankingBadge,
                        style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (n.isDemoData)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AVRColors.warning,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'DEMO DATA',
                          style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                ],
              ),

              // Nursery Details Body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  n.name,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AVRColors.forestGreenDark),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (n.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, color: AVRColors.forestGreen, size: 13),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          // Tappable rating → opens Trust Modal
                          GestureDetector(
                            onTap: () => NurseryTrustModal.show(
                              context, n,
                              onBrowseCatalog: () => ref.read(selectedNurseryProvider.notifier).state = n,
                            ),
                            child: Row(
                              children: [
                                Text('⭐ ${n.rating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AVRColors.forestGreenDark)),
                                Text(' (${n.reviewCount})', style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
                                const SizedBox(width: 4),
                                Icon(Icons.info_outline, size: 11, color: Colors.grey.shade500),
                                const Spacer(),
                                if (n.distanceKm != null)
                                  Text('${n.distanceKm!.toStringAsFixed(1)} km', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AVRColors.terracotta)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Activity freshness
                          Row(
                            children: [
                              Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFF40916C), shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Text(n.activityText, style: TextStyle(fontSize: 9.5, color: Colors.grey.shade600)),
                              const Spacer(),
                              Text('${n.activeVarietiesCount}+ Varieties', style: TextStyle(fontSize: 9.5, color: Colors.grey.shade700)),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: n.isOpen ? AVRColors.success : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                n.isOpen ? 'Open Now' : 'Closed',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: n.isOpen ? AVRColors.success : Colors.grey),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Trust info button
                              GestureDetector(
                                onTap: () => NurseryTrustModal.show(
                                  context, n,
                                  onBrowseCatalog: () => ref.read(selectedNurseryProvider.notifier).state = n,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFF2D6A4F).withValues(alpha: 0.4)),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.shield_outlined, size: 11, color: Color(0xFF2D6A4F)),
                                      SizedBox(width: 3),
                                      Text('Trust', style: TextStyle(fontSize: 9.5, color: Color(0xFF2D6A4F), fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AVRColors.forestGreen,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  ref.read(selectedNurseryProvider.notifier).state = n;
                                },
                                child: const Text(
                                  'Browse',
                                  style: TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.bold),
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
            ],
          ),
        ),
      ),
    );
  }

  // ── Section 2.1: Categorized Multi-Type Search Breakdown (Section 13) ────────
  Widget _buildCategorizedSearchResults(
    BuildContext context,
    WidgetRef ref,
    AppLanguage language,
    String query,
    List<Product> products,
    AsyncValue<List<NurseryModel>> nurseriesAsync,
  ) {
    final cleanQ = query.trim().toLowerCase();

    // Find matching crops
    const cropsList = [
      'Tomato', 'Chilli', 'Capsicum', 'Brinjal', 'Cabbage',
      'Cauliflower', 'Marigold', 'Sugarcane', 'Mango', 'Coconut', 'Lemon', 'Tulsi'
    ];
    final matchingCrops = cropsList.where((c) => c.toLowerCase().contains(cleanQ)).toList();

    // Find matching nurseries
    final allNurseries = nurseriesAsync.value ?? [];
    final matchingNurseries = allNurseries.where((n) =>
      n.name.toLowerCase().contains(cleanQ) || n.city.toLowerCase().contains(cleanQ)
    ).toList();

    // Matching products / varieties (top 5)
    final matchingVarieties = products.where((p) =>
      p.variety.toLowerCase().contains(cleanQ) ||
      p.commonName.toLowerCase().contains(cleanQ) ||
      (p.scientificName?.toLowerCase().contains(cleanQ) ?? false)
    ).take(5).toList();

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 4, 14, 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AVRColors.forestGreen.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.manage_search_rounded, size: 18, color: AVRColors.forestGreen),
                    const SizedBox(width: 6),
                    Text(
                      '${AppStrings.get("search_results_title", language)}: "$query"',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AVRColors.forestGreenDark),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    ref.read(searchQueryProvider.notifier).state = '';
                    ref.read(nurserySearchQueryProvider.notifier).state = '';
                  },
                  child: const Text('Clear', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AVRColors.terracotta)),
                ),
              ],
            ),
            const Divider(height: 12),

            // 1. CROPS Section
            if (matchingCrops.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF2D6A4F).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                      child: Text(AppStrings.get('search_type_crop', language), style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF2D6A4F))),
                    ),
                    const SizedBox(width: 6),
                    Text('Matching Crops (${matchingCrops.length})', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: matchingCrops.map((cropName) {
                  return ActionChip(
                    avatar: const Icon(Icons.eco_rounded, size: 14, color: AVRColors.forestGreen),
                    label: Text(cropName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    backgroundColor: const Color(0xFFF1F5F2),
                    side: const BorderSide(color: AVRColors.forestGreen),
                    onPressed: () {
                      ref.read(selectedCropProvider.notifier).state = cropName;
                      ref.read(searchQueryProvider.notifier).state = '';
                      ref.read(nurserySearchQueryProvider.notifier).state = '';
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],

            // 2. NURSERIES Section
            if (matchingNurseries.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                      child: Text(AppStrings.get('search_type_nursery', language), style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                    ),
                    const SizedBox(width: 6),
                    Text('Matching Nurseries (${matchingNurseries.length})', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              ...matchingNurseries.map((n) => ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: const Icon(Icons.storefront_rounded, color: AVRColors.forestGreen, size: 18),
                title: Text(n.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                subtitle: Text('${n.city}${n.distanceKm == null ? '' : ' • ${n.distanceKm!.toStringAsFixed(1)} km'} • ⭐ ${n.rating}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                onTap: () {
                  ref.read(selectedNurseryProvider.notifier).state = n;
                  ref.read(searchQueryProvider.notifier).state = '';
                  ref.read(nurserySearchQueryProvider.notifier).state = '';
                },
              )),
              const SizedBox(height: 8),
            ],

            // 3. VARIETIES Section
            if (matchingVarieties.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(4)),
                      child: Text(AppStrings.get('search_type_variety', language), style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                    ),
                    const SizedBox(width: 6),
                    Text('Matching Varieties (${matchingVarieties.length})', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              ...matchingVarieties.map((p) => ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: const Icon(Icons.grass_rounded, color: AVRColors.terracotta, size: 18),
                title: Text(p.variety, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                subtitle: Text('${p.nurseryName} • ${p.perPlantPriceText} • ${p.readyStock} ready', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                trailing: const Icon(Icons.chevron_right_rounded, size: 16),
                onTap: () => context.push('/catalog/${p.id}'),
              )),
            ],

            if (matchingCrops.isEmpty && matchingNurseries.isEmpty && matchingVarieties.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Text(AppStrings.get('no_varieties_found', language), style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Pre-booking Upcoming Batch Card ─────────────────────────────────────────
  Widget _buildPrebookingCard(
    BuildContext context,
    WidgetRef ref, {
    required String crop,
    required String variety,
    required String readyDate,
    required int traySize,
    required String price,
    required String nursery,
    required String image,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppProductImage.thumbnail(
                imageUrl: image,
                cropName: crop,
                size: 44,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(variety, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(crop, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                    Text('$traySize-Cell Pro-Tray', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: AVRColors.forestGreenDark)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(6)),
            child: Row(
              children: [
                const Icon(Icons.schedule, size: 12, color: Colors.orange),
                const SizedBox(width: 4),
                Text('Ready for Dispatch: $readyDate', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.brown)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(price, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AVRColors.forestGreen)),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  side: const BorderSide(color: AVRColors.forestGreen),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () async {
                  final lang = ref.read(appLanguageProvider);
                  await runWithNetworkRetry(
                    context: context,
                    pendingProcessName: 'Pre-booking $variety batch for $readyDate',
                    language: lang,
                    action: () async {
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AVRColors.forestGreen,
                          content: Text('Pre-booking confirmed for $variety. Expected dispatch: $readyDate.'),
                        ),
                      );
                    },
                  );
                },
                child: const Text('Pre-book', style: TextStyle(fontSize: 10, color: AVRColors.forestGreen, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Network Error Recovery Banner for Nursery Discovery ───────────────────────
  Widget _buildNurseryNetworkErrorCard(BuildContext context, WidgetRef ref, Object err) {
    final language = ref.watch(appLanguageProvider);
    final location = ref.watch(selectedLocationProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AVRColors.terracotta.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AVRColors.terracotta.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.wifi_off_rounded, color: AVRColors.terracotta, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('network_issue_title', language),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AVRColors.forestGreenDark),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Unable to reach live nurseries in ${location.city}. Check connection.',
                      style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  ref.read(allowOfflineDemoNurseriesProvider.notifier).state = true;
                  ref.invalidate(nearbyNurseriesProvider);
                },
                child: const Text('View Offline Demo', style: TextStyle(fontSize: 10.5, color: AVRColors.terracotta, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AVRColors.forestGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  await showNetworkRetryPopup(
                    context: context,
                    pendingProcessName: 'Discovering Nurseries in ${location.displayName}',
                    language: language,
                    onRetry: () async {
                      ref.invalidate(nearbyNurseriesProvider);
                      await ref.read(nearbyNurseriesProvider.future);
                    },
                  );
                },
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: Text(
                  AppStrings.get('try_again', language),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Farmer Guide Card Item ──────────────────────────────────────────────────
  Widget _buildGuideItem({required String title, required String desc, required IconData icon, required String readTime}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AVRColors.forestGreenSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AVRColors.forestGreen, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AVRColors.forestGreenDark),
                      ),
                    ),
                    Text(readTime, style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(desc, style: TextStyle(fontSize: 11, color: Colors.grey.shade700, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Nursery Sort Chip Helper ────────────────────────────────────────────────
  Widget _buildSortChip(WidgetRef ref, String label, String value, String current) {
    final isSelected = current == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AVRColors.forestGreen,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 10.5,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : Colors.grey.shade800,
      ),
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      side: BorderSide(color: isSelected ? AVRColors.forestGreen : Colors.grey.shade300),
      onSelected: (_) {
        ref.read(nurserySortByProvider.notifier).state = value;
      },
    );
  }

  // ── Location Selector Bottom Sheet ──────────────────────────────────────────
  void _showLocationSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (ctx) {
        final current = ref.watch(selectedLocationProvider);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Farming Hub / Location',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AVRColors.forestGreenDark),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Text(
                'Nurseries and available seedling stocks will update automatically for this area.',
                style: TextStyle(fontSize: 11.5, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // ── GPS Device Location Button (Sections 29, 30, 31) ───────────
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AVRColors.forestGreenSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AVRColors.forestGreen.withValues(alpha: 0.3)),
                ),
                child: ListTile(
                  dense: true,
                  leading: const CircleAvatar(
                    backgroundColor: AVRColors.forestGreen,
                    radius: 16,
                    child: Icon(Icons.my_location_rounded, color: Colors.white, size: 16),
                  ),
                  title: const Text(
                    'Use My Current Location (GPS)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AVRColors.forestGreenDark),
                  ),
                  subtitle: const Text(
                    'Reads real coordinates to compute accurate nursery transit distances',
                    style: TextStyle(fontSize: 10.5, color: Colors.black87),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AVRColors.forestGreen),
                  onTap: () => _handleUseMyLocation(context, ctx, ref),
                ),
              ),

              const Divider(height: 16),
              Text(
                'Or select nearest regional farming hub:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
              ...supportedLocations.map((loc) {
                final isSelected = loc.city == current.city;
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  leading: Icon(
                    Icons.location_on,
                    color: isSelected ? AVRColors.forestGreen : Colors.grey.shade400,
                    size: 20,
                  ),
                  title: Text(
                    '${loc.city}, ${loc.district}',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AVRColors.forestGreenDark : AVRColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check, color: AVRColors.forestGreen, size: 18) : null,
                  onTap: () {
                    ref.read(selectedLocationProvider.notifier).state = loc;
                    ref.read(selectedNurseryProvider.notifier).state = null; // reset to show all nurseries for new location
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ── Real-Time Device Location Detection (Sections 29, 30, 31) ──────────────
  Future<void> _handleUseMyLocation(BuildContext context, BuildContext dialogContext, WidgetRef ref) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.location_disabled_rounded, color: AVRColors.warning),
                  SizedBox(width: 8),
                  Text('GPS Service Disabled', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              content: const Text(
                'Location services are turned off on your device. Please turn on GPS to discover nearest nurseries to your farm.',
                style: TextStyle(fontSize: 12),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK', style: TextStyle(color: AVRColors.forestGreen, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied. Please pick a regional hub from the list.'),
                backgroundColor: AVRColors.warning,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.lock_outline_rounded, color: AVRColors.error),
                  SizedBox(width: 8),
                  Text('Location Access Blocked', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              content: const Text(
                'Location permissions are permanently denied in browser/app settings. Please allow location permissions in settings, or select your nearest taluka hub manually.',
                style: TextStyle(fontSize: 12),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AVRColors.forestGreen),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Geolocator.openAppSettings();
                  },
                  child: const Text('Open Settings', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Read real GPS position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      String cityName = 'Current GPS Location';
      String districtName = 'Nashik Region';

      try {
        final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          if (p.locality != null && p.locality!.isNotEmpty) {
            cityName = p.locality!;
          } else if (p.subAdministrativeArea != null && p.subAdministrativeArea!.isNotEmpty) {
            cityName = p.subAdministrativeArea!;
          }
          if (p.subAdministrativeArea != null && p.subAdministrativeArea!.isNotEmpty) {
            districtName = p.subAdministrativeArea!;
          } else if (p.administrativeArea != null) {
            districtName = p.administrativeArea!;
          }
        }
      } catch (_) {
        cityName = 'GPS (${position.latitude.toStringAsFixed(2)}°N, ${position.longitude.toStringAsFixed(2)}°E)';
      }

      final realLoc = FarmerLocation(
        city: cityName,
        district: districtName,
        state: 'Maharashtra',
        lat: position.latitude,
        lng: position.longitude,
      );

      ref.read(selectedLocationProvider.notifier).state = realLoc;
      ref.read(selectedNurseryProvider.notifier).state = null;
      ref.invalidate(nearbyNurseriesProvider);

      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.my_location, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('📍 Location updated: $cityName ($districtName)'),
                ),
              ],
            ),
            backgroundColor: AVRColors.forestGreen,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not obtain GPS location: $e. You can choose a regional hub below.'),
            backgroundColor: AVRColors.warning,
          ),
        );
      }
    }
  }

  // ── Live Nursery Production Broadcasts & Announcements Banner ───────────────
  Widget _buildLiveAnnouncementsBanner(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<NurseryAnnouncementModel>> announcementsAsync,
    List<Product> allProducts,
  ) {
    return SliverToBoxAdapter(
      child: announcementsAsync.when(
        data: (announcements) {
          if (announcements.isEmpty) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.fromLTRB(14, 8, 14, 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF1F8F1), Color(0xFFFFF9E6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AVRColors.forestGreen.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AVRColors.forestGreen,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Live Nursery Production Updates',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AVRColors.forestGreenDark,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'BROADCAST',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 138,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: announcements.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (ctx, idx) {
                      final item = announcements[idx];
                      return Container(
                        width: 290,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: AVRColors.forestGreenDark,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      item.nurseryName ?? 'AVR Green Nursery',
                                      style: TextStyle(fontSize: 9.5, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.content,
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade800, height: 1.25),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (item.readyQuantity != null && item.readyQuantity! > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AVRColors.forestGreenSurface,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '✓ ${item.readyQuantity} ready',
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AVRColors.forestGreenDark),
                                    ),
                                  ),
                                if (item.futureQuantity != null && item.futureQuantity! > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '⏳ Next: ${item.futureQuantity} (${item.expectedDays ?? 10}d)',
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                                    ),
                                  ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE65100),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    visualDensity: VisualDensity.compact,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    final matchedProduct = allProducts.firstWhere(
                                      (p) =>
                                          p.variety.toLowerCase().contains((item.variety ?? '').toLowerCase()) ||
                                          p.crop.toLowerCase().contains((item.crop ?? '').toLowerCase()),
                                      orElse: () => allProducts.first,
                                    );
                                    FarmerPreBookingModal.show(context, matchedProduct);
                                  },
                                  child: const Text('Pre-Book', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  // ── Transparent Ranking Explanation Modal ───────────────────────────────────
  void _showRankingExplanationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.military_tech_rounded, color: AVRColors.forestGreen),
            SizedBox(width: 8),
            Text('Nursery Ranking Criteria', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AVR Green Nursery uses a transparent, data-driven ranking model to help farmers find the best local seed providers:',
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
            SizedBox(height: 10),
            Text('1. Proximity to Farm (35%)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text('Nurseries closest to your farm or selected taluka are prioritized to ensure fresh seedling transit.', style: TextStyle(fontSize: 11, color: Colors.grey)),
            SizedBox(height: 6),
            Text('2. Official Verified Status (25%)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text('Nurseries with verified polyhouse facilities, certified seed source, and active business registration.', style: TextStyle(fontSize: 11, color: Colors.grey)),
            SizedBox(height: 6),
            Text('3. Active Variety Breadth (20%)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text('Number of live vegetable, fruit, and commercial crop seedling varieties available in ready stock.', style: TextStyle(fontSize: 11, color: Colors.grey)),
            SizedBox(height: 6),
            Text('4. Farmer Ratings & Reviews (20%)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text('Authentic post-delivery ratings and reviews submitted by commercial farmers.', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it', style: TextStyle(color: AVRColors.forestGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Farmer Special Offers & Campaigns Section (Sections 4, 7, 8, 10) ────────
  Widget _buildFarmerSpecialOffersSection(BuildContext context, AsyncValue<List<NurseryOffer>> offersAsync) {
    return offersAsync.when(
      data: (offers) {
        if (offers.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AVRColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.local_offer_rounded, color: AVRColors.warning, size: 16),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Farmer Special Offers',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AVRColors.forestGreenDark,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => context.push('/offers'),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Row(
                          children: [
                            Text(
                              'View All (${offers.length})',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AVRColors.forestGreen,
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, size: 16, color: AVRColors.forestGreen),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 155,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: offers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    return _buildStorefrontOfferCard(context, offer);
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: SizedBox(
          height: 80,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AVRColors.forestGreen),
            ),
          ),
        ),
      ),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }

  Widget _buildStorefrontOfferCard(BuildContext context, NurseryOffer offer) {
    return Container(
      width: 285,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: offer.discountType == 'PERCENTAGE'
              ? AVRColors.warning.withValues(alpha: 0.6)
              : AVRColors.forestGreen.withValues(alpha: 0.35),
          width: 1.2,
        ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.store_rounded, size: 14, color: AVRColors.forestGreen),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        offer.nurseryName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AVRColors.forestGreenDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE89620), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  offer.discountBadgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (offer.festivalEventLabel != null && offer.festivalEventLabel!.isNotEmpty)
                Text(
                  '🌿 ${offer.festivalEventLabel!.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AVRColors.terracotta,
                    letterSpacing: 0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              Text(
                offer.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AVRColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                offer.applicableCrops.isNotEmpty
                    ? 'For ${offer.applicableCrops.join(", ")} seedlings'
                    : (offer.shortDescription ?? 'Exclusive farmer discount'),
                style: TextStyle(
                  fontSize: 10.5,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule, size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Ends ${offer.endDate.day} ${_monthName(offer.endDate.month)}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AVRColors.forestGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  visualDensity: VisualDensity.compact,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  context.push('/offers');
                },
                child: Text(
                  offer.isPrebooking ? 'Pre-Book' : 'Shop Offer',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }
}
