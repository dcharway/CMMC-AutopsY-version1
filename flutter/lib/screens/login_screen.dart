import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _obscure = true;
  bool _busy = false;
  bool _remember = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final ok = await context.read<AuthState>().signIn(
          email: _email.text,
          password: _password.text,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(context.read<AuthState>().lastError ?? 'Sign-in failed'),
            backgroundColor: const Color(0xFFDC2626)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;

    final form = _LoginForm(
      formKey: _form,
      email: _email,
      password: _password,
      obscure: _obscure,
      onToggleObscure: () => setState(() => _obscure = !_obscure),
      remember: _remember,
      onRemember: (v) => setState(() => _remember = v ?? true),
      busy: _busy,
      onSubmit: _submit,
      onFillDemo: (email, password) {
        _email.text = email;
        _password.text = password;
      },
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
    required this.formKey,
    required this.email,
    required this.password,
    required this.obscure,
    required this.onToggleObscure,
    required this.remember,
    required this.onRemember,
    required this.busy,
    required this.onSubmit,
    required this.onFillDemo,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final bool remember;
  final ValueChanged<bool?> onRemember;
  final bool busy;
  final VoidCallback onSubmit;
  final void Function(String email, String password) onFillDemo;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Sign in',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          const Text('Access your RPO administrator workspace.',
              style: TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 24),
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
          const SizedBox(height: 14),
          TextFormField(
            controller: password,
            obscureText: obscure,
            autofillHints: const [AutofillHints.password],
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
            ),
            validator: (v) => (v == null || v.isEmpty)
                ? 'Enter your password'
                : null,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Checkbox(value: remember, onChanged: onRemember),
                const Text('Stay signed in'),
              ]),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'Password reset is not wired to a backend in this build.'),
                  ));
                },
                child: const Text('Forgot password?'),
              ),
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
                  : const Icon(Icons.login),
              label: Text(busy ? 'Signing in…' : 'Sign in'),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF5E6),
              border: Border.all(color: const Color(0xFFE9C56F)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.info_outline,
                      size: 16, color: Color(0xFF92400E)),
                  SizedBox(width: 6),
                  Text('Demo accounts',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF92400E))),
                ]),
                const SizedBox(height: 6),
                for (final h in AuthState.demoHints) ...[
                  InkWell(
                    onTap: () => onFillDemo(h.email, h.password),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF030213),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(h.role,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('${h.email} · ${h.password}',
                              style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: Color(0xFF1F2937))),
                        ),
                        const Icon(Icons.chevron_right, size: 16),
                      ]),
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                const Text(
                  'Tap a row to autofill credentials.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              '© cyberAutopsy · single-tenant demo build',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
