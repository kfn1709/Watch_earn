import 'package:flutter/material.dart';

class Animations {
  static Animation<double> fadeIn(AnimationController controller) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeIn,
      ),
    );
  }

  static Animation<double> scaleIn(AnimationController controller) {
    return Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ),
    );
  }

  static Animation<double> slideUp(AnimationController controller) {
    return Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ),
    );
  }

  static Animation<double> pulse(AnimationController controller) {
    return Tween<double>(begin: 1, end: 1.05).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
  }

  static Animation<double> rotate(AnimationController controller) {
    return Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ),
    );
  }

  static Animation<double> shimmer(AnimationController controller) {
    return Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }
}