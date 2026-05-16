import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { admin, contributor }

class _DemoAccount {
  const _DemoAccount(this.email, this.password, this.role, this.displayName);
  final String email;
  final String password;
  final UserRole role;
  final String displayName;
}

// Demo credentials for the local-only build. Replace with real auth (OIDC,
// SSO, etc.) when wiring to a backend.
const _demoAccounts = <_DemoAccount>[
  _DemoAccount('admin@cyberautopsy.com', 'admin', UserRole.admin,
      'RPO Administrator'),
  _DemoAccount('contributor@cyberautopsy.com', 'contributor',
      UserRole.contributor, 'Control Owner'),
];

const _kPrefsEmail = 'cyber_autopsy_session_email';

class AuthState extends ChangeNotifier {
  String? _email;
  UserRole? _role;
  String? _displayName;
  bool _hydrated = false;
  String? _lastError;

  bool get hydrated => _hydrated;
  bool get loggedIn => _role != null;
  bool get isAdmin => _role == UserRole.admin;
  String? get email => _email;
  String? get displayName => _displayName;
  UserRole? get role => _role;
  String? get lastError => _lastError;

  Future<void> hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_kPrefsEmail);
      if (email != null) {
        final acct = _demoAccounts
            .where((a) => a.email.toLowerCase() == email.toLowerCase())
            .firstOrNull;
        if (acct != null) {
          _email = acct.email;
          _role = acct.role;
          _displayName = acct.displayName;
        }
      }
    } catch (_) {
      // ignore — first launch
    } finally {
      _hydrated = true;
      notifyListeners();
    }
  }

  /// Returns true on success. Sets [lastError] on failure.
  Future<bool> signIn({required String email, required String password}) async {
    final acct = _demoAccounts
        .where((a) =>
            a.email.toLowerCase() == email.trim().toLowerCase() &&
            a.password == password)
        .firstOrNull;
    if (acct == null) {
      _lastError = 'Invalid email or password.';
      notifyListeners();
      return false;
    }
    _email = acct.email;
    _role = acct.role;
    _displayName = acct.displayName;
    _lastError = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefsEmail, acct.email);
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    _email = null;
    _role = null;
    _displayName = null;
    _lastError = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrefsEmail);
    notifyListeners();
  }

  /// For the demo banner on the login screen.
  static List<({String email, String password, String role})> get demoHints =>
      _demoAccounts
          .map((a) => (
                email: a.email,
                password: a.password,
                role: a.role == UserRole.admin ? 'RPO Admin' : 'Contributor'
              ))
          .toList();
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
