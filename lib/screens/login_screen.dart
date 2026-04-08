// ignore_for_file: deprecated_member_use, use_super_parameters

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;

  int _loginAttempts = 0;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;
    final savedEmail = prefs.getString('saved_email') ?? '';
    final attempts = prefs.getInt('login_attempts') ?? 0;

    setState(() {
      _rememberMe = rememberMe;
      _loginAttempts = attempts;
      if (rememberMe && savedEmail.isNotEmpty) {
        _emailController.text = savedEmail;
      }
    });
  }

  Future<void> _handleRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _rememberMe = value);
    await prefs.setBool('remember_me', value);
    if (!value) {
      await prefs.remove('saved_email');
    }
  }

  Future<void> _incrementLoginAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = (prefs.getInt('login_attempts') ?? 0) + 1;
    await prefs.setInt('login_attempts', attempts);
    setState(() => _loginAttempts = attempts);
  }

  Future<void> _resetLoginAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('login_attempts');
    setState(() => _loginAttempts = 0);
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _loadSavedData();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    if (_loginAttempts >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Too many failed attempts. Please try again later.',
          ),
          backgroundColor: const Color(0xFFFF6584),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    auth.clearMessages();

    final success = await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', _emailController.text.trim());
      }
      await _resetLoginAttempts();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Login successful!'),
          backgroundColor: const Color(0xFF43E97B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      await _incrementLoginAttempts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),

                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.train_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Welcome back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Login to your EZ Train account',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 32),

                    if (_loginAttempts >= 3 && _loginAttempts < 5)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_outlined,
                              color: Colors.orange,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Warning: ${5 - _loginAttempts} attempts remaining',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        if (auth.errorMessage != null) {
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6584).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFF6584).withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Color(0xFFFF6584),
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    auth.errorMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFFFF6584),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Email is required';
                        }
                        final regex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!regex.hasMatch(val.trim())) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      isPassword: true,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Password is required'
                          : null,
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (val) => _handleRememberMe(val ?? false),
                            activeColor: const Color(0xFF6C63FF),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.4),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Remember me',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    Consumer<AuthProvider>(
                      builder: (context, auth, _) => SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            disabledBackgroundColor: const Color(
                              0xFF6C63FF,
                            ).withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.white.withOpacity(0.1)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.white.withOpacity(0.1)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                            children: const [
                              TextSpan(
                                text: 'Register',
                                style: TextStyle(
                                  color: Color(0xFF6C63FF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
