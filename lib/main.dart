import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//new_feature
import 'login_dialog.dart';
import 'register_dialog.dart';

// Inicjalizacja Supabase

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await dotenv.load(fileName: ".env");

//   await Supabase.initialize(
//     url: 'https://hajhuirqyxqsdsoxxyos.supabase.co',
//     anonKey:
//         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhhamh1aXJxeXhxc2Rzb3h4eW9zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4ODM4MTAsImV4cCI6MjA3MjQ1OTgxMH0.kozsF-4oQy5H4zohfbr9U-wflh-fqSBgN2mX6iR52Tg',
//   );

//   runApp(const MyApp());
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Funkcja: dodawanie usera
  Future<void> insertUser(String name) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      print('Brak zalogowanego użytkownika!');
      return;
    }

    await supabase.from('users').insert({'id': userId, 'name': name});
    print('Dodano usera: $name');
  }

  /// Funkcja: pobieranie userów
  Future<void> fetchUsers() async {
    final response = await supabase.from('users').select();
    print('Users: $response');
  }

  /// Funkcja: dodawanie projektu
  Future<void> insertProject(String title) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      print('Brak zalogowanego użytkownika!');
      return;
    }

    await supabase.from('projects').insert({'user_id': userId, 'title': title});
    print('Dodano projekt: $title');
  }

  /// Funkcja: pobieranie projektów
  Future<void> fetchProjects() async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      print('Brak zalogowanego użytkownika!');
      return;
    }

    final response = await supabase
        .from('projects')
        .select()
        .eq('user_id', userId);

    print('Projects: $response');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ERP Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => insertUser('Jan Kowalski'),
              child: const Text('➕ Add user'),
            ),
            ElevatedButton(
              onPressed: fetchUsers,
              child: const Text('📥 Fetch users'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => insertProject('Projekt A'),
              child: const Text('➕ Add project'),
            ),
            ElevatedButton(
              onPressed: fetchProjects,
              child: const Text('📥 Fetch projects'),
            ),
            // ElevatedButton(onPressed: signUp, child: const Text('🆕 Register')),
            // ElevatedButton(onPressed: signIn, child: const Text('🔑 Login')),
            ElevatedButton(
              onPressed: () => showRegisterDialog(context),
              child: const Text('🆕 Register'),
            ),
            ElevatedButton(
              onPressed: () => showLoginDialog(context),
              child: const Text('🔑 Login'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Rejestracja nowego usera
  Future<void> signUp() async {
    final response = await supabase.auth.signUp(
      email: 'mikoda.krystian@gmail.com',
      password: 'Lisbon123!',
    );
    print('Zarejestrowano: ${response.user?.id}');
  }

  /// Logowanie istniejącego usera
  Future<void> signIn() async {
    final response = await supabase.auth.signInWithPassword(
      email: 'mikoda.krystian@gmail.com',
      password: 'Lisbon123!',
    );
    print('Zalogowano: ${response.user?.id}');
  }
}
