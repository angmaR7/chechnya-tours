import 'package:flutter/material.dart';

class AppMessages {
  static void success(BuildContext context, String text) {
    _show(
      context,
      text: text,
      backgroundColor: const Color(0xFF2C7A4B),
      icon: Icons.check_circle_outline,
    );
  }

  static void error(BuildContext context, String text) {
    _show(
      context,
      text: text,
      backgroundColor: const Color(0xFFD14C38),
      icon: Icons.error_outline,
    );
  }

  static void info(BuildContext context, String text) {
    _show(
      context,
      text: text,
      backgroundColor: const Color(0xFF2D6CDF),
      icon: Icons.info_outline,
    );
  }

  static void _show(
    BuildContext context, {
    required String text,
    required Color backgroundColor,
    required IconData icon,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}