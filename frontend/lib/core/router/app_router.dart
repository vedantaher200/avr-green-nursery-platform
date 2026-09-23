import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/catalog/presentation/screens/catalog_screen.dart';
import '../../features/catalog/presentation/screens/product_detail_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/order/presentation/screens/orders_screen.dart';
import '../../features/order/presentation/screens/order_detail_screen.dart';
import '../../features/delivery/presentation/screens/delivery_dashboard_screen.dart';
import '../../features/delivery/presentation/screens/live_tracking_screen.dart';
import '../../features/customer/presentation/screens/storefront_screen.dart';
import '../../features/customer/presentation/screens/cart_screen.dart';
import '../../features/customer/presentation/screens/checkout_screen.dart';
import '../../features/customer/presentation/screens/profile_screen.dart';
import '../../features/report/presentation/screens/reports_screen.dart';
import '../../features/superadmin/presentation/screens/superadmin_screen.dart';
import '../../features/auth/data/providers/auth_provider.dart';
import '../shell/main_shell.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GoRouter Configuration with Role-Based Guards
// ─────────────────────────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/otp');

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }
      if (isAuthenticated && isAuthRoute) {
        return authState.isCustomer
            ? '/storefront'
            : authState.isSuperAdmin
                ? '/superadmin'
                : authState.isDeliveryAgent
                    ? '/deliveries'
                    : '/dashboard';
      }
      final path = state.matchedLocation;
      if (path == '/superadmin' && !authState.isSuperAdmin) {
        return '/dashboard';
      }
      if (path.startsWith('/reports') && !authState.canViewReports) {
        return '/storefront';
      }
      if (path.startsWith('/inventory') && !authState.canManageInventory) {
        return '/storefront';
      }
      if (authState.isCustomer &&
          !(path.startsWith('/storefront') ||
              path.startsWith('/catalog') ||
              path.startsWith('/cart') ||
              path.startsWith('/checkout') ||
              path.startsWith('/orders') ||
              path.startsWith('/profile') ||
              path.startsWith('/deliveries'))) {
        return '/storefront';
      }
      if (authState.isDeliveryAgent && !path.startsWith('/deliveries')) {
        return '/deliveries';
      }
      if (authState.isSuperAdmin && !path.startsWith('/superadmin')) {
        return '/superadmin';
      }
      return null;
    },
    routes: [
      // ── Auth Routes ───────────────────────────────────────────────────────
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
          path: '/otp',
          builder: (_, state) => OtpVerificationScreen(
                phone: state.extra as String? ?? '',
              )),

      // ── App Shell (Authenticated) ─────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
              path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/catalog', builder: (_, __) => const CatalogScreen()),
          GoRoute(
            path: '/catalog/:productId',
            builder: (_, state) => ProductDetailScreen(
              productId: state.pathParameters['productId']!,
            ),
          ),
          GoRoute(
              path: '/inventory', builder: (_, __) => const InventoryScreen()),
          GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
          GoRoute(
            path: '/orders/:orderId',
            builder: (_, state) => OrderDetailScreen(
              orderId: state.pathParameters['orderId']!,
            ),
          ),
          GoRoute(
              path: '/deliveries',
              builder: (_, __) => const DeliveryDashboardScreen()),
          GoRoute(
            path: '/deliveries/:deliveryId/track',
            builder: (_, state) => LiveTrackingScreen(
              deliveryId: state.pathParameters['deliveryId']!,
            ),
          ),
          GoRoute(
              path: '/storefront',
              builder: (_, __) => const StorefrontScreen()),
          GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
          GoRoute(
              path: '/checkout', builder: (_, __) => const CheckoutScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
          GoRoute(
              path: '/superadmin',
              builder: (_, __) => const SuperAdminScreen()),
        ],
      ),
    ],
  );
});
