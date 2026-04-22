import 'package:flutter/material.dart';

class AppDialogs {
  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Подтвердить',
    String cancelText = 'Отмена',
    bool isDanger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: isDanger
                  ? ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD14C38),
                    )
                  : null,
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}