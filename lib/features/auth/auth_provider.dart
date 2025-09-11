import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authProvider = StateNotifierProvider<AuthNotifier, Session?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<Session?> {
  AuthNotifier() : super(Supabase.instance.client.auth.currentSession) {
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      state = event.session;
    });
  }

  void signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}
