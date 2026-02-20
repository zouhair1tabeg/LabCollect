import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/user_model.dart';
import '../repositories/auth_repository.dart';

// ── Auth State ──────────────────────────────────────────

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final UserModel? user;
  final AuthStatus status;
  final String? error;

  const AuthState({this.user, this.status = AuthStatus.initial, this.error});

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({UserModel? user, AuthStatus? status, String? error}) {
    return AuthState(
      user: user ?? this.user,
      status: status ?? this.status,
      error: error,
    );
  }
}

// ── Auth Notifier ───────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final FlutterSecureStorage _secureStorage;

  AuthNotifier(this._repository, this._secureStorage)
    : super(const AuthState()) {
    _tryAutoLogin();
  }

  /// Attempt to restore session from secure storage on app startup
  Future<void> _tryAutoLogin() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final token = await _secureStorage.read(key: AppConstants.secureTokenKey);
      final userJson = await _secureStorage.read(
        key: AppConstants.secureUserKey,
      );

      if (token != null && userJson != null) {
        final user = UserModel.fromJson(
          jsonDecode(userJson) as Map<String, dynamic>,
        );
        state = AuthState(user: user, status: AuthStatus.authenticated);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      // Corrupted data — clear and go to login
      await _secureStorage.deleteAll();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      final user = await _repository.login(email, password);

      // Persist token & user JSON via secure storage
      await _secureStorage.write(
        key: AppConstants.secureTokenKey,
        value: user.token,
      );
      await _secureStorage.write(
        key: AppConstants.secureUserKey,
        value: jsonEncode(user.toJson()),
      );

      state = AuthState(user: user, status: AuthStatus.authenticated);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Clear session and return to unauthenticated state
  Future<void> logout() async {
    await _secureStorage.deleteAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

// ── Providers ───────────────────────────────────────────

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(secureStorageProvider),
  );
});
