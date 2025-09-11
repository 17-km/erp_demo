import 'package:flutter/material.dart';
import 'app_router.dart';
import 'root_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Globalny navigatorKey – używany np. w deep linkach
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP Demo',
      theme: ThemeData(useMaterial3: true),
      navigatorKey: navigatorKey,
      // RootRouter decyduje czy AuthPage czy HomePage (oraz obsługuje linki)
      home: const RootRouter(),
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
