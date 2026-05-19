import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'screens/login_screen.dart';
import 'state/auth.dart';
import 'state/grc_store.dart';
import 'theme/metallic_theme.dart';

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
      theme: MT.themeData(),
      darkTheme: MT.themeData(),
      themeMode: ThemeMode.dark,
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
