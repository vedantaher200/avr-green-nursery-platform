import 'package:flutter/material.dart';
import '../../../../core/localization/app_strings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/providers/auth_provider.dart';
import '../../../catalog/data/models/product_model.dart';

class NotifyMeModal extends ConsumerStatefulWidget {
  final Product product;
  final VoidCallback? onSuccess;

  const NotifyMeModal({
    super.key,
    required this.product,
    this.onSuccess,
  });

  static void show(BuildContext context, Product product, {VoidCallback? onSuccess}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NotifyMeModal(
        product: product,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  ConsumerState<NotifyMeModal> createState() => _NotifyMeModalState();
}

class _NotifyMeModalState extends ConsumerState<NotifyMeModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Farmer');
  final _phoneController = TextEditingController(text: '9822334455');
  final _locationController = TextEditingController(text: 'Chandwad, Nashik');
  final _qtyController = TextEditingController(text: '10');
  final _notesController = TextEditingController();

  String _selectedUnit = 'tray';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _qtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      final desiredQty = int.tryParse(_qtyController.text.trim()) ?? 10;
      final payload = {
        'productId': widget.product.id,
        'farmerName': _nameController.text.trim(),
        'farmerPhone': _phoneController.text.trim(),
        'farmerLocation': _locationController.text.trim(),
        'desiredQuantity': desiredQty,
        'unit': _selectedUnit,
        if (_notesController.text.trim().isNotEmpty) 'notes': _notesController.text.trim(),
      };

      await apiClient.dio.post('/marketplace/notify-me', data: payload);

      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF2D6A4F),
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ref.tr('notification_set_success'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );

      widget.onSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text('Failed to register notification: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appLanguageProvider);
    final theme = Theme.of(context);
    final p = widget.product;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title and Product Summary
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications_active_outlined, color: Color(0xFF2D6A4F), size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref.tr('notify_when_available'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1B4332),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${p.commonName} (${p.variety})',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                        ),
                        if (p.futureStock > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'Expected: ${p.readyDate} (${p.futureStock} plants growing)',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF2D6A4F), fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Farmer Phone Input
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: ref.tr('farmer_mobile_number'),
                  hintText: ref.tr('phone_alert_hint'),
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Phone number is required';
                  if (val.trim().replaceAll(RegExp(r'[^0-9]'), '').length < 10) return 'Enter a valid 10-digit phone number';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Farmer Name Input
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: ref.tr('farmer_name'),
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),

              // Desired Quantity & Unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: ref.tr('estimated_quantity'),
                        prefixIcon: const Icon(Icons.pin_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Enter quantity';
                        final n = int.tryParse(val.trim());
                        if (n == null || n <= 0) return 'Must be > 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: InputDecoration(
                        labelText: ref.tr('unit_label'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: [
                        DropdownMenuItem(value: 'tray', child: Text('Trays (${p.trayCapacity} pl)')),
                        const DropdownMenuItem(value: 'plant', child: Text('Plants')),
                        const DropdownMenuItem(value: 'bulk', child: Text('Bulk (1000+)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedUnit = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Farmer Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: ref.tr('delivery_location_hint'),
                  hintText: 'e.g. Chandwad, Nashik',
                  prefixIcon: const Icon(Icons.location_city_outlined, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitNotification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A4F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.notifications_active, size: 20),
                  label: Text(
                    _isSubmitting ? ref.tr('registering') : ref.tr('alert_me_when_ready'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
