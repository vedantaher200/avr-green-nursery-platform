import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';

final ownerLocationsProvider = FutureProvider.autoDispose((ref) async {
  final client = ref.watch(apiClientProvider);
  final res = await client.dio.get('/management/locations');
  return res.data['data'] as List<dynamic>;
});

class ManageLocationScreen extends ConsumerStatefulWidget {
  const ManageLocationScreen({super.key});

  @override
  ConsumerState<ManageLocationScreen> createState() => _ManageLocationScreenState();
}

class _ManageLocationScreenState extends ConsumerState<ManageLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, dynamic>? _selectedLocation;
  
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _areaController = TextEditingController();
  final _talukaController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  bool _isPublished = false;

  void _loadLocationData(Map<String, dynamic> location) {
    setState(() {
      _selectedLocation = location;
      _nameController.text = location['name'] ?? '';
      _addressController.text = location['address_line'] ?? '';
      _areaController.text = location['area'] ?? '';
      _talukaController.text = location['taluka'] ?? '';
      _cityController.text = location['city'] ?? '';
      _districtController.text = location['district'] ?? '';
      _stateController.text = location['state'] ?? '';
      _pincodeController.text = location['pincode'] ?? '';
      _isPublished = location['is_published'] ?? false;
    });
  }

  Future<void> _saveLocation() async {
    if (!_formKey.currentState!.validate() || _selectedLocation == null) return;
    
    setState(() => _isLoading = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.put('/management/locations/${_selectedLocation!['id']}', data: {
        'name': _nameController.text.trim(),
        'address_line': _addressController.text.trim(),
        'area': _areaController.text.trim(),
        'taluka': _talukaController.text.trim(),
        'city': _cityController.text.trim(),
        'district': _districtController.text.trim(),
        'state': _stateController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'is_published': _isPublished,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location updated successfully', style: TextStyle(color: Colors.white)), backgroundColor: AVRColors.success));
        ref.invalidate(ownerLocationsProvider);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e', style: const TextStyle(color: Colors.white)), backgroundColor: AVRColors.error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(ownerLocationsProvider);
    
    return Scaffold(
      backgroundColor: AVRColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Manage Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: AVRColors.textPrimary,
        elevation: 0,
      ),
      body: locationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading locations: $e')),
        data: (locations) {
          if (locations.isEmpty) return const Center(child: Text('No locations found.'));
          if (_selectedLocation == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _loadLocationData(locations.first));
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nursery Branch Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Branch Name', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address Line', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextFormField(controller: _areaController, decoration: const InputDecoration(labelText: 'Area / Locality', border: OutlineInputBorder()))),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(controller: _talukaController, decoration: const InputDecoration(labelText: 'Taluka / Village', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextFormField(controller: _cityController, decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()))),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(controller: _districtController, decoration: const InputDecoration(labelText: 'District', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextFormField(controller: _stateController, decoration: const InputDecoration(labelText: 'State', border: OutlineInputBorder()))),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(controller: _pincodeController, decoration: const InputDecoration(labelText: 'Pincode', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Marketplace Visibility', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Publish Location'),
                    subtitle: const Text('Make this nursery branch discoverable to farmers.'),
                    value: _isPublished,
                    onChanged: (v) => setState(() => _isPublished = v),
                    activeColor: AVRColors.forestGreen,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AVRColors.forestGreen, foregroundColor: Colors.white),
                      onPressed: _isLoading ? null : _saveLocation,
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Location'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
