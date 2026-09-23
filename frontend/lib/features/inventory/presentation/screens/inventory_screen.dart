import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../catalog/data/providers/catalog_provider.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _selectedLocation = 'Central Nursery & Greenhouse';
  String _filter = 'all'; // all, low_stock
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogListProvider).value ?? defaultBotanicalCatalog;

    final displayedItems = catalog.where((item) {
      if (_filter == 'low_stock' && item.availableStock >= 50) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return item.commonName.toLowerCase().contains(query) ||
            (item.scientificName?.toLowerCase().contains(query) ?? false) ||
            item.sku.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AVRColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Nursery Seedling Stock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AVRColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.location_on_outlined, color: AVRColors.forestGreen),
            tooltip: 'Select Greenhouse / Nursery Branch',
            onSelected: (loc) => setState(() => _selectedLocation = loc),
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'Central Nursery & Greenhouse',
                child: Text('Central Nursery & Greenhouse'),
              ),
              const PopupMenuItem(
                value: 'Polyhouse Facility Unit-2',
                child: Text('Polyhouse Facility Unit-2'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Location Indicator Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AVRColors.forestGreenSurface,
                child: Row(
                  children: [
                    const Icon(Icons.storefront, color: AVRColors.forestGreen, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Active Facility: $_selectedLocation',
                        style: const TextStyle(color: AVRColors.forestGreenDark, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              // KPI Stats Header Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        'Total Seedling SKUs',
                        '${catalog.length} Varieties',
                        Icons.inventory_2_outlined,
                        AVRColors.forestGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        'Low Stock Alert',
                        '${catalog.where((p) => p.availableStock < 50).length} Varieties',
                        Icons.warning_amber_rounded,
                        AVRColors.warning,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar & Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search variety, SKU or category...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: AVRColors.forestGreen),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All Seedlings'),
                      selected: _filter == 'all',
                      selectedColor: AVRColors.forestGreenSurface,
                      side: BorderSide(color: _filter == 'all' ? AVRColors.forestGreen : Colors.grey.shade300),
                      labelStyle: TextStyle(
                        color: _filter == 'all' ? AVRColors.forestGreenDark : AVRColors.textPrimary,
                        fontWeight: _filter == 'all' ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _filter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Low Stock (< 50) ⚠️'),
                      selected: _filter == 'low_stock',
                      selectedColor: Colors.amber.shade100,
                      side: BorderSide(color: _filter == 'low_stock' ? Colors.amber.shade800 : Colors.grey.shade300),
                      labelStyle: TextStyle(
                        color: _filter == 'low_stock' ? Colors.amber.shade900 : AVRColors.textPrimary,
                        fontWeight: _filter == 'low_stock' ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _filter = 'low_stock'),
                    ),
                  ],
                ),
              ),

              // Inventory List
              Expanded(
                child: displayedItems.isEmpty
                    ? Center(
                        child: Text(
                          'No seedling varieties match "$_searchQuery"',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: displayedItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = displayedItems[index];
                          final isLowStock = item.availableStock < 50;

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isLowStock ? AVRColors.warning.withValues(alpha: 0.6) : Colors.grey.shade200,
                                width: isLowStock ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Seedling Botanical Photograph
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width: 54,
                                        height: 54,
                                        color: AVRColors.forestGreenSurface,
                                        child: Image.asset(
                                          item.primaryImageAsset,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.eco, color: AVRColors.forestGreen),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.commonName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'SKU: ${item.sku} • Tray #${100 + index}',
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isLowStock ? AVRColors.warning.withValues(alpha: 0.15) : AVRColors.forestGreenSurface,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isLowStock ? 'LOW STOCK' : 'HEALTHY',
                                        style: TextStyle(
                                          color: isLowStock ? AVRColors.warning : AVRColors.forestGreenDark,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStockCount('Available', '${item.availableStock}', AVRColors.forestGreen),
                                    _buildStockCount('Reserved', '12', Colors.blueGrey),
                                    _buildStockCount('Damaged', '0', Colors.redAccent),
                                    _buildStockCount('Unit Price', '₹${item.price.toStringAsFixed(0)}', AVRColors.textPrimary),
                                  ],
                                ),
                                const Divider(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                        side: const BorderSide(color: AVRColors.forestGreen),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () => _showStockAdjustDialog(item.commonName),
                                      icon: const Icon(Icons.tune, size: 14, color: AVRColors.forestGreen),
                                      label: const Text('Adjust', style: TextStyle(color: AVRColors.forestGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AVRColors.forestGreen,
                                        foregroundColor: Colors.white,
                                        visualDensity: VisualDensity.compact,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        elevation: 0,
                                      ),
                                      onPressed: () => _showTransferDialog(item.commonName),
                                      icon: const Icon(Icons.swap_horiz, size: 14),
                                      label: const Text('Transfer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
        ),
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockCount(String label, String count, Color color) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }

  void _showStockAdjustDialog(String plantName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adjust Nursery Stock: $plantName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity Change (+ or -)',
                hintText: 'e.g. +50 or -10',
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Reason for Adjustment',
                hintText: 'Tray germination audit / damaged in transit / fresh grafting',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AVRColors.forestGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Stock audit logged for $plantName with immutable history 🌱'),
                      backgroundColor: AVRColors.forestGreen,
                    ),
                  );
                },
                child: const Text('Confirm Stock Adjustment', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransferDialog(String plantName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transfer Seedling Trays: $plantName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 14),
            const Text('Source: Central Nursery & Greenhouse', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 6),
            const Text('Destination: Polyhouse Facility Unit-2', style: TextStyle(fontSize: 13, color: AVRColors.forestGreen, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Number of Seedlings / Trays'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AVRColors.terracotta,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Dispatch transfer initiated for $plantName 🚚'),
                      backgroundColor: AVRColors.forestGreen,
                    ),
                  );
                },
                child: const Text('Initiate Stock Transfer', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
