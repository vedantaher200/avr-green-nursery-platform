import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/providers/catalog_provider.dart';
import '../widgets/compact_product_card.dart';
import '../../../customer/data/providers/cart_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Amazon-Style Compact Farmer Product Marketplace Screen
// Category → Crop → Variety → Product with High Density Grid Scrolling
// ─────────────────────────────────────────────────────────────────────────────

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(filteredCatalogProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedCrop = ref.watch(selectedCropProvider);
    final cropOptions = ref.watch(categoryCropsProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_rounded, color: AVRColors.forestGreen, size: 20),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Farmer Marketplace',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.5, color: AVRColors.forestGreenDark),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined, color: AVRColors.forestGreenDark, size: 24),
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
      ),
      body: Column(
        children: [
          // ── 1. Compact Search Bar ──────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search variety (e.g. Abhinav, Balram, Indra)...',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12.5),
                prefixIcon: const Icon(Icons.search_rounded, color: AVRColors.forestGreen, size: 19),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF1F5F2),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),

          // ── 2. Primary Category Horizontal Rail ────────────────────────────
          Container(
            height: 42,
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 6),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: marketplaceCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final cat = marketplaceCategories[index];
                final isSelected = selectedCategory == cat.id;
                return ChoiceChip(
                  avatar: Text(cat.emoji, style: const TextStyle(fontSize: 11)),
                  label: Text(cat.label),
                  selected: isSelected,
                  selectedColor: AVRColors.forestGreen,
                  backgroundColor: const Color(0xFFF1F5F2),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AVRColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 11,
                  ),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(color: isSelected ? AVRColors.forestGreen : Colors.transparent),
                  onSelected: (_) {
                    ref.read(selectedCategoryProvider.notifier).state = cat.id;
                    ref.read(selectedCropProvider.notifier).state = 'all'; // reset crop when category changes
                  },
                );
              },
            ),
          ),

          // ── 3. Category → Crop Filter Rail ──────────────────────────────────
          if (cropOptions.length > 1)
            Container(
              height: 38,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cropOptions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 5),
                itemBuilder: (context, index) {
                  final item = cropOptions[index];
                  final isSelected = selectedCrop.toLowerCase() == item['crop']!.toLowerCase();
                  return ChoiceChip(
                    avatar: Text(item['emoji']!, style: const TextStyle(fontSize: 10)),
                    label: Text(item['label']!),
                    selected: isSelected,
                    selectedColor: AVRColors.forestGreenDark,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade800,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 10.5,
                    ),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(
                      color: isSelected ? AVRColors.forestGreenDark : Colors.grey.shade300,
                    ),
                    onSelected: (_) {
                      ref.read(selectedCropProvider.notifier).state = item['crop']!;
                    },
                  );
                },
              ),
            ),

          // ── 4. Compact Results Header ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${products.length} Varieties Available',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    selectedCrop != 'all' ? 'Filtering: $selectedCrop' : 'All Regional Varieties',
                    style: const TextStyle(fontSize: 10.5, color: AVRColors.forestGreen, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),

          // ── 5. Compact 2-Column Responsive Marketplace Grid ───────────────
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'No varieties found matching your criteria',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () {
                            ref.read(selectedCategoryProvider.notifier).state = 'all';
                            ref.read(selectedCropProvider.notifier).state = 'all';
                            _searchCtrl.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                          child: const Text('Reset All Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.58, // High density card aspect ratio
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return CompactProductCard(product: product);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
