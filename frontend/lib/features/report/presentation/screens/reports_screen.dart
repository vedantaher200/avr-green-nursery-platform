import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/language_selector_dialog.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _selectedRange = 'month';

  @override
  Widget build(BuildContext context) {
    ref.watch(appLanguageProvider);

    return Scaffold(
      backgroundColor: AVRColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          ref.tr('reports_analytics_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AVRColors.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          const LanguageSelectorButton(),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AVRColors.forestGreen),
            tooltip: ref.tr('export_gst_csv'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${ref.tr('export_gst_csv')}... 📥'),
                  backgroundColor: AVRColors.forestGreen,
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Filter Selector
                Row(
                  children: [
                    Text(ref.tr('date_range_label'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _selectedRange,
                      underline: const SizedBox(),
                      onChanged: (val) => setState(() => _selectedRange = val!),
                      items: [
                        DropdownMenuItem(value: 'today', child: Text(ref.tr('range_today'))),
                        DropdownMenuItem(value: 'week', child: Text(ref.tr('range_this_week'))),
                        DropdownMenuItem(value: 'month', child: Text(ref.tr('range_this_month'))),
                        DropdownMenuItem(value: 'year', child: Text(ref.tr('range_year_to_date'))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Top Revenue Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard('Gross Seedling Sales', '₹1,42,850', '+18.4% vs last month', AVRColors.forestGreen),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiCard('Orders Dispatched', '184', '98.5% fulfillment rate', AVRColors.terracotta),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard('Greenhouse Valuation', '₹4,85,200', '1,420 healthy plants', AVRColors.success),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiCard('Average Order Size', '₹776', '45 saplings / farmer', Colors.blueGrey),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Top-Selling Plant Species
                Text(ref.tr('top_selling_plants'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
                  ),
                  child: Column(
                    children: [
                      _buildProductRow('Abhinav F1 Hybrid Tomato', '14,200 saplings', '₹1,13,600', '48%'),
                      const Divider(height: 1),
                      _buildProductRow('Sita F1 Red Tomato', '8,400 saplings', '₹67,200', '28%'),
                      const Divider(height: 1),
                      _buildProductRow('G4 Teja Green Chilli', '5,100 saplings', '₹40,800', '16%'),
                      const Divider(height: 1),
                      _buildProductRow('Indra Green Capsicum', '2,400 saplings', '₹28,800', '8%'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildProductRow(String name, String qty, String rev, String share) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                Text(qty, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(rev, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AVRColors.forestGreen)),
              Text('$share share', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }
}
