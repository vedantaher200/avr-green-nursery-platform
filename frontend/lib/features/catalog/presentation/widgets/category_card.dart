// Premium circular category card for the marketplace UI
// Displays a circular image (or emoji fallback) with the category label underneath.
// Tapping the card selects the category.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/catalog_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';

class CategoryCard extends ConsumerWidget {
  final MarketplaceCategory category;
  final bool isSelected;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLanguageProvider);
    final localizedLabel = switch (category.id) {
      'all' => AppStrings.get('cat_all', lang),
      'vegetables' => AppStrings.get('cat_vegetables', lang),
      'flowers' => AppStrings.get('cat_flowers', lang),
      'fruits' => AppStrings.get('cat_fruits', lang),
      'medicinal' => AppStrings.get('cat_medicinal', lang),
      'indoor' => AppStrings.get('cat_indoor', lang),
      'other' => AppStrings.get('cat_other', lang),
      _ => category.label,
    };

    // Image asset path – expect assets/category_images/<id>.png
    final imagePath = 'assets/category_images/${category.id}.png';
    // Try loading image asset; if fails, fallback to emoji text.
    final imageWidget = Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Center(
        child: Text(
          category.emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );

    return GestureDetector(
      onTap: () {
        ref.read(selectedCategoryProvider.notifier).state = category.id;
        ref.read(selectedCropProvider.notifier).state = 'all'; // reset crop
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AVRColors.forestGreen : Colors.transparent,
                width: 2,
              ),
              // Slight shadow for premium feel
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: imageWidget,
          ),
          const SizedBox(height: 4),
          Text(
            localizedLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected ? AVRColors.forestGreen : AVRColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
