import 'package:flutter/material.dart';

import '../validators/register_validator.dart';

class PasswordRequirements extends StatelessWidget {
  final String password;

  const PasswordRequirements({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final requirements = [
      (
        label: 'Минимум 8 символов',
        passed: RegisterValidator.hasMinLength(password),
      ),
      (
        label: 'Хотя бы одна буква',
        passed: RegisterValidator.hasLetter(password),
      ),
      (
        label: 'Хотя бы одна цифра',
        passed: RegisterValidator.hasDigit(password),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: requirements.map((item) {
        final color = item.passed ? Colors.green : theme.hintColor;

        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                item.passed
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  style: theme.textTheme.bodySmall?.copyWith(color: color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}