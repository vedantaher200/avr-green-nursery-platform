import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_product_image.dart';
import '../../../../core/localization/app_strings.dart';
import '../../data/providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AVRColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              ref.tr('my_garden_cart'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AVRColors.textPrimary),
            ),
            if (!cart.isEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AVRColors.forestGreenSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${cart.totalItemCount} items',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AVRColors.forestGreen),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!cart.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              tooltip: ref.tr('clear_cart_tooltip'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Text(ref.tr('clear_cart_dialog_title')),
                    content: Text(ref.tr('clear_cart_dialog_msg')),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text(ref.tr('cancel'))),
                      TextButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).clearCart();
                          Navigator.pop(ctx);
                        },
                        child: Text(ref.tr('clear_all'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: cart.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: const BoxDecoration(
                        color: AVRColors.forestGreenSurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shopping_basket_outlined, size: 72, color: AVRColors.forestGreen),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      ref.tr('cart_empty_title'),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AVRColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ref.tr('cart_empty_sub'),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AVRColors.forestGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () => context.go('/storefront'),
                      icon: const Icon(Icons.spa_outlined),
                      label: Text(ref.tr('browse_storefront_btn'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Free Delivery Progress Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: cart.deliveryFee == 0 ? AVRColors.forestGreenSurface : Colors.amber.shade50,
                  child: Row(
                    children: [
                      Icon(
                        cart.deliveryFee == 0 ? Icons.check_circle : Icons.local_shipping_outlined,
                        size: 20,
                        color: cart.deliveryFee == 0 ? AVRColors.forestGreen : Colors.amber.shade800,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          cart.deliveryFee == 0
                              ? '🎉 You unlocked FREE Farm-Direct Nursery Delivery!'
                              : 'Add ₹${(500 - cart.subtotal).clamp(0, 500).toStringAsFixed(0)} more for FREE Nursery Delivery!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cart.deliveryFee == 0 ? AVRColors.forestGreenDark : Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Fulfilling Nursery Banner
                if (cart.currentNurseryName != null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AVRColors.forestGreen.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.storefront, color: AVRColors.forestGreen, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Fulfilling Nursery: ${cart.currentNurseryName}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AVRColors.forestGreenDark),
                          ),
                        ),
                        const Icon(Icons.verified, color: AVRColors.forestGreen, size: 14),
                      ],
                    ),
                  ),

                // Cart Items List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Botanical Seedling Photograph
                            AppProductImage.thumbnail(
                              imageUrl: item.product.primaryImageAsset,
                              cropName: item.product.crop,
                              size: 72,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            const SizedBox(width: 12),

                            // Item details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.commonName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.product.categoryName,
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        '₹${item.product.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AVRColors.forestGreen,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Total: ₹${item.totalPrice.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Stepper Controls
                            Container(
                              decoration: BoxDecoration(
                                color: AVRColors.backgroundLight,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 16),
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    color: item.quantity == 1 ? Colors.redAccent : Colors.grey.shade700,
                                    onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.product.id, -1),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      '${item.quantity}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 16),
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    color: AVRColors.forestGreen,
                                    onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.product.id, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Order Summary Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSummaryRow(ref.tr('subtotal'), '₹${cart.subtotal.toStringAsFixed(2)}'),
                        const SizedBox(height: 6),
                        _buildSummaryRow(ref.tr('gst'), '₹${cart.gst.toStringAsFixed(2)}'),
                        const SizedBox(height: 6),
                        _buildSummaryRow(
                          ref.tr('delivery_fee'),
                          cart.deliveryFee == 0 ? 'FREE' : '₹${cart.deliveryFee.toStringAsFixed(2)}',
                          highlight: cart.deliveryFee == 0,
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ref.tr('total'), style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                Text(
                                  '₹${cart.grandTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AVRColors.forestGreen),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AVRColors.terracotta,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              onPressed: () => context.push('/checkout'),
                              icon: const Icon(Icons.arrow_forward, size: 18),
                              label: Text(
                                ref.tr('checkout'),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: highlight ? AVRColors.success : AVRColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
