import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'state/grc_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final store = GrcStore();
  // Fire-and-forget hydration; UI rebuilds via ChangeNotifier when ready.
  store.hydrate();
  runApp(
    ChangeNotifierProvider<GrcStore>.value(
      value: store,
      child: const CyberAutopsyApp(),
    ),
  );
}
