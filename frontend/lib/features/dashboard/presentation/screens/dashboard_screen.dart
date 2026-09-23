import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/avr_widgets.dart';
import '../../../../core/data/avr_repositories.dart';
import '../../../auth/data/providers/auth_provider.dart';
import '../../../order/data/providers/order_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Screen — Mobile-First Nursery Business Dashboard (Connected to Backend)
// ─────────────────────────────────────────────────────────────────────────────

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
                // ── Mobile-First Header ──────────────────────────────────────────
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
                                    'Namaste, ${authState.firstName ?? 'Grower'} 🌱',
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

                // ── Nursery Quick Action Chips (For Owner / Manager / Staff) ────
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

                // ── KPI Cards Grid ─────────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: _buildKpiGrid(role),
                  ),
                ),

                // ── Recent Commercial Orders ───────────────────────────────────────
                const SliverToBoxAdapter(
                  child: AVRSectionHeader(title: 'Recent Nursery Orders', actionLabel: 'View All'),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildRecentOrdersList(),
                  ),
                ),

                // ── Top Selling Nursery Seedlings ──────────────────────────────────
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
          subtitle: '₹124 equivalent',
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
          value: '₹320',
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

    // Owner / Manager default — Powered by live backend data
    final dashAsync = ref.watch(reportDashboardProvider);
    final dashData = dashAsync.value;

    final double rawTodayRev = double.tryParse(dashData?['today']?['revenue']?.toString() ?? '0') ?? 0.0;
    final String todayRev = '₹${rawTodayRev.toStringAsFixed(0)}';
    final String todayOrders = (dashData?['today']?['orderCount'] ?? 0).toString();
    final String lowStock = (dashData?['lowStockAlerts'] ?? 0).toString();
    final String activeDeliveries = (dashData?['activeDeliveries'] ?? 0).toString();
    final double rawMonthRev = double.tryParse(dashData?['thisMonth']?['revenue']?.toString() ?? '0') ?? 0.0;
    final String monthRev = rawMonthRev >= 100000
        ? '₹${(rawMonthRev / 100000).toStringAsFixed(1)}L'
        : '₹${rawMonthRev.toStringAsFixed(0)}';
    final String activeCust = (dashData?['activeCustomers'] ?? 0).toString();

    return [
      AVRStatCard(
        title: "Today's Revenue",
        value: todayRev,
        icon: Icons.currency_rupee,
        gradient: AVRColors.primaryGradient,
        subtitle: 'Live tenant source of truth',
      ),
      AVRStatCard(
        title: "Today's Plant Orders",
        value: todayOrders,
        icon: Icons.receipt_long,
        color: AVRColors.terracotta,
        subtitle: 'Tenant orders today',
      ),
      AVRStatCard(
        title: 'Low Stock Seedlings',
        value: lowStock,
        icon: Icons.warning_amber_rounded,
        color: AVRColors.warning,
        subtitle: 'Needs greenhouse prep',
      ),
      AVRStatCard(
        title: 'Live Deliveries',
        value: activeDeliveries,
        icon: Icons.local_shipping,
        color: AVRColors.sage,
        subtitle: 'Out with dispatch van',
      ),
      AVRStatCard(
        title: 'Monthly Nursery Sales',
        value: monthRev,
        icon: Icons.bar_chart,
        gradient: AVRColors.terracottaGradient,
        subtitle: 'Current billing period',
      ),
      AVRStatCard(
        title: 'Active Growers/Farms',
        value: activeCust,
        icon: Icons.people,
        color: AVRColors.forestGreenLight,
        subtitle: 'Registered customer farms',
      ),
    ];
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
                          '₹${order.totalAmount.toStringAsFixed(0)}',
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
      {'name': 'G4 Green Chilli (Teja Variety)', 'sold': '14,200 saplings', 'revenue': '₹1,13,600'},
      {'name': 'Hybrid Red Tomato (Abhinav)', 'sold': '12,500 saplings', 'revenue': '₹1,25,000'},
      {'name': 'Indra Yellow Bell Pepper', 'sold': '4,800 saplings', 'revenue': '₹57,600'},
      {'name': 'Alphonso Mango Graft (2-Year)', 'sold': '420 saplings', 'revenue': '₹1,05,000'},
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
}
