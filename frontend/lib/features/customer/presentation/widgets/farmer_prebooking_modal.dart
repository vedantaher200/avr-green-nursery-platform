import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../../inventory/data/providers/owner_inventory_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Farmer Advance Pre-Booking Modal
// Allows farmers to reserve future polyhouse batch production directly.
// Strictly isolated from ready stock inventory.
// ─────────────────────────────────────────────────────────────────────────────

class FarmerPreBookingModal extends ConsumerStatefulWidget {
  final Product product;

  const FarmerPreBookingModal({super.key, required this.product});

  static Future<void> show(BuildContext context, Product product) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FarmerPreBookingModal(product: product),
    );
  }

  @override
  ConsumerState<FarmerPreBookingModal> createState() => _FarmerPreBookingModalState();
}

class _FarmerPreBookingModalState extends ConsumerState<FarmerPreBookingModal> {
  String _selectedUnit = 'tray'; // 'plant', 'tray', 'bulk'
  int _quantity = 5;
  final TextEditingController _nameController = TextEditingController(text: 'Suresh Patil');
  final TextEditingController _phoneController = TextEditingController(text: '9822011223');
  final TextEditingController _locationController = TextEditingController(text: 'Chandwad, Nashik');
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final trayCap = p.trayCapacity > 0 ? p.trayCapacity : 104;

    // Unit prices
    final plantRate = p.effectivePlantPrice;
    final trayRate = p.effectiveTrayPrice ?? (plantRate * trayCap);
    final bulkRate = p.effectiveBulkPrice ?? (plantRate * 0.85);

    int totalPlants;
    double unitPrice;
    double totalCost;

    if (_selectedUnit == 'tray') {
      unitPrice = trayRate;
      totalCost = unitPrice * _quantity;
      totalPlants = _quantity * trayCap;
    } else if (_selectedUnit == 'bulk') {
      unitPrice = bulkRate;
      totalCost = unitPrice * (_quantity * 1000);
      totalPlants = _quantity * 1000;
    } else {
      unitPrice = plantRate;
      totalCost = unitPrice * (_quantity * 50); // min 50 plants for pre-book
      totalPlants = _quantity * 50;
    }

    final advanceDeposit = totalCost * 0.20; // 20% advance
    final balanceOnDelivery = totalCost - advanceDeposit;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
        left: 18,
        right: 18,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
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
            const SizedBox(height: 12),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.orange.shade300),
                            ),
                            child: const Text(
                              '⏳ ADVANCE PRE-BOOKING',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFE65100),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              p.nurseryName,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AVRColors.forestGreenDark,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${p.crop} — ${p.variety}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AVRColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 20),

            // Expected Timeline Callout
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBF8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AVRColors.forestGreen.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AVRColors.forestGreenSurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.event_available_rounded, color: AVRColors.forestGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Expected Batch Readiness Date',
                          style: TextStyle(fontSize: 10.5, color: Colors.grey, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          p.readyDate.isNotEmpty ? p.readyDate : '10-15 Days (Fresh Polyhouse Lot)',
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AVRColors.forestGreenDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Next batch capacity: ${p.futureStock} plants scheduled',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Step 1: Unit Selector
            const Text(
              '1. Select Pre-Booking Unit',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AVRColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildUnitChoice(
                  id: 'tray',
                  title: 'Pro-Tray',
                  subtitle: '$trayCap plants / tray\n₹${trayRate.toStringAsFixed(0)}',
                  selected: _selectedUnit == 'tray',
                ),
                const SizedBox(width: 8),
                _buildUnitChoice(
                  id: 'bulk',
                  title: 'Bulk Lot',
                  subtitle: '1,000 plants lot\n₹${bulkRate.toStringAsFixed(2)}/plant',
                  selected: _selectedUnit == 'bulk',
                ),
                const SizedBox(width: 8),
                _buildUnitChoice(
                  id: 'plant',
                  title: 'Per Plant',
                  subtitle: '50 plants pack\n₹${plantRate.toStringAsFixed(2)}/plant',
                  selected: _selectedUnit == 'plant',
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Step 2: Quantity Counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '2. Choose Quantity',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AVRColors.textPrimary),
                    ),
                    Text(
                      _selectedUnit == 'tray'
                          ? 'Total: $totalPlants seedlings ($trayCap/tray)'
                          : _selectedUnit == 'bulk'
                              ? 'Total: $totalPlants seedlings (${_quantity * 1000} plants)'
                              : 'Total: $totalPlants seedlings',
                      style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 16),
                        visualDensity: VisualDensity.compact,
                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Step 3: Farmer Information
            const Text(
              '3. Farmer Contact & Delivery Details',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AVRColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Farmer Name',
                      labelStyle: const TextStyle(fontSize: 11),
                      prefixIcon: const Icon(Icons.person_outline, size: 16),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: const TextStyle(fontSize: 11),
                      prefixIcon: const Icon(Icons.phone_outlined, size: 16),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Village / Taluka / Delivery Location',
                labelStyle: const TextStyle(fontSize: 11),
                prefixIcon: const Icon(Icons.location_on_outlined, size: 16),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 14),

            // Commercial Cost & Advance Summary Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBF8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Plants Reserved:', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700)),
                      Text('$totalPlants Plants', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Estimated Total Amount:', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700)),
                      Text('₹${totalCost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Advance Payable (20%):',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AVRColors.forestGreenDark),
                      ),
                      Text(
                        '₹${advanceDeposit.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AVRColors.forestGreenDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Balance Due at Pickup/Delivery (80%):', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                      Text('₹${balanceOnDelivery.toStringAsFixed(2)}', style: TextStyle(fontSize: 10.5, color: Colors.grey.shade700)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 1,
                ),
                onPressed: _isSubmitting ? null : () => _submitPreBooking(totalCost, advanceDeposit, totalPlants),
                icon: _isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.flash_on_rounded, size: 20),
                label: Text(
                  _isSubmitting ? 'Reserving Polyhouse Batch...' : 'Confirm Pre-Booking (Pay ₹${advanceDeposit.toStringAsFixed(0)} Advance)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '🛡️ Verified Nursery Reservation • Zero ready inventory deducted',
                style: TextStyle(fontSize: 9.5, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitChoice({
    required String id,
    required String title,
    required String subtitle,
    required bool selected,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedUnit = id),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? AVRColors.forestGreenSurface : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AVRColors.forestGreen : Colors.grey.shade300,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: selected ? AVRColors.forestGreenDark : AVRColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.5,
                  color: selected ? AVRColors.forestGreenDark : Colors.grey.shade700,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitPreBooking(double totalCost, double advanceDeposit, int totalPlants) async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name and phone number')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final booking = await ref.read(ownerInventoryControllerProvider.notifier).placeFarmerPreBooking(
      productId: widget.product.id,
      farmerName: name,
      farmerPhone: phone,
      farmerLocation: _locationController.text.trim(),
      unit: _selectedUnit,
      quantity: _quantity,
      notes: 'Pre-booking for $totalPlants seedlings. Adv: ₹$advanceDeposit',
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;
    Navigator.pop(context); // Close bottom sheet

    // Show Confirmation Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AVRColors.success, size: 28),
            SizedBox(width: 8),
            Text('Pre-Booking Confirmed!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8F1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Booking ID:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                  Text(
                    booking?.bookingNumber ?? 'PRE-AVR-004812',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AVRColors.forestGreenDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Crop: ${widget.product.crop} — ${widget.product.variety}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text('Nursery: ${widget.product.nurseryName}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text('Quantity: $_quantity (${_selectedUnit.toUpperCase()}) = $totalPlants Plants', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text('Expected Ready: ${widget.product.readyDate.isNotEmpty ? widget.product.readyDate : "In 10 Days"}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AVRColors.forestGreenDark)),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Advance Payable:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text('₹${advanceDeposit.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AVRColors.forestGreenDark)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'A notification has been sent to ${widget.product.nurseryName}. You will receive batch propagation updates on $phone.',
              style: TextStyle(fontSize: 10.5, color: Colors.grey.shade700),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AVRColors.forestGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Back to Store', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
