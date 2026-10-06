import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/app_product_image.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../customer/data/providers/cart_provider.dart';
import '../../../customer/presentation/widgets/farmer_prebooking_modal.dart';
import '../../../customer/presentation/widgets/notify_me_modal.dart';
import '../../data/models/product_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Premium Compact Agricultural Marketplace Product Card
// Content-driven, zero dead whitespace, responsive, high trust hierarchy.
// ─────────────────────────────────────────────────────────────────────────────

class CompactProductCard extends ConsumerWidget {
  final Product product;
  final bool showHotBadge;

  const CompactProductCard({
    super.key,
    required this.product,
    this.showHotBadge = false,
  });

  String _getStockBadgeText(String state, AppLanguage lang) {
    switch (state) {
      case 'limited_stock':
        return AppStrings.get('limited_stock', lang);
      case 'coming_soon':
        return AppStrings.get('coming_soon', lang);
      case 'prebook_available':
        return AppStrings.get('prebook_available', lang);
      case 'sold_out':
        return AppStrings.get('sold_out', lang);
      case 'ready_now':
      default:
        return AppStrings.get('ready_now', lang);
    }
  }

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
    final language = ref.watch(appLanguageProvider);
    final isPrebookMode = product.isPrebookAvailable || product.isComingSoon || (product.readyStock == 0 && product.isPrebookable);
    final isSoldOut = product.isSoldOut || (product.readyStock == 0 && !product.isPrebookable);

    return InkWell(
      onTap: () => context.push('/catalog/${product.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AVRColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Controlled Image Thumbnail (Aspect Ratio: 1.45) ───────────
            AspectRatio(
              aspectRatio: 1.45,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppProductImage.card(
                    imagePath: product.primaryImageAsset,
                    crop: product.crop,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
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
                  // Availability Indicator (Official Stock State)
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
                        _getStockBadgeText(product.stockState, language),
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

            // ── 2. Compact Card Content (Tight, Content-Driven Spacing) ───────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 5, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 3),

                    // Nursery Name & Verified Badge
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
                        if (product.nurseryVerified)
                          const Padding(
                            padding: EdgeInsets.only(left: 2),
                            child: Icon(Icons.verified, size: 10, color: AVRColors.forestGreen),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Rating & Stock Row
                    Row(
                      children: [
                        Text(
                          '⭐ ${product.nurseryRating.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 9.5,
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
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: product.isReadyStock ? AVRColors.forestGreen : const Color(0xFFEA580C),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Pricing Information (Per Plant & Per Tray)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.perPlantPriceText,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: AVRColors.forestGreenDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (product.effectiveTrayPrice != null)
                          Text(
                            '₹${product.effectiveTrayPrice!.toStringAsFixed(0)} / tray (${product.trayCapacity} plants)',
                            style: TextStyle(
                              fontSize: 8.5,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),

                    // Stock Freshness
                    if (product.stockFreshnessText != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.update, size: 8.5, color: Colors.grey.shade500),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              product.stockFreshnessText!,
                              style: TextStyle(fontSize: 8, color: Colors.grey.shade500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const Spacer(),

                    // ── Dynamic Action Button ─────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 27,
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.notifications_outlined, size: 11),
                                  const SizedBox(width: 3),
                                  Text(AppStrings.get('notify_me', language), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.event_available_rounded, size: 12),
                                      const SizedBox(width: 3),
                                      Text(
                                        AppStrings.get('prebook_now', language),
                                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 0.3),
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
                                  onPressed: () => _handleAddToCart(context, ref),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.add_shopping_cart, size: 12),
                                      const SizedBox(width: 3),
                                      Text(
                                        language == AppLanguage.mr
                                            ? '+ कार्टमध्ये जोडा'
                                            : (language == AppLanguage.hi ? '+ कार्ट में जोड़ें' : '+ Add Cart'),
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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

  void _handleAddToCart(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider);

    if (cart.hasDifferentNursery(product.tenantId)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(ref.tr('different_nursery'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          content: Text(
            '${ref.tr('different_nursery_msg')}\n(${product.nurseryName})',
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(ref.tr('keep_current_cart')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AVRColors.forestGreen),
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(cartProvider.notifier).clearAndAdd(product);
                AppFeedback.showCartSuccess(
                  context,
                  message: '${product.nurseryName} - ${product.variety}',
                  onGoToCart: () => context.push('/cart'),
                );
              },
              child: Text(ref.tr('clear_and_switch'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      ref.read(cartProvider.notifier).addItem(product);
      AppFeedback.showCartSuccess(
        context,
        message: 'Added ${product.variety} (${product.perPlantPriceText}) to cart',
        onGoToCart: () => context.push('/cart'),
      );
    }
  }
}
