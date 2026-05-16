import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'screens/login_screen.dart';
import 'state/auth.dart';
import 'state/grc_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final store = GrcStore()..hydrate();
  final auth = AuthState()..hydrate();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<GrcStore>.value(value: store),
        ChangeNotifierProvider<AuthState>.value(value: auth),
      ],
      child: const _Root(),
    ),
  );
}

class _Root extends StatelessWidget {
  const _Root();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cyberAutopsy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        scaffoldBackgroundColor: Colors.white,
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    if (!auth.hydrated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!auth.loggedIn) return const LoginScreen();
    return const CyberAutopsyApp();
  }
}
