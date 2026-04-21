import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/helpers.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _userId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('HISTORY'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'EARNINGS'),
            Tab(text: 'WITHDRAWALS'),
          ],
          indicatorColor: const Color(0xFFFF00E5),
          labelColor: const Color(0xFF00F0FF),
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEarningsHistory(),
          _buildWithdrawalsHistory(),
        ],
      ),
    );
  }

  Widget _buildEarningsHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('earnings')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final earnings = snapshot.data!.docs;

        if (earnings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No earnings yet', style: TextStyle(color: Colors.grey)),
                Text('Watch ads to start earning', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: earnings.length,
          itemBuilder: (context, index) {
            final data = earnings[index].data() as Map<String, dynamic>;
            final points = data['points'] ?? 0;
            final timestamp = (data['timestamp'] as Timestamp).toDate();
            
            return _buildHistoryCard(
              icon: Icons.play_circle,
              title: '+${Helpers.formatPoints(points)} POINTS',
              subtitle: '+${Helpers.formatAmount(points / 1000)} USD',
              time: timestamp,
              color: const Color(0xFF00F0FF),
            );
          },
        );
      },
    );
  }

  Widget _buildWithdrawalsHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('withdrawals')
          .orderBy('requestDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final withdrawals = snapshot.data!.docs;

        if (withdrawals.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No withdrawals yet', style: TextStyle(color: Colors.grey)),
                Text('Reach \$10 to withdraw', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: withdrawals.length,
          itemBuilder: (context, index) {
            final data = withdrawals[index].data() as Map<String, dynamic>;
            final timestamp = (data['requestDate'] as Timestamp).toDate();
            
            Color statusColor;
            IconData statusIcon;
            String status = data['status'] ?? 'pending';

            switch (status) {
              case 'pending':
                statusColor = Colors.orange;
                statusIcon = Icons.pending;
                break;
              case 'approved':
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
                break;
              case 'completed':
                statusColor = const Color(0xFF00F0FF);
                statusIcon = Icons.done_all;
                break;
              case 'rejected':
                statusColor = Colors.red;
                statusIcon = Icons.cancel;
                break;
              default:
                statusColor = Colors.grey;
                statusIcon = Icons.help;
            }

            return _buildHistoryCard(
              icon: statusIcon,
              title: '\$${data['amount']} USD',
              subtitle: '${data['paymentMethod']} • ${status.toUpperCase()}',
              time: timestamp,
              color: statusColor,
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required DateTime time,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF12122A), Color(0xFF1A1A3A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            Helpers.formatTimeAgo(time),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}