import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/providers/order_provider.dart';
import '../../../auth/data/providers/auth_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersListProvider);

    final authState = ref.watch(authStateProvider);
    final isOwnerOrStaff = authState.isOwner || authState.isManager || authState.isStaff;

    return Scaffold(
      backgroundColor: AVRColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isOwnerOrStaff ? 'Nursery Commercial Orders' : 'My Plant Orders',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AVRColors.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AVRColors.forestGreen),
            onPressed: () => ref.refresh(ordersListProvider),
            tooltip: 'Refresh Orders',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ordersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AVRColors.forestGreen)),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AVRColors.error),
                    const SizedBox(height: 12),
                    Text('Failed to load orders: $err', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AVRColors.forestGreen),
                      onPressed: () => ref.refresh(ordersListProvider),
                      child: const Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
            data: (orders) {
              if (orders.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: AVRColors.forestGreenSurface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.receipt_long_outlined, size: 64, color: AVRColors.forestGreen),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isOwnerOrStaff ? 'No Nursery Orders Received Yet' : 'No Orders Placed Yet',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isOwnerOrStaff
                              ? 'Commercial plant and seedling orders placed by farmers will automatically appear here with dispatch actions.'
                              : 'Your plant nursery orders, seedlings tracking, and digital tax invoices will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 24),
                        if (isOwnerOrStaff)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AVRColors.forestGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => ref.refresh(ordersListProvider),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh Orders', style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                        else
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AVRColors.forestGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => context.go('/storefront'),
                            icon: const Icon(Icons.spa_outlined),
                            label: const Text('Start Shopping', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildOrderCard(context, order);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderRecord order) {
    Color statusColor;
    Color statusBg;
    switch (order.status.toLowerCase()) {
      case 'confirmed':
        statusColor = AVRColors.success;
        statusBg = AVRColors.forestGreenSurface;
        break;
      case 'delivered':
        statusColor = AVRColors.forestGreen;
        statusBg = AVRColors.forestGreenSurface;
        break;
      case 'dispatched':
      case 'in_transit':
        statusColor = AVRColors.warning;
        statusBg = Colors.amber.shade50;
        break;
      case 'cancelled':
      case 'failed':
        statusColor = AVRColors.error;
        statusBg = Colors.red.shade50;
        break;
      default:
        statusColor = Colors.orange;
        statusBg = Colors.orange.shade50;
    }

    return Container(
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
      child: Column(
        children: [
          // Header: Order Number and Status Chip
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AVRColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.locationName,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Body: Summary & Amount
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        const Icon(Icons.eco, size: 14, color: AVRColors.forestGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${item['quantity']}x ${item['common_name'] ?? 'Botanical Plant'}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Text(
                          '₹${item['unit_price'] ?? ''}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Paid (Incl. GST):', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    Text(
                      '₹${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AVRColors.forestGreen),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Actions Row: View Details & Download Invoice
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => context.push('/orders/${order.id}'),
                  icon: const Icon(Icons.local_shipping_outlined, size: 16, color: AVRColors.forestGreen),
                  label: const Text('Track Order', style: TextStyle(color: AVRColors.forestGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tax Invoice downloaded for #${order.orderNumber} (GST Included) 📄'),
                        backgroundColor: AVRColors.forestGreen,
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_outlined, size: 16, color: AVRColors.terracotta),
                  label: const Text('Invoice PDF', style: TextStyle(color: AVRColors.terracotta, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
