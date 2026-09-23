import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  State<DeliveryDashboardScreen> createState() => _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  final List<Map<String, dynamic>> _deliveries = [
    {
      'id': 'del-001',
      'orderNumber': 'ORD-2026-8812',
      'customerName': 'Ananya Sharma',
      'phone': '+91 99000 00005',
      'address': '123 Farm House Road, Indiranagar, Bengaluru',
      'itemsSummary': '50x Green Chilli Saplings, 50x Hybrid Tomato',
      'status': 'in_transit',
      'codAmount': 0.0,
      'paymentMode': 'Prepaid (UPI Confirmed)',
    },
    {
      'id': 'del-002',
      'orderNumber': 'ORD-2026-8815',
      'customerName': 'Vikram Reddy Agro Farm',
      'phone': '+91 99000 00018',
      'address': 'Plot 45, Green Glen Farm, Bellandur, Bengaluru',
      'itemsSummary': '2x Alphonso Mango Graft, 100x Chilli Seedlings',
      'status': 'assigned',
      'codAmount': 1097.0,
      'paymentMode': 'Cash on Delivery (₹1097)',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AVRColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Nursery Delivery Fleet 🚚', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AVRColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AVRColors.forestGreen),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              // Agent Summary Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AVRColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 24,
                      child: Icon(Icons.two_wheeler, color: AVRColors.forestGreen, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Driver: Rajesh (Nursery Van #4)',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_deliveries.length} Rootstock Deliveries Scheduled Today',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Deliveries List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: _deliveries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final del = _deliveries[index];
                    return _buildDeliveryCard(context, del, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(BuildContext context, Map<String, dynamic> del, int index) {
    final status = del['status'] as String;
    final isDelivered = status == 'delivered';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order & Payment Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                del['orderNumber'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AVRColors.forestGreen),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDelivered ? AVRColors.forestGreenSurface : AVRColors.terracottaSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: isDelivered ? AVRColors.forestGreen : AVRColors.terracotta,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Customer Name & Phone
          Row(
            children: [
              const Icon(Icons.person_outline, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(del['customerName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              Text(del['phone'], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),

          // Delivery Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.pin_drop_outlined, size: 18, color: Colors.redAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  del['address'],
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 13, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Plants Summary
          Row(
            children: [
              const Icon(Icons.eco_outlined, size: 18, color: AVRColors.forestGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  del['itemsSummary'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // Delivery Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AVRColors.forestGreen),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => context.push('/deliveries/${del['id']}/track'),
                  icon: const Icon(Icons.navigation_outlined, size: 16, color: AVRColors.forestGreen),
                  label: const Text('Live Track', style: TextStyle(color: AVRColors.forestGreen, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDelivered ? Colors.grey : AVRColors.success,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: isDelivered
                      ? null
                      : () {
                          setState(() {
                            del['status'] = 'delivered';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Delivery marked DELIVERED for ${del['orderNumber']} 🎉'),
                              backgroundColor: AVRColors.forestGreen,
                            ),
                          );
                        },
                  icon: const Icon(Icons.check, size: 16, color: Colors.white),
                  label: Text(
                    isDelivered ? 'Delivered' : 'Complete (POD)',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
