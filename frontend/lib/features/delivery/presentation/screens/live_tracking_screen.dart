import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_strings.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class LiveTrackingScreen extends ConsumerWidget {
  final String deliveryId;

  const LiveTrackingScreen({super.key, required this.deliveryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appLanguageProvider);
    return Scaffold(
      backgroundColor: AVRColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Live Delivery Tracking 📍', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AVRColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Visual Map Simulation View
          Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AVRColors.forestGreenSurface,
                  AVRColors.sageSurface,
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Simulated route lines
                CustomPaint(
                  size: const Size(double.infinity, 260),
                  painter: _RoutePainter(),
                ),
                // Origin Pin (Branch)
                Positioned(
                  left: 40,
                  top: 70,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AVRColors.forestGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.storefront, color: Colors.white, size: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(ref.tr('nursery_branch'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // Agent Pin (Moving position)
                Positioned(
                  left: 170,
                  top: 110,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AVRColors.terracotta,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AVRColors.terracotta.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.two_wheeler, color: Colors.white, size: 24),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        child: Text(ref.tr('agent_en_route'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                // Destination Pin (Customer)
                Positioned(
                  right: 40,
                  bottom: 60,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AVRColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.home, color: Colors.white, size: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(ref.tr('customer_home'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Realtime ETA & Agent Details Card
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ref.tr('estimated_arrival'), style: TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(height: 2),
                                const Text(
                                  '18 - 25 Minutes ⏱️',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AVRColors.forestGreen),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AVRColors.forestGreenSurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                ref.tr('live_gps_sync'),
                                style: TextStyle(color: AVRColors.forestGreen, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AVRColors.forestGreenSurface,
                              child: Icon(Icons.person, color: AVRColors.forestGreen),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Rajesh DeliveryRider', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('+91 99000 00006 • Rating: 4.9 ★', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.phone, color: AVRColors.forestGreen),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text('Delivery Milestones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
                    ),
                    child: Column(
                      children: [
                        _buildStepTile('Plants Packed at Greenhouse', '10:30 AM', true),
                        _buildStepTile('Agent Picked Up & Dispatched', '11:15 AM', true),
                        _buildStepTile('In Transit via Ring Road', 'Current Location', true, isActive: true),
                        _buildStepTile('Doorstep Delivery & Confirmation', 'Estimated 11:45 AM', false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTile(String title, String time, bool isDone, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: isActive
                ? AVRColors.terracotta
                : isDone
                    ? AVRColors.success
                    : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? AVRColors.terracotta : AVRColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          Text(time, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AVRColors.forestGreen.withValues(alpha: 0.4)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(60, 80);
    path.quadraticBezierTo(size.width * 0.4, 50, 190, 120);
    path.quadraticBezierTo(size.width * 0.7, 180, size.width - 60, size.height - 70);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
