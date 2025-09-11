import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';

import '../features/auth/auth_page.dart';
import '../features/home/home_page.dart';
import '../features/auth/reset_password_page.dart';
import '../features/auth/auth_provider.dart';

final supabase = Supabase.instance.client;

const kUrlScheme = 'erpdemo';
const kUrlHostAuth = 'auth-callback';

class RootRouter extends ConsumerStatefulWidget {
  const RootRouter({super.key});

  @override
  ConsumerState<RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends ConsumerState<RootRouter> {
  StreamSubscription<Uri>? _linkSub;
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();

    _appLinks = AppLinks();

    // obsługa initial link (np. reset hasła przy starcie aplikacji)
    _appLinks.getInitialLink().then((uri) {
      if (!mounted || uri == null) return;
      _handleIncomingUri(uri);
    });

    // stream linków w trakcie działania aplikacji
    _linkSub = _appLinks.uriLinkStream.listen(
      (uri) => _handleIncomingUri(uri),
      onError: (e) => debugPrint('AppLinks error: $e'),
    );
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
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

  Future<void> _handleIncomingUri(Uri uri) async {
    debugPrint('🔗 Incoming URI: $uri');

    final isCustomCallback =
        (uri.scheme == kUrlScheme && uri.host == kUrlHostAuth);

    if (!isCustomCallback && uri.scheme != 'https') {
      debugPrint('⛔ Ignored URI (not matching custom scheme or https)');
      return;
    }

    var flow = uri.queryParameters['flow'];
    var type = uri.queryParameters['type'];
    var accessToken = uri.queryParameters['access_token'];

    if ((type == null || accessToken == null) && uri.fragment.isNotEmpty) {
      final frag = _parseFragment(uri.fragment);
      type ??= frag['type'];
      accessToken ??= frag['access_token'];
      flow ??= frag['flow'];
    }

    try {
      await supabase.auth.getSessionFromUrl(uri);
    } catch (e) {
      debugPrint('❌ getSessionFromUrl failed: $e');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (flow == 'reset') {
        debugPrint('🔄 Reset password flow detected');
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ResetPasswordPage()));
        return;
      }

      if (flow == 'signup') {
        debugPrint('✅ Signup confirmation flow detected');
        Navigator.of(context).popUntil((r) => r.isFirst);
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authProvider);

    debugPrint("🔑 RootRouter session: $session");

    if (session == null) {
      return const AuthPage();
    } else {
      return const HomePage();
    }
  }
}
