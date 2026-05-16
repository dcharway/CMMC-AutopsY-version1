import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'parse_config.dart';

enum UserRole { admin, contributor }

/// Auth-state container backed by Back4App / Parse Server.
///
/// - [hydrate] initializes the Parse SDK and restores any saved session.
/// - [signIn], [signUp], [signOut] delegate to ParseUser.
/// - [isAdmin] is true when the authenticated user has `role == 'admin'`
///   on their `_User` record.
class AuthState extends ChangeNotifier {
  ParseUser? _user;
  bool _hydrated = false;
  String? _lastError;
  bool _initialized = false;

  bool get hydrated => _hydrated;
  bool get loggedIn => _user != null;
  String? get email => _user?.emailAddress ?? _user?.username;
  String? get displayName {
    final n = _user?.get<String>('displayName');
    if (n != null && n.trim().isNotEmpty) return n;
    return _user?.username;
  }

  UserRole? get role {
    if (_user == null) return null;
    final r = _user!.get<String>(kRoleFieldName);
    if (r == 'admin') return UserRole.admin;
    return UserRole.contributor;
  }

  bool get isAdmin => role == UserRole.admin;
  String? get lastError => _lastError;

  /// Initialize Parse + restore any persisted session.
  Future<void> hydrate() async {
    try {
      if (!_initialized) {
        await Parse().initialize(
          kParseApplicationId,
          kParseServerUrl,
          clientKey: kParseClientKey,
          autoSendSessionId: true,
          debug: kDebugMode,
        );
        _initialized = true;
      }
      final stored = await ParseUser.currentUser() as ParseUser?;
      if (stored != null) {
        _user = stored;
        // Try to refresh role / displayName from the server in the background.
        // We don't block startup on this — if it fails (offline, expired
        // session) the cached values are good enough until next login.
        unawaited(_refreshCurrentUser(stored));
      }
    } catch (e) {
      debugPrint('AuthState.hydrate: $e');
    } finally {
      _hydrated = true;
      notifyListeners();
    }
  }

  /// Returns true on success. On failure sets [lastError] and notifies.
  Future<bool> signIn({required String email, required String password}) async {
    _lastError = null;
    notifyListeners();
    try {
      final user = ParseUser(email.trim(), password, email.trim());
      final res = await user.login();
      if (!res.success) {
        _lastError = _humanize(res.error?.message) ??
            'Sign-in failed. Check your email and password.';
        notifyListeners();
        return false;
      }
      _user = res.result as ParseUser;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = 'Network error: $e';
      notifyListeners();
      return false;
    }
  }

  /// Registers a new account on Back4App. If [asAdmin] is true the user is
  /// flagged with `role: 'admin'` so they land on the admin console.
  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
    bool asAdmin = true,
  }) async {
    _lastError = null;
    notifyListeners();
    try {
      final user = ParseUser(email.trim(), password, email.trim());
      if (displayName != null && displayName.trim().isNotEmpty) {
        user.set('displayName', displayName.trim());
      }
      user.set(kRoleFieldName, asAdmin ? 'admin' : 'contributor');
      final res = await user.signUp();
      if (!res.success) {
        _lastError = _humanize(res.error?.message) ??
            'Sign-up failed. Try a different email or stronger password.';
        notifyListeners();
        return false;
      }
      _user = res.result as ParseUser;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = 'Network error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      final current = await ParseUser.currentUser() as ParseUser?;
      await current?.logout();
    } catch (e) {
      debugPrint('AuthState.signOut: $e');
    }
    _user = null;
    _lastError = null;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    try {
      final user = ParseUser(null, null, email.trim());
      final res = await user.requestPasswordReset();
      if (!res.success) {
        _lastError = _humanize(res.error?.message);
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      _lastError = 'Network error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> _refreshCurrentUser(ParseUser stored) async {
    try {
      final refreshed = await stored.fetch();
      if (refreshed is ParseUser) {
        _user = refreshed;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('AuthState._refreshCurrentUser: $e');
    }
  }

  String? _humanize(String? raw) {
    if (raw == null) return null;
    // Strip Parse's verbose prefixes
    if (raw.toLowerCase().contains('invalid login')) {
      return 'Invalid email or password.';
    }
    if (raw.toLowerCase().contains('account already exists')) {
      return 'An account with that email already exists.';
    }
    if (raw.toLowerCase().contains('email address is invalid')) {
      return 'That email address is not valid.';
    }
    return raw;
  }
}
