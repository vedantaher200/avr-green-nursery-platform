import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../network/api_client.dart';
import '../theme/app_theme.dart';

class InvoiceDownloadHelper {
  static Future<void> downloadAndOpenInvoice(
    BuildContext context, {
    required ApiClient apiClient,
    required String orderId,
    required String orderNumber,
  }) async {
    final messenger = ScaffoldMessenger.of(context);

    // Show temporary downloading feedback
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 74, left: 16, right: 16),
        duration: const Duration(seconds: 2),
        backgroundColor: AVRColors.forestGreen,
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Fetching GST Tax Invoice for #$orderNumber...',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );

    try {
      final response = await apiClient.dio.get<List<int>>(
        '/invoices/$orderId/pdf',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'application/pdf'},
        ),
      );

      if (response.data == null || response.data!.isEmpty) {
        throw Exception('Received empty invoice response');
      }

      final bytes = Uint8List.fromList(response.data!);
      final filename = 'Invoice-${orderNumber.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}.pdf';

      // Cross-platform PDF open / share / download via Printing plugin
      await Printing.sharePdf(bytes: bytes, filename: filename);

      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 74, left: 16, right: 16),
          duration: const Duration(seconds: 3),
          backgroundColor: AVRColors.forestGreenDark,
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tax Invoice for #$orderNumber ready 📄',
                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 74, left: 16, right: 16),
          duration: const Duration(seconds: 4),
          backgroundColor: AVRColors.error,
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Failed to download invoice: ${e.toString().replaceAll('Exception:', '').trim()}',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
