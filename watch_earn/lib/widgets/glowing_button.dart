import 'package:flutter/material.dart';

class GlowingButton extends StatefulWidget {

  final VoidCallback? onPressed;

  final IconData icon;

  final String label;

  final LinearGradient gradient;

  final bool isLoading;

  const GlowingButton({

    super.key,

    this.onPressed,

    required this.icon,

    required this.label,

    required this.gradient,

    this.isLoading = false,

  });

  @override

  State<GlowingButton> createState() => _GlowingButtonState();

}

class _GlowingButtonState extends State<GlowingButton>

    with SingleTickerProviderStateMixin {

  late AnimationController _pulseController;

  late Animation<double> _pulseAnimation;

  @override

  void initState() {

    super.initState();

    _pulseController = AnimationController(

      duration: const Duration(milliseconds: 1500),

      vsync: this,

    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(_pulseController);

  }

  @override

  void dispose() {

    _pulseController.dispose();

    super.dispose();

  }

  @override

  Widget build(BuildContext context) {

    return AnimatedBuilder(

      animation: _pulseAnimation,

      builder: (context, child) {

        return Container(

          decoration: BoxDecoration(

            gradient: widget.gradient,

            borderRadius: BorderRadius.circular(16),

            boxShadow: widget.onPressed != null

                ? [

                    BoxShadow(

                      color: widget.gradient.colors.first.withOpacity(_pulseAnimation.value),

                      blurRadius: 20,

                      spreadRadius: 5,

                    ),

                  ]

                : [],

          ),

          child: ElevatedButton.icon(

            onPressed: widget.onPressed,

            icon: widget.isLoading

                ? const SizedBox(

                    width: 20,

                    height: 20,

                    child: CircularProgressIndicator(

                      strokeWidth: 2,

                      color: Colors.white,

                    ),

                  )

                : Icon(widget.icon, size: 24),

            label: Text(

              widget.label,

              style: const TextStyle(

                fontWeight: FontWeight.bold,

                letterSpacing: 1.5,

              ),

            ),

            style: ElevatedButton.styleFrom(

              backgroundColor: Colors.transparent,

              shadowColor: Colors.transparent,

              foregroundColor: Colors.white,

              minimumSize: const Size(double.infinity, 56),

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(16),

              ),

            ),

          ),

        );

      },

    );

  }

}