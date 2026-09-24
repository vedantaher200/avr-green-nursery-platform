import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_product_image.dart';
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
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String _selectedUnit = 'tray'; // 'plant', 'tray', 'bulk'
  int _quantity = 1;
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogListProvider).value ?? defaultBotanicalCatalog;
    final product = catalog.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => defaultBotanicalCatalog.first,
    );
    final cart = ref.watch(cartProvider);
    final gallery = product.galleryImages;
    final currentImage = _selectedImageIndex < gallery.length ? gallery[_selectedImageIndex] : product.primaryImageAsset;

    // Calculate total price based on selected unit and quantity
    double calculatedTotal;
    int totalPlantsCount;
    if (_selectedUnit == 'tray') {
      calculatedTotal = (product.effectiveTrayPrice ?? (product.effectivePlantPrice * product.trayCapacity)) * _quantity;
      totalPlantsCount = product.trayCapacity * _quantity;
    } else if (_selectedUnit == 'bulk') {
      final bulkRate = product.effectiveBulkPrice ?? (product.effectivePlantPrice * 0.85);
      final bulkPlants = _quantity * 1000;
      calculatedTotal = bulkRate * bulkPlants;
      totalPlantsCount = bulkPlants;
    } else {
      calculatedTotal = product.effectivePlantPrice * (_quantity * 10); // minimum 10 plants for single order
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
                      icon: const Icon(Icons.arrow_back_rounded, color: AVRColors.forestGreenDark, size: 20),
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
                            icon: const Icon(Icons.shopping_bag_outlined, color: AVRColors.forestGreenDark, size: 20),
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
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              child: Text(
                                '${cart.totalItemCount}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
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
                        onTap: () => AppProductImage.showImageProvenance(context, currentImage),
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
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AVRColors.forestGreen,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  product.crop,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => AppProductImage.showImageProvenance(context, currentImage),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified_rounded, size: 12, color: AVRColors.sageLight),
                                    SizedBox(width: 4),
                                    Text(
                                      'Photo Info',
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
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
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey.shade700),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => AppProductImage.showImageProvenance(context, currentImage),
                              child: const Text(
                                'Photo Provenance',
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AVRColors.forestGreen),
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
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, idx) {
                              final isSelected = _selectedImageIndex == idx;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedImageIndex = idx),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected ? AVRColors.forestGreen : Colors.grey.shade300,
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
                              child: const Icon(Icons.storefront_rounded, color: AVRColors.forestGreen, size: 20),
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
                                      const Icon(Icons.verified, color: AVRColors.forestGreen, size: 14),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        '⭐ ${product.nurseryRating.toStringAsFixed(1)}',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                                      ),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: Text(
                                          '(${product.reviewCount} reviews)',
                                          style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF9C4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Product ⭐ ${product.productRating!.toStringAsFixed(1)}',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown.shade900),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── 3. Transparent Price Breakdown (Per Plant / Tray / Bulk) ──
                      const Text(
                        'Commercial Pricing Tiers',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AVRColors.forestGreenDark),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildPriceCard(
                            title: 'Per Plant',
                            price: product.perPlantPriceText,
                            subtitle: 'Min 10 plants',
                            unitKey: 'plant',
                          ),
                          const SizedBox(width: 8),
                          _buildPriceCard(
                            title: 'Pro-Tray',
                            price: product.effectiveTrayPrice != null ? '₹${product.effectiveTrayPrice!.toStringAsFixed(0)}' : 'N/A',
                            subtitle: '${product.trayCapacity} plants/tray',
                            unitKey: 'tray',
                            isPopular: true,
                          ),
                          const SizedBox(width: 8),
                          _buildPriceCard(
                            title: 'Bulk Quantity',
                            price: product.effectiveBulkPrice != null ? '₹${product.effectiveBulkPrice!.toStringAsFixed(2)}/plant' : 'N/A',
                            subtitle: '1,000+ seedlings',
                            unitKey: 'bulk',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Configurable Tray Capacity Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AVRColors.forestGreenSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AVRColors.forestGreen.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.grid_4x4_rounded, size: 16, color: AVRColors.forestGreen),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Configured Nursery Tray Capacity: ${product.trayCapacity} Plants / Pro-Tray',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AVRColors.forestGreenDark),
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
                                      const Icon(Icons.inventory_2_rounded, size: 16, color: AVRColors.forestGreen),
                                      const SizedBox(width: 6),
                                      const Flexible(
                                        child: Text(
                                          'Stock & Dispatch Schedule',
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: product.isReadyStock ? AVRColors.success.withValues(alpha: 0.12) : const Color(0xFFFFF3E0),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: product.isReadyStock ? AVRColors.success : const Color(0xFFE65100),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    product.stockBadgeLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                      color: product.isReadyStock ? AVRColors.success : const Color(0xFFE65100),
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
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.check_circle_outline, size: 13, color: AVRColors.forestGreen),
                                            const SizedBox(width: 4),
                                            Text('Ready Stock', style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${product.readyStock} Plants',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AVRColors.forestGreenDark),
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
                                      border: Border.all(color: Colors.amber.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.schedule_rounded, size: 13, color: Color(0xFFE65100)),
                                            const SizedBox(width: 4),
                                            Text('Next Batch', style: TextStyle(fontSize: 10.5, color: Colors.brown.shade700, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${product.futureStock} Plants',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F8F1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month_outlined, size: 15, color: AVRColors.forestGreen),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Expected Dispatch: ${product.readyDate.isNotEmpty ? product.readyDate : "In 10 days"}',
                                      style: const TextStyle(fontSize: 11.5, color: AVRColors.forestGreenDark, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE65100),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      visualDensity: VisualDensity.compact,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      elevation: 0,
                                    ),
                                    onPressed: () => FarmerPreBookingModal.show(context, product),
                                    child: const Text('PRE-BOOK NOW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
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
                            const Text('Order Quantity & Units', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
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
                                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                      icon: const Icon(Icons.remove_circle_outline, color: AVRColors.forestGreen),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF6F8F5),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Text(
                                        '$_quantity ${_selectedUnit == "tray" ? "Tray(s)" : _selectedUnit == "bulk" ? "Lot(s)" : "Pack(s)"}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                                      ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => setState(() => _quantity++),
                                      icon: const Icon(Icons.add_circle_outline, color: AVRColors.forestGreen),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Total: ₹${calculatedTotal.toStringAsFixed(0)}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AVRColors.forestGreenDark)),
                                    Text('($totalPlantsCount Total Seedlings)',
                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── 6. Reliable Agricultural Growing Information ──────────────
                      const Text(
                        'Field Agronomy & Growing Information',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AVRColors.forestGreenDark),
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
                            _buildAgronomyRow(Icons.wb_sunny_outlined, 'Season', product.agronomy.season),
                            const Divider(height: 14),
                            _buildAgronomyRow(Icons.thermostat_rounded, 'Temperature', product.agronomy.temperature),
                            const Divider(height: 14),
                            _buildAgronomyRow(Icons.water_drop_outlined, 'Water Requirement', product.agronomy.waterRequirement),
                            const Divider(height: 14),
                            _buildAgronomyRow(Icons.wb_sunny_rounded, 'Sunlight', product.agronomy.sunlight),
                            const Divider(height: 14),
                            _buildAgronomyRow(Icons.terrain_rounded, 'Soil Type', product.agronomy.soil),
                            const Divider(height: 14),
                            _buildAgronomyRow(Icons.agriculture_rounded, 'Transplanting Age', product.agronomy.transplanting),
                            const Divider(height: 14),
                            _buildAgronomyRow(Icons.straighten_rounded, 'Field Spacing', product.agronomy.spacing),
                            const Divider(height: 14),
                            _buildAgronomyRow(Icons.eco_rounded, 'Expected Yield', product.agronomy.expectedYield),
                            const Divider(height: 14),
                            _buildAgronomyRow(Icons.schedule_rounded, 'Days to Harvest', product.agronomy.harvestDays),
                            const Divider(height: 14),
                            _buildAgronomyRow(Icons.shield_outlined, 'Basic Field Care', product.agronomy.basicCare),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // About this Variety
                      const Text('About This Variety', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AVRColors.forestGreenDark)),
                      const SizedBox(height: 6),
                      Text(
                        product.description ??
                            'High-performance commercial seedling cultivated in disease-free climate controlled polyhouses. Bred for strong root development, uniform growth, and maximum market yield.',
                        style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.4),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AVRColors.forestGreen, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.add_shopping_cart, color: AVRColors.forestGreen, size: 16),
                        label: const Text('Add to Cart', style: TextStyle(color: AVRColors.forestGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: () => _handleAddToCart(product, false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE65100),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.event_available_rounded, size: 16),
                        label: const Text('Pre-Book Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: () => FarmerPreBookingModal.show(context, product),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AVRColors.forestGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.flash_on_rounded, size: 16),
                        label: const Text('Buy Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                  color: isSelected ? AVRColors.forestGreenDark : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                price,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: AVRColors.forestGreenDark),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 9, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
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
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5, color: AVRColors.textPrimary)),
        ),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade800, height: 1.3)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AVRColors.warning),
              SizedBox(width: 8),
              Text('Switch Nursery Cart?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Your cart currently contains plants from "${cart.currentNurseryName}".\n\nTo order from "${product.nurseryName}", would you like to clear your current cart and start an order with this nursery?',
            style: const TextStyle(fontSize: 12.5),
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
                if (buyNow) {
                  context.push('/checkout');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AVRColors.forestGreen,
                      content: Text('Switched to ${product.nurseryName} and added ${product.variety}'),
                    ),
                  );
                }
              },
              child: const Text('Clear & Switch', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      if (buyNow) {
        context.push('/checkout');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('Added ${product.variety} to cart', style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            backgroundColor: AVRColors.forestGreenDark,
            action: SnackBarAction(
              label: 'VIEW CART',
              textColor: AVRColors.sageLight,
              onPressed: () => context.push('/cart'),
            ),
          ),
        );
      }
    }
  }
}
