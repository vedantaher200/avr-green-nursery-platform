import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../theme/app_theme.dart';
import '../localization/app_strings.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Network Error Detection & Recovery Mechanism
// Handles intermittent rural / agricultural mobile connectivity issues.
// Allows farmers to retry pending operations without losing progress or state.
// ─────────────────────────────────────────────────────────────────────────────

/// Checks if an error is caused by network / connectivity failure.
bool isNetworkException(dynamic error) {
  if (error == null) return false;
  if (error is SocketException || error is TimeoutException || error is HttpException) {
    return true;
  }
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        return code != null && (code == 502 || code == 503 || code == 504);
      default:
        final msg = error.message?.toLowerCase() ?? '';
        return msg.contains('socket') ||
            msg.contains('network') ||
            msg.contains('connection refused') ||
            msg.contains('failed host lookup') ||
            msg.contains('timed out');
    }
  }
  final str = error.toString().toLowerCase();
  return str.contains('socketexception') ||
      str.contains('network') ||
      str.contains('connection refused') ||
      str.contains('failed host lookup') ||
      str.contains('clientexception') ||
      str.contains('timed out') ||
      str.contains('offline');
}

/// Displays the Network Issue Retry Popup Dialog.
/// Returns true if retry succeeded, false if user cancelled.
Future<bool> showNetworkRetryPopup({
  required BuildContext context,
  required String pendingProcessName,
  String? customMessage,
  required Future<void> Function() onRetry,
  AppLanguage language = AppLanguage.en,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) => _NetworkRetryDialogWidget(
      pendingProcessName: pendingProcessName,
      customMessage: customMessage,
      onRetry: onRetry,
      language: language,
    ),
  );
  return result ?? false;
}

/// Executes an async action with automatic Network Retry Popup support.
/// If a network error occurs, pops up the Retry Dialog and allows the farmer
/// to continue the pending process as soon as connection is restored.
Future<T?> runWithNetworkRetry<T>({
  required BuildContext context,
  required String pendingProcessName,
  required Future<T> Function() action,
  VoidCallback? onCancel,
  AppLanguage language = AppLanguage.en,
}) async {
  while (true) {
    try {
      return await action();
    } catch (error) {
      if (isNetworkException(error)) {
        bool retrySuccess = false;
        T? actionResult;

        final proceed = await showNetworkRetryPopup(
          context: context,
          pendingProcessName: pendingProcessName,
          language: language,
          onRetry: () async {
            actionResult = await action();
            retrySuccess = true;
          },
        );

        if (proceed && retrySuccess) {
          return actionResult;
        } else {
          onCancel?.call();
          return null;
        }
      } else {
        // Not a network issue; bubble up to ordinary handler
        rethrow;
      }
    }
  }
}

// ── Interactive Network Retry Dialog Widget ──────────────────────────────────
class _NetworkRetryDialogWidget extends StatefulWidget {
  final String pendingProcessName;
  final String? customMessage;
  final Future<void> Function() onRetry;
  final AppLanguage language;

  const _NetworkRetryDialogWidget({
    required this.pendingProcessName,
    this.customMessage,
    required this.onRetry,
    required this.language,
  });

  @override
  State<_NetworkRetryDialogWidget> createState() => _NetworkRetryDialogWidgetState();
}

class _NetworkRetryDialogWidgetState extends State<_NetworkRetryDialogWidget> {
  bool _isRetrying = false;
  String? _retryErrorMessage;

  Future<void> _executeRetry() async {
    setState(() {
      _isRetrying = true;
      _retryErrorMessage = null;
    });

    try {
      await widget.onRetry();
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRetrying = false;
        _retryErrorMessage = 'Still unable to reach network. Please check your signal and tap Try Again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = AppStrings.get('network_issue_title', widget.language);
    final msg = widget.customMessage ?? AppStrings.get('network_issue_msg', widget.language);
    final tryAgain = AppStrings.get('try_again', widget.language);
    final cancel = AppStrings.get('cancel', widget.language);
    final pendingLabel = AppStrings.get('pending_process', widget.language);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 12,
      contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Alert Icon
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AVRColors.terracotta.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.wifi_off_rounded,
                  color: AVRColors.terracotta,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AVRColors.forestGreenDark,
              ),
            ),
            const SizedBox(height: 8),

            // Explanation message
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),

            // Pending Process Pill
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sync_problem_rounded, size: 14, color: AVRColors.terracotta),
                      const SizedBox(width: 4),
                      Text(
                        pendingLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AVRColors.terracotta,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.pendingProcessName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AVRColors.forestGreenDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Your input & choices are preserved. Resuming pending process upon reconnect.',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),

            if (_retryErrorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _retryErrorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AVRColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 18),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isRetrying
                        ? null
                        : () => Navigator.of(context, rootNavigator: true).pop(false),
                    child: Text(
                      cancel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AVRColors.forestGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: _isRetrying ? null : _executeRetry,
                    child: _isRetrying
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.refresh_rounded, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                tryAgain,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
