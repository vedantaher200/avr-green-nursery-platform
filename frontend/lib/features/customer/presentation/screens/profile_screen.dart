import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../auth/data/providers/auth_provider.dart';
import '../../../inventory/data/providers/owner_inventory_provider.dart';
import '../../data/providers/marketplace_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Farmer / Customer Profile Screen
// ─────────────────────────────────────────────────────────────────────────────

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authStateProvider);
    _nameController = TextEditingController(text: auth.firstName ?? 'Kisan Farmer');
    _phoneController = TextEditingController(text: '9900000005');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final selectedLocation = ref.watch(selectedLocationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      appBar: AppBar(
        title: const Text(
          'Farmer Account & Profile',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AVRColors.forestGreenDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check_circle : Icons.edit_note_rounded, color: AVRColors.forestGreen, size: 24),
            tooltip: _isEditing ? 'Save Profile' : 'Edit Profile',
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
              if (!_isEditing) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile details updated successfully')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Farmer Profile Card ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AVRColors.forestGreenSurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.person_rounded, color: AVRColors.forestGreen, size: 36),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isEditing) ...[
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 4)),
                          ),
                        ] else ...[
                          Text(
                            _nameController.text,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: AVRColors.textPrimary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 13, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              _phoneController.text,
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AVRColors.sageSurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '🌾 Registered Farmer • 6-Digit PIN Secured',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AVRColors.forestGreenDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Regional Cluster & Farm Location ─────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: AVRColors.terracotta, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Active Farming Location',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AVRColors.forestGreenDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${selectedLocation.city}, ${selectedLocation.district} (${selectedLocation.state})',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Used to match nearby certified seedling nurseries in Maharashtra.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── App Settings & Options ───────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.receipt_long_rounded, color: AVRColors.forestGreen),
                    title: const Text('My Plant Orders', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('View invoices, order status & seedling tracking', style: TextStyle(fontSize: 11.5)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => context.push('/orders'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.event_note_rounded, color: Color(0xFFE65100)),
                    title: const Text('My Advance Pre-Bookings', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Track reserved polyhouse batches & dispatch dates', style: TextStyle(fontSize: 11.5)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => _showMyPreBookingsModal(context, _phoneController.text),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.translate_rounded, color: AVRColors.forestGreen),
                    title: const Text('Language / भाषा / भाषा निवडा', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(
                      language == AppLanguage.mr
                          ? 'मराठी (Marathi)'
                          : language == AppLanguage.hi
                              ? 'हिन्दी (Hindi)'
                              : 'English',
                      style: const TextStyle(fontSize: 11.5),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => _showLanguageModal(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.support_agent_rounded, color: AVRColors.forestGreen),
                    title: const Text('Nursery Technical Support', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('WhatsApp or call agronomy support: +91 9900000002', style: TextStyle(fontSize: 11.5)),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Connecting to AVR Green Agronomy Helpline...')),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Logout Action ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AVRColors.error,
                  side: const BorderSide(color: AVRColors.error, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text('Log Out of Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                onPressed: () async {
                  await ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'AVR Green Nursery Platform • Multi-Nursery SaaS v1.0.0\nOperating across Yeola, Angangaon, Chandwad & Nashik',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Preferred Language',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AVRColors.forestGreenDark),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('English'),
              onTap: () {
                ref.read(appLanguageProvider.notifier).state = AppLanguage.en;
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('हिन्दी (Hindi)'),
              onTap: () {
                ref.read(appLanguageProvider.notifier).state = AppLanguage.hi;
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('मराठी (Marathi)'),
              onTap: () {
                ref.read(appLanguageProvider.notifier).state = AppLanguage.mr;
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Farmer Advance Pre-Bookings Tracking Modal ──────────────────────────────
  void _showMyPreBookingsModal(BuildContext context, String phone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final bookingsAsync = ref.watch(farmerPreBookingsProvider(phone));

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.event_available_rounded, color: Color(0xFFE65100), size: 20),
                        SizedBox(width: 8),
                        Text('My Advance Pre-Bookings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: bookingsAsync.when(
                    data: (bookings) {
                      if (bookings.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.event_busy_rounded, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 10),
                              const Text('No active pre-bookings found for this number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('Reserve upcoming polyhouse batches from the marketplace.', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: bookings.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, idx) {
                          final b = bookings[idx];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FBF8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      b.bookingNumber,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AVRColors.forestGreenDark),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: b.status == 'ready'
                                            ? const Color(0xFFE8F5E9)
                                            : b.status == 'confirmed'
                                                ? const Color(0xFFE0F2FE)
                                                : const Color(0xFFFFF3E0),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        b.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: b.status == 'ready'
                                              ? AVRColors.success
                                              : b.status == 'confirmed'
                                                  ? const Color(0xFF0369A1)
                                                  : const Color(0xFFE65100),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Quantity: ${b.quantity} (${b.unit.toUpperCase()}) = ${b.totalPlants} Plants',
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('📅 Expected: ${b.expectedReadyDate}', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700)),
                                    Text('Advance: ₹${b.advanceAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AVRColors.forestGreenDark)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Center(child: Text('Unable to load pre-bookings')),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

