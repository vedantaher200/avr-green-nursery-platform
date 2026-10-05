import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
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
    final completeness = _calculateCompleteness();

    return Scaffold(
      backgroundColor: AVRColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Business Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check_circle : Icons.edit),
            color: AVRColors.forestGreen,
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
              if (!_isEditing) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile saved successfully!')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.visibility),
            color: AVRColors.forestGreen,
            tooltip: 'Preview Storefront',
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
                      const Text('Profile Completeness', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    const Text('Missing fields: Cover Image, Location', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                  const Text('Business Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  _buildTextField('Nursery Name', _nameController),
                  _buildTextField('Description', _descController, maxLines: 3),
                  _buildTextField('Contact Number', _contactController),
                  _buildTextField('Operating Hours', _hoursController),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AVRColors.forestGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    icon: const Icon(Icons.location_on),
                    label: const Text('Manage Location'),
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
