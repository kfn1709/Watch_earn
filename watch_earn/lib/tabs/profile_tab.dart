import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../screens/login_screen.dart';
import '../utils/helpers.dart';
import '../services/notification_service.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String? _userId;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (_userId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();
      setState(() {
        _userData = doc.data();
      });
    }
  }

  Future<void> _logout() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      NotificationService.showSuccess('Logged out successfully');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userData == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00F0FF)),
      );
    }

    final points = _userData?['points'] ?? 0;
    final level = Helpers.calculateLevel(points);
    final nextLevelPoints = level * 10000;
    final progress = (points / nextLevelPoints).clamp(0.0, 1.0);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF00F0FF).withOpacity(0.3),
                      const Color(0xFF6B00FF).withOpacity(0.3),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00F0FF), Color(0xFFFF00E5)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00F0FF).withOpacity(0.5),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF12122A),
                            ),
                            child: _userData?['photoUrl'] != null
                                ? Image.network(
                                    _userData!['photoUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Color(0xFF00F0FF),
                                    ),
                                  )
                                : Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Color(0xFF00F0FF),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _userData?['name'] ?? 'Player',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF00E5).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFF00E5)),
                        ),
                        child: Text(
                          'LEVEL $level',
                          style: const TextStyle(
                            color: Color(0xFFFF00E5),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF12122A), Color(0xFF1A1A3A)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'TOTAL POINTS',
                              Helpers.formatPoints(points),
                              const Color(0xFF00F0FF),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white24,
                            ),
                            _buildStatItem(
                              'TOTAL EARNED',
                              Helpers.formatAmount(points / 1000),
                              const Color(0xFFFF00E5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00F0FF), Color(0xFFFF00E5)],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}% to Level ${level + 1}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Personal Info',
                    subtitle: _userData?['email'] ?? 'No email',
                    onTap: () => _showPersonalInfoDialog(),
                  ),
                  _buildMenuItem(
                    icon: Icons.security,
                    title: 'Security',
                    subtitle: '2FA, Password, Devices',
                    onTap: () => _showSecurityDialog(),
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Push notifications, Email alerts',
                    onTap: () => _showNotificationsDialog(),
                  ),
                  _buildMenuItem(
                    icon: Icons.currency_exchange,
                    title: 'Language & Currency',
                    subtitle: 'English, USD / EUR / MAD',
                    onTap: () => _showCurrencyDialog(),
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Support',
                    subtitle: 'FAQ, Contact us, Report issue',
                    onTap: () => _showSupportDialog(),
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'Version 3.0.0 • Terms • Privacy',
                    onTap: () => _showAboutDialog(),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.red, Colors.redAccent],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('LOGOUT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF12122A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF00F0FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF00F0FF), size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF00F0FF)),
        onTap: onTap,
      ),
    );
  }

  void _showPersonalInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF12122A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF00F0FF)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person, size: 50, color: Color(0xFF00F0FF)),
              const SizedBox(height: 16),
              const Text(
                'PERSONAL INFO',
                style: TextStyle(
                  color: Color(0xFF00F0FF),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoRow('Name', _userData?['name'] ?? 'N/A'),
              _buildInfoRow('Email', _userData?['email'] ?? 'N/A'),
              _buildInfoRow('Gender', _userData?['gender'] ?? 'Not set'),
              _buildInfoRow('Birth Date', _userData?['birthDate']?.split('T').first ?? 'Not set'),
              _buildInfoRow('Player ID', _userData?['playerId'] ?? 'N/A'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F0FF),
                  foregroundColor: Colors.black,
                ),
                child: const Text('CLOSE'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF12122A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF00F0FF)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.currency_exchange, size: 50, color: Color(0xFF00F0FF)),
              const SizedBox(height: 16),
              const Text(
                'CURRENCY',
                style: TextStyle(
                  color: Color(0xFF00F0FF),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              ...['USD', 'EUR', 'MAD'].map((currency) {
                return ListTile(
                  leading: const Icon(Icons.attach_money, color: Color(0xFF00F0FF)),
                  title: Text(currency, style: const TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFF00F0FF)),
                  onTap: () {
                    NotificationService.showInfo('Currency changed to $currency');
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF12122A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF00F0FF)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security, size: 50, color: Color(0xFFFF00E5)),
              const SizedBox(height: 16),
              const Text(
                'SECURITY',
                style: TextStyle(
                  color: Color(0xFFFF00E5),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              const ListTile(
                leading: Icon(Icons.fingerprint, color: Color(0xFF00F0FF)),
                title: Text('Biometric Login', style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.toggle_on, color: Color(0xFF00F0FF)),
              ),
              const ListTile(
                leading: Icon(Icons.sms, color: Color(0xFF00F0FF)),
                title: Text('2FA Authentication', style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.toggle_off, color: Colors.grey),
              ),
              const ListTile(
                leading: Icon(Icons.devices, color: Color(0xFF00F0FF)),
                title: Text('Trusted Devices', style: TextStyle(color: Colors.white)),
                subtitle: Text('3 devices', style: TextStyle(color: Colors.white54)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF00E5),
                  foregroundColor: Colors.black,
                ),
                child: const Text('CLOSE'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF12122A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF00F0FF)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.notifications, size: 50, color: Color(0xFF00F0FF)),
              const SizedBox(height: 16),
              const Text(
                'NOTIFICATIONS',
                style: TextStyle(
                  color: Color(0xFF00F0FF),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              const ListTile(
                leading: Icon(Icons.push_pin, color: Color(0xFF00F0FF)),
                title: Text('Push Notifications', style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.toggle_on, color: Color(0xFF00F0FF)),
              ),
              const ListTile(
                leading: Icon(Icons.email, color: Color(0xFF00F0FF)),
                title: Text('Email Alerts', style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.toggle_on, color: Color(0xFF00F0FF)),
              ),
              const ListTile(
                leading: Icon(Icons.celebration, color: Color(0xFF00F0FF)),
                title: Text('Promotions', style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.toggle_off, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F0FF),
                  foregroundColor: Colors.black,
                ),
                child: const Text('SAVE'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF12122A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF00F0FF)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.support_agent, size: 50, color: Color(0xFF00F0FF)),
              const SizedBox(height: 16),
              const Text(
                'SUPPORT',
                style: TextStyle(
                  color: Color(0xFF00F0FF),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.help, color: Color(0xFF00F0FF)),
                title: const Text('FAQ', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.email, color: Color(0xFF00F0FF)),
                title: const Text('Contact Support', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.report_problem, color: Color(0xFFFF00E5)),
                title: const Text('Report an Issue', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F0FF),
                  foregroundColor: Colors.black,
                ),
                child: const Text('CLOSE'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF12122A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF00F0FF)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.auto_awesome,
                      size: 60,
                      color: Color(0xFF00F0FF),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'WATCH & EARN',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00F0FF),
                ),
              ),
              const Text(
                'CYBER EDITION',
                style: TextStyle(
                  color: Color(0xFFFF00E5),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Version 3.0.0',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 8),
              const Text(
                '© 2026 Watch & Earn Pro\nAll rights reserved',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF00F0FF)),
                      ),
                      child: const Text('Terms'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF00F0FF)),
                      ),
                      child: const Text('Privacy'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}