import 'package:flutter/foundation.dart';
import 'package:huawei_account/huawei_account.dart';
import 'auth_params_helper.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  AccountAuthService? _authService;
  AuthAccount? _currentUser;

  /// Initialize Huawei Account service
  void _initService({bool emailPhone = false}) {
    final helper = AuthParamsHelper();

    if (emailPhone) {
      helper.setEmail();
      helper.setMobileNumber();
    }

    helper.setIdToken();
    helper.setAccessToken();

    final params = helper.createParams();
    _authService = AccountAuthManager.getService(params);
  }

  /// Huawei ID login
  Future<AuthAccount?> signInWithHuaweiID() async {
    try {
      _initService();
      final result = await _authService!.signIn();
      _currentUser = result;
      return result;
    } catch (e) {
      debugPrint("Huawei ID login failed: $e");
      return null;
    }
  }

  /// Email/Phone login
  Future<AuthAccount?> signInWithEmailPhone() async {
    try {
      _initService(emailPhone: true);
      final result = await _authService!.signIn();
      _currentUser = result;
      return result;
    } catch (e) {
      debugPrint("Email/Phone login failed: $e");
      return null;
    }
  }

  /// Get current user
  AuthAccount? get currentUser => _currentUser;

  /// Sign out
  Future<void> signOut() async {
    try {
      await _authService?.signOut();
      _currentUser = null;
    } catch (e) {
      debugPrint("Sign out failed: $e");
    }
  }
}
