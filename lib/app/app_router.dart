import 'package:flutter/material.dart';
import '../auth_page.dart';
import '../home_page.dart';
import '../table_page.dart';
import '../reset_password_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/auth':
        return MaterialPageRoute(builder: (_) => const AuthPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/reset-password':
        return MaterialPageRoute(builder: (_) => const ResetPasswordPage());
      case '/table':
        final tableName = settings.arguments as String? ?? 'users';
        return MaterialPageRoute(
          builder: (_) => TablePage(tableName: tableName),
        );
      default:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('404 — route not found')),
              ),
        );
    }
  }
}
