import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/language_selector_dialog.dart';
import '../../../../core/theme/app_theme.dart';

class SuperAdminScreen extends ConsumerStatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  ConsumerState<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends ConsumerState<SuperAdminScreen> {
  final List<Map<String, dynamic>> _tenants = [
    {
      'id': '33333333-3333-3333-3333-333333333333',
      'name': 'AVRGREEN Flagship Nursery',
      'slug': 'avrgreen-flagship',
      'plan': 'Growth Enterprise (₹3,999/mo)',
      'branches': 2,
      'status': 'active',
      'users': 6,
    },
    {
      'id': 'tenant-002',
      'name': 'Green Agro Orchards & Nursery',
      'slug': 'green-agro',
      'plan': 'Starter Nursery (₹1,499/mo)',
      'branches': 1,
      'status': 'active',
      'users': 2,
    },
    {
      'id': 'tenant-003',
      'name': 'Deccan Flora Botanicals',
      'slug': 'deccan-flora',
      'plan': 'Pro Multi-Branch SaaS (₹9,999/mo)',
      'branches': 4,
      'status': 'active',
      'users': 14,
    },
  ];

  @override
  Widget build(BuildContext context) {
    ref.watch(appLanguageProvider);
    return Scaffold(
      backgroundColor: AVRColors.backgroundLight,
      appBar: AppBar(
        title: Text(ref.tr('superadmin_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: const [LanguageSelectorButton(color: Colors.white)],
        backgroundColor: AVRColors.forestGreenDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Platform Overview Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AVRColors.forestGreenDark, AVRColors.forestGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ref.tr('saas_platform_control'), style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  const Text(
                    'Multi-Tenant Platform Health: 100% Operational',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderStat('Active Nurseries', '3 Tenants'),
                      _buildHeaderStat('Monthly ARR', '₹15,497/mo'),
                      _buildHeaderStat('System Status', 'Nominal ✅'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Onboarded Nursery Tenants
            Text(ref.tr('onboarded_nurseries_stat'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),

            ..._tenants.map((t) => _buildTenantCard(t)),

            const SizedBox(height: 24),

            // Subscription Tiers Configuration
            Text(ref.tr('active_subscriptions_stat'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildPlanCard('Starter Nursery', '₹1,499 / mo', '1 Branch • Up to 3 Staff Members • Basic Inventory'),
            const SizedBox(height: 10),
            _buildPlanCard('Growth Enterprise', '₹3,999 / mo', '5 Branches • Up to 15 Staff • Live Tracking • Advanced Reports'),
            const SizedBox(height: 10),
            _buildPlanCard('Pro Multi-Branch SaaS', '₹9,999 / mo', '20 Branches • 100 Staff • Unlimited Storage • Custom API Access'),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String title, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildTenantCard(Map<String, dynamic> t) {
    final isActive = t['status'] == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(t['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              Switch(
                value: isActive,
                activeColor: AVRColors.success,
                onChanged: (val) {
                  setState(() {
                    t['status'] = val ? 'active' : 'suspended';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tenant ${t['name']} status updated to ${t['status']}'),
                      backgroundColor: val ? AVRColors.forestGreen : AVRColors.warning,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Slug: ${t['slug']} • Plan: ${t['plan']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('${t['branches']} Branch(es)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AVRColors.forestGreen)),
              const SizedBox(width: 12),
              Text('${t['users']} Users', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AVRColors.terracotta)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? AVRColors.forestGreenSurface : AVRColors.terracottaSurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isActive ? 'ACTIVE' : 'SUSPENDED',
                  style: TextStyle(
                    color: isActive ? AVRColors.forestGreen : AVRColors.terracotta,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String name, String price, String details) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(details, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AVRColors.forestGreen)),
        ],
      ),
    );
  }
}
