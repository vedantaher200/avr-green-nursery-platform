import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/language_selector_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/providers/auth_provider.dart';
import '../../../customer/data/providers/offers_provider.dart';

class OwnerOffersScreen extends ConsumerStatefulWidget {
  const OwnerOffersScreen({super.key});

  @override
  ConsumerState<OwnerOffersScreen> createState() => _OwnerOffersScreenState();
}

class _OwnerOffersScreenState extends ConsumerState<OwnerOffersScreen> {
  final List<String> _tabs = ['all', 'active', 'scheduled', 'draft', 'expired'];

  String _getTabLabel(String tab, AppLanguage lang) {
    switch (tab) {
      case 'all': return AppStrings.get('tab_all', lang);
      case 'active': return AppStrings.get('tab_active', lang);
      case 'scheduled': return AppStrings.get('tab_scheduled', lang);
      case 'draft': return AppStrings.get('tab_draft', lang);
      case 'expired': return AppStrings.get('tab_expired', lang);
      default: return tab;
    }
  }


  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(selectedOwnerOfferTabProvider);
    final offersAsync = ref.watch(ownerOffersProvider);
    final language = ref.watch(appLanguageProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      appBar: AppBar(
        title: Text(
          ref.tr('offers_campaigns_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AVRColors.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          const LanguageSelectorButton(),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AVRColors.forestGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () => _showCreateOfferDialog(context),
              icon: const Icon(Icons.add, size: 16),
              label: Text(ref.tr('create_offer_btn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            height: 44,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isSelected = selectedTab == tab;
                return ChoiceChip(
                  label: Text(_getTabLabel(tab, language)),
                  selected: isSelected,
                  selectedColor: AVRColors.forestGreen,
                  backgroundColor: const Color(0xFFF1F5F2),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AVRColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11.5,
                  ),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: isSelected ? AVRColors.forestGreen : Colors.transparent),
                  onSelected: (_) {
                    ref.read(selectedOwnerOfferTabProvider.notifier).state = tab;
                  },
                );
              },
            ),
          ),

          // Offers List
          Expanded(
            child: offersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AVRColors.forestGreen)),
              error: (err, _) => Center(
                child: Text('Error loading campaigns: $err'),
              ),
              data: (offers) {
                if (offers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.campaign_outlined, size: 54, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text(
                          'No ${selectedTab != 'all' ? selectedTab : ''} campaigns found',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AVRColors.forestGreen),
                          onPressed: () => _showCreateOfferDialog(context),
                          icon: const Icon(Icons.add, size: 16),
                          label: Text(ref.tr('create_first_offer')),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
                  itemCount: offers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final o = offers[index];
                    return _buildOwnerCampaignCard(context, o);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerCampaignCard(BuildContext context, Map<String, dynamic> o) {
    final status = (o['dynamic_status'] ?? o['status'] ?? 'active').toString().toLowerCase();
    Color statusColor;
    Color statusBg;
    switch (status) {
      case 'active':
        statusColor = AVRColors.forestGreen;
        statusBg = AVRColors.forestGreenSurface;
        break;
      case 'scheduled':
        statusColor = Colors.blue.shade700;
        statusBg = Colors.blue.shade50;
        break;
      case 'paused':
        statusColor = AVRColors.warning;
        statusBg = Colors.amber.shade50;
        break;
      case 'expired':
        statusColor = Colors.grey.shade700;
        statusBg = Colors.grey.shade200;
        break;
      default:
        statusColor = Colors.grey.shade600;
        statusBg = Colors.grey.shade100;
    }

    final discountVal = o['discount_value'] ?? 0;
    final discountType = o['discount_type'] ?? 'percentage';
    final discountLabel = discountType == 'percentage' ? '$discountVal% OFF' : '₹$discountVal OFF';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AVRColors.borderPromotional.withValues(alpha: 0.65), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AVRColors.goldDark.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAF8),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(color: statusColor, fontSize: 9.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      o['event_label'] ?? '🌿 Nursery Offer',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AVRColors.textPrimary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD98E27),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    discountLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  o['title'] ?? 'Campaign',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AVRColors.textPrimary),
                ),
                if (o['short_description'] != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    o['short_description'],
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (o['applicable_crop'] != null) ...[
                      Text('Crop: ${o['applicable_crop']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AVRColors.forestGreenDark)),
                      const SizedBox(width: 10),
                    ],
                    Text('Redemptions: ${o['current_redemptions'] ?? 0}${o['max_redemptions'] != null ? ' / ${o['max_redemptions']}' : ''}', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Validity: ${_formatDate(o['start_date'])} – ${_formatDate(o['end_date'])}',
                  style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Actions: Pause / Resume / Cancel / Delete
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (status == 'active')
                      TextButton.icon(
                        onPressed: () => _updateStatus(o['id'], 'paused'),
                        icon: const Icon(Icons.pause, size: 14, color: AVRColors.warning),
                        label: Text(ref.tr('pause_btn'), style: const TextStyle(fontSize: 11, color: AVRColors.warning, fontWeight: FontWeight.bold)),
                      )
                    else if (status == 'paused')
                      TextButton.icon(
                        onPressed: () => _updateStatus(o['id'], 'active'),
                        icon: const Icon(Icons.play_arrow, size: 14, color: AVRColors.success),
                        label: Text(ref.tr('resume_btn'), style: const TextStyle(fontSize: 11, color: AVRColors.success, fontWeight: FontWeight.bold)),
                      ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _confirmDelete(o['id'], o['title']),
                      icon: const Icon(Icons.delete_outline, size: 14, color: AVRColors.error),
                      label: Text(ref.tr('delete_btn'), style: const TextStyle(fontSize: 11, color: AVRColors.error, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
    } catch (_) {
      return date.toString().split('T').first;
    }
  }

  String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m - 1];
  }

  Future<void> _updateStatus(String offerId, String newStatus) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.patch('/owner/offers/$offerId/status', data: {'status': newStatus});
      ref.invalidate(ownerOffersProvider);
      ref.invalidate(marketplaceOffersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Offer status updated to $newStatus'), backgroundColor: AVRColors.forestGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e'), backgroundColor: AVRColors.error),
        );
      }
    }
  }

  Future<void> _confirmDelete(String offerId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ref.tr('delete_offer_title'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Text('${ref.tr('confirm_delete_offer_prefix')} "$title"? ${ref.tr('confirm_delete_offer_suffix')}', style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(ref.tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AVRColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ref.tr('delete'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final client = ref.read(apiClientProvider);
        await client.dio.delete('/owner/offers/$offerId');
        ref.invalidate(ownerOffersProvider);
        ref.invalidate(marketplaceOffersProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ref.tr('offer_deleted_success')), backgroundColor: AVRColors.forestGreen),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete failed: $e'), backgroundColor: AVRColors.error),
          );
        }
      }
    }
  }

  void _showCreateOfferDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _CreateOfferModal(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Owner Create Offer Modal with Live Farmer-Facing Preview
// ─────────────────────────────────────────────────────────────────────────────

class _CreateOfferModal extends ConsumerStatefulWidget {
  const _CreateOfferModal();

  @override
  ConsumerState<_CreateOfferModal> createState() => _CreateOfferModalState();
}

class _CreateOfferModalState extends ConsumerState<_CreateOfferModal> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _discountValCtrl = TextEditingController(text: '10');
  final _minQtyCtrl = TextEditingController(text: '2');
  final _minOrderValCtrl = TextEditingController(text: '300');
  final _termsCtrl = TextEditingController();

  String _discountType = 'percentage';
  String _selectedCrop = 'Tomato';
  String _eventLabel = '🌿 Farmer Festival Offer';
  bool _isPrebooking = false;
  bool _isSaving = false;

  int _daysDuration = 10;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _discountValCtrl.dispose();
    _minQtyCtrl.dispose();
    _minOrderValCtrl.dispose();
    _termsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.add_circle_outline, color: AVRColors.forestGreen, size: 20),
                    SizedBox(width: 8),
                    Text(
                      ref.tr('create_nursery_offer'),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AVRColors.textPrimary),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Live Farmer Preview Card
            Text(
              ref.tr('live_preview_farmers'),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AVRColors.forestGreen, letterSpacing: 0.5),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAF8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AVRColors.forestGreen.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _eventLabel,
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AVRColors.forestGreenDark),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD98E27),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _discountType == 'percentage'
                              ? '${_discountValCtrl.text}% OFF'
                              : '₹${_discountValCtrl.text} OFF',
                          style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _titleCtrl.text.isNotEmpty ? _titleCtrl.text : 'E.g. Ganesh Chaturthi Farmer Offer',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Crop: $_selectedCrop • Min ${_minQtyCtrl.text} Trays • Valid for $_daysDuration days',
                    style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Offer Title
            _buildTextField(
              controller: _titleCtrl,
              label: 'Campaign Title',
              hint: 'E.g. Ganesh Chaturthi Tomato Seedling Special',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),

            // Event Label
            _buildTextField(
              controller: TextEditingController(text: _eventLabel),
              label: 'Event / Festival Label',
              hint: 'E.g. 🌿 Farmer Festival Offer, 🔥 Pre-Booking Offer',
              onChanged: (val) => setState(() => _eventLabel = val),
            ),
            const SizedBox(height: 10),

            // Applicable Crop & Pre-booking Toggle
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Applicable Crop', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: _selectedCrop,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: ['Tomato', 'Chilli', 'Capsicum', 'Brinjal', 'Marigold', 'Sugarcane', 'Lemon']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCrop = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pre-Booking Offer?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(_isPrebooking ? 'Yes' : 'No', style: const TextStyle(fontSize: 12)),
                        value: _isPrebooking,
                        activeColor: AVRColors.forestGreen,
                        onChanged: (val) => setState(() => _isPrebooking = val),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Discount Type & Value
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Discount Type', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: _discountType,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'percentage', child: Text('Percentage (%)', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'flat_amount', child: Text('Flat Amount (₹)', style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _discountType = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    controller: _discountValCtrl,
                    label: _discountType == 'percentage' ? 'Discount (%)' : 'Discount (₹)',
                    hint: '10',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Min Qty & Min Order Value
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _minQtyCtrl,
                    label: 'Min Trays Required',
                    hint: '2',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    controller: _minOrderValCtrl,
                    label: 'Min Order Value (₹)',
                    hint: '300',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Duration in Days
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Offer Duration: $_daysDuration Days', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                Slider(
                  value: _daysDuration.toDouble(),
                  min: 3,
                  max: 30,
                  divisions: 27,
                  activeColor: AVRColors.forestGreen,
                  label: '$_daysDuration days',
                  onChanged: (val) => setState(() => _daysDuration = val.round()),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Submit Buttons
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AVRColors.forestGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isSaving ? null : () => _submitOffer(publish: true),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Publish Offer to Marketplace', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isSaving ? null : () => _submitOffer(publish: false),
                child: const Text('Save as Draft', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 12.5),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Future<void> _submitOffer({required bool publish}) async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter campaign title'), backgroundColor: AVRColors.error),
      );
      return;
    }

    final discountVal = double.tryParse(_discountValCtrl.text.trim()) ?? 0;
    if (discountVal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid discount value greater than zero'), backgroundColor: AVRColors.error),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final client = ref.read(apiClientProvider);
      final startDate = DateTime.now();
      final endDate = startDate.add(Duration(days: _daysDuration));

      final body = {
        'title': title,
        'shortDescription': '${_discountType == 'percentage' ? '$discountVal% OFF' : '₹$discountVal OFF'} on $_selectedCrop seedling trays.',
        'offerType': _isPrebooking ? 'prebook_offer' : (_discountType == 'percentage' ? 'percentage_discount' : 'flat_discount'),
        'discountType': _discountType,
        'discountValue': discountVal,
        'applicableCrop': _selectedCrop,
        'minQuantity': int.tryParse(_minQtyCtrl.text.trim()) ?? 1,
        'minOrderValue': double.tryParse(_minOrderValCtrl.text.trim()) ?? 0,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isPrebookingOffer': _isPrebooking,
        'eventLabel': _eventLabel,
        'termsConditions': 'Valid for local nursery dispatch and pickup.',
      };

      await client.dio.post('/owner/offers', data: body);
      ref.invalidate(ownerOffersProvider);
      ref.invalidate(marketplaceOffersProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(publish ? 'Campaign published successfully! 🚀' : 'Offer saved as draft! 📄'),
            backgroundColor: AVRColors.forestGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create offer: $e'), backgroundColor: AVRColors.error),
        );
      }
    }
  }
}
