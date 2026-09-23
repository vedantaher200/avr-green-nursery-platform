import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/providers/order_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersListProvider);
    final order = ordersAsync.value?.firstWhere(
      (o) => o.id == orderId,
      orElse: () => OrderRecord(
        id: orderId,
        orderNumber: 'ORD-2026-8812',
        status: 'confirmed',
        totalAmount: 1472.00,
        subtotal: 1248.00,
        taxAmount: 224.00,
        createdAt: DateTime.now().toIso8601String(),
        locationName: 'Central Botanical Garden Branch',
        items: [
          {'common_name': 'Fresh Green Chilli (Mirchi)', 'quantity': 50, 'unit_price': 8.00},
          {'common_name': 'Hybrid Red Tomato Seedling', 'quantity': 50, 'unit_price': 10.00},
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AVRColors.backgroundLight,
      appBar: AppBar(
        title: Text('Order #${order?.orderNumber ?? 'Details'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AVRColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: AVRColors.terracotta),
            tooltip: 'Download Invoice',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Downloading Tax Invoice PDF... 📄'),
                  backgroundColor: AVRColors.forestGreen,
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AVRColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_shipping, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status: ${order?.status.toUpperCase()}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Expected Nursery Delivery: Within 24-48 Hours 🌿',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Order Tracking Stepper
                const Text('Fulfillment Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
                  ),
                  child: Column(
                    children: [
                      _buildTimelineStep('Order Placed', 'Payment confirmed via UPI', true, isFirst: true),
                      _buildTimelineStep('Greenhouse Packing', 'Seedlings inspected and rootstock moisture checked', true),
                      _buildTimelineStep('Dispatched from Nursery', 'Assigned to botanical delivery van', true),
                      _buildTimelineStep('Out for Delivery', 'Driver en route to your farm/home address', false),
                      _buildTimelineStep('Delivered & Inspected', 'Seedlings delivered in healthy condition', false, isLast: true),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Item Details Table
                const Text('Ordered Seedlings & Plants', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
                  ),
                  child: Column(
                    children: [
                      ...order!.items.map(
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.spa, size: 14, color: AVRColors.forestGreen),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('${i['quantity']}x ${i['common_name']}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                              ),
                              Text(
                                '₹${(double.tryParse(i['unit_price']?.toString() ?? '0') ?? 0) * (int.tryParse(i['quantity']?.toString() ?? '1') ?? 1)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 24),
                      _buildFeeRow('Subtotal', '₹${order.subtotal.toStringAsFixed(2)}'),
                      const SizedBox(height: 4),
                      _buildFeeRow('CGST (9%)', '₹${(order.taxAmount / 2).toStringAsFixed(2)}'),
                      const SizedBox(height: 4),
                      _buildFeeRow('SGST (9%)', '₹${(order.taxAmount / 2).toStringAsFixed(2)}'),
                      const SizedBox(height: 4),
                      _buildFeeRow('Delivery', 'FREE', isHighlight: true),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                            '₹${order.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AVRColors.forestGreen),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Live Tracking CTA Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AVRColors.forestGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: () => context.push('/deliveries/${order.id}/track'),
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Live Nursery Van Tracking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep(String title, String subtitle, bool isCompleted, {bool isFirst = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isCompleted ? AVRColors.success : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(isCompleted ? Icons.check : Icons.circle, size: 12, color: Colors.white),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isCompleted ? AVRColors.success : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isCompleted ? AVRColors.textPrimary : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeeRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isHighlight ? AVRColors.success : AVRColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
