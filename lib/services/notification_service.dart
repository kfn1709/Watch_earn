import 'package:flutter/material.dart';

class NotificationService {

  static final GlobalKey<ScaffoldMessengerState> messengerKey =

      GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(String message) {

    messengerKey.currentState?.showSnackBar(

      SnackBar(

        content: Row(

          children: [

            const Icon(Icons.check_circle, color: Colors.green),

            const SizedBox(width: 12),

            Expanded(child: Text(message)),

          ],

        ),

        backgroundColor: const Color(0xFF12122A),

        behavior: SnackBarBehavior.floating,

        shape: RoundedRectangleBorder(

          borderRadius: BorderRadius.circular(12),

          side: const BorderSide(color: Colors.green),

        ),

      ),

    );

  }

  static void showError(String message) {

    messengerKey.currentState?.showSnackBar(

      SnackBar(

        content: Row(

          children: [

            const Icon(Icons.error, color: Colors.red),

            const SizedBox(width: 12),

            Expanded(child: Text(message)),

          ],

        ),

        backgroundColor: const Color(0xFF12122A),

        behavior: SnackBarBehavior.floating,

        shape: RoundedRectangleBorder(

          borderRadius: BorderRadius.circular(12),

          side: const BorderSide(color: Colors.red),

        ),

      ),

    );

  }

  static void showInfo(String message) {

    messengerKey.currentState?.showSnackBar(

      SnackBar(

        content: Row(

          children: [

            const Icon(Icons.info, color: Color(0xFF00F0FF)),

            const SizedBox(width: 12),

            Expanded(child: Text(message)),

          ],

        ),

        backgroundColor: const Color(0xFF12122A),

        behavior: SnackBarBehavior.floating,

        shape: RoundedRectangleBorder(

          borderRadius: BorderRadius.circular(12),

          side: const BorderSide(color: Color(0xFF00F0FF)),

        ),

      ),

    );

  }

}