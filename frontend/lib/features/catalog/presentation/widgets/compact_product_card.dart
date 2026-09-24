import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_product_image.dart';
import '../../../customer/data/providers/cart_provider.dart';
import '../../../customer/presentation/widgets/farmer_prebooking_modal.dart';
import '../../../customer/presentation/widgets/notify_me_modal.dart';
import '../../data/models/product_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Amazon-Style Compact Farmer Marketplace Product Card
// High information density, zero dead whitespace, 4-6 cards visible on screen.
// ─────────────────────────────────────────────────────────────────────────────

class CompactProductCard extends ConsumerWidget {
  final Product product;
  final bool showHotBadge;

  const CompactProductCard({
    super.key,
    required this.product,
    this.showHotBadge = false,
  });

  Color _getStockBadgeColor(String state) {
    switch (state) {
      case 'limited_stock':
        return const Color(0xFFD97706);
      case 'coming_soon':
        return const Color(0xFF0284C7);
      case 'prebook_available':
        return const Color(0xFFEA580C);
      case 'sold_out':
        return Colors.grey.shade600;
      case 'ready_now':
      default:
        return AVRColors.success;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrebookMode = product.isPrebookAvailable || product.isComingSoon || (product.readyStock == 0 && product.isPrebookable);
    final isSoldOut = product.isSoldOut || (product.readyStock == 0 && !product.isPrebookable);

    return GestureDetector(
      onTap: () => context.push('/catalog/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Controlled Image Thumbnail (Aspect Ratio: 1.35) ─────────────
            AspectRatio(
              aspectRatio: 1.35,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppProductImage.card(
                    imagePath: product.primaryImageAsset,
                    crop: product.crop,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                  ),
                  // Crop badge overlay
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.crop,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Availability Indicator (5 Official Stock States)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: _getStockBadgeColor(product.stockState),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.stockBadgeLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Compact Card Body (Zero Dead Whitespace) ────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Variety Name
                    Text(
                      product.variety,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                        color: AVRColors.textPrimary,
                        height: 1.15,
                      ),
                    ),

                    // Nursery Name
                    Row(
                      children: [
                        const Icon(Icons.storefront_rounded, size: 10.5, color: AVRColors.forestGreen),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            product.nurseryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: AVRColors.forestGreenDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Rating & Stock Row
                    Row(
                      children: [
                        Text(
                          '⭐ ${product.nurseryRating.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            '(${product.reviewCount})',
                            style: TextStyle(fontSize: 8.5, color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            product.isReadyStock ? '• ${product.readyStock} ready' : '• Batch: ${product.futureStock}',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: product.isReadyStock ? AVRColors.forestGreen : const Color(0xFFEA580C),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Pricing Information (Per Plant & Per Tray)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.perPlantPriceText,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AVRColors.forestGreenDark,
                          ),
                        ),
                        if (product.effectiveTrayPrice != null)
                          Text(
                            '₹${product.effectiveTrayPrice!.toStringAsFixed(0)} / tray (${product.trayCapacity} plants)',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),

                    // Stock & Price Freshness
                    if (product.stockFreshnessText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            Icon(Icons.update, size: 9, color: Colors.grey.shade500),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                product.stockFreshnessText!,
                                style: TextStyle(fontSize: 8.5, color: Colors.grey.shade500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Dynamic Action Button: [+ Add Cart] or [PRE-BOOK NOW] or [Sold Out]
                    SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: isSoldOut
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A5568),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                elevation: 0,
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () => NotifyMeModal.show(context, product),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.notifications_outlined, size: 11),
                                  SizedBox(width: 3),
                                  Text('Notify Me', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            )
                          : isPrebookMode
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE65100),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    elevation: 0,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () => FarmerPreBookingModal.show(context, product),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.event_available_rounded, size: 12),
                                      SizedBox(width: 3),
                                      Text(
                                        'PRE-BOOK NOW',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                                      ),
                                    ],
                                  ),
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AVRColors.forestGreen,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    elevation: 0,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () => _handleAddToCart(context, ref, product),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_shopping_cart_rounded, size: 12),
                                      SizedBox(width: 3),
                                      Text(
                                        '+ Add Cart',
                                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                ),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AVRColors.forestGreen,
                    content: Text('Switched to ${product.nurseryName} and added ${product.variety}'),
                  ),
                );
              },
              child: const Text('Clear & Switch', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Added ${product.variety} (${product.perPlantPriceText}) to cart',
                  style: const TextStyle(fontSize: 11.5),
                ),
              ),
            ],
          ),
          backgroundColor: AVRColors.forestGreenDark,
          action: SnackBarAction(
            label: 'CART',
            textColor: AVRColors.sageLight,
            onPressed: () => context.push('/cart'),
          ),
        ),
      );
    }
  }
}
