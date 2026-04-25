import 'dart:io';

class SecurityService {
  static Future<bool> isVpnActive() async {
    try {
      var interfaces = await NetworkInterface.list();
      return interfaces.any((i) => 
        i.name.contains('tun') || 
        i.name.contains('ppp') || 
        i.name.contains('pptp'));
    } catch (e) {
      return false;
    }
  }

  // يمكن إضافة فحص الـ Root هنا لاحقاً باستخدام Package متخصص
}
