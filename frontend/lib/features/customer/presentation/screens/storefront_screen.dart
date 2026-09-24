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
import '../../data/providers/cart_provider.dart';
import '../../data/providers/marketplace_provider.dart';

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

    // Derived product collections for Farmer Home sections
    final readyStockProducts = allProducts.where((p) => p.isReadyStock).toList();
    final prebookingProducts = allProducts.where((p) => p.isPrebooking).toList();
    final bestSellers = allProducts.take(6).toList();
    final featuredVarieties = allProducts.take(8).toList();

    final categories = marketplaceCategories;

    final popularCrops = [
      {'crop': 'all', 'label': 'All Crops', 'local': 'सर्व पिके', 'emoji': '🌱'},
      {'crop': 'Chilli', 'label': 'Chilli', 'local': 'मिरची / Mirchi', 'emoji': '🌶'},
      {'crop': 'Tomato', 'label': 'Tomato', 'local': 'टोमॅटो / Tamatar', 'emoji': '🍅'},
      {'crop': 'Capsicum', 'label': 'Capsicum', 'local': 'शिमला / Shimla', 'emoji': '🫑'},
      {'crop': 'Brinjal', 'label': 'Brinjal', 'local': 'वांगी / Baingan', 'emoji': '🍆'},
      {'crop': 'Cabbage', 'label': 'Cabbage', 'local': 'कोबी / Gobhi', 'emoji': '🥬'},
      {'crop': 'Cauliflower', 'label': 'Cauliflower', 'local': 'फ्लॉवर / Phool', 'emoji': '🥦'},
      {'crop': 'Marigold', 'label': 'Marigold', 'local': 'झेंडू / Genda', 'emoji': '🌼'},
      {'crop': 'Sugarcane', 'label': 'Sugarcane', 'local': 'ऊस / Ganna', 'emoji': '🎋'},
      {'crop': 'Lemon', 'label': 'Lemon', 'local': 'लिंबू / Nimbu', 'emoji': '🍋'},
    ];

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
                              '${selectedNursery.city} • ${selectedNursery.distanceKm} km away • ⭐ ${selectedNursery.rating} (${selectedNursery.reviewCount})',
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
                  'Popular Agricultural Crops (Nashik Region)',
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
                        ref.read(selectedCropProvider.notifier).state = c['crop']!;
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
                            Text(c['emoji']!, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c['label']!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : AVRColors.textPrimary,
                                  ),
                                ),
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
                    const Text(
                      'Featured Varieties',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AVRColors.forestGreenDark),
                    ),
                    Text(
                      '${featuredVarieties.length} available',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

            // High-density 2-column Compact Marketplace Grid (Sections 6 & 21)
            featuredVarieties.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No varieties found matching criteria')),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.58,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = featuredVarieties[index];
                          return CompactProductCard(product: product);
                        },
                        childCount: featuredVarieties.length,
                      ),
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
                  height: 255,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    scrollDirection: Axis.horizontal,
                    itemCount: readyStockProducts.take(8).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                height: 255,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: bestSellers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                            Text('${n.distanceKm} km', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AVRColors.terracotta)),
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
}
