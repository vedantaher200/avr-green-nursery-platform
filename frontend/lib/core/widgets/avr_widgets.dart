import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Widget Library — AVRGREEN Component System
// ─────────────────────────────────────────────────────────────────────────────

// ── KPI Stat Card ────────────────────────────────────────────────────────────
class AVRStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final LinearGradient? gradient;
  final String? trend; // e.g. "+12%"
  final bool trendUp;
  final VoidCallback? onTap;

  const AVRStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.color,
    this.gradient,
    this.trend,
    this.trendUp = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AVRColors.forestGreen;
    final cardGradient = gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardColor, cardColor.withValues(alpha: 0.8)],
        );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: cardGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: cardColor.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                if (trend != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendUp ? Icons.trending_up : Icons.trending_down,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(trend!,
                            style: AVRTextStyles.labelSmall
                                .copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(value,
                style: AVRTextStyles.kpiValue.copyWith(color: Colors.white)),
            const SizedBox(height: 2),
            Text(title,
                style: AVRTextStyles.bodySmall.copyWith(color: Colors.white70)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!,
                  style:
                      AVRTextStyles.labelSmall.copyWith(color: Colors.white54)),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

// ── Status Badge ─────────────────────────────────────────────────────────────
class AVRStatusBadge extends StatelessWidget {
  final String status;
  const AVRStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig[status.toLowerCase()] ??
        const _StatusConfig(AVRColors.sage, 'Unknown', Icons.help_outline);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(color: config.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(config.label,
              style: AVRTextStyles.labelSmall
                  .copyWith(color: config.color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  static final Map<String, _StatusConfig> _statusConfig = {
    'active':
        const _StatusConfig(AVRColors.success, 'Active', Icons.check_circle),
    'pending_payment': const _StatusConfig(
        AVRColors.warning, 'Pending Payment', Icons.pending),
    'confirmed': const _StatusConfig(AVRColors.info, 'Confirmed', Icons.check),
    'packed': const _StatusConfig(AVRColors.info, 'Packed', Icons.inventory),
    'dispatched': const _StatusConfig(
        AVRColors.terracotta, 'Dispatched', Icons.local_shipping),
    'in_transit': const _StatusConfig(
        AVRColors.terracotta, 'In Transit', Icons.directions_car),
    'delivered':
        const _StatusConfig(AVRColors.success, 'Delivered', Icons.done_all),
    'cancelled':
        const _StatusConfig(AVRColors.error, 'Cancelled', Icons.cancel),
    'failed': const _StatusConfig(AVRColors.error, 'Failed', Icons.error),
    'low_stock':
        const _StatusConfig(AVRColors.warning, 'Low Stock', Icons.warning),
    'assigned':
        const _StatusConfig(AVRColors.info, 'Assigned', Icons.assignment),
  };
}

class _StatusConfig {
  final Color color;
  final String label;
  final IconData icon;
  const _StatusConfig(this.color, this.label, this.icon);
}

// ── Loading Shimmer Card ──────────────────────────────────────────────────────
class AVRShimmerCard extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  const AVRShimmerCard(
      {super.key, this.height = 80, this.width, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AVRColors.sageSurface,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
          duration: 1200.ms,
          color: Colors.white.withValues(alpha: 0.6),
        );
  }
}

// ── Search Bar ───────────────────────────────────────────────────────────────
class AVRSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;

  const AVRSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search_rounded,
              color: AVRColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: AVRTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AVRTextStyles.bodyMedium
                    .copyWith(color: AVRColors.textDisabled),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                filled: false,
              ),
            ),
          ),
          if (onFilterTap != null)
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AVRColors.forestGreenSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune_rounded,
                    color: AVRColors.forestGreen, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class AVREmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AVREmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AVRColors.forestGreenSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AVRColors.forestGreen, size: 40),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(title,
                    style: AVRTextStyles.titleLarge,
                    textAlign: TextAlign.center)
                .animate()
                .fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Text(subtitle,
                    style: AVRTextStyles.bodyMedium
                        .copyWith(color: AVRColors.textSecondary),
                    textAlign: TextAlign.center)
                .animate()
                .fadeIn(delay: 300.ms),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class AVRSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onActionTap; // Alias for onAction

  const AVRSectionHeader(
      {super.key, required this.title, this.actionLabel, this.onAction, this.onActionTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AVRTextStyles.titleMedium),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction ?? onActionTap,
              child: Text(actionLabel!,
                  style: AVRTextStyles.labelLarge
                      .copyWith(color: AVRColors.forestGreen)),
            ),
        ],
      ),
    );
  }
}
