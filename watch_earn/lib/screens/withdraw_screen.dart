import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/helpers.dart';
import '../services/notification_service.dart';

class WithdrawScreen extends StatefulWidget {
  final int currentPoints;
  const WithdrawScreen({super.key, required this.currentPoints});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _paymentDetailController = TextEditingController();

  String _selectedPaymentMethod = 'PayPal';
  String _selectedCurrency = 'USD';
  bool _isVerified = false;
  bool _isLoading = false;
  double _withdrawAmount = 0;
  double _fee = 0;
  double _netAmount = 0;

  final List<Map<String, dynamic>> _paymentMethods = const [
    {'icon': Icons.paypal, 'name': 'PayPal', 'fee': 0, 'time': '24-48h'},
    {'icon': Icons.account_balance, 'name': 'Bank Transfer', 'fee': 1, 'time': '3-5 days'},
    {'icon': Icons.currency_bitcoin, 'name': 'Crypto (USDT)', 'fee': 0.5, 'time': '1-2h'},
    {'icon': Icons.attach_money, 'name': 'Cash by Bill', 'fee': 2, 'time': '7-14 days'},
    {'icon': Icons.local_post_office, 'name': 'Barid Bank (CCP)', 'fee': 0, 'time': '48h'},
  ];

  final List<Map<String, dynamic>> _currencies = const [
    {'code': 'USD', 'symbol': '\$', 'rate': 1.0},
    {'code': 'EUR', 'symbol': '€', 'rate': 0.92},
    {'code': 'MAD', 'symbol': 'DH', 'rate': 9.8},
    {'code': 'GBP', 'symbol': '£', 'rate': 0.79},
    {'code': 'CAD', 'symbol': 'C\$', 'rate': 1.35},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
    _withdrawAmount = widget.currentPoints / 1000;
    _calculateNetAmount();
    _checkVerification();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _paymentDetailController.dispose();
    super.dispose();
  }

  void _calculateNetAmount() {
    final method = _paymentMethods.firstWhere((m) => m['name'] == _selectedPaymentMethod);
    _fee = _withdrawAmount * (method['fee'] / 100);
    _netAmount = _withdrawAmount - _fee;
  }

  double getConvertedAmount(double usdAmount) {
    final currency = _currencies.firstWhere((c) => c['code'] == _selectedCurrency);
    return usdAmount * (currency['rate'] as double);
  }

  String getCurrencySymbol() {
    return _currencies.firstWhere((c) => c['code'] == _selectedCurrency)['symbol'] as String;
  }

  Future<void> _checkVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await Helpers.withTimeout(
        action: () => FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get(),
        timeout: const Duration(seconds: 10),
      );
      
      final data = doc.data();
      if (data != null && data.containsKey('isWithdrawVerified')) {
        setState(() {
          _isVerified = data['isWithdrawVerified'] ?? false;
          if (_isVerified) {
            _fullNameController.text = data['fullName'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _addressController.text = data['address'] ?? '';
            _selectedPaymentMethod = data['paymentMethod'] ?? 'PayPal';
            _paymentDetailController.text = data['paymentDetail'] ?? '';
          }
        });
      }
    } catch (e) {
      NotificationService.showError('Failed to load verification data');
    }
  }

  Future<void> _saveVerification() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await Helpers.retry(
        action: () => FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fullName': _fullNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'paymentMethod': _selectedPaymentMethod,
          'paymentDetail': _paymentDetailController.text.trim(),
          'isWithdrawVerified': true,
          'verificationDate': FieldValue.serverTimestamp(),
        }),
        maxAttempts: 3,
        delayBetween: const Duration(seconds: 1),
      );
    }

    setState(() {
      _isVerified = true;
      _isLoading = false;
    });

    NotificationService.showSuccess('Verification complete!');
  }

  Future<void> _submitWithdraw() async {
    if (!_isVerified) {
      NotificationService.showError('Please complete verification first');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    await Helpers.retry(
      action: () async {
        final method = _paymentMethods.firstWhere((m) => m['name'] == _selectedPaymentMethod);
        final convertedAmount = getConvertedAmount(_netAmount);
        final currencySymbol = getCurrencySymbol();

        final uri = Uri(
          scheme: 'mailto',
          path: 'withdraw@watchandearn.com',
          queryParameters: {
            'subject': 'WITHDRAWAL REQUEST - ${user.uid}',
            'body': _buildEmailBody(method, convertedAmount, currencySymbol),
          },
        );

        final canLaunch = await Helpers.withTimeout(
          action: () => canLaunchUrl(uri),
          timeout: const Duration(seconds: 5),
          defaultValue: false,
        );
        
        if (!canLaunch) throw Exception('Cannot launch email app');

        await launchUrl(uri);
        
        await Helpers.retry(
          action: () => FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('withdrawals')
              .add({
            'amount': _netAmount.toStringAsFixed(2),
            'points': widget.currentPoints,
            'status': 'pending',
            'requestDate': FieldValue.serverTimestamp(),
            'paymentMethod': _selectedPaymentMethod,
            'currency': _selectedCurrency,
          }),
          maxAttempts: 3,
        );
      },
      maxAttempts: 2,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      NotificationService.showSuccess('Request sent! Check your email.');
      Navigator.pop(context);
    }
  }

  String _buildEmailBody(Map<String, dynamic> method, double convertedAmount, String currencySymbol) {
    return '''
═══════════════════════════════════
         WITHDRAWAL REQUEST
═══════════════════════════════════

📱 User ID: ${FirebaseAuth.instance.currentUser?.uid}
👤 Full Name: ${_fullNameController.text.trim()}
📞 Phone: ${_phoneController.text.trim()}
🏠 Address: ${_addressController.text.trim()}

💳 Payment Method: $_selectedPaymentMethod
📧 Details: ${_paymentDetailController.text.trim()}
💱 Currency: $_selectedCurrency

💰 Gross Amount: ${Helpers.formatAmount(_withdrawAmount)} USD
📉 Fee (${method['fee']}%): ${Helpers.formatAmount(_fee)} USD
💵 Net Amount: ${Helpers.formatAmount(_netAmount)} USD
🔄 Converted: $currencySymbol${convertedAmount.toStringAsFixed(2)} $_selectedCurrency

═══════════════════════════════════
Please process my withdrawal request.
═══════════════════════════════════
''';
  }

  String _getPaymentHint() {
    switch (_selectedPaymentMethod) {
      case 'PayPal':
        return 'Enter your PayPal email address';
      case 'Bank Transfer':
        return 'Enter IBAN / RIB / Account number';
      case 'Crypto (USDT)':
        return 'Enter USDT wallet address (TRC20/BEP20)';
      case 'Cash by Bill':
        return 'Enter your phone number for cash delivery';
      case 'Barid Bank (CCP)':
        return 'Enter CCP account number + CNE';
      default:
        return 'Enter payment details';
    }
  }

  @override
  Widget build(BuildContext context) {
    final canWithdraw = widget.currentPoints >= 10000;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        title: const Text('WITHDRAWAL PORTAL'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _animationController,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Balance Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00F0FF), Color(0xFF6B00FF)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Text(
                      'AVAILABLE BALANCE',
                      style: TextStyle(
                        color: Colors.white70,
                        letterSpacing: 2,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Color(0xFFFF00E5)],
                      ).createShader(bounds),
                      child: Text(
                        Helpers.formatAmount(_withdrawAmount),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${Helpers.formatPoints(widget.currentPoints)} POINTS',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    if (!canWithdraw) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '⚠️ Minimum: \$10 USD (10,000 points)',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Verification Form
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF12122A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF00F0FF), width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield, color: Color(0xFF00F0FF), size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'ACCOUNT VERIFICATION',
                          style: TextStyle(
                            color: Color(0xFF00F0FF),
                            letterSpacing: 2,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        if (_isVerified)
                          const Icon(Icons.verified, color: Color(0xFF00F0FF), size: 20),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (!_isVerified) ...[
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildCyberTextField(
                              controller: _fullNameController,
                              icon: Icons.person,
                              label: 'FULL NAME',
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildCyberTextField(
                              controller: _phoneController,
                              icon: Icons.phone,
                              label: 'PHONE NUMBER',
                              keyboardType: TextInputType.phone,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildCyberTextField(
                              controller: _addressController,
                              icon: Icons.location_on,
                              label: 'ADDRESS',
                              maxLines: 2,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),

                            // Currency Selector
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFF00F0FF)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedCurrency,
                                dropdownColor: const Color(0xFF1A1A3A),
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  prefixIcon: Icon(Icons.currency_exchange, color: Color(0xFF00F0FF)),
                                  labelText: 'CURRENCY',
                                  labelStyle: TextStyle(color: Color(0xFF00F0FF), fontSize: 12),
                                ),
                                items: _currencies.map<DropdownMenuItem<String>>((currency) {
                                  return DropdownMenuItem<String>(
                                    value: currency['code'] as String,
                                    child: Text('${currency['symbol']} ${currency['code']}'),
                                  );
                                }).toList(),
                                onChanged: (v) {
                                  setState(() {
                                    _selectedCurrency = v!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Payment Method Selector
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFF00F0FF)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedPaymentMethod,
                                dropdownColor: const Color(0xFF1A1A3A),
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  prefixIcon: Icon(Icons.payment, color: Color(0xFF00F0FF)),
                                ),
                                items: _paymentMethods.map<DropdownMenuItem<String>>((method) {
                                  return DropdownMenuItem<String>(
                                    value: method['name'] as String,
                                    child: Row(
                                      children: [
                                        Icon(method['icon'], color: const Color(0xFF00F0FF), size: 18),
                                        const SizedBox(width: 8),
                                        Text(method['name'] as String),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF00E5).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${method['fee']}%',
                                            style: const TextStyle(
                                              color: Color(0xFFFF00E5),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (v) {
                                  setState(() {
                                    _selectedPaymentMethod = v!;
                                    _calculateNetAmount();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildCyberTextField(
                              controller: _paymentDetailController,
                              icon: Icons.info,
                              label: 'PAYMENT DETAILS',
                              hint: _getPaymentHint(),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _saveVerification,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00F0FF),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                                    : const Text('VERIFY ACCOUNT'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (_isVerified) ...[
                      // Fee Breakdown
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildFeeRow('Gross Amount', _withdrawAmount),
                            const SizedBox(height: 8),
                            _buildFeeRow('Fee (${_paymentMethods.firstWhere((m) => m['name'] == _selectedPaymentMethod)['fee']}%)', _fee, isNegative: true),
                            const Divider(color: Colors.white24),
                            const SizedBox(height: 8),
                            _buildFeeRow('Net Amount (USD)', _netAmount, isBold: true),
                            const SizedBox(height: 8),
                            _buildFeeRow(
                              'Converted (${getCurrencySymbol()}$_selectedCurrency)',
                              getConvertedAmount(_netAmount),
                              isBold: false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: canWithdraw ? _submitWithdraw : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canWithdraw ? const Color(0xFFFF00E5) : Colors.grey,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: canWithdraw ? 8 : 0,
                            shadowColor: canWithdraw ? const Color(0xFFFF00E5) : null,
                          ),
                          child: Text(canWithdraw ? 'PROCEED TO WITHDRAW' : 'MINIMUM \$10 REQUIRED'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCyberTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF00F0FF)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF00F0FF)),
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF00F0FF), fontSize: 12),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildFeeRow(String label, double amount, {bool isNegative = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isNegative ? Colors.red : Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          Helpers.formatAmount(amount),
          style: TextStyle(
            color: isNegative ? Colors.red : (isBold ? const Color(0xFF00F0FF) : Colors.white),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 18 : 14,
          ),
        ),
      ],
    );
  }
}