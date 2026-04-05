// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final authProvider = AuthProvider();
    final isLoggedIn = await authProvider.checkSession();

    setState(() {
      _isLoading = false;
      _isLoggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFF0F0E17),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Petstore Auth',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFF6C63FF),
            surface: const Color(0xFF0F0E17),
          ),
          scaffoldBackgroundColor: const Color(0xFF0F0E17),
        ),
        home: _isLoggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }
}
