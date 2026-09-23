import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/api_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth State & Providers (Riverpod)
// ─────────────────────────────────────────────────────────────────────────────

class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? role;
  final String? tenantId;
  final String? firstName;
  final String? accessToken;

  const AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.role,
    this.tenantId,
    this.firstName,
    this.accessToken,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? role,
    String? tenantId,
    String? firstName,
    String? accessToken,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      tenantId: tenantId ?? this.tenantId,
      firstName: firstName ?? this.firstName,
      accessToken: accessToken ?? this.accessToken,
    );
  }

  // Convenience role checkers
  bool get isOwner => role == 'owner';
  bool get isManager => role == 'manager';
  bool get isSuperAdmin => role == 'super_admin';
  bool get isCustomer => role == 'customer';
  bool get isStaff => role == 'staff';
  bool get isDeliveryAgent => role == 'delivery_agent';
  bool get isSupplier => role == 'supplier';
  bool get canManageInventory => isOwner || isManager || isStaff;
  bool get canViewReports => isOwner || isManager || isSuperAdmin;
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier(this._client, this._storage) : super(const AuthState()) {
    restore();
  }
  final ApiClient _client;
  final FlutterSecureStorage _storage;

  Future<void> restore() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return;
    try {
      final response = await _client.dio.get('/auth/me');
      final data = response.data['data'] as Map<String, dynamic>;
      state = AuthState(
          isAuthenticated: true,
          userId: data['userId'],
          role: data['roleName'],
          tenantId: data['tenantId'],
          accessToken: token);
    } on DioException {
      await logout();
    }
  }

  Future<void> loginWithPassword(String email, String password) async {
    final response = await _client.dio
        .post('/auth/login', data: {'email': email, 'password': password});
    final data = response.data['data'] as Map<String, dynamic>;
    if (data['requiresMfa'] == true) {
      throw StateError('Multi-factor verification is required.');
    }
    final token = data['accessToken'] as String;
    await _storage.write(key: 'access_token', value: token);
    await _storage.write(
        key: 'refresh_token', value: data['refreshToken'] as String);
    final me = await _client.dio.get('/auth/me');
    final profile = me.data['data'] as Map<String, dynamic>;
    state = AuthState(
        isAuthenticated: true,
        userId: profile['userId'],
        role: profile['roleName'],
        tenantId: profile['tenantId'],
        firstName: profile['firstName'],
        accessToken: token);
  }

  Future<void> loginWithPhoneAndPin(String phone, String pin) async {
    final cleanPhone = phone.trim();
    final response = await _client.dio
        .post('/auth/login', data: {'phone': cleanPhone, 'pin': pin.trim()});
    final data = response.data['data'] as Map<String, dynamic>;
    if (data['requiresMfa'] == true) {
      throw StateError('Multi-factor verification is required.');
    }
    final token = data['accessToken'] as String;
    await _storage.write(key: 'access_token', value: token);
    await _storage.write(
        key: 'refresh_token', value: data['refreshToken'] as String);
    final me = await _client.dio.get('/auth/me');
    final profile = me.data['data'] as Map<String, dynamic>;
    state = AuthState(
        isAuthenticated: true,
        userId: profile['userId'],
        role: profile['roleName'],
        tenantId: profile['tenantId'],
        firstName: profile['firstName'] ?? 'Farmer',
        accessToken: token);
  }

  Future<void> registerFarmer({
    required String phone,
    required String pin,
    String? firstName,
  }) async {
    final cleanPhone = phone.trim();
    await _client.dio.post('/auth/register', data: {
      'phone': cleanPhone,
      'pin': pin.trim(),
      'firstName': firstName?.trim() ?? 'Farmer',
      'role': 'customer',
    });
    // Immediately log in without any OTP
    await loginWithPhoneAndPin(cleanPhone, pin);
  }

  Future<void> login({
    required String userId,
    required String role,
    required String firstName,
    String? tenantId,
    String? accessToken,
  }) async {
    state = AuthState(
      isAuthenticated: true,
      userId: userId,
      role: role,
      tenantId: tenantId,
      firstName: firstName,
      accessToken: accessToken,
    );
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AuthState();
  }
}

final secureStorageProvider = Provider((_) => const FlutterSecureStorage());
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(ref.watch(secureStorageProvider));
  client.configure();
  return client;
});

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>(
  (ref) => AuthStateNotifier(
      ref.watch(apiClientProvider), ref.watch(secureStorageProvider)),
);
