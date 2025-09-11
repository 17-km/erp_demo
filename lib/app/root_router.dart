import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/auth_page.dart';
import '../features/home/home_page.dart';
import '../features/auth/reset_password_page.dart';
import 'app.dart';

final supabase = Supabase.instance.client;

const kUrlScheme = 'erpdemo';
const kHostAuth = 'auth-callback';

class RootRouter extends StatefulWidget {
  const RootRouter({super.key});

  @override
  State<RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<RootRouter> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  Session? _session;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _session = supabase.auth.currentSession;
    supabase.auth.onAuthStateChange.listen((data) {
      setState(() => _session = data.session);
    });

    // nasłuch linków
    _sub = _appLinks.uriLinkStream.listen((uri) {
      if (!mounted) return;
      _handleIncomingUri(uri);
    }, onError: (_) {});

    // link przy starcie
    _appLinks.getInitialLink().then((uri) {
      if (!mounted || uri == null) return;
      _handleIncomingUri(uri);
    });

    setState(() => _loading = false);
  }

  Map<String, String> _parseFragment(String fragment) {
    if (fragment.isEmpty) return {};
    return Map.fromEntries(
      fragment.split('&').map((pair) {
        final idx = pair.indexOf('=');
        if (idx == -1) return MapEntry(Uri.decodeComponent(pair), '');
        final k = Uri.decodeComponent(pair.substring(0, idx));
        final v = Uri.decodeComponent(pair.substring(idx + 1));
        return MapEntry(k, v);
      }),
    );
  }

  void _handleIncomingUri(Uri uri) async {
    debugPrint('🔗 Incoming URI: $uri');

    if (uri.scheme != kUrlScheme || uri.host != kHostAuth) {
      debugPrint('⛔ Ignored (scheme/host mismatch)');
      return;
    }

    final flow = uri.queryParameters['flow'];
    var type = uri.queryParameters['type'];
    var accessToken = uri.queryParameters['access_token'];

    if ((accessToken == null || type == null) && uri.fragment.isNotEmpty) {
      final frag = _parseFragment(uri.fragment);
      type ??= frag['type'];
      accessToken ??= frag['access_token'];
    }

    try {
      await supabase.auth.getSessionFromUrl(uri);
    } catch (e) {
      debugPrint('❌ getSessionFromUrl failed: $e');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = MyApp.navigatorKey.currentState;
      final ctx = MyApp.navigatorKey.currentContext;
      if (nav == null || ctx == null) return;

      if (flow == 'reset') {
        nav.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
          (route) => false,
        );
        return;
      }

      if (flow == 'signup') {
        nav.pushNamedAndRemoveUntil('/auth', (r) => false);
        showDialog(
          context: ctx,
          builder:
              (_) => const AlertDialog(
                title: Text('Email confirmed'),
                content: Text('Your account is verified. You can log in now.'),
              ),
        );
        return;
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _session == null ? const AuthPage() : const HomePage();
  }
}
