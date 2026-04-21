import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main_tabs_screen.dart';
import '../utils/helpers.dart';
import '../services/notification_service.dart';

class RegisterScreen extends StatefulWidget {
  final String userId;
  final String email;
  final String name;
  final String? photoUrl;

  const RegisterScreen({
    super.key,
    required this.userId,
    required this.email,
    required this.name,
    this.photoUrl,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _formKey = GlobalKey<FormState>();
  String _selectedGender = 'Prefer not to say';
  DateTime _selectedDate = DateTime(2000, 1, 1);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!Helpers.isAdult(_selectedDate)) {
      NotificationService.showError('You must be 18+ to join');
      return;
    }

    setState(() => _isLoading = true);
    final playerId = Helpers.getPlayerId(widget.userId);

    await Helpers.retry(
      action: () => FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
        'playerId': playerId,
        'email': widget.email,
        'name': widget.name,
        'photoUrl': widget.photoUrl,
        'gender': _selectedGender,
        'birthDate': _selectedDate.toIso8601String(),
        'points': 0,
        'level': 1,
        'xp': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': true,
        'isWithdrawVerified': false,
      }),
      maxAttempts: 3,
    );

    if (mounted) {
      NotificationService.showSuccess('Account created successfully!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainTabsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A1A), Color(0xFF1A1A3A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _animationController,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF00F0FF), Color(0xFF6B00FF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F0FF).withOpacity(0.3),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: widget.photoUrl != null
                        ? CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(widget.photoUrl!),
                            onBackgroundImageError: (_, __) {},
                          )
                        : ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Color(0xFF00F0FF),
                                  child: Icon(Icons.person, size: 50, color: Colors.white),
                                );
                              },
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00F0FF),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12122A).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF00F0FF)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            'COMPLETE PROFILE',
                            style: TextStyle(
                              color: Color(0xFFFF00E5),
                              letterSpacing: 2,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF00F0FF)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              dropdownColor: const Color(0xFF1A1A3A),
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                prefixIcon: Icon(Icons.person, color: Color(0xFF00F0FF)),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Male', child: Text('Male')),
                                DropdownMenuItem(value: 'Female', child: Text('Female')),
                                DropdownMenuItem(value: 'Other', child: Text('Other')),
                                DropdownMenuItem(value: 'Prefer not to say', child: Text('Prefer not to say')),
                              ],
                              onChanged: (v) => setState(() => _selectedGender = v!),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF00F0FF)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.cake, color: Color(0xFF00F0FF)),
                              title: const Text('Date of Birth'),
                              subtitle: Text(
                                Helpers.formatDate(_selectedDate),
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: const Icon(Icons.calendar_today, color: Color(0xFF00F0FF)),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                  initialDate: _selectedDate,
                                  builder: (context, child) {
                                    return Theme(
                                      data: ThemeData.dark().copyWith(
                                        colorScheme: const ColorScheme.dark(
                                          primary: Color(0xFF00F0FF),
                                          onPrimary: Colors.black,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) setState(() => _selectedDate = picked);
                              },
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00F0FF),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'ACTIVATE ACCOUNT',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
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