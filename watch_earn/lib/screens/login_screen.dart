import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';
import '../main_tabs_screen.dart';
import '../services/notification_service.dart';
import '../utils/helpers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final googleUser = await Helpers.withTimeout(
        action: () => _googleSignIn.signIn(),
        timeout: const Duration(seconds: 10),
      );
      
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final doc = await Helpers.withTimeout(
        action: () => FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        timeout: const Duration(seconds: 10),
      );

      if (!doc.exists) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => RegisterScreen(
                userId: user.uid,
                email: user.email ?? '',
                name: user.displayName ?? '',
                photoUrl: user.photoURL,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainTabsScreen()),
          );
        }
      }
    } catch (e) {
      NotificationService.showError('Login failed: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A1A),
              Color(0xFF1A1A3A),
              Color(0xFF0A0A1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(seconds: 1),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF00F0FF).withOpacity(0.3),
                                const Color(0xFF6B00FF).withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF00F0FF), Color(0xFF6B00FF)],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF00F0FF), Color(0xFFFF00E5)],
                    ).createShader(bounds),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 100,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00F0FF), Color(0xFFFF00E5)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12122A).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFF00F0FF), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F0FF).withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.security, size: 50, color: Color(0xFF00F0FF)),
                        const SizedBox(height: 20),
                        const Text(
                          'SECURE ACCESS',
                          style: TextStyle(
                            color: Color(0xFF00F0FF),
                            letterSpacing: 2,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _isLoading
                            ? const CircularProgressIndicator(color: Color(0xFF00F0FF))
                            : ElevatedButton.icon(
                                onPressed: _handleGoogleSignIn,
                                icon: const Icon(Icons.g_mobiledata, size: 24),
                                label: const Text(
                                  'CONTINUE WITH GOOGLE',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  minimumSize: const Size(double.infinity, 55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 1,
                        color: const Color(0xFF00F0FF).withOpacity(0.5),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'ENTER THE FUTURE',
                        style: TextStyle(
                          color: Color(0xFF00F0FF),
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 50,
                        height: 1,
                        color: const Color(0xFF00F0FF).withOpacity(0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}