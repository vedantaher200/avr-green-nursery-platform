import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/avr_widgets.dart';
import '../../../../core/data/avr_repositories.dart';
import '../../../auth/data/providers/auth_provider.dart';
import '../../../order/data/providers/order_provider.dart';
import '../../../inventory/data/providers/owner_inventory_provider.dart';

// Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
// Dashboard Screen Ã¢â‚¬â€ Mobile-First Nursery Business Dashboard (Connected to Backend)
// Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final role = authState.role ?? 'customer';

    return Scaffold(
      backgroundColor: AVRColors.backgroundLight,
      body: RefreshIndicator(
        color: AVRColors.forestGreen,
        onRefresh: () async {
          ref.invalidate(reportDashboardProvider);
          ref.invalidate(ordersListProvider);
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: CustomScrollView(
              slivers: [
                // Ã¢â€â‚¬Ã¢â€â‚¬ Mobile-First Header Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
                SliverAppBar(
                  expandedHeight: 130,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: AVRColors.primaryGradient,
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Namaste, ${authState.firstName ?? 'Grower'} Ã°Å¸Å’Â±',
                                    style: AVRTextStyles.headlineSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ).animate().fadeIn(duration: 400.ms),
                                  const SizedBox(height: 2),
                                  Text(
                                    _getRoleTitle(role),
                                    style: AVRTextStyles.bodyMedium.copyWith(color: Colors.white70, fontSize: 13),
                                  ).animate().fadeIn(delay: 150.ms),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Ã¢â€â‚¬Ã¢â€â‚¬ Nursery Quick Action Chips (For Owner / Manager / Staff) Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
                if (role != 'customer' && role != 'delivery_agent') ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildQuickActionChip(
                              icon: Icons.add_circle_outline,
                              label: '+ Add Variety',
                              color: AVRColors.forestGreen,
                              onTap: () => context.push('/catalog'),
                            ),
                            const SizedBox(width: 8),
                            _buildQuickActionChip(
                              icon: Icons.inventory_2_outlined,
                              label: 'Stock Adjust',
                              color: AVRColors.terracotta,
                              onTap: () => context.push('/inventory'),
                            ),
                            const SizedBox(width: 8),
                            _buildQuickActionChip(
                              icon: Icons.local_shipping_outlined,
                              label: 'Live Deliveries',
                              color: AVRColors.forestGreenDark,
                              onTap: () => context.push('/deliveries'),
                            ),
                            const SizedBox(width: 8),
                            _buildQuickActionChip(
                              icon: Icons.receipt_long_outlined,
                              label: 'GST Reports',
                              color: AVRColors.warning,
                              onTap: () => context.push('/reports'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                // Ã¢â€â‚¬Ã¢â€â‚¬ KPI Cards Grid Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: _buildKpiGrid(role),
                  ),
                ),

                // Ã¢â€â‚¬Ã¢â€â‚¬ Nursery Owner Supply Management Sections Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
                if (role != 'customer' && role != 'delivery_agent') ...[
                  SliverToBoxAdapter(
                    child: AVRSectionHeader(
                      title: 'Pending Farmer Pre-Bookings',
                      actionLabel: 'Manage All',
                      onActionTap: () => context.push('/inventory'),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: _buildOwnerPrebookingsSection(),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: AVRSectionHeader(
                      title: 'Live Production Broadcasts',
                      actionLabel: '+ Broadcast',
                      onActionTap: () => context.push('/inventory'),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: _buildOwnerAnnouncementsSection(),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                   const SliverToBoxAdapter(child: SizedBox(height: 14)),
                   // Market Demand Signals section
                   SliverToBoxAdapter(
                     child: AVRSectionHeader(
                       title: 'Market Demand Signals',
                       actionLabel: 'View All',
                       onActionTap: () => context.push('/inventory'),
                     ),
                   ),
                   SliverPadding(
                     padding: const EdgeInsets.symmetric(horizontal: 16),
                     sliver: SliverToBoxAdapter(
                       child: _buildDemandSignalsSection(),
                     ),
                   ),
                ],

                // Ã¢â€â‚¬Ã¢â€â‚¬ Recent Commercial Orders Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
                const SliverToBoxAdapter(
                  child: AVRSectionHeader(title: 'Recent Nursery Orders', actionLabel: 'View All'),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildRecentOrdersList(),
                  ),
                ),

                // Ã¢â€â‚¬Ã¢â€â‚¬ Top Selling Nursery Seedlings Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                const SliverToBoxAdapter(
                  child: AVRSectionHeader(title: 'Top Commercial Seedlings', actionLabel: 'Catalog'),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildTopProductsList(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiGrid(String role) {
    final kpis = _getKpisForRole(role);
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: kpis
              .asMap()
              .entries
              .map((e) => e.value.animate(delay: (e.key * 60).ms))
              .toList(),
        );
      },
    );
  }

  List<Widget> _getKpisForRole(String role) {
    if (role == 'customer') {
      final orders = ref.watch(ordersListProvider).value ?? [];
      return [
        AVRStatCard(
          title: 'My Orders',
          value: '${orders.length}',
          icon: Icons.receipt_long,
          color: AVRColors.forestGreen,
          trend: 'Active orders',
          trendUp: true,
        ),
        const AVRStatCard(
          title: 'Loyalty Points',
          value: '1,240',
          icon: Icons.stars_rounded,
          color: AVRColors.terracotta,
          subtitle: 'Ã¢â€šÂ¹124 equivalent',
        ),
        AVRStatCard(
          title: 'Active Nursery Orders',
          value: '${orders.where((o) => o.status != 'delivered' && o.status != 'cancelled').length}',
          icon: Icons.local_shipping_outlined,
          color: AVRColors.forestGreenLight,
          subtitle: 'In fulfillment',
        ),
        const AVRStatCard(
          title: 'Saved',
          value: 'Ã¢â€šÂ¹320',
          icon: Icons.savings_outlined,
          color: AVRColors.sage,
          subtitle: 'Farmer discounts',
        ),
      ];
    }
    if (role == 'delivery_agent') {
      final deliveries = ref.watch(deliveriesProvider).value ?? [];
      return [
        AVRStatCard(
          title: "Assigned Deliveries",
          value: '${deliveries.length}',
          icon: Icons.local_shipping,
          color: AVRColors.forestGreen,
        ),
        AVRStatCard(
          title: 'Delivered',
          value: '${deliveries.where((d) => d['status'] == 'delivered').length}',
          icon: Icons.check_circle,
          color: AVRColors.success,
        ),
        AVRStatCard(
          title: 'In Transit',
          value: '${deliveries.where((d) => d['status'] == 'in_transit' || d['status'] == 'assigned').length}',
          icon: Icons.pending_actions,
          color: AVRColors.warning,
        ),
        const AVRStatCard(
          title: 'Km Covered',
          value: '28',
          icon: Icons.route,
          color: AVRColors.sage,
          subtitle: 'Route optimized',
        ),
      ];
    }

    // Owner / Manager default Ã¢â‚¬â€ Powered by live backend supply & inventory overview
    final overview = ref.watch(ownerInventoryOverviewProvider).value;

    final String readyStockStr = overview != null ? _formatNum(overview.totalReadyStock) : '25.4K';
    final String reservedStockStr = overview != null ? _formatNum(overview.totalReservedStock) : '1,200';
    final String prebookedStr = overview != null ? _formatNum(overview.totalPrebookedQuantity) : '18.5K';
    final String futureProdStr = overview != null ? _formatNum(overview.totalFutureProduction) : '1.8L';
    final String nextBatchDate = overview?.expectedProductionDate ?? '10 Oct 2026';
    final String pendingBookings = overview != null ? '${overview.pendingPrebookingsCount}' : '3';

    return [
      AVRStatCard(
        title: "Ready Stock",
        value: readyStockStr,
        icon: Icons.eco,
        gradient: AVRColors.primaryGradient,
        subtitle: 'Available for immediate dispatch',
      ),
      AVRStatCard(
        title: "Reserved Stock",
        value: reservedStockStr,
        icon: Icons.lock_outline,
        color: AVRColors.terracotta,
        subtitle: 'Allocated for active orders',
      ),
      AVRStatCard(
        title: 'Pre-booked Quantity',
        value: prebookedStr,
        icon: Icons.bookmark_added_outlined,
        color: AVRColors.forestGreenDark,
        subtitle: 'Farmer advance reservations',
      ),
      AVRStatCard(
        title: 'Future Production',
        value: futureProdStr,
        icon: Icons.schedule,
        gradient: AVRColors.terracottaGradient,
        subtitle: 'In greenhouse plug-trays',
      ),
      AVRStatCard(
        title: 'Expected Batch Date',
        value: nextBatchDate,
        icon: Icons.event_available,
        color: AVRColors.warning,
        subtitle: 'Next commercial harvest',
      ),
      AVRStatCard(
        title: 'Pending Pre-bookings',
        value: pendingBookings,
        icon: Icons.pending_actions,
        color: AVRColors.error,
        subtitle: 'Awaiting nursery approval',
      ),
    ];
  }

  String _formatNum(int num) {
    if (num >= 100000) return '${(num / 100000).toStringAsFixed(1)}L';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}K';
    return num.toString();
  }

  Widget _buildRecentOrdersList() {
    final ordersAsync = ref.watch(ordersListProvider);

    return ordersAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: AVRColors.forestGreen),
        ),
      ),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Text('Unable to load orders: $e', style: const TextStyle(fontSize: 12, color: AVRColors.error)),
        ),
      ),
      data: (orders) {
        if (orders.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 36, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No nursery orders received yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 2),
                  Text('Orders placed by farmers will automatically appear here.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        final recent = orders.take(5).toList();
        return Column(
          children: recent.asMap().entries.map((entry) {
            final order = entry.value;
            return InkWell(
              onTap: () => context.push('/orders/${order.id}'),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AVRColors.forestGreenSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.receipt_long, color: AVRColors.forestGreen, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(
                            order.customerName ?? order.locationName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AVRStatusBadge(status: order.status),
                        const SizedBox(height: 4),
                        Text(
                          'Ã¢â€šÂ¹${order.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AVRColors.forestGreen),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTopProductsList() {
    final products = [
      {'name': 'G4 Green Chilli (Teja Variety)', 'sold': '14,200 saplings', 'revenue': 'Ã¢â€šÂ¹1,13,600'},
      {'name': 'Hybrid Red Tomato (Abhinav)', 'sold': '12,500 saplings', 'revenue': 'Ã¢â€šÂ¹1,25,000'},
      {'name': 'Indra Yellow Bell Pepper', 'sold': '4,800 saplings', 'revenue': 'Ã¢â€šÂ¹57,600'},
      {'name': 'Alphonso Mango Graft (2-Year)', 'sold': '420 saplings', 'revenue': 'Ã¢â€šÂ¹1,05,000'},
    ];

    return Column(
      children: products.asMap().entries.map((e) {
        final p = e.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AVRColors.forestGreenSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.eco, color: AVRColors.forestGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(p['sold']!, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Text(
                p['revenue']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AVRColors.forestGreen),
              ),
            ],
          ),
        ).animate(delay: (e.key * 60).ms).fadeIn();
      }).toList(),
    );
  }

  Widget _buildOwnerPrebookingsSection() {
    final overview = ref.watch(ownerInventoryOverviewProvider).value;
    final prebookings = overview?.recentPrebookings.where((b) => b.status == 'pending').toList() ?? [];

    if (prebookings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: AVRColors.success, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'All farmer pre-bookings have been processed! No pending approvals.',
                style: TextStyle(fontSize: 12, color: AVRColors.forestGreenDark, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: prebookings.take(3).map((b) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bookmark_added_outlined, color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${b.farmerName} Ã¢â‚¬Â¢ ${b.quantity} ${b.unit.toUpperCase()} (${b.totalPlants} plants)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                    ),
                    Text(
                      'Target Ready: ${b.expectedReadyDate} Ã¢â‚¬Â¢ Total: Ã¢â€šÂ¹${b.totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AVRColors.forestGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () => context.push('/inventory'),
                child: const Text('Review', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOwnerAnnouncementsSection() {
    final overview = ref.watch(ownerInventoryOverviewProvider).value;
    final announcements = overview?.announcements ?? [];

    if (announcements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.campaign_outlined, color: AVRColors.terracotta, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Publish production announcements so farmers can pre-book next batches.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => context.push('/inventory'),
              child: const Text('Publish Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AVRColors.forestGreen)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: announcements.take(2).map((a) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
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
                  const Icon(Icons.campaign, color: AVRColors.terracotta, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      a.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                    child: const Text('Active', style: TextStyle(fontSize: 9.5, color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                a.content,
                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getRoleTitle(String role) {
    const titles = {
      'super_admin': 'Platform Administrator',
      'owner': 'Nursery Owner Operations',
      'manager': 'Branch Nursery Manager',
      'staff': 'Greenhouse Floor Staff',
      'customer': 'Farmer & Home Grower Account',
      'delivery_agent': 'Delivery Fleet Agent',
      'supplier': 'Supplier Portal',
    };
    return titles[role] ?? 'AVRGREEN Dashboard';
  }

  Widget _buildDemandSignalsSection() {
    final overview = ref.watch(ownerInventoryOverviewProvider).value;
    final signals = overview?.demandSignals ?? [];
    final totalInterested = overview?.totalInterestedFarmers ?? 0;

    if (signals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.trending_up, color: AVRColors.forestGreen, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'No active farmer interest signals yet. Share your catalog link to receive demand notifications.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF2D6A4F).withValues(alpha: 0.08), const Color(0xFF52B788).withValues(alpha: 0.04)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2D6A4F).withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.people_outline, color: Color(0xFF2D6A4F), size: 18),
              const SizedBox(width: 8),
              Text(
                '$totalInterested farmers interested',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B4332)),
              ),
              const Spacer(),
              Text(
                '${signals.length} varieties in demand',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
        ...signals.take(5).map((sig) {
          final hasNotify = sig.interestedFarmersCount > 0;
          final hasPrebook = sig.prebookedPlantsCount > 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.trending_up, color: Color(0xFF2D6A4F), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sig.commonName + (sig.variety != null ? ' ()' : ''),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (hasNotify) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${sig.interestedFarmersCount} interested',
                                style: TextStyle(fontSize: 9.5, color: Colors.blue.shade800, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          if (hasPrebook)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${sig.prebookedPlantsCount} pre-booked',
                                style: TextStyle(fontSize: 9.5, color: Colors.green.shade800, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
              ],
            ),
          );
        }),
      ],
    );
  }
}
