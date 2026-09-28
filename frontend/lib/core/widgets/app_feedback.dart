import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class AppFeedback {
  /// Displays a non-blocking, auto-dismissing cart confirmation banner.
  /// Prevents stacking, does not block the UI, and provides a functioning "VIEW CART" action.
  static void showCartSuccess(
    BuildContext context, {
    required String message,
    VoidCallback? onGoToCart,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    // Atomically dismiss any existing snackbars to avoid broken stacking or permanent banners
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 74, left: 16, right: 16),
        duration: const Duration(seconds: 3),
        elevation: 6,
        backgroundColor: AVRColors.forestGreenDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: AVRColors.sage.withValues(alpha: 0.3)),
        ),
        dismissDirection: DismissDirection.horizontal,
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: const Color(0xFFFBBF24),
          onPressed: () {
            messenger.hideCurrentSnackBar();
            if (onGoToCart != null) {
              onGoToCart();
            } else {
              context.push('/cart');
            }
          },
        ),
      ),
    );
  }
}
