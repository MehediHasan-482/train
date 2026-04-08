// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_project/providers/auth_provider.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _lastLoginTime = '';

  @override
  void initState() {
    super.initState();
    _loadAndSaveLoginTime();
  }

  Future<void> _loadAndSaveLoginTime() async {
    final prefs = await SharedPreferences.getInstance();

    final previousLogin = prefs.getString('last_login_time') ?? '';
    final now = DateTime.now();
    final formatted =
        '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    await prefs.setString('last_login_time', formatted);

    setState(() {
      _lastLoginTime = previousLogin.isNotEmpty ? previousLogin : formatted;
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6584),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.currentUser;
        final username = user?.name ?? auth.userName;
        final email = user?.email ?? auth.userEmail;
        final token = auth.token;
        final initials = username.isNotEmpty ? username[0].toUpperCase() : '?';

        return Scaffold(
          backgroundColor: const Color(0xFF0F0E17),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'EZ Train',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Color(0xFFFF6584)),
                onPressed: () => _handleLogout(context),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back!',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                username,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (token.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Text(
                          'SESSION TOKEN',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            token,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43E97B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF43E97B).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_user,
                        color: Color(0xFF43E97B),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Authentication Successful',
                            style: TextStyle(
                              color: Color(0xFF43E97B),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'You are now logged in to EZ Train.',
                            style: TextStyle(
                              color: const Color(0xFF43E97B).withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                Text(
                  'USER DETAILS',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 14),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      _infoRow(Icons.person_outline, 'Name', username),
                      Divider(
                        color: Colors.white.withOpacity(0.07),
                        height: 1,
                        indent: 50,
                      ),
                      _infoRow(Icons.email_outlined, 'Email', email),
                      if (_lastLoginTime.isNotEmpty) ...[
                        Divider(
                          color: Colors.white.withOpacity(0.07),
                          height: 1,
                          indent: 50,
                        ),
                        _infoRow(
                          Icons.access_time_outlined,
                          'Last Login',
                          _lastLoginTime,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleLogout(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF6584)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(
                      Icons.logout,
                      color: Color(0xFFFF6584),
                      size: 18,
                    ),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Color(0xFFFF6584),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6C63FF), size: 18),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '—' : value,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
