import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _Mode { signIn, signUp }

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _displayName = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _obscure = true;
  bool _busy = false;
  bool _remember = true;
  _Mode _mode = _Mode.signIn;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _displayName.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final auth = context.read<AuthState>();
    final ok = _mode == _Mode.signIn
        ? await auth.signIn(email: _email.text, password: _password.text)
        : await auth.signUp(
            email: _email.text,
            password: _password.text,
            displayName: _displayName.text,
            asAdmin: true,
          );
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(auth.lastError ?? 'Authentication failed'),
            backgroundColor: const Color(0xFFDC2626)),
      );
    }
  }

  Future<void> _onForgot() async {
    if (_email.text.trim().isEmpty || !_email.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Enter your email above first, then tap Forgot password.'),
      ));
      return;
    }
    final auth = context.read<AuthState>();
    final ok = await auth.resetPassword(_email.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'If an account exists for ${_email.text}, a reset link is on its way.'
          : (auth.lastError ?? 'Could not send reset email.')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;

    final form = _LoginForm(
      mode: _mode,
      onChangeMode: (m) => setState(() => _mode = m),
      formKey: _form,
      email: _email,
      password: _password,
      displayName: _displayName,
      obscure: _obscure,
      onToggleObscure: () => setState(() => _obscure = !_obscure),
      remember: _remember,
      onRemember: (v) => setState(() => _remember = v ?? true),
      busy: _busy,
      onSubmit: _submit,
      onForgot: _onForgot,
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _Backdrop(),
          SafeArea(
            child: isWide
                ? Row(children: [
                    Expanded(child: _HeroPane(big: true)),
                    SizedBox(
                      width: 460,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 24),
                        child: SingleChildScrollView(child: form),
                      ),
                    ),
                  ])
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        const _HeroPane(big: false),
                        const SizedBox(height: 24),
                        Card(
                          color: Colors.white,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: form,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF03050E), Color(0xFF0B0E22), Color(0xFF1A1206)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

class _HeroPane extends StatelessWidget {
  const _HeroPane({required this.big});
  final bool big;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: big ? 56 : 16, vertical: big ? 48 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.15),
                border: Border.all(color: const Color(0xFFD4AF37)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shield_outlined,
                  color: Color(0xFFE9C56F)),
            ),
            const SizedBox(width: 12),
            const Text('cyberAutopsy',
                style: TextStyle(
                  color: Color(0xFFE9C56F),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                )),
          ]),
          SizedBox(height: big ? 36 : 20),
          Text(
            'Balance compliance.\nProve readiness.',
            style: TextStyle(
              color: Colors.white,
              fontSize: big ? 44 : 26,
              fontWeight: FontWeight.w700,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'The executive console for Registered Provider Organizations '
            'managing CMMC Level 2 engagements.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: big ? 16 : 13,
              height: 1.5,
            ),
          ),
          SizedBox(height: big ? 36 : 22),
          if (big) ...[
            _heroPoint(Icons.balance, 'Stoplight readiness across every client'),
            _heroPoint(Icons.lock_outline, 'Evidence governed end-to-end'),
            _heroPoint(Icons.workspace_premium_outlined,
                'Audit packets exportable in one click'),
          ],
        ],
      ),
    );
  }

  Widget _heroPoint(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, color: const Color(0xFFE9C56F), size: 18),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: TextStyle(color: Colors.white.withOpacity(0.85)))),
      ]),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.mode,
    required this.onChangeMode,
    required this.formKey,
    required this.email,
    required this.password,
    required this.displayName,
    required this.obscure,
    required this.onToggleObscure,
    required this.remember,
    required this.onRemember,
    required this.busy,
    required this.onSubmit,
    required this.onForgot,
  });

  final _Mode mode;
  final ValueChanged<_Mode> onChangeMode;
  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController displayName;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final bool remember;
  final ValueChanged<bool?> onRemember;
  final bool busy;
  final VoidCallback onSubmit;
  final VoidCallback onForgot;

  bool get _isSignUp => mode == _Mode.signUp;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_isSignUp ? 'Create admin account' : 'Sign in',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(
            _isSignUp
                ? 'Register a Back4App user with admin privileges for the RPO console.'
                : 'Access your RPO administrator workspace.',
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          _ModeToggle(mode: mode, onChange: onChangeMode),
          const SizedBox(height: 16),
          if (_isSignUp) ...[
            TextFormField(
              controller: displayName,
              autofillHints: const [AutofillHints.name],
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.badge_outlined, size: 18),
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().length < 2)
                  ? 'Enter your name'
                  : null,
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email, AutofillHints.username],
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline, size: 18),
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || !v.contains('@'))
                ? 'Enter a valid email'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: password,
            obscureText: obscure,
            autofillHints: _isSignUp
                ? const [AutofillHints.newPassword]
                : const [AutofillHints.password],
            onFieldSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline, size: 18),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility : Icons.visibility_off,
                    size: 18),
                onPressed: onToggleObscure,
              ),
              helperText: _isSignUp ? 'Minimum 8 characters recommended.' : null,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter your password';
              if (_isSignUp && v.length < 6) {
                return 'Password should be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          if (!_isSignUp)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Checkbox(value: remember, onChanged: onRemember),
                  const Text('Stay signed in'),
                ]),
                TextButton(
                    onPressed: onForgot,
                    child: const Text('Forgot password?')),
              ],
            ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF030213),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: busy ? null : onSubmit,
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Icon(_isSignUp ? Icons.person_add_alt_1 : Icons.login),
              label: Text(busy
                  ? (_isSignUp ? 'Creating account…' : 'Signing in…')
                  : (_isSignUp ? 'Create account' : 'Sign in')),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(children: [
              Icon(Icons.cloud_done_outlined,
                  size: 16, color: Color(0xFF0F172A)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Authenticated by Back4App (Parse Server).',
                  style: TextStyle(fontSize: 12, color: Color(0xFF334155)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              '© cyberAutopsy',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChange});
  final _Mode mode;
  final ValueChanged<_Mode> onChange;

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, _Mode value) {
      final selected = mode == value;
      return Expanded(
        child: InkWell(
          onTap: () => onChange(value),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 4,
                          offset: Offset(0, 1))
                    ]
                  : null,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        tab('Sign in', _Mode.signIn),
        tab('Create account', _Mode.signUp),
      ]),
    );
  }
}
