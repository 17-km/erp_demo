import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AuthNotifier extends StateNotifier<Session?> {
  AuthNotifier() : super(Supabase.instance.client.auth.currentSession) {
    debugPrint("🚀 AuthNotifier initialized");

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      debugPrint("📡 Auth event: ${data.event}");

      // reagujemy tylko na istotne eventy
      switch (data.event) {
        case AuthChangeEvent.signedIn:
          state = data.session;
          break;
        case AuthChangeEvent.tokenRefreshed:
          state = data.session;
          break;
        case AuthChangeEvent.signedOut:
          state = null;
          break;
        default:
          // ignorujemy inne eventy
          break;
      }
    });
  }

  Future<void> signOut() async {
    debugPrint("👋 signOut called");
    try {
      await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
    } catch (e) {
      debugPrint("❌ signOut error: $e");
    }
    // dodatkowe zabezpieczenie
    state = null;
    debugPrint("✅ AuthNotifier: state wyzerowany");
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, Session?>(
  (ref) => AuthNotifier(),
);
