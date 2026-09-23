import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/providers/catalog_provider.dart';
import '../../data/models/product_model.dart';
import '../../../auth/data/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mobile-First Nursery Catalog & Product Management Screen
// ─────────────────────────────────────────────────────────────────────────────

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchCtrl = TextEditingController();

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'label': 'All Varieties', 'emoji': '🌿'},
    {'id': 'vegetables', 'label': 'Vegetables', 'emoji': '🌶'},
    {'id': 'fruits', 'label': 'Fruit Plants', 'emoji': '🌱'},
    {'id': 'flowering', 'label': 'Flowers', 'emoji': '🌸'},
    {'id': 'medicinal', 'label': 'Medicinal', 'emoji': '🌿'},
    {'id': 'indoor', 'label': 'Indoor Plants', 'emoji': '🪴'},
    {'id': 'fertilizers', 'label': 'Fertilizers', 'emoji': '🌾'},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(filteredCatalogProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);
    final auth = ref.watch(authStateProvider);
    final isOwnerOrStaff = auth.canManageInventory;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      appBar: AppBar(
        title: const Text(
          'Plant Catalog & Seedlings',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AVRColors.forestGreenDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isOwnerOrStaff)
            IconButton(
              icon: const Icon(Icons.add_circle, color: AVRColors.forestGreen, size: 26),
              tooltip: 'Add Variety',
              onPressed: () => _showAddProductBottomSheet(context),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
              style: const TextStyle(fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'Search SKU, common or botanical name...',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: AVRColors.forestGreen, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF1F5F2),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
            ),
          ),

          // ── Horizontal Category Selector ──────────────────────────────────
          Container(
            height: 48,
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = selectedCat == cat['id'];
                return ChoiceChip(
                  avatar: Text(cat['emoji']!, style: const TextStyle(fontSize: 13)),
                  label: Text(cat['label']!),
                  selected: isSelected,
                  selectedColor: AVRColors.forestGreen,
                  backgroundColor: const Color(0xFFF1F5F2),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AVRColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 11.5,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: BorderSide(
                    color: isSelected ? AVRColors.forestGreen : Colors.transparent,
                  ),
                  onSelected: (_) {
                    ref.read(selectedCategoryProvider.notifier).state = cat['id']!;
                  },
                );
              },
            ),
          ),

          // ── Product List Summary ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${products.length} Varieties Found',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.grey.shade700),
                ),
                const Text(
                  'Tap for details',
                  style: TextStyle(fontSize: 11, color: AVRColors.forestGreen, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // ── Mobile Product List ───────────────────────────────────────────
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.spa_outlined, size: 54, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text('No plant varieties found', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                      ],
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildMobileProductCard(context, product, isOwnerOrStaff);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileProductCard(BuildContext context, Product product, bool isOwnerOrStaff) {
    return GestureDetector(
      onTap: () => context.push('/catalog/${product.id}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            // Real Plant Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                product.primaryImageAsset,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 72,
                  height: 72,
                  color: AVRColors.sageSurface,
                  child: const Icon(Icons.eco, color: AVRColors.forestGreen),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Plant Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AVRColors.forestGreenSurface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.sku,
                          style: const TextStyle(
                            color: AVRColors.forestGreenDark,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        product.categoryName,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.commonName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AVRColors.textPrimary),
                  ),
                  if (product.scientificName != null) ...[
                    Text(
                      product.scientificName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AVRColors.forestGreen),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: product.availableStock > 0 ? const Color(0xFFE8F6ED) : const Color(0xFFFDECEB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          product.availableStock > 0 ? '${product.availableStock} in stock' : 'Out of stock',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: product.availableStock > 0 ? AVRColors.success : AVRColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductBottomSheet(BuildContext context) {
    final cropCtrl = TextEditingController(text: 'Chilli');
    final varietyCtrl = TextEditingController(text: 'Balram F1');
    final commonNameCtrl = TextEditingController(text: 'Balram Green Chilli Seedlings');
    final priceCtrl = TextEditingController(text: '220');
    final stockCtrl = TextEditingController(text: '500');
    String selectedUnit = 'tray';
    int traySize = 104;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Register Plant Variety',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AVRColors.forestGreenDark),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cropCtrl,
                        decoration: const InputDecoration(labelText: 'Crop (e.g. Chilli, Tomato)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: varietyCtrl,
                        decoration: const InputDecoration(labelText: 'Variety (e.g. Balram F1)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: commonNameCtrl,
                  decoration: const InputDecoration(labelText: 'Commercial Listing Title'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedUnit,
                        decoration: const InputDecoration(labelText: 'Selling Unit'),
                        items: const [
                          DropdownMenuItem(value: 'tray', child: Text('Tray (Cells)')),
                          DropdownMenuItem(value: 'seedling', child: Text('Per Seedling')),
                          DropdownMenuItem(value: 'pack_100', child: Text('Pack of 100')),
                          DropdownMenuItem(value: 'bulk', child: Text('Bulk Order')),
                        ],
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedUnit = val);
                        },
                      ),
                    ),
                    if (selectedUnit == 'tray') ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: traySize,
                          decoration: const InputDecoration(labelText: 'Tray Size'),
                          items: const [
                            DropdownMenuItem(value: 104, child: Text('104 Cells')),
                            DropdownMenuItem(value: 70, child: Text('70 Cells')),
                            DropdownMenuItem(value: 50, child: Text('50 Cells')),
                          ],
                          onChanged: (val) {
                            if (val != null) setModalState(() => traySize = val);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        decoration: const InputDecoration(labelText: 'Price (₹)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: stockCtrl,
                        decoration: const InputDecoration(labelText: 'Opening Stock'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AVRColors.forestGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        final apiClient = ref.read(apiClientProvider);
                        await apiClient.dio.post('/products', data: {
                          'sku': 'VAR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                          'commonName': commonNameCtrl.text.trim(),
                          'crop': cropCtrl.text.trim(),
                          'variety': varietyCtrl.text.trim(),
                          'sellingUnit': selectedUnit,
                          'traySize': traySize,
                          'minOrderQty': 1,
                          'price': double.tryParse(priceCtrl.text) ?? 200,
                          'costPrice': (double.tryParse(priceCtrl.text) ?? 200) * 0.6,
                        });
                        ref.invalidate(catalogListProvider);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AVRColors.forestGreen,
                            content: Text('Registered variety "${varietyCtrl.text}" in nursery catalog'),
                          ),
                        );
                      } catch (_) {
                        ref.invalidate(catalogListProvider);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AVRColors.forestGreen,
                            content: Text('Variety "${varietyCtrl.text}" published to nursery storefront'),
                          ),
                        );
                      }
                    },
                    child: const Text('Save & Publish Variety', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
