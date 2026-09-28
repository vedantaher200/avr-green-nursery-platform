import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../localization/app_strings.dart';
import '../../features/auth/data/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Main App Shell — Responsive Navigation
// Mobile: Bottom Navigation Bar
// Tablet/Web: Navigation Rail (Sidebar)
// ─────────────────────────────────────────────────────────────────────────────

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authStateProvider).role ?? 'customer';

    // Farmer / Customer ALWAYS has the clean mobile bottom navigation without a permanent desktop sidebar
    if (role == 'customer') {
      return _MobileShell(child: child);
    }

    final size = MediaQuery.of(context).size;
    final isTabletOrWeb = size.width >= 768;

    if (isTabletOrWeb) {
      return _DesktopShell(child: child);
    }
    return _MobileShell(child: child);
  }
}

// ── Mobile Shell with Bottom Navigation ──────────────────────────────────────
class _MobileShell extends ConsumerWidget {
  final Widget child;
  const _MobileShell({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authStateProvider).role ?? 'customer';
    final language = ref.watch(appLanguageProvider);
    final navItems = _getNavItemsForRole(role, language);
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getCurrentIndex(location, navItems);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: navItems.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final isSelected = i == currentIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => context.go(item.route),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AVRColors.forestGreenSurface
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected
                                  ? AVRColors.forestGreen
                                  : AVRColors.textDisabled,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: AVRTextStyles.labelSmall.copyWith(
                              color: isSelected
                                  ? AVRColors.forestGreen
                                  : AVRColors.textDisabled,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Desktop/Tablet Shell with Navigation Rail (Sidebar) ──────────────────────
class _DesktopShell extends ConsumerWidget {
  final Widget child;
  const _DesktopShell({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authStateProvider).role ?? 'customer';
    final language = ref.watch(appLanguageProvider);
    final navItems = _getNavItemsForRole(role, language);
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getCurrentIndex(location, navItems);
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= 1280;

    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ─────────────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isWideScreen ? 240 : 72,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AVRColors.forestGreenDark, AVRColors.forestGreen],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWideScreen ? 20 : 12,
                      vertical: 28,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.eco_rounded,
                              color: Colors.white, size: 24),
                        ),
                        if (isWideScreen) ...[
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AVRGREEN',
                                style: AVRTextStyles.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                'Nursery Management',
                                style: AVRTextStyles.labelSmall.copyWith(
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 8),
                  // Nav Items
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWideScreen ? 12 : 8,
                        vertical: 4,
                      ),
                      itemCount: navItems.length,
                      itemBuilder: (ctx, i) {
                        final item = navItems[i];
                        final isSelected = i == currentIndex;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: InkWell(
                            onTap: () => context.go(item.route),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                horizontal: isWideScreen ? 12 : 8,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color:
                                            Colors.white.withValues(alpha: 0.2))
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? item.activeIcon : item.icon,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white60,
                                    size: 20,
                                  ),
                                  if (isWideScreen) ...[
                                    const SizedBox(width: 12),
                                    Text(
                                      item.label,
                                      style: AVRTextStyles.bodyMedium.copyWith(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white60,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Main Content ────────────────────────────────────────────────────
          Expanded(
            child: ClipRect(child: child),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Role-based Navigation Configuration
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

List<_NavItem> _getNavItemsForRole(String role, AppLanguage lang) {
  switch (role) {
    case 'super_admin':
      return [
        const _NavItem(
            label: 'Platform',
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            route: '/superadmin'),
        const _NavItem(
            label: 'Tenants',
            icon: Icons.business_outlined,
            activeIcon: Icons.business,
            route: '/superadmin'),
        const _NavItem(
            label: 'Reports',
            icon: Icons.bar_chart_outlined,
            activeIcon: Icons.bar_chart,
            route: '/reports'),
      ];
    case 'owner':
    case 'manager':
      return [
        const _NavItem(
            label: 'Home',
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            route: '/dashboard'),
        const _NavItem(
            label: 'Catalog',
            icon: Icons.eco_outlined,
            activeIcon: Icons.eco_rounded,
            route: '/catalog'),
        const _NavItem(
            label: 'Offers',
            icon: Icons.campaign_outlined,
            activeIcon: Icons.campaign_rounded,
            route: '/owner/offers'),
        const _NavItem(
            label: 'Stock',
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2_rounded,
            route: '/inventory'),
        const _NavItem(
            label: 'Orders',
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            route: '/orders'),
        const _NavItem(
            label: 'Reports',
            icon: Icons.bar_chart_outlined,
            activeIcon: Icons.bar_chart_rounded,
            route: '/reports'),
      ];
    case 'staff':
      return [
        const _NavItem(
            label: 'Dashboard',
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            route: '/dashboard'),
        const _NavItem(
            label: 'Inventory',
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2_rounded,
            route: '/inventory'),
        const _NavItem(
            label: 'Orders',
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            route: '/orders'),
      ];
    case 'delivery_agent':
      return [
        const _NavItem(
            label: 'Deliveries',
            icon: Icons.local_shipping_outlined,
            activeIcon: Icons.local_shipping_rounded,
            route: '/deliveries'),
        const _NavItem(
            label: 'History',
            icon: Icons.history_outlined,
            activeIcon: Icons.history_rounded,
            route: '/orders'),
      ];
    case 'customer':
    default:
      return [
        _NavItem(
            label: AppStrings.get('nav_home', lang),
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            route: '/storefront'),
        _NavItem(
            label: AppStrings.get('nav_categories', lang),
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            route: '/catalog'),
        _NavItem(
            label: AppStrings.get('nav_offers', lang),
            icon: Icons.local_offer_outlined,
            activeIcon: Icons.local_offer_rounded,
            route: '/offers'),
        _NavItem(
            label: AppStrings.get('nav_orders', lang),
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            route: '/orders'),
        _NavItem(
            label: AppStrings.get('nav_profile', lang),
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            route: '/profile'),
      ];
  }
}

int _getCurrentIndex(String location, List<_NavItem> items) {
  for (int i = 0; i < items.length; i++) {
    if (location.startsWith(items[i].route)) return i;
  }
  return 0;
}
