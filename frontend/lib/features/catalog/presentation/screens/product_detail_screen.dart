import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer/data/providers/cart_provider.dart';
import '../../data/models/product_model.dart';
import '../../data/providers/catalog_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Visual Commercial Product Details Screen — Mobile-First
// ─────────────────────────────────────────────────────────────────────────────

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogListProvider).value ?? defaultBotanicalCatalog;
    final product = catalog.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => defaultBotanicalCatalog.first,
    );
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Large Product Image Header ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 330,
                pinned: true,
                elevation: 0,
                backgroundColor: AVRColors.forestGreen,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
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
                          backgroundColor: Colors.white.withValues(alpha: 0.9),
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
                      Image.asset(
                        product.primaryImageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AVRColors.sageSurface,
                          child: const Icon(Icons.eco_rounded, size: 80, color: AVRColors.forestGreen),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.35),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.50),
                            ],
                          ),
                        ),
                      ),
                      // Top Badges
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AVRColors.forestGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                product.badgeText,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                product.categoryName,
                                style: const TextStyle(color: AVRColors.forestGreenDark, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Plant Information & Commercial Specs ─────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Crop & Variety Hierarchy Breadcrumb
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AVRColors.sageSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '🌱 Crop: ${product.crop} • Variety: ${product.variety} • Nursery: ${product.nurseryName}',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AVRColors.forestGreenDark),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Name & Rating
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.commonName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AVRColors.forestGreenDark,
                                    height: 1.2,
                                  ),
                                ),
                                if (product.scientificName != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    product.scientificName!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9E6),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFFD56B)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.star_rounded, color: Color(0xFFE5A100), size: 16),
                                SizedBox(width: 2),
                                Text(
                                  '4.9',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF7A5600)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Price & In-Stock Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '₹${product.price.toStringAsFixed(product.price % 1 == 0 ? 0 : 2)}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: AVRColors.forestGreen,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '/ ${product.unitLabel}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: product.availableStock > 0 ? const Color(0xFFE8F6ED) : const Color(0xFFFDECEB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  product.availableStock > 0 ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                  color: product.availableStock > 0 ? AVRColors.success : AVRColors.error,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  product.availableStock > 0
                                      ? '${product.availableStock} in Stock'
                                      : 'Currently Unavailable',
                                  style: TextStyle(
                                    color: product.availableStock > 0 ? AVRColors.success : AVRColors.error,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Selling Unit / Pack Configuration Pills (Section 9)
                      const Text(
                        'Select Selling Unit & Pack Size:',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AVRColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildUnitChip('🌱 1 Seedling', '₹${product.price.toStringAsFixed(0)}', true),
                          _buildUnitChip('📦 Pack of 50', '₹${(product.price * 50 * 0.95).toStringAsFixed(0)}', false),
                          _buildUnitChip('🪴 104-Cell Tray', '₹${(product.price * 104 * 0.90).toStringAsFixed(0)}', false),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Bulk Quote Action Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9E6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFD56B)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.agriculture_rounded, color: AVRColors.warning, size: 24),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Commercial Farm Order (1,000+ Seedlings)?',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7A5600)),
                                  ),
                                  Text(
                                    'Get special farm-gate wholesale rates directly from nursery.',
                                    style: TextStyle(fontSize: 10.5, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => _showBulkQuoteDialog(context, product),
                              child: const Text('Request Quote', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AVRColors.forestGreenDark)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Farmer-Friendly Key Specifications ──────────────────────────
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Plant & Farming Characteristics',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AVRColors.forestGreenDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildSpecChip('Sunlight', product.sunlightLabel, Icons.wb_sunny_outlined),
                                const SizedBox(width: 10),
                                _buildSpecChip('Watering', product.wateringLabel, Icons.water_drop_outlined),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Row(
                              children: [
                                _buildSpecChip('Season', product.seasonLabel, Icons.calendar_today_outlined),
                                const SizedBox(width: 10),
                                _buildSpecChip('Growth', 'Rapid Growth 🌿', Icons.trending_up_rounded),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ── Description ───────────────────────────────────────────────
                      if (product.description != null) ...[
                        const Text(
                          'About this Plant',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AVRColors.forestGreenDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          product.description!,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // ── Nursery Care & Sowing Guide ───────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AVRColors.forestGreenSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AVRColors.sage.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.eco_rounded, color: AVRColors.forestGreen, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Nursery Planting & Care Guide',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AVRColors.forestGreenDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildCareRow('Sunlight requirement', product.care.sunlight),
                            _buildCareRow('Watering schedule', product.care.watering),
                            _buildCareRow('Fertilizer schedule', product.care.fertilizer),
                            _buildCareRow('Ideal temperature', product.care.temperature),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Sticky Bottom Cart Bar ──────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Quantity selector
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18, color: AVRColors.forestGreen),
                            onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                          ),
                          Text(
                            '$quantity',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18, color: AVRColors.forestGreen),
                            onPressed: () => setState(() => quantity++),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Add to Cart Button
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AVRColors.forestGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          onPressed: product.availableStock > 0
                              ? () => _handleDetailAddToCart(context, product)
                              : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Add  •  ₹${(product.price * quantity).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  void _handleDetailAddToCart(BuildContext context, ProductModel product) {
    final result = ref.read(cartProvider.notifier).addItem(product, quantity: quantity);

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
                ref.read(cartProvider.notifier).clearAndAdd(product, quantity: quantity);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AVRColors.forestGreen,
                    content: Text('Switched to ${product.nurseryName} and added $quantity x ${product.commonName}'),
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
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Added $quantity x ${product.commonName} (${product.variety}) to cart'),
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

  Widget _buildUnitChip(String title, String price, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AVRColors.forestGreen : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? AVRColors.forestGreen : Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AVRColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            price,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white70 : AVRColors.forestGreen,
            ),
          ),
        ],
      ),
    );
  }

  void _showBulkQuoteDialog(BuildContext context, ProductModel product) {
    final phoneCtrl = TextEditingController(text: '9900000005');
    final qtyCtrl = TextEditingController(text: '1000');
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.agriculture_rounded, color: AVRColors.forestGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Request Bulk Quote: ${product.crop}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nursery: ${product.nurseryName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('Variety: ${product.variety}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
              const SizedBox(height: 12),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Required Plants/Seedlings', hintText: 'e.g. 1000, 2500'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Contact Phone Number'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Farm Location / Delivery Notes'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AVRColors.forestGreen),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AVRColors.forestGreen,
                  content: Text('Bulk quote request for ${qtyCtrl.text} ${product.crop} plants sent to ${product.nurseryName}!'),
                ),
              );
            },
            child: const Text('Submit Quote Request', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecChip(String title, String val, IconData icon) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AVRColors.forestGreen),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    val,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AVRColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareRow(String label, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AVRColors.forestGreen, fontWeight: FontWeight.bold)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12.5, color: AVRColors.textPrimary, height: 1.4),
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: detail),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
