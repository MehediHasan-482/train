// ignore_for_file: deprecated_member_use, use_super_parameters, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    auth.clearMessages();

    final success = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registration successful!'),
          backgroundColor: const Color(0xFF43E97B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
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
                    const SizedBox(height: 10),
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

                    const SizedBox(height: 24),

                    const Text(
                      'Create account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Join EZ Train today',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 28),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        if (auth.errorMessage != null) {
                          return _statusBanner(
                            auth.errorMessage!,
                            isError: true,
                          );
                        }
                        if (auth.successMessage != null) {
                          return _statusBanner(
                            auth.successMessage!,
                            isError: false,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    const SizedBox(height: 8),

                    CustomTextField(
                      label: 'Full Name',
                      hint: 'Enter your name',
                      icon: Icons.person_outline,
                      controller: _nameController,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty)
                          return 'Name is required';
                        if (val.trim().length < 2) return 'Min 2 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty)
                          return 'Email is required';
                        final regex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!regex.hasMatch(val.trim()))
                          return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Password',
                      hint: 'Min 4 characters',
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      isPassword: true,
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return 'Password is required';
                        if (val.length < 4) return 'Min 4 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      icon: Icons.lock_outline,
                      controller: _confirmPasswordController,
                      isPassword: true,
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return 'Please confirm your password';
                        if (val != _passwordController.text)
                          return 'Passwords do not match';
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) => SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleRegister,
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
                                  'Register',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                            children: const [
                              TextSpan(
                                text: 'Login',
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

  Widget _statusBanner(String message, {required bool isError}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isError
            ? const Color(0xFFFF6584).withOpacity(0.15)
            : const Color(0xFF43E97B).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError
              ? const Color(0xFFFF6584).withOpacity(0.4)
              : const Color(0xFF43E97B).withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? const Color(0xFFFF6584) : const Color(0xFF43E97B),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError
                    ? const Color(0xFFFF6584)
                    : const Color(0xFF43E97B),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
