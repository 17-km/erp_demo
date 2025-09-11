import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'auth_page.dart';
import 'home_page.dart';
import 'reset_password_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    debug: false,
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const kUrlScheme = 'erpdemo';
const kHostAuth = 'auth-callback';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    // link w trakcie działania
    _sub = _appLinks.uriLinkStream.listen((uri) {
      if (!mounted) return;
      _handleIncomingUri(uri);
    }, onError: (_) {});

    // link przy starcie
    _appLinks.getInitialLink().then((uri) {
      if (!mounted || uri == null) return;
      _handleIncomingUri(uri);
    });
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
    debugPrint('query=${uri.queryParameters}');
    debugPrint('fragment=${uri.fragment}');

    if (uri.scheme != kUrlScheme || uri.host != kHostAuth) {
      debugPrint('⛔ Ignored (scheme/host mismatch)');
      return;
    }

    // Wyciągamy parametry query i fragment
    final flow = uri.queryParameters['flow'];
    var type = uri.queryParameters['type'];
    var accessToken = uri.queryParameters['access_token'];

    if ((accessToken == null || type == null) && uri.fragment.isNotEmpty) {
      final frag = _parseFragment(uri.fragment);
      type ??= frag['type'];
      accessToken ??= frag['access_token'];
    }

    // 🔑 Spróbuj ustawić sesję na podstawie linku (to ustawi currentUser)
    try {
      await supabase.auth.getSessionFromUrl(uri);
    } catch (e) {
      debugPrint('❌ getSessionFromUrl failed: $e');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = navigatorKey.currentState;
      final ctx = navigatorKey.currentContext;
      if (nav == null || ctx == null) return;

      if (flow == 'reset') {
        // 🔒 Reset hasła – zawsze pokaż ResetPasswordPage
        nav.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
          (route) => false,
        );
        return;
      }

      if (flow == 'signup') {
        // ✉️ Potwierdzenie rejestracji
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

      debugPrint(
        'ℹ️ Unhandled flow=$flow type=$type accessToken? ${accessToken != null}',
      );
    });
  }

  // void _handleIncomingUri(Uri uri) {
  //   debugPrint("🔗 FULL URI: $uri");
  //   debugPrint("query: ${uri.queryParameters}");
  //   debugPrint("fragment: ${uri.fragment}");

  //   final flow = uri.queryParameters['flow'];
  //   final frag = _parseFragment(uri.fragment);
  //   final type = frag['type'];
  //   final accessToken = frag['access_token'];

  //   showDialog(
  //     context: navigatorKey.currentContext!,
  //     builder:
  //         (_) => AlertDialog(
  //           title: const Text("DEBUG"),
  //           content: Text(
  //             "flow=$flow\ntype=$type\naccessToken? ${accessToken != null}",
  //           ),
  //         ),
  //   );

  //   if (flow == 'reset' && type == 'recovery' && accessToken != null) {
  //     navigatorKey.currentState?.push(
  //       MaterialPageRoute(
  //         builder: (_) => ResetPasswordPage(accessToken: accessToken),
  //       ),
  //     );
  //   }
  // }

  // void _handleIncomingUri(Uri uri) async {
  //   debugPrint('🔗 Incoming URI: $uri');

  //   // query: np. {flow: reset}
  //   final qp = uri.queryParameters;

  //   // fragment: np. "access_token=...&type=recovery"
  //   final frag = _parseFragment(uri.fragment);

  //   final flow = qp['flow'];
  //   final type = frag['type'];
  //   final accessToken = frag['access_token'];

  //   if (flow == 'reset' && type == 'recovery' && accessToken != null) {
  //     navigatorKey.currentState?.push(
  //       MaterialPageRoute(
  //         builder: (_) => ResetPasswordPage(accessToken: accessToken),
  //       ),
  //     );
  //     return;
  //   }

  //   if (type == 'signup') {
  //     navigatorKey.currentState?.pushNamedAndRemoveUntil('/auth', (r) => false);
  //     showDialog(
  //       context: navigatorKey.currentContext!,
  //       builder:
  //           (_) => const AlertDialog(
  //             title: Text('Email confirmed'),
  //             content: Text('Your account is verified. You can log in now.'),
  //           ),
  //     );
  //     return;
  //   }

  //   debugPrint('ℹ️ Unhandled link: flow=$flow, type=$type');
  // }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP Demo',
      navigatorKey: navigatorKey,
      theme: ThemeData(primarySwatch: Colors.blue),
      // 🔄 RootRouter zamiast initialRoute — lepsze do obsługi async session
      home: RootRouter(),
      routes: {
        '/auth': (_) => const AuthPage(),
        '/home': (_) => const HomePage(),
      },
    );
  }
}

class RootRouter extends StatefulWidget {
  @override
  State<RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<RootRouter> {
  bool _loading = true;
  Session? _session;

  @override
  void initState() {
    super.initState();
    _session = supabase.auth.currentSession;
    supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        _session = data.session;
      });
    });
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _session == null ? const AuthPage() : const HomePage();
  }
}
