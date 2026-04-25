import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceBlack,
      body: Column(
        children: [
          SizedBox(height: 60),
          Center(child: CircleAvatar(radius: 50, backgroundColor: AppColors.gold, child: Icon(Icons.person, size: 50, color: Colors.black))),
          SizedBox(height: 20),
          Text("KING OF WATCH & EARN", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 40),
          _buildSupportTile("Contact Support (Email)", Icons.email, () => launchUrl(Uri.parse("mailto:cntact.watchandearn@outlook.com"))),
          _buildSupportTile("Join Telegram", Icons.send, () => launchUrl(Uri.parse("https://t.me/+l4j6uvCl5SA1MmI0"))),
          _buildSupportTile("WhatsApp Support", Icons.chat, () => launchUrl(Uri.parse("https://wa.me/message/PWMHCDBC5YXNG1"))),
        ],
      ),
    );
  }

  Widget _buildSupportTile(String title, IconData icon, VoidCallback action) {
    return ListTile(
      leading: Icon(icon, color: AppColors.emerald),
      title: Text(title, style: TextStyle(color: Colors.white70)),
      onTap: action,
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 15),
    );
  }
}
