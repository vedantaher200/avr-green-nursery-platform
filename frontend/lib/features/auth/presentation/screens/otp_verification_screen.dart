import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class OtpVerificationScreen extends StatelessWidget {
  final String phone;
  const OtpVerificationScreen({super.key, required this.phone});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Verify OTP')),
        body: Center(
            child:
                Text('OTP Screen for $phone', style: AVRTextStyles.bodyLarge)),
      );
}
