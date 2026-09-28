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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: cardGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: cardColor.withValues(alpha: 0.22),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                if (trend != null)
                  Flexible(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            trendUp ? Icons.trending_up : Icons.trending_down,
                            color: Colors.white,
                            size: 11,
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              trend!,
                              style: AVRTextStyles.labelSmall
                                  .copyWith(color: Colors.white, fontSize: 9),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: AVRTextStyles.kpiValue.copyWith(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: AVRTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: AVRTextStyles.labelSmall.copyWith(
                        color: Colors.white70,
                        fontSize: 9,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.08, end: 0);
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 11, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: AVRTextStyles.labelSmall
                .copyWith(color: config.color, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ],
      ),
    );
  }

  static final Map<String, _StatusConfig> _statusConfig = {
    'active':
        const _StatusConfig(AVRColors.success, 'Active', Icons.check_circle_outline),
    'pending':
        const _StatusConfig(AVRColors.warning, 'Pending', Icons.schedule),
    'pending_payment': const _StatusConfig(
        AVRColors.warning, 'Pending Payment', Icons.pending_outlined),
    'confirmed': const _StatusConfig(AVRColors.info, 'Confirmed', Icons.check_circle),
    'packed': const _StatusConfig(AVRColors.info, 'Packed', Icons.inventory_2_outlined),
    'dispatched': const _StatusConfig(
        AVRColors.terracotta, 'Dispatched', Icons.local_shipping_outlined),
    'in_transit': const _StatusConfig(
        AVRColors.terracotta, 'In Transit', Icons.directions_car_outlined),
    'delivered':
        const _StatusConfig(AVRColors.success, 'Delivered', Icons.done_all_rounded),
    'cancelled':
        const _StatusConfig(AVRColors.error, 'Cancelled', Icons.cancel_outlined),
    'failed': const _StatusConfig(AVRColors.error, 'Failed', Icons.error_outline),
    'ready_now':
        const _StatusConfig(AVRColors.success, 'Ready Stock', Icons.eco_rounded),
    'limited_stock':
        const _StatusConfig(Color(0xFFD97706), 'Limited Stock', Icons.warning_amber_rounded),
    'prebook_available':
        const _StatusConfig(Color(0xFFEA580C), 'Pre-Book Open', Icons.bookmark_added_rounded),
    'coming_soon':
        const _StatusConfig(Color(0xFF0284C7), 'Coming Soon', Icons.schedule_rounded),
    'sold_out':
        const _StatusConfig(Color(0xFF64748B), 'Sold Out', Icons.block_rounded),
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
