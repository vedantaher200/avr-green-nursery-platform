import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/language_selector_dialog.dart';
import '../../../auth/data/providers/auth_provider.dart';

class OwnerBusinessProfileScreen extends ConsumerStatefulWidget {
  const OwnerBusinessProfileScreen({super.key});

  @override
  ConsumerState<OwnerBusinessProfileScreen> createState() => _OwnerBusinessProfileScreenState();
}

class _OwnerBusinessProfileScreenState extends ConsumerState<OwnerBusinessProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _contactController;
  late TextEditingController _hoursController;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authStateProvider);
    _nameController = TextEditingController(text: auth.firstName ?? 'My Nursery');
    _descController = TextEditingController(text: 'High quality commercial seedlings.');
    _contactController = TextEditingController(text: '9900000000');
    _hoursController = TextEditingController(text: '09:00 AM - 06:00 PM');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _contactController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  int _calculateCompleteness() {
    int score = 0;
    if (_nameController.text.isNotEmpty) score += 25;
    if (_descController.text.isNotEmpty) score += 25;
    if (_contactController.text.isNotEmpty) score += 25;
    if (_hoursController.text.isNotEmpty) score += 25;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appLanguageProvider);
    final completeness = _calculateCompleteness();

    return Scaffold(
      backgroundColor: AVRColors.backgroundLight,
      appBar: AppBar(
        title: Text(ref.tr('business_profile_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          const LanguageSelectorButton(),
          IconButton(
            icon: Icon(_isEditing ? Icons.check_circle : Icons.edit),
            color: AVRColors.forestGreen,
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
              if (!_isEditing) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ref.tr('profile_saved_success')), backgroundColor: AVRColors.forestGreen),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.visibility),
            color: AVRColors.forestGreen,
            tooltip: ref.tr('preview_storefront_action'),
            onPressed: () => context.push('/storefront'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Completeness Indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(ref.tr('profile_completeness'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('$completeness%', style: const TextStyle(color: AVRColors.forestGreen, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: completeness / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: AVRColors.forestGreen,
                  ),
                  if (completeness < 100) ...[
                    const SizedBox(height: 8),
                    Text(ref.tr('farming_location_purpose'), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Profile Form
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ref.tr('business_information'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  _buildTextField(ref.tr('nursery_name_label'), _nameController),
                  _buildTextField(ref.tr('nursery_desc_label'), _descController, maxLines: 3),
                  _buildTextField(ref.tr('contact_phone_label'), _contactController),
                  _buildTextField(ref.tr('operating_hours_label'), _hoursController),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AVRColors.forestGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    icon: const Icon(Icons.location_on),
                    label: Text(ref.tr('manage_location_action')),
                    onPressed: () => context.push('/owner/location'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        enabled: _isEditing,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}
