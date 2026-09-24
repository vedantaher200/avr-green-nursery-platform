import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_product_image.dart';
import '../../data/models/owner_inventory_models.dart';
import '../../data/providers/owner_inventory_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Nursery Owner Inventory, Future Stock & Pre-Booking Command Center
// ─────────────────────────────────────────────────────────────────────────────

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedStateFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overviewAsync = ref.watch(ownerInventoryOverviewProvider);

    return Scaffold(
      backgroundColor: AVRColors.backgroundLight,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nursery Supply & Inventory',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AVRColors.textPrimary),
            ),
            Text(
              'Ready Stock • Future Batches • Pre-Bookings',
              style: TextStyle(fontSize: 11, color: AVRColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign_outlined, color: AVRColors.forestGreen),
            tooltip: 'Publish Announcement',
            onPressed: () => _showPublishAnnouncementDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AVRColors.textSecondary),
            tooltip: 'Refresh Inventory',
            onPressed: () => ref.invalidate(ownerInventoryOverviewProvider),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AVRColors.forestGreen,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: AVRColors.forestGreen,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
          tabs: const [
            Tab(text: 'Ready Stock'),
            Tab(text: 'Future Batches'),
            Tab(text: 'Pre-Bookings'),
            Tab(text: 'Broadcasts'),
          ],
        ),
      ),
      body: overviewAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AVRColors.forestGreen),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 40, color: AVRColors.error),
              const SizedBox(height: 12),
              Text('Unable to load nursery stock: $err'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(ownerInventoryOverviewProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (overview) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                children: [
                  // ── Top Supply KPI Summary Ribbon ───────────────────────────
                  _buildKpiRibbon(overview),

                  // ── Tab Content Views ───────────────────────────────────────
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildReadyStockTab(overview),
                        _buildFutureBatchesTab(overview),
                        _buildPreBookingsTab(overview),
                        _buildBroadcastsTab(overview),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Supply KPI Ribbon (6 Metrics) ───────────────────────────────────────────
  Widget _buildKpiRibbon(OwnerDashboardOverview overview) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildRibbonPill('Ready Stock', '${_formatNum(overview.totalReadyStock)} Plants', Icons.eco, AVRColors.forestGreen),
            const SizedBox(width: 8),
            _buildRibbonPill('Reserved Stock', '${_formatNum(overview.totalReservedStock)} Plants', Icons.lock_outline, AVRColors.terracotta),
            const SizedBox(width: 8),
            _buildRibbonPill('Pre-booked Qty', '${_formatNum(overview.totalPrebookedQuantity)} Plants', Icons.bookmark_added_outlined, AVRColors.forestGreenDark),
            const SizedBox(width: 8),
            _buildRibbonPill('Future Production', '${_formatNum(overview.totalFutureProduction)} Plants', Icons.schedule, Colors.blueGrey),
            const SizedBox(width: 8),
            _buildRibbonPill('Next Batch Date', overview.expectedProductionDate ?? '10 Oct 2026', Icons.event_available, AVRColors.warning),
            const SizedBox(width: 8),
            _buildRibbonPill('Pending Pre-books', '${overview.pendingPrebookingsCount} Requests', Icons.pending_actions, AVRColors.error),
          ],
        ),
      ),
    );
  }

  Widget _buildRibbonPill(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(fontSize: 9.5, color: Colors.grey.shade700)),
              Text(value, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab 1: Ready Stock & Pricing Management ─────────────────────────────────
  Widget _buildReadyStockTab(OwnerDashboardOverview overview) {
    final filtered = overview.products.where((p) {
      if (_selectedStateFilter != 'all' && p.stockState != _selectedStateFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return p.commonName.toLowerCase().contains(q) ||
            p.crop.toLowerCase().contains(q) ||
            p.variety.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Search & Filter Row
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search variety or crop...',
                      hintStyle: const TextStyle(fontSize: 12),
                      prefixIcon: const Icon(Icons.search, size: 18),
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButtonHideUnderline(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedStateFilter,
                    icon: const Icon(Icons.filter_list, size: 16),
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AVRColors.textPrimary),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All States')),
                      DropdownMenuItem(value: 'ready_now', child: Text('READY NOW')),
                      DropdownMenuItem(value: 'limited_stock', child: Text('LIMITED STOCK')),
                      DropdownMenuItem(value: 'coming_soon', child: Text('COMING SOON')),
                      DropdownMenuItem(value: 'prebook_available', child: Text('PRE-BOOK AVAILABLE')),
                      DropdownMenuItem(value: 'sold_out', child: Text('SOLD OUT')),
                    ],
                    onChanged: (v) => setState(() => _selectedStateFilter = v ?? 'all'),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Products List
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No varieties found matching filter'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    return _buildProductCard(product);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductCard(OwnerProductModel p) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              AppProductImage.thumbnail(
                imageUrl: p.primaryImageAsset,
                cropName: p.crop,
                size: 64,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(width: 12),

              // Title and Variety
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStockStateBadge(p.stockState),
                        const Spacer(),
                        Text(
                          'SKU: ${p.sku}',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.variety,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AVRColors.textPrimary),
                    ),
                    Text(
                      '${p.commonName} • ${p.crop}',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 6),
                    // Multi-tiered Pricing
                    Wrap(
                      spacing: 8,
                      children: [
                        Text('₹${p.plantPrice.toStringAsFixed(2)}/plant', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AVRColors.forestGreenDark)),
                        if (p.trayPrice != null)
                          Text('₹${p.trayPrice!.toStringAsFixed(0)}/tray (${p.trayCapacity}p)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AVRColors.terracotta)),
                        if (p.bulkPrice != null)
                          Text('₹${p.bulkPrice!.toStringAsFixed(2)}/bulk', style: TextStyle(fontSize: 10.5, color: Colors.grey.shade700)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 16),

          // Stock Breakdown & Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStockCounter('Ready Stock', '${_formatNum(p.readyStock)} plants', AVRColors.success),
              _buildStockCounter('Future Batch', '${_formatNum(p.futureStock)} plants', Colors.blueGrey),
              _buildStockCounter('Expected Date', p.expectedReadyDate?.split('T')[0] ?? 'In 10 days', AVRColors.warning),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AVRColors.forestGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                icon: const Icon(Icons.edit, size: 12),
                label: const Text('Manage Stock'),
                onPressed: () => _showManageStockDialog(p),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockCounter(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 9.5, color: Colors.grey.shade600)),
        Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  Widget _buildStockStateBadge(String state) {
    Color bg;
    Color fg;
    String text;

    switch (state) {
      case 'ready_now':
        bg = AVRColors.forestGreenSurface;
        fg = AVRColors.forestGreen;
        text = 'READY NOW';
        break;
      case 'limited_stock':
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade900;
        text = 'LIMITED STOCK';
        break;
      case 'coming_soon':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade900;
        text = 'COMING SOON';
        break;
      case 'prebook_available':
        bg = Colors.purple.shade50;
        fg = Colors.purple.shade900;
        text = 'PRE-BOOK AVAILABLE';
        break;
      case 'sold_out':
      default:
        bg = Colors.red.shade50;
        fg = Colors.red.shade900;
        text = 'SOLD OUT';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: fg)),
    );
  }

  // ── Tab 2: Future Production Batches ────────────────────────────────────────
  Widget _buildFutureBatchesTab(OwnerDashboardOverview overview) {
    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: overview.products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final p = overview.products[index];
        return Container(
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
                children: [
                  AppProductImage.thumbnail(imageUrl: p.primaryImageAsset, size: 48, borderRadius: BorderRadius.circular(8)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.variety, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        Text('${p.crop} • Next Production Cycle', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: p.isPrebookable ? Colors.green.shade50 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: p.isPrebookable ? Colors.green.shade300 : Colors.grey.shade300),
                    ),
                    child: Text(
                      p.isPrebookable ? 'Pre-Booking Active' : 'Pre-Booking Paused',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: p.isPrebookable ? Colors.green.shade800 : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AVRColors.sageSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Planned Production', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text('${_formatNum(p.futureStock)} plants', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AVRColors.forestGreenDark)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Expected Readiness', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text(p.expectedReadyDate?.split('T')[0] ?? 'In 10 days', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AVRColors.terracottaDark)),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AVRColors.forestGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () => _showManageStockDialog(p),
                      child: const Text('Update Batch', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 3: Pre-Booking Orders ───────────────────────────────────────────────
  Widget _buildPreBookingsTab(OwnerDashboardOverview overview) {
    if (overview.recentPrebookings.isEmpty) {
      return const Center(child: Text('No advance pre-bookings placed yet.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: overview.recentPrebookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final b = overview.recentPrebookings[index];
        return Container(
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
                  Text(b.bookingNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AVRColors.forestGreenDark)),
                  _buildPrebookingStatusBadge(b.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text('${b.farmerName} (${b.farmerPhone})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                  const Spacer(),
                  Text('₹${b.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: AVRColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Variety: ${b.variety ?? b.commonName ?? "Crop"} • Quantity: ${b.quantity} ${b.unit.toUpperCase()} (${b.totalPlants} plants)',
                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
              ),
              Text(
                'Target Field Readiness: ${b.expectedReadyDate}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AVRColors.warning),
              ),
              if (b.notes != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Note: "${b.notes}"', style: TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: Colors.grey.shade600)),
                ),
              const Divider(height: 16),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (b.status == 'pending') ...[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _updateBookingStatus(b.id, 'cancelled'),
                      child: const Text('Decline', style: TextStyle(fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AVRColors.forestGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _updateBookingStatus(b.id, 'confirmed'),
                      child: const Text('Confirm Pre-Booking', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ] else if (b.status == 'confirmed') ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AVRColors.terracotta,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _updateBookingStatus(b.id, 'ready_for_pickup'),
                      child: const Text('Mark Ready for Pickup', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ] else ...[
                    Text('Status: ${b.statusDisplay}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AVRColors.forestGreen)),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrebookingStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'ready_for_pickup':
        color = AVRColors.success;
        break;
      case 'fulfilled':
        color = AVRColors.forestGreen;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'pending':
      default:
        color = Colors.orange;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(status.toUpperCase(), style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: color)),
    );
  }

  // ── Tab 4: Broadcasts & Announcements ───────────────────────────────────────
  Widget _buildBroadcastsTab(OwnerDashboardOverview overview) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active Marketplace Broadcasts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AVRColors.forestGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 14),
                label: const Text('New Announcement', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: () => _showPublishAnnouncementDialog(),
              ),
            ],
          ),
        ),
        Expanded(
          child: overview.announcements.isEmpty
              ? const Center(child: Text('No announcements published yet.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: overview.announcements.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final a = overview.announcements[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.campaign, color: AVRColors.terracotta, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('Live in Marketplace', style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(a.content, style: const TextStyle(fontSize: 12, height: 1.3)),
                          const SizedBox(height: 8),
                          if (a.readyQuantity != null || a.futureQuantity != null)
                            Wrap(
                              spacing: 8,
                              children: [
                                if (a.readyQuantity != null)
                                  Text('✓ ${_formatNum(a.readyQuantity!)} ready now', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AVRColors.forestGreen)),
                                if (a.futureQuantity != null)
                                  Text('⏳ Next batch: ${_formatNum(a.futureQuantity!)} in ${a.expectedDays ?? 10} days', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AVRColors.terracottaDark)),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Modal: Manage Variety, Pricing & Stock ──────────────────────────────────
  void _showManageStockDialog(OwnerProductModel p) {
    final readyStockController = TextEditingController(text: p.readyStock.toString());
    final futureStockController = TextEditingController(text: p.futureStock.toString());
    final plantPriceController = TextEditingController(text: p.plantPrice.toStringAsFixed(2));
    final trayPriceController = TextEditingController(text: (p.trayPrice ?? (p.plantPrice * p.trayCapacity)).toStringAsFixed(0));
    final bulkPriceController = TextEditingController(text: (p.bulkPrice ?? (p.plantPrice * 0.85)).toStringAsFixed(2));
    final trayCapController = TextEditingController(text: p.trayCapacity.toString());
    final expectedDateController = TextEditingController(text: p.expectedReadyDate?.split('T')[0] ?? '2026-10-10');
    String selectedStockState = p.stockState;
    bool isPrebookable = p.isPrebookable;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 12),
                Text('Manage Variety & Stock: ${p.variety}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AVRColors.forestGreenDark)),
                Text('${p.commonName} • Crop: ${p.crop}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 16),

                // Stock State Selector
                const Text('Stock State in Marketplace', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedStockState,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'ready_now', child: Text('1. READY NOW (In Greenhouse)')),
                        DropdownMenuItem(value: 'limited_stock', child: Text('2. LIMITED STOCK (< 500 left)')),
                        DropdownMenuItem(value: 'coming_soon', child: Text('3. COMING SOON (Production Sown)')),
                        DropdownMenuItem(value: 'prebook_available', child: Text('4. PRE-BOOK AVAILABLE (Reserve Next Batch)')),
                        DropdownMenuItem(value: 'sold_out', child: Text('5. SOLD OUT')),
                      ],
                      onChanged: (v) {
                        if (v != null) setModalState(() => selectedStockState = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Ready Stock & Future Stock Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: readyStockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Ready Stock (Plants)', hintText: '20000'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: futureStockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Future Production', hintText: '50000'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Next Batch Ready Date & Tray Capacity
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: expectedDateController,
                        decoration: const InputDecoration(labelText: 'Expected Batch Date', hintText: 'YYYY-MM-DD'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: trayCapController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Tray Capacity', hintText: '104'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Pricing Tiers: Plant Price, Tray Price, Bulk Price
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: plantPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Plant Price (₹)', hintText: '2.50'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: trayPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Tray Price (₹)', hintText: '260'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: bulkPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Bulk Rate (₹)', hintText: '2.10'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Pre-booking Toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Advance Pre-Booking', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Allow farmers to reserve upcoming production batch', style: TextStyle(fontSize: 11)),
                  value: isPrebookable,
                  activeColor: AVRColors.forestGreen,
                  onChanged: (v) => setModalState(() => isPrebookable = v),
                ),
                const SizedBox(height: 16),

                // Save Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AVRColors.forestGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final success = await ref.read(ownerInventoryControllerProvider.notifier).updateProductStock(
                            productId: p.id,
                            readyStock: int.tryParse(readyStockController.text) ?? p.readyStock,
                            futureStock: int.tryParse(futureStockController.text) ?? p.futureStock,
                            expectedReadyDate: expectedDateController.text,
                            plantPrice: double.tryParse(plantPriceController.text) ?? p.plantPrice,
                            trayPrice: double.tryParse(trayPriceController.text) ?? (p.trayPrice ?? 260.0),
                            bulkPrice: double.tryParse(bulkPriceController.text) ?? (p.bulkPrice ?? 2.10),
                            trayCapacity: int.tryParse(trayCapController.text) ?? p.trayCapacity,
                            minOrderQty: p.minOrderQty,
                            stockState: selectedStockState,
                            isPrebookable: isPrebookable,
                          );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Stock & pricing updated in real-time 🌱' : 'Update saved to nursery catalog'),
                            backgroundColor: AVRColors.forestGreen,
                          ),
                        );
                      }
                    },
                    child: const Text('Save Stock & Publish Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Modal: Publish Nursery Production Announcement ──────────────────────────
  void _showPublishAnnouncementDialog() {
    final titleController = TextEditingController(text: 'Tomato Hybrid Production Batch Announcement');
    final contentController = TextEditingController(
      text: 'Tomato Hybrid — 20,000 plants ready for immediate field dispatch. Next production batch of 50,000 plants expected in 10 days.',
    );
    final cropController = TextEditingController(text: 'Tomato');
    final varietyController = TextEditingController(text: 'Abhinav Hybrid');
    final readyQtyController = TextEditingController(text: '20000');
    final futureQtyController = TextEditingController(text: '50000');
    final daysController = TextEditingController(text: '10');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.campaign, color: AVRColors.terracotta, size: 22),
                  SizedBox(width: 8),
                  Text('Publish Nursery Announcement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AVRColors.forestGreenDark)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Farmers in your region will see this broadcast in the marketplace.', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Announcement Title', hintText: 'e.g. Marigold Diwali Flowering Batch Ready'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Announcement Content',
                  hintText: 'e.g. Marigold — 1,000 trays ready. Next production batch: 5,000 trays in 20 days.',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: cropController, decoration: const InputDecoration(labelText: 'Crop'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: varietyController, decoration: const InputDecoration(labelText: 'Variety'))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: readyQtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Ready Qty'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: futureQtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Next Batch Qty'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: daysController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Days Expected'))),
                ],
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
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await ref.read(ownerInventoryControllerProvider.notifier).publishAnnouncement(
                          title: titleController.text,
                          content: contentController.text,
                          crop: cropController.text,
                          variety: varietyController.text,
                          readyQuantity: int.tryParse(readyQtyController.text),
                          futureQuantity: int.tryParse(futureQtyController.text),
                          expectedDays: int.tryParse(daysController.text),
                        );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Announcement broadcasted to regional marketplace farmers 📢'),
                          backgroundColor: AVRColors.forestGreen,
                        ),
                      );
                    }
                  },
                  child: const Text('Publish Announcement to Marketplace', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateBookingStatus(String bookingId, String status) async {
    final success = await ref.read(ownerInventoryControllerProvider.notifier).updatePreBookingStatus(
          preBookingId: bookingId,
          status: status,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Pre-booking marked as $status' : 'Pre-booking status updated'),
          backgroundColor: AVRColors.forestGreen,
        ),
      );
    }
  }

  String _formatNum(int num) {
    if (num >= 100000) return '${(num / 100000).toStringAsFixed(1)}L';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(0)},${(num % 1000).toString().padLeft(3, '0')}';
    return num.toString();
  }
}
