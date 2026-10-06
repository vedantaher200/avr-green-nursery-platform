import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/language_selector_dialog.dart';
import '../../data/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePin = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final language = ref.read(appLanguageProvider);
    if (!_formKey.currentState!.validate()) return;

    if (_pinController.text.trim() != _confirmPinController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('val_pins_mismatch', language)),
          backgroundColor: AVRColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authStateProvider.notifier).registerFarmer(
            phone: _phoneController.text.trim(),
            pin: _pinController.text.trim(),
            firstName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Farmer',
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.get('app_name', language)} 🌱 ${AppStrings.get('saved_successfully', language)}'),
            backgroundColor: AVRColors.forestGreen,
          ),
        );
        context.go('/storefront');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.get('network_issue_msg', language)),
            backgroundColor: AVRColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);

    return Scaffold(
      backgroundColor: AVRColors.backgroundLight,
      appBar: AppBar(
        title: Text(AppStrings.get('farmer_signup_title', language), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: Colors.white,
        foregroundColor: AVRColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: LanguageSelectorButton(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AVRColors.forestGreenSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AVRColors.sage.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.eco_rounded, color: AVRColors.forestGreen, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.get('fast_signup_banner', language),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AVRColors.forestGreenDark),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppStrings.get('fast_signup_banner_sub', language),
                                  style: const TextStyle(fontSize: 12, color: AVRColors.forestGreenDark),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Farmer Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: AppStrings.get('full_name_label', language),
                        hintText: AppStrings.get('full_name_hint', language),
                        prefixIcon: const Icon(Icons.person_outline, color: AVRColors.forestGreen),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Mobile Number
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: '${AppStrings.get('mobile_number', language)} *',
                        hintText: '9876543210',
                        prefixText: '+91 ',
                        prefixIcon: const Icon(Icons.phone_android, color: AVRColors.forestGreen),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                      ),
                      validator: (value) => (value?.trim().length ?? 0) < 10 ? AppStrings.get('val_phone_required', language) : null,
                    ),
                    const SizedBox(height: 14),

                    // 6-digit PIN
                    TextFormField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      obscureText: _obscurePin,
                      decoration: InputDecoration(
                        labelText: AppStrings.get('create_pin_label', language),
                        hintText: 'e.g. 556677',
                        counterText: '',
                        prefixIcon: const Icon(Icons.pin_rounded, color: AVRColors.forestGreen),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscurePin = !_obscurePin),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                      ),
                      validator: (value) => (value?.trim().length ?? 0) != 6 ? AppStrings.get('val_pin_exact_6', language) : null,
                    ),
                    const SizedBox(height: 14),

                    // Confirm 6-digit PIN
                    TextFormField(
                      controller: _confirmPinController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      obscureText: _obscurePin,
                      decoration: InputDecoration(
                        labelText: AppStrings.get('confirm_pin_label', language),
                        hintText: AppStrings.get('confirm_pin_hint', language),
                        counterText: '',
                        prefixIcon: const Icon(Icons.lock_clock_outlined, color: AVRColors.forestGreen),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                      ),
                      validator: (value) => (value?.trim().length ?? 0) != 6 ? AppStrings.get('val_pin_exact_6', language) : null,
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AVRColors.forestGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : _handleRegister,
                        child: _isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(AppStrings.get('btn_create_account', language), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(AppStrings.get('already_have_account_btn', language), style: const TextStyle(color: AVRColors.forestGreen, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
