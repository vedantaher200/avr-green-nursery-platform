import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../localization/app_strings.dart';

/// Shows a standardized language selector modal
void showAppLanguageSelector(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _LanguageSelectorSheet(),
  );
}

class _LanguageSelectorSheet extends ConsumerWidget {
  const _LanguageSelectorSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(appLanguageProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.translate_rounded, color: AVRColors.forestGreen, size: 22),
              const SizedBox(width: 10),
              Text(
                AppStrings.get('select_language_dialog', currentLang),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AVRColors.forestGreenDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Choose your preferred language • भाषा निवडा • भाषा चुनें',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          _buildLanguageOption(
            context: context,
            ref: ref,
            language: AppLanguage.en,
            title: 'English',
            subtitle: 'Default Application Language',
            isSelected: currentLang == AppLanguage.en,
          ),
          const SizedBox(height: 10),
          _buildLanguageOption(
            context: context,
            ref: ref,
            language: AppLanguage.mr,
            title: 'मराठी (Marathi)',
            subtitle: 'महाराष्ट्र शेतकरी व रोपवाटिका मंच',
            isSelected: currentLang == AppLanguage.mr,
          ),
          const SizedBox(height: 10),
          _buildLanguageOption(
            context: context,
            ref: ref,
            language: AppLanguage.hi,
            title: 'हिन्दी (Hindi)',
            subtitle: 'व्यावसायिक पौधशाला एवं कृषि मंच',
            isSelected: currentLang == AppLanguage.hi,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required WidgetRef ref,
    required AppLanguage language,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        ref.read(appLanguageProvider.notifier).setLanguage(language);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AVRColors.forestGreenSurface : const Color(0xFFF9FBF8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AVRColors.forestGreen : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 15,
                      color: isSelected ? AVRColors.forestGreenDark : AVRColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isSelected ? AVRColors.forestGreen : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AVRColors.forestGreen, size: 22)
            else
              Icon(Icons.radio_button_off_rounded, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Compact button for AppBars
class LanguageSelectorButton extends ConsumerWidget {
  final Color? color;
  const LanguageSelectorButton({super.key, this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLanguageProvider);
    final shortLabel = switch (lang) {
      AppLanguage.mr => 'मराठी',
      AppLanguage.hi => 'हिंदी',
      AppLanguage.en => 'EN',
    };

    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: color ?? AVRColors.forestGreenDark,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: (color ?? AVRColors.forestGreenDark).withOpacity(0.3)),
        ),
      ),
      onPressed: () => showAppLanguageSelector(context),
      icon: const Icon(Icons.translate_rounded, size: 16),
      label: Text(
        shortLabel,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
