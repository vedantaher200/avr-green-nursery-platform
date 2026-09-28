import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/offer_model.dart';
import '../../data/providers/offers_provider.dart';
import '../../../catalog/data/providers/catalog_provider.dart';

class FarmerOffersScreen extends ConsumerStatefulWidget {
  const FarmerOffersScreen({super.key});

  @override
  ConsumerState<FarmerOffersScreen> createState() => _FarmerOffersScreenState();
}

class _FarmerOffersScreenState extends ConsumerState<FarmerOffersScreen> {
  String _selectedCropFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final offersAsync = ref.watch(marketplaceOffersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_offer_rounded, color: AVRColors.forestGreen, size: 20),
            SizedBox(width: 8),
            Text(
              'Farmer Offers & Campaigns',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.5, color: AVRColors.forestGreenDark),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AVRColors.forestGreen),
            tooltip: 'Refresh Offers',
            onPressed: () => ref.invalidate(marketplaceOffersProvider),
          ),
        ],
      ),
      body: offersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AVRColors.forestGreen),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 40, color: AVRColors.error),
              const SizedBox(height: 8),
              Text('Unable to load offers: $err'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(marketplaceOffersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (offers) {
          final crops = ['All', ...offers.map((o) => o.applicableCrop).whereType<String>().toSet()];
          final filteredOffers = _selectedCropFilter == 'All'
              ? offers
              : offers.where((o) => o.applicableCrop?.toLowerCase() == _selectedCropFilter.toLowerCase()).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── 1. Hero Campaign Banner ───────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AVRColors.forestGreenDark, Color(0xFF1B4D31)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AVRColors.forestGreenDark.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD98E27),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'OFFICIAL NURSERY CAMPAIGNS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Verified Plantation Discounts',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Save on bulk seedling trays and advance crop bookings directly from verified regional nurseries.',
                              style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.25),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.celebration_rounded, color: Color(0xFFEAB308), size: 30),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 2. Crop Filter Rail ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  height: 38,
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: crops.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final crop = crops[index];
                      final isSelected = _selectedCropFilter == crop;
                      return ChoiceChip(
                        label: Text(crop),
                        selected: isSelected,
                        selectedColor: AVRColors.forestGreen,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AVRColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11,
                        ),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(
                          color: isSelected ? AVRColors.forestGreen : Colors.grey.shade300,
                        ),
                        onSelected: (_) {
                          setState(() => _selectedCropFilter = crop);
                        },
                      );
                    },
                  ),
                ),
              ),

              // ── 3. Offers List ────────────────────────────────────────────
              if (filteredOffers.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_offer_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'No active offers found for $_selectedCropFilter',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final offer = filteredOffers[index];
                        return _buildOfferCard(context, ref, offer);
                      },
                      childCount: filteredOffers.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, WidgetRef ref, NurseryOffer offer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AVRColors.borderPromotional.withValues(alpha: 0.65), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AVRColors.goldDark.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Event Label & Discount Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAF8),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      offer.eventLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AVRColors.forestGreenDark,
                      ),
                    ),
                    if (offer.isPrebookingOffer) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AVRColors.terracotta.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PRE-BOOK',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            color: AVRColors.terracotta,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD98E27),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    offer.discountLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Offer Title
                Text(
                  offer.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AVRColors.textPrimary,
                  ),
                ),
                if (offer.shortDescription != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    offer.shortDescription!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.3,
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Participating Nursery
                Row(
                  children: [
                    const Icon(Icons.storefront_rounded, size: 14, color: AVRColors.forestGreen),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${offer.nurseryName} (${offer.nurseryCity})',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AVRColors.forestGreenDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (offer.nurseryIsVerified)
                      const Icon(Icons.verified, size: 13, color: AVRColors.forestGreen),
                    const SizedBox(width: 6),
                    Text(
                      '⭐ ${offer.nurseryRating.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Applicable Crop & Terms Badges
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (offer.applicableCrop != null)
                      _buildChip(
                        icon: Icons.eco_outlined,
                        label: 'Crop: ${offer.applicableCrop}',
                        color: AVRColors.forestGreen,
                      ),
                    if (offer.minQuantity > 1)
                      _buildChip(
                        icon: Icons.shopping_basket_outlined,
                        label: 'Min ${offer.minQuantity} Trays',
                        color: Colors.grey.shade700,
                      ),
                    if (offer.minOrderValue > 0)
                      _buildChip(
                        icon: Icons.currency_rupee,
                        label: 'Min ₹${offer.minOrderValue.toStringAsFixed(0)}',
                        color: Colors.grey.shade700,
                      ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Footer Row: Countdown & CTA Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: Color(0xFFD98E27)),
                        const SizedBox(width: 4),
                        Text(
                          offer.validityText,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD98E27),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AVRColors.forestGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () {
                        // Apply crop filter in catalog and navigate
                        if (offer.applicableCrop != null) {
                          ref.read(selectedCropProvider.notifier).state = offer.applicableCrop!;
                        }
                        context.push('/catalog');
                      },
                      icon: Icon(
                        offer.isPrebookingOffer ? Icons.event_available : Icons.shopping_cart_checkout,
                        size: 14,
                      ),
                      label: Text(
                        offer.isPrebookingOffer ? 'Pre-Book Offer' : 'Shop Offer',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
