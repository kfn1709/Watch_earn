import 'package:flutter/material.dart';

class NeonCard extends StatelessWidget {

  final Widget child;

  final Color? borderColor;

  final double? elevation;

  final EdgeInsets? padding;

  const NeonCard({

    super.key,

    required this.child,

    this.borderColor,

    this.elevation,

    this.padding,

  });

  @override

  Widget build(BuildContext context) {

    return Container(

      padding: padding ?? const EdgeInsets.all(20),

      decoration: BoxDecoration(

        gradient: const LinearGradient(

          colors: [Color(0xFF12122A), Color(0xFF1A1A3A)],

        ),

        borderRadius: BorderRadius.circular(24),

        border: Border.all(

          color: (borderColor ?? const Color(0xFF00F0FF)).withOpacity(0.5),

          width: 1,

        ),

        boxShadow: [

          BoxShadow(

            color: (borderColor ?? const Color(0xFF00F0FF)).withOpacity(0.2),

            blurRadius: elevation ?? 15,

            spreadRadius: 2,

          ),

        ],

      ),

      child: child,

    );

  }

}