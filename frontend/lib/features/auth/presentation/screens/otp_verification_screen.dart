import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/language_selector_dialog.dart';

class OtpVerificationScreen extends ConsumerWidget {
  final String phone;
  const OtpVerificationScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appLanguageProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(ref.tr('verify_otp')),
        actions: const [LanguageSelectorButton()],
      ),
      body: Center(
        child: Text(
          '${ref.tr('verify_otp')} for $phone',
          style: AVRTextStyles.bodyLarge,
        ),
      ),
    );
  }
}
