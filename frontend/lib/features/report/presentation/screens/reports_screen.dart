import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedRange = 'This Month';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AVRColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Nursery Reports & Analytics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AVRColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AVRColors.forestGreen),
            tooltip: 'Export Nursery GST CSV',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting nursery analytics CSV... 📥'), backgroundColor: AVRColors.forestGreen),
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
                    const Text('Date Range:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _selectedRange,
                      underline: const SizedBox(),
                      onChanged: (val) => setState(() => _selectedRange = val!),
                      items: const [
                        DropdownMenuItem(value: 'Today', child: Text('Today')),
                        DropdownMenuItem(value: 'This Week', child: Text('This Week')),
                        DropdownMenuItem(value: 'This Month', child: Text('This Month')),
                        DropdownMenuItem(value: 'Year to Date', child: Text('Year to Date')),
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
                const Text('Top-Selling Commercial Seedlings 🌿', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                      _buildPlantRow('1. G4 Green Chilli (Teja)', '14,200 saplings sold', '₹1,13,600', AVRColors.forestGreen),
                      const Divider(height: 1),
                      _buildPlantRow('2. Hybrid Red Tomato (Abhinav)', '12,500 saplings sold', '₹1,25,000', AVRColors.forestGreen),
                      const Divider(height: 1),
                      _buildPlantRow('3. Indra Bell Pepper (Capsicum)', '4,800 saplings sold', '₹57,600', AVRColors.forestGreen),
                      const Divider(height: 1),
                      _buildPlantRow('4. Alphonso Mango Graft (2-Year)', '420 saplings sold', '₹1,05,000', AVRColors.forestGreen),
                      const Divider(height: 1),
                      _buildPlantRow('5. Desi Fragrant Rose', '380 saplings sold', '₹26,600', AVRColors.forestGreen),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Branch Breakdown
                const Text('Nursery Sales by Location 🏢', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
                  ),
                  child: Column(
                    children: [
                      _buildBranchProgress('Central Nursery & Greenhouse', 0.72, '₹1,02,852 (72%)'),
                      const SizedBox(height: 16),
                      _buildBranchProgress('Polyhouse Facility Unit-2', 0.28, '₹39,998 (28%)'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, String subtitle, Color color) {
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
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildPlantRow(String name, String units, String revenue, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text(units, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
          Text(revenue, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AVRColors.forestGreen)),
        ],
      ),
    );
  }

  Widget _buildBranchProgress(String branchName, double fraction, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(branchName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text(amount, style: const TextStyle(fontSize: 11, color: AVRColors.forestGreen, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(AVRColors.forestGreen),
          ),
        ),
      ],
    );
  }
}
