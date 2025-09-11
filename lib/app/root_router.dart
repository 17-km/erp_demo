// lib/app/root_router.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';

import '../features/auth/auth_page.dart';
import '../features/home/home_page.dart';
import '../features/auth/reset_password_page.dart'; // <- dostosuj jeśli masz inną ścieżkę

final supabase = Supabase.instance.client;

/// Jeśli w Supabase masz inny custom scheme/host, zmień tu:
const kUrlScheme = 'erpdemo'; // np. erpdemo
const kUrlHostAuth = 'auth-callback'; // np. auth-callback

class RootRouter extends StatefulWidget {
  const RootRouter({super.key});

  @override
  State<RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<RootRouter> {
  bool _loading = true;
  Session? _session;

  // subskrypcje, które trzeba anulować w dispose
  StreamSubscription<AuthState>? _authSub;
  StreamSubscription<Uri>? _linkSub;
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();

    // 1) Bieżąca sesja + nasłuch zmian
    _session = supabase.auth.currentSession;
    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      setState(() {
        _session = data.session;
      });
    });

    // 2) Deep linki (initial + stream)
    _appLinks = AppLinks();

    // link, z którym aplikacja została otwarta
    _appLinks.getInitialLink().then((uri) {
      if (!mounted || uri == null) return;
      _handleIncomingUri(uri);
    });

    // kolejne linki w trakcie działania
    _linkSub = _appLinks.uriLinkStream.listen(
      (uri) => _handleIncomingUri(uri),
      onError: (e) => debugPrint('AppLinks error: $e'),
    );

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _linkSub?.cancel();
    super.dispose();
  }

  // Prostą parsę fragmentu "#type=...&access_token=..."
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

  Future<void> _handleIncomingUri(Uri uri) async {
    debugPrint('🔗 Incoming URI: $uri');

    // Jeśli używasz custom-scheme (desktop/apka), możesz filtrować:
    // zostaw jak jest, albo dopasuj do swoich wartości.
    final isCustomCallback =
        (uri.scheme == kUrlScheme && uri.host == kUrlHostAuth);

    // Dla bezpieczeństwa pozwólmy też na https w przyszłości (web),
    // ale TERAZ i tak działa custom scheme.
    if (!isCustomCallback && uri.scheme != 'https') {
      debugPrint('⛔ Ignored URI (not matching custom scheme or https)');
      return;
    }

    // flow=reset / flow=signup (czasem parametry są w fragmencie)
    var flow = uri.queryParameters['flow'];
    var type = uri.queryParameters['type'];
    var accessToken = uri.queryParameters['access_token'];
    if ((type == null || accessToken == null) && uri.fragment.isNotEmpty) {
      final frag = _parseFragment(uri.fragment);
      type ??= frag['type'];
      accessToken ??= frag['access_token'];
      flow ??= frag['flow'];
    }

    // Przekazanie URL do Supabase (ustawi sesję po magic-link/reset)
    try {
      await supabase.auth.getSessionFromUrl(uri);
    } catch (e) {
      debugPrint('❌ getSessionFromUrl failed: $e');
      // Nawet jeśli to się nie uda, nadal możemy nawigować wg flow
    }

    // Nawigację zróbmy po klatce, żeby nie mieszać z bieżącym buildem
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (flow == 'reset') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
          (route) => false,
        );
        return;
      }

      if (flow == 'signup') {
        Navigator.of(context).pushNamedAndRemoveUntil('/auth', (r) => false);
        showDialog(
          context: context,
          builder:
              (_) => const AlertDialog(
                title: Text('Email confirmed'),
                content: Text('Your account is verified. You can log in now.'),
              ),
        );
        return;
      }

      // Brak znanego flow — nic nie robimy. Sesja i tak zaktualizuje się przez _authSub.
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _session == null ? const AuthPage() : const HomePage();
  }
}
