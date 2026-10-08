import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/network_retry_dialog.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/language_selector_dialog.dart';
import '../../data/providers/cart_provider.dart';
import '../../../order/data/providers/order_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  String _selectedPaymentMethod = 'upi';
  bool _isProcessing = false;

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _handlePlaceOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.tr('cart_is_empty'))),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final order = await runWithNetworkRetry<OrderRecord>(
        context: context,
        pendingProcessName:
            'Placing Order (${cart.items.length} items from ${cart.currentNurseryName})',
        action: () => PlaceOrderService.checkoutAndPlaceOrder(
          ref: ref,
          cart: cart,
          street: _streetController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          pincode: _pincodeController.text.trim(),
          paymentMethod: _selectedPaymentMethod,
        ),
      );

      if (order == null || !mounted) return;

      // Show Order Confirmation Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AVRColors.forestGreenSurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    size: 64, color: AVRColors.success),
              ),
              const SizedBox(height: 16),
              Text(ref.tr('order_confirmed'),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AVRColors.forestGreen),
              ),
              const SizedBox(height: 8),
              Text(
                'Order #${order.orderNumber}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Amount: ₹${order.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                'Payment method: ${_selectedPaymentMethod.toUpperCase()}',
                style: const TextStyle(
                    fontSize: 12,
                    color: AVRColors.textSecondary,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Text(
                ref.tr('tax_invoice_ready_msg'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AVRColors.forestGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/orders');
                  },
                  child: Text(ref.tr('view_details'),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/storefront');
                },
                child: Text(ref.tr('browse_storefront_btn'),
                    style: TextStyle(color: AVRColors.forestGreen)),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Order failed: $e'),
              backgroundColor: AVRColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appLanguageProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AVRColors.backgroundLight,
      appBar: AppBar(
        title: Text(ref.tr('checkout'),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AVRColors.textPrimary,
        elevation: 0,
        actions: const [
          LanguageSelectorButton(),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nursery Protection Notice
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AVRColors.forestGreenSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AVRColors.sage.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_outlined,
                            color: AVRColors.forestGreen, size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ref.tr('botanical_transport_guarantee'),
                            style: TextStyle(
                                fontSize: 12,
                                color: AVRColors.forestGreenDark,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Delivery Address Section
                  _buildSectionHeader('1. ${ref.tr('shipping_address')} 📍'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _streetController,
                          decoration: InputDecoration(
                            labelText: ref.tr('street_address'),
                            prefixIcon: const Icon(Icons.home_outlined),
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? ref.tr('field_required') : null,
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(builder: (context, constraints) {
                          final cityField = TextFormField(
                            controller: _cityController,
                            decoration: InputDecoration(labelText: ref.tr('city_taluka')),
                            validator: (val) =>
                                val == null || val.isEmpty ? ref.tr('field_required') : null,
                          );
                          final pincodeField = TextFormField(
                            controller: _pincodeController,
                            keyboardType: TextInputType.number,
                            decoration:
                                InputDecoration(labelText: ref.tr('pincode')),
                            validator: (val) =>
                                val == null || val.isEmpty ? ref.tr('field_required') : null,
                          );
                          if (constraints.maxWidth < 360) {
                            return Column(children: [
                              cityField,
                              const SizedBox(height: 12),
                              pincodeField
                            ]);
                          }
                          return Row(children: [
                            Expanded(child: cityField),
                            const SizedBox(width: 12),
                            Expanded(child: pincodeField)
                          ]);
                        }),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _stateController,
                          decoration: InputDecoration(labelText: ref.tr('state')),
                          validator: (val) =>
                              val == null || val.isEmpty ? ref.tr('field_required') : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Payment Method Section
                  _buildSectionHeader('2. ${ref.tr('payment_method')} 💳'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8),
                      ],
                    ),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text(
                              'UPI (GPay / PhonePe / Paytm / BHIM)',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(
                              ref.tr('instant_conf_invoice'),
                              style: TextStyle(fontSize: 12)),
                          secondary: const Icon(Icons.qr_code_2,
                              color: AVRColors.forestGreen),
                          activeColor: AVRColors.forestGreen,
                          value: 'upi',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (val) =>
                              setState(() => _selectedPaymentMethod = val!),
                        ),
                        const Divider(height: 1),
                        RadioListTile<String>(
                          title: Text(ref.tr('credit_debit_card'),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(ref.tr('card_networks'),
                              style: TextStyle(fontSize: 12)),
                          secondary: const Icon(Icons.credit_card,
                              color: AVRColors.terracotta),
                          activeColor: AVRColors.forestGreen,
                          value: 'card',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (val) =>
                              setState(() => _selectedPaymentMethod = val!),
                        ),
                        const Divider(height: 1),
                        RadioListTile<String>(
                          title: Text(ref.tr('cod_label'),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(
                              ref.tr('cod_subtitle'),
                              style: TextStyle(fontSize: 12)),
                          secondary: const Icon(Icons.local_shipping_outlined,
                              color: AVRColors.warning),
                          activeColor: AVRColors.forestGreen,
                          value: 'cash',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (val) =>
                              setState(() => _selectedPaymentMethod = val!),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Order Summary Section
                  _buildSectionHeader('3. ${ref.tr('order_summary')} 📋'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8),
                      ],
                    ),
                    child: Column(
                      children: [
                        ...cart.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Text('${item.quantity}x',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AVRColors.forestGreen)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.product.commonName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                Text('₹${item.totalPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${ref.tr('total')}:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(
                              '₹${cart.grandTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AVRColors.forestGreen),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Confirm and Place Order Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AVRColors.forestGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: _isProcessing ? null : _handlePlaceOrder,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        _isProcessing
                            ? ref.tr('confirming_order')
                            : ref.tr('confirm_order_and_pay'),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AVRColors.forestGreenDark),
      ),
    );
  }
}
