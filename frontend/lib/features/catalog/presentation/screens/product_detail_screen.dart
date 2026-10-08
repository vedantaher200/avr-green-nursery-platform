import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/app_product_image.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../customer/data/providers/cart_provider.dart';
import '../../../customer/presentation/widgets/farmer_prebooking_modal.dart';
import '../../data/models/product_model.dart';
import '../../data/providers/catalog_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Commercial Product Detail Screen — Farmer Marketplace
// Complete pricing tiers, configurable tray capacities, and reliable agronomy
// ─────────────────────────────────────────────────────────────────────────────

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String _selectedUnit = 'tray'; // 'plant', 'tray', 'bulk'
  int _quantity = 1;
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final catalogState = ref.watch(catalogListProvider);
    if (catalogState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (catalogState.hasError) {
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.get('nav_catalog', language))),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(AppStrings.get('marketplace_unavailable', language)),
            const SizedBox(height: 8),
            TextButton(
                onPressed: () => ref.invalidate(catalogListProvider),
                child: Text(AppStrings.get('retry', language))),
          ]),
        ),
      );
    }
    final catalog = catalogState.valueOrNull ?? const <Product>[];
    final matchingProducts =
        catalog.where((item) => item.id == widget.productId);
    if (matchingProducts.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.get('nav_catalog', language))),
        body: Center(child: Text(AppStrings.get('no_products_found', language))),
      );
    }
    final product = matchingProducts.first;
    final cart = ref.watch(cartProvider);
    final gallery = product.galleryImages;
    final currentImage = _selectedImageIndex < gallery.length
        ? gallery[_selectedImageIndex]
        : product.primaryImageAsset;

    // Calculate total price based on selected unit and quantity
    double calculatedTotal;
    int totalPlantsCount;
    if (_selectedUnit == 'tray') {
      calculatedTotal = (product.effectiveTrayPrice ??
              (product.effectivePlantPrice * product.trayCapacity)) *
          _quantity;
      totalPlantsCount = product.trayCapacity * _quantity;
    } else if (_selectedUnit == 'bulk') {
      final bulkRate =
          product.effectiveBulkPrice ?? (product.effectivePlantPrice * 0.85);
      final bulkPlants = _quantity * 1000;
      calculatedTotal = bulkRate * bulkPlants;
      totalPlantsCount = bulkPlants;
    } else {
      calculatedTotal = product.effectivePlantPrice *
          (_quantity * 10); // minimum 10 plants for single order
      totalPlantsCount = _quantity * 10;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── 1. Controlled Hero Image Header (Max 260dp) ────────────────
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                elevation: 0,
                backgroundColor: AVRColors.forestGreen,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.92),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: AVRColors.forestGreenDark, size: 20),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white.withValues(alpha: 0.92),
                          child: IconButton(
                            icon: const Icon(Icons.shopping_bag_outlined,
                                color: AVRColors.forestGreenDark, size: 20),
                            onPressed: () => context.push('/cart'),
                          ),
                        ),
                        if (cart.totalItemCount > 0)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AVRColors.terracotta,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                  minWidth: 16, minHeight: 16),
                              child: Text(
                                '${cart.totalItemCount}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppProductImage.hero(
                        imagePath: currentImage,
                        crop: product.crop,
                        height: 260,
                        onTap: () => AppProductImage.showImageProvenance(
                            context, currentImage),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.30),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.60),
                            ],
                          ),
                        ),
                      ),
                      // Top Badges & Photo Provenance
                      Positioned(
                        bottom: 14,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AVRColors.forestGreen,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  product.crop,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => AppProductImage.showImageProvenance(
                                  context, currentImage),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.4)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified_rounded,
                                        size: 12, color: AVRColors.sageLight),
                                    SizedBox(width: 4),
                                    Text(
                                      'Photo Info',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 2. Product Information & Pricing Tiers ────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Variety Name
                      Text(
                        product.variety,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AVRColors.forestGreenDark,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${product.commonName} • ${product.scientificName ?? "Commercial Horticultural Variety"}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),

                      // ── Interactive Detail Gallery Thumbnails ───────────────
                      if (gallery.length > 1) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Perspectives (${_selectedImageIndex + 1}/${gallery.length})',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade700),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => AppProductImage.showImageProvenance(
                                  context, currentImage),
                              child: const Text(
                                'Photo Provenance',
                                style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: AVRColors.forestGreen),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 52,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: gallery.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, idx) {
                              final isSelected = _selectedImageIndex == idx;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedImageIndex = idx),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? AVRColors.forestGreen
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: AppProductImage.galleryThumb(
                                    imagePath: gallery[idx],
                                    isSelected: isSelected,
                                    size: 48,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ] else ...[
                        const SizedBox(height: 2),
                      ],

                      // Nursery info card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AVRColors.forestGreenSurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.storefront_rounded,
                                  color: AVRColors.forestGreen, size: 20),
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
                                          product.nurseryName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: AVRColors.forestGreenDark,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.verified,
                                          color: AVRColors.forestGreen,
                                          size: 14),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        '⭐ ${product.nurseryRating.toStringAsFixed(1)}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber.shade900),
                                      ),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: Text(
                                          '(${product.reviewCount} reviews)',
                                          style: TextStyle(
                                              fontSize: 10.5,
                                              color: Colors.grey.shade600),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (product.productRating != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF9C4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Product ⭐ ${product.productRating!.toStringAsFixed(1)}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown.shade900),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Section 12: Variety → Multiple Nurseries Comparison ───────
                      _buildMultipleNurseryComparison(
                          context, product, catalog, language),
                      const SizedBox(height: 16),

                      // ── 3. Transparent Price Breakdown (Per Plant / Tray / Bulk) ──
                      Text(
                        AppStrings.get('pricing_tiers', language),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AVRColors.forestGreenDark),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildPriceCard(
                            title: AppStrings.get('per_plant', language),
                            price: product.perPlantPriceText,
                            subtitle: AppStrings.get('min_10_plants', language),
                            unitKey: 'plant',
                          ),
                          const SizedBox(width: 8),
                          _buildPriceCard(
                            title: AppStrings.get('pro_tray', language),
                            price: product.effectiveTrayPrice != null
                                ? '₹${product.effectiveTrayPrice!.toStringAsFixed(0)}'
                                : 'N/A',
                            subtitle: '${product.trayCapacity} ${AppStrings.get('plants_per_tray', language)}',
                            unitKey: 'tray',
                            isPopular: true,
                          ),
                          const SizedBox(width: 8),
                          _buildPriceCard(
                            title: AppStrings.get('bulk_qty', language),
                            price: product.effectiveBulkPrice != null
                                ? '₹${product.effectiveBulkPrice!.toStringAsFixed(2)}/plant'
                                : 'N/A',
                            subtitle: AppStrings.get('bulk_seedlings_sub', language),
                            unitKey: 'bulk',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Configurable Tray Capacity Banner
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AVRColors.forestGreenSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color:
                                  AVRColors.forestGreen.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.grid_4x4_rounded,
                                size: 16, color: AVRColors.forestGreen),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Configured Nursery Tray Capacity: ${product.trayCapacity} Plants / Pro-Tray',
                                style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: AVRColors.forestGreenDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── 4. Stock & Pre-Booking Availability ───────────────────────
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.inventory_2_rounded,
                                          size: 16,
                                          color: AVRColors.forestGreen),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          AppStrings.get('stock_dispatch_sched', language),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: product.isReadyStock
                                        ? AVRColors.success
                                            .withValues(alpha: 0.12)
                                        : const Color(0xFFFFF3E0),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: product.isReadyStock
                                          ? AVRColors.success
                                          : const Color(0xFFE65100),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    product.localizedStockBadgeLabel(language),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                      color: product.isReadyStock
                                          ? AVRColors.success
                                          : const Color(0xFFE65100),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FBF8),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                                Icons.check_circle_outline,
                                                size: 13,
                                                color: AVRColors.forestGreen),
                                            const SizedBox(width: 4),
                                            Text(AppStrings.get('ready_now', language),
                                                style: TextStyle(
                                                    fontSize: 10.5,
                                                    color: Colors.grey.shade600,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${product.readyStock} Plants',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AVRColors.forestGreenDark),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF9F0),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.amber.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.schedule_rounded,
                                                size: 13,
                                                color: Color(0xFFE65100)),
                                            const SizedBox(width: 4),
                                            Text(AppStrings.get('next_batch', language),
                                                style: TextStyle(
                                                    fontSize: 10.5,
                                                    color:
                                                        Colors.brown.shade700,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${product.futureStock} Plants',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFE65100)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F8F1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month_outlined,
                                      size: 15, color: AVRColors.forestGreen),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${AppStrings.get('expected_dispatch', language)}: ${product.readyDate.isNotEmpty ? product.readyDate : "In 10 days"}',
                                      style: const TextStyle(
                                          fontSize: 11.5,
                                          color: AVRColors.forestGreenDark,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE65100),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      visualDensity: VisualDensity.compact,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      elevation: 0,
                                    ),
                                    onPressed: () => FarmerPreBookingModal.show(
                                        context, product),
                                    child: Text(AppStrings.get('prebook_now', language),
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── 5. Quantity Selector & Calculation ────────────────────────
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.get('order_qty_units', language),
                                style: TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 13)),
                            const SizedBox(height: 8),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      onPressed: _quantity > 1
                                          ? () => setState(() => _quantity--)
                                          : null,
                                      icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: AVRColors.forestGreen),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF6F8F5),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: Text(
                                        '$_quantity ${_selectedUnit == "tray" ? "Tray(s)" : _selectedUnit == "bulk" ? "Lot(s)" : "Pack(s)"}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.5),
                                      ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () =>
                                          setState(() => _quantity++),
                                      icon: const Icon(Icons.add_circle_outline,
                                          color: AVRColors.forestGreen),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        'Total: ₹${calculatedTotal.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: AVRColors.forestGreenDark)),
                                    Text('($totalPlantsCount Total Seedlings)',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── 6. Reliable Agricultural Growing Information ──────────────
                      Text(
                        AppStrings.get('agronomy_title', language),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AVRColors.forestGreenDark),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAgronomyRow(
                                Icons.wb_sunny_outlined,
                                AppStrings.get('season', language),
                                product.agronomy.season),
                            const Divider(height: 14),
                            _buildAgronomyRow(
                                Icons.thermostat_rounded,
                                AppStrings.get('temperature', language),
                                product.agronomy.temperature),
                            const Divider(height: 14),
                            _buildAgronomyRow(
                                Icons.water_drop_outlined,
                                AppStrings.get('watering', language),
                                product.agronomy.waterRequirement),
                            const Divider(height: 14),
                            _buildAgronomyRow(
                                Icons.wb_sunny_rounded,
                                AppStrings.get('sunlight', language),
                                product.agronomy.sunlight),
                            const Divider(height: 14),
                            _buildAgronomyRow(
                                Icons.terrain_rounded,
                                AppStrings.get('soil', language),
                                product.agronomy.soil),
                            const Divider(height: 14),
                            _buildAgronomyRow(
                                Icons.agriculture_rounded,
                                AppStrings.get('transplanting', language),
                                product.agronomy.transplanting),
                            const Divider(height: 14),
                            _buildAgronomyRow(
                                Icons.straighten_rounded,
                                AppStrings.get('spacing', language),
                                product.agronomy.spacing),
                            const Divider(height: 14),
                            _buildAgronomyRow(
                                Icons.eco_rounded,
                                AppStrings.get('expected_yield', language),
                                product.agronomy.expectedYield),
                            const Divider(height: 14),
                            _buildAgronomyRow(
                                Icons.schedule_rounded,
                                AppStrings.get('harvest_days', language),
                                product.agronomy.harvestDays),
                            const Divider(height: 14),
                            _buildAgronomyRow(
                                Icons.shield_outlined,
                                AppStrings.get('basic_care', language),
                                product.agronomy.basicCare),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // About this Variety
                      Text(AppStrings.get('about_this_variety', language),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AVRColors.forestGreenDark)),
                      const SizedBox(height: 6),
                      Text(
                        product.description ??
                            'High-performance commercial seedling cultivated in disease-free climate controlled polyhouses. Bred for strong root development, uniform growth, and maximum market yield.',
                        style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade700,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Sticky Bottom Action Bar: Add to Cart & Buy Now ─────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          side: const BorderSide(
                              color: AVRColors.forestGreen, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.add_shopping_cart,
                            color: AVRColors.forestGreen, size: 16),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(AppStrings.get('add_to_cart', language),
                              style: const TextStyle(
                                  color: AVRColors.forestGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                        onPressed: () => _handleAddToCart(product, false),
                      ),
                    ),
                    if (product.isPrebookable || product.futureStock > 0) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 5,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE65100),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.event_available_rounded,
                              size: 16),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(AppStrings.get('prebook_now', language),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          onPressed: () =>
                              FarmerPreBookingModal.show(context, product),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AVRColors.forestGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.flash_on_rounded, size: 16),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(AppStrings.get('buy_now', language),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        onPressed: () => _handleAddToCart(product, true),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard({
    required String title,
    required String price,
    required String subtitle,
    required String unitKey,
    bool isPopular = false,
  }) {
    final isSelected = _selectedUnit == unitKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedUnit = unitKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AVRColors.forestGreenSurface : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AVRColors.forestGreen : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AVRColors.forestGreenDark
                      : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                price,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AVRColors.forestGreenDark),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgronomyRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AVRColors.forestGreen),
        const SizedBox(width: 8),
        SizedBox(
          width: 110,
          child: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  color: AVRColors.textPrimary)),
        ),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontSize: 11.5, color: Colors.grey.shade800, height: 1.3)),
        ),
      ],
    );
  }

  void _handleAddToCart(Product product, bool buyNow) {
    final result = ref.read(cartProvider.notifier).addItem(product);

    if (result == CartAddResult.nurseryConflict) {
      final cart = ref.read(cartProvider);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AVRColors.warning),
              const SizedBox(width: 8),
              Text(ref.tr('different_nursery'),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            '${ref.tr('cart_contains_plants_from')} "${cart.currentNurseryName}".\n\n${ref.tr('single_nursery_rule_msg')}',
            style: const TextStyle(fontSize: 12.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(ref.tr('keep_current_cart')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AVRColors.forestGreen),
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(cartProvider.notifier).clearAndAdd(product);
                if (buyNow) {
                  context.push('/checkout');
                } else {
                  AppFeedback.showCartSuccess(
                    context,
                    message:
                        'Switched to ${product.nurseryName} and added ${product.variety}',
                    onGoToCart: () => context.push('/cart'),
                  );
                }
              },
              child: Text(ref.tr('clear_and_switch'),
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      if (buyNow) {
        context.push('/checkout');
      } else {
        ref.read(cartProvider.notifier).addItem(product);
        AppFeedback.showCartSuccess(
          context,
          message:
              'Added ${product.variety} (${product.perPlantPriceText}) to cart',
          onGoToCart: () => context.push('/cart'),
        );
      }
    }
  }

  Widget _buildMultipleNurseryComparison(
    BuildContext context,
    Product currentProduct,
    List<Product> catalog,
    AppLanguage language,
  ) {
    // Look for other nurseries selling this variety or crop (Section 12)
    final exactVarietyMatches = catalog
        .where((p) =>
            p.id != currentProduct.id &&
            p.variety.toLowerCase().trim() ==
                currentProduct.variety.toLowerCase().trim())
        .toList();

    final alternativeOffers = exactVarietyMatches.isNotEmpty
        ? exactVarietyMatches
        : catalog
            .where((p) =>
                p.id != currentProduct.id &&
                p.crop.toLowerCase().trim() ==
                    currentProduct.crop.toLowerCase().trim() &&
                p.nurseryName != currentProduct.nurseryName)
            .take(3)
            .toList();

    if (alternativeOffers.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AVRColors.forestGreen.withValues(alpha: 0.25)),
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
            children: [
              const Icon(Icons.compare_arrows_rounded,
                  color: AVRColors.forestGreen, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  AppStrings.get('compare_nurseries', language),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AVRColors.forestGreenDark),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AVRColors.forestGreenSurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${alternativeOffers.length} Nurseries',
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AVRColors.forestGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Compare price, nursery rating, and dispatch readiness for this crop across verified regional nurseries:',
            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
          ),
          const Divider(height: 14),
          ...alternativeOffers.map((alt) {
            final isLowerPrice =
                alt.effectivePlantPrice < currentProduct.effectivePlantPrice;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBF8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                alt.nurseryName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AVRColors.forestGreenDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (alt.nurseryVerified) ...[
                              const SizedBox(width: 3),
                              const Icon(Icons.verified,
                                  size: 12, color: AVRColors.forestGreen),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text('⭐ ${alt.nurseryRating.toStringAsFixed(1)}',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade900)),
                            Text('• ${alt.readyStock} ready',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AVRColors.forestGreen,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            alt.perPlantPriceText,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: isLowerPrice
                                  ? AVRColors.forestGreenDark
                                  : AVRColors.textPrimary,
                            ),
                          ),
                          if (isLowerPrice) ...[
                            const SizedBox(width: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color:
                                    AVRColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Lower',
                                  style: TextStyle(
                                      fontSize: 8.5,
                                      color: AVRColors.success,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 24,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 0),
                            side: const BorderSide(
                                color: AVRColors.forestGreen, width: 1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                          ),
                          onPressed: () => context.push('/catalog/${alt.id}'),
                          child: Text(AppStrings.get('view_offer', language),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AVRColors.forestGreen,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
