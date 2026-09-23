import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Login Screen — Role Entry Selection (Farmer vs Nursery/Staff)
// ─────────────────────────────────────────────────────────────────────────────

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // 0 = Farmer / Customer, 1 = Nursery / Staff
  int _selectedRoleIndex = 0;

  final _formKeyFarmer = GlobalKey<FormState>();
  final _formKeyOwner = GlobalKey<FormState>();

  // Farmer login fields (Mobile + 6-digit PIN)
  final _farmerPhoneCtrl = TextEditingController(text: '9900000005');
  final _farmerPinCtrl = TextEditingController(text: '123456');

  // Owner/Staff login fields (Email/Phone + Password)
  final _ownerEmailCtrl = TextEditingController(text: 'owner@avrnursery.com');
  final _ownerPasswordCtrl = TextEditingController(text: 'Admin@123456');

  bool _isLoading = false;
  bool _obscurePin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _farmerPhoneCtrl.dispose();
    _farmerPinCtrl.dispose();
    _ownerEmailCtrl.dispose();
    _ownerPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loginFarmer() async {
    if (!_formKeyFarmer.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authStateProvider.notifier).loginWithPhoneAndPin(
            _farmerPhoneCtrl.text.trim(),
            _farmerPinCtrl.text.trim(),
          );
      if (mounted) {
        context.go('/storefront');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Farmer sign in failed: $error'),
            backgroundColor: AVRColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginOwner() async {
    if (!_formKeyOwner.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authStateProvider.notifier).loginWithPassword(
            _ownerEmailCtrl.text.trim(),
            _ownerPasswordCtrl.text,
          );
      if (mounted) {
        final authState = ref.read(authStateProvider);
        if (authState.isCustomer) {
          context.go('/storefront');
        } else if (authState.isDeliveryAgent) {
          context.go('/deliveries');
        } else {
          context.go('/dashboard');
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nursery sign in failed: $error'),
            backgroundColor: AVRColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _quickFillAndLogin(String type) {
    if (type == 'farmer') {
      setState(() => _selectedRoleIndex = 0);
      _farmerPhoneCtrl.text = '9900000005';
      _farmerPinCtrl.text = '123456';
      _loginFarmer();
    } else if (type == 'owner') {
      setState(() => _selectedRoleIndex = 1);
      _ownerEmailCtrl.text = 'owner@avrnursery.com';
      _ownerPasswordCtrl.text = 'Admin@123456';
      _loginOwner();
    } else if (type == 'driver') {
      setState(() => _selectedRoleIndex = 1);
      _ownerEmailCtrl.text = 'driver@gmail.com';
      _ownerPasswordCtrl.text = 'Admin@123456';
      _loginOwner();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AVRColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 490),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  // ── Branding Header ─────────────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: AVRColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AVRColors.forestGreen.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.eco_rounded, color: Colors.white, size: 34),
                          ),
                        ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 12),
                        const Text(
                          'AVR GREEN NURSERY',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AVRColors.forestGreenDark,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Commercial Plant & Nursery Platform',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Role Entry Selection Header ─────────────────────────────
                  const Text(
                    'Who are you logging in as?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AVRColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Select your account type to open your specialized workspace',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),

                  // ── 2 Main Role Choice Cards (Farmer vs Nursery/Staff) ───────
                  Row(
                    children: [
                      // OPTION 1: Farmer / Customer
                      Expanded(
                        child: _buildRoleSelectionCard(
                          index: 0,
                          icon: Icons.agriculture_rounded,
                          title: 'Farmer / Customer',
                          subtitle: 'Shop plants & seedlings',
                          badge: 'Mobile + PIN',
                          activeColor: AVRColors.forestGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // OPTION 2: Nursery / Staff
                      Expanded(
                        child: _buildRoleSelectionCard(
                          index: 1,
                          icon: Icons.storefront_rounded,
                          title: 'Nursery / Staff',
                          subtitle: 'Manage your nursery',
                          badge: 'Email + Password',
                          activeColor: AVRColors.terracotta,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Active Role Form Card ───────────────────────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      key: ValueKey<int>(_selectedRoleIndex),
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _selectedRoleIndex == 0 ? _buildFarmerForm() : _buildOwnerForm(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── 1-Tap Quick Dev Credentials ─────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AVRColors.forestGreenSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AVRColors.sage.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.flash_on_rounded, size: 16, color: AVRColors.forestGreen),
                            SizedBox(width: 6),
                            Text(
                              'Instant Test Login (1-Tap)',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: AVRColors.forestGreenDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
                                  side: BorderSide(color: AVRColors.forestGreen.withValues(alpha: 0.5)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () => _quickFillAndLogin('farmer'),
                                child: const Text(
                                  '🌾 Farmer Demo',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AVRColors.forestGreen),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
                                  side: BorderSide(color: AVRColors.terracotta.withValues(alpha: 0.5)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () => _quickFillAndLogin('owner'),
                                child: const Text(
                                  '🌱 Nursery Owner',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AVRColors.terracotta),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
                                  side: BorderSide(color: Colors.blueGrey.shade300),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () => _quickFillAndLogin('driver'),
                                child: Text(
                                  '🚚 Delivery Agent',
                                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Role Selection Card Component ───────────────────────────────────────────
  Widget _buildRoleSelectionCard({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
    required Color activeColor,
  }) {
    final isSelected = _selectedRoleIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedRoleIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? activeColor.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.02),
              blurRadius: isSelected ? 10 : 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? activeColor : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: activeColor, shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? activeColor : AVRColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.2),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? activeColor.withValues(alpha: 0.15) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? activeColor : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Farmer Form (Mobile Number + 6-digit PIN, Zero OTP) ───────────────────────
  Widget _buildFarmerForm() {
    return Form(
      key: _formKeyFarmer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco_rounded, size: 18, color: AVRColors.forestGreen),
              const SizedBox(width: 6),
              const Text(
                'Farmer & Customer Sign In',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AVRColors.textPrimary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AVRColors.forestGreenSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Zero OTP',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AVRColors.forestGreenDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Sign in using your mobile number and secret 6-digit PIN.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),

          // Mobile Number Field
          TextFormField(
            controller: _farmerPhoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Mobile Number',
              hintText: '9900000005',
              prefixIcon: const Icon(Icons.phone_android_rounded, size: 20, color: AVRColors.forestGreen),
              prefixText: '+91 ',
              filled: true,
              fillColor: AVRColors.backgroundLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
            validator: (v) => (v == null || v.trim().length < 10) ? 'Enter valid 10-digit number' : null,
          ),
          const SizedBox(height: 12),

          // 6-digit PIN Field
          TextFormField(
            controller: _farmerPinCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            obscureText: _obscurePin,
            decoration: InputDecoration(
              labelText: '6-digit Security PIN',
              hintText: '123456',
              counterText: '',
              prefixIcon: const Icon(Icons.pin_rounded, size: 20, color: AVRColors.forestGreen),
              suffixIcon: IconButton(
                icon: Icon(_obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                onPressed: () => setState(() => _obscurePin = !_obscurePin),
              ),
              filled: true,
              fillColor: AVRColors.backgroundLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
            validator: (v) => (v == null || v.trim().length < 4) ? 'Enter your 6-digit PIN' : null,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => context.go('/register'),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                child: const Text('New Farmer? Register', style: TextStyle(color: AVRColors.forestGreen, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PIN Recovery: Optional SMS recovery is available if configured.'),
                      backgroundColor: AVRColors.forestGreen,
                    ),
                  );
                },
                style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                child: Text('Forgot PIN?', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AVRColors.forestGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: _isLoading ? null : _loginFarmer,
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Shop Plants & Seedlings 🌱', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Nursery/Staff Form (Email + Password) ───────────────────────────────────
  Widget _buildOwnerForm() {
    return Form(
      key: _formKeyOwner,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_rounded, size: 18, color: AVRColors.terracotta),
              const SizedBox(width: 6),
              const Text(
                'Nursery Workspace Sign In',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AVRColors.textPrimary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AVRColors.terracottaSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Operations',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AVRColors.terracotta),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'For Nursery Owners, Managers, Floor Staff & Drivers.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),

          // Email Field
          TextFormField(
            controller: _ownerEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email or Mobile Number',
              hintText: 'owner@avrnursery.com',
              prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20, color: AVRColors.terracotta),
              filled: true,
              fillColor: AVRColors.backgroundLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),

          // Password Field
          TextFormField(
            controller: _ownerPasswordCtrl,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password or PIN',
              hintText: 'Admin@123456',
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AVRColors.terracotta),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              filled: true,
              fillColor: AVRColors.backgroundLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password Reset: Please contact your SaaS administrator or support.'),
                    backgroundColor: AVRColors.terracotta,
                  ),
                );
              },
              style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
              child: Text('Forgot Password?', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ),
          ),
          const SizedBox(height: 12),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AVRColors.terracotta,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: _isLoading ? null : _loginOwner,
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Manage Nursery Workspace 🏢', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
