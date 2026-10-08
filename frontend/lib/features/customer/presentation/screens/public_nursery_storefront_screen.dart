import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/language_selector_dialog.dart';
import '../../data/providers/marketplace_provider.dart';

class PublicNurseryStorefrontScreen extends ConsumerWidget {
  final String nurseryId;
  const PublicNurseryStorefrontScreen({super.key, required this.nurseryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appLanguageProvider);
    final nurseriesAsync = ref.watch(nearbyNurseriesProvider);
    
    return Scaffold(
      backgroundColor: AVRColors.backgroundLight,
      body: nurseriesAsync.when(
        data: (nurseries) {
          final nursery = nurseries.firstWhere((n) => n.id == nurseryId, orElse: () => nurseries.first);
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                actions: const [
                  LanguageSelectorButton(color: Colors.white),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(nursery.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset('assets/images/nursery_cover_placeholder.jpg', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AVRColors.forestGreen)),
                      Container(color: Colors.black.withOpacity(0.4)),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AVRColors.terracotta, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text('${nursery.city}, Maharashtra', style: const TextStyle(fontSize: 16))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(ref.tr('about_us'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(ref.tr('nursery_storefront_desc')),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInfoCard(Icons.verified, ref.tr('verified')),
                          _buildInfoCard(Icons.access_time, ref.tr('open_now')),
                          _buildInfoCard(Icons.local_shipping, ref.tr('delivery')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Catalog Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(selectedNurseryProvider.notifier).state = nursery;
                      context.go('/storefront');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AVRColors.forestGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(ref.tr('view_available_varieties')),
                  ),
                ),
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${ref.tr('error_loading_storefront')}: $e')),
      ),
    );
  }
  
  Widget _buildInfoCard(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(backgroundColor: AVRColors.forestGreenSurface, child: Icon(icon, color: AVRColors.forestGreen)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
