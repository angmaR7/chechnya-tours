import 'package:flutter/material.dart';

import '../../../../core/ui/app_messages.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/validators/register_validator.dart';
import '../../../auth/presentation/widgets/password_requirements.dart';
import '../../data/services/profile_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _profileService = ProfileService();
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _newPassword2Controller = TextEditingController();

  bool _isLoading = false;
  bool _hasSubmitted = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureNew2 = true;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_onPasswordChanged);

    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _newPassword2Controller.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String? _validateOldPassword(String? value) {
    final text = value ?? '';

    if (text.trim().isEmpty) {
      return 'Введите текущий пароль';
    }

    return null;
  }

  String? _validateNewPassword(String? value) {
    final text = value ?? '';

    if (text == _oldPasswordController.text) {
      return 'Новый пароль должен отличаться от старого';
    }

    return RegisterValidator.validatePassword(text);
  }

  String? _validateNewPassword2(String? value) {
    return RegisterValidator.validatePasswordConfirm(
      value,
      _newPasswordController.text,
    );
  }

  String _mapChangePasswordError(Object error) {
    final text = error.toString().toLowerCase();

    if (text.contains('old password') || text.contains('стар')) {
      return 'Старый пароль введен неверно';
    }

    if (text.contains('password')) {
      return 'Проверьте новый пароль';
    }

    if (text.contains('network') ||
        text.contains('socket') ||
        text.contains('connection')) {
      return 'Не удалось подключиться к серверу';
    }

    return 'Не удалось изменить пароль';
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _hasSubmitted = true;
    });

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _profileService.changePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
        newPassword2: _newPassword2Controller.text,
      );

      await _authService.logout();

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Пароль изменен'),
            content: const Text(
              'Пароль успешно обновлен. Теперь войдите в приложение заново.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Понятно'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      AppMessages.error(context, _mapChangePasswordError(e));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final autovalidateMode = _hasSubmitted
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Смена пароля'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: autovalidateMode,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 8),
              Text(
                'Обновление пароля',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'После успешной смены пароля нужно будет войти в приложение заново.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _oldPasswordController,
                obscureText: _obscureOld,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: 'Текущий пароль',
                  icon: Icons.lock_outline_rounded,
                  hintText: 'Введите текущий пароль',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureOld = !_obscureOld;
                      });
                    },
                    icon: Icon(
                      _obscureOld
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: _validateOldPassword,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: 'Новый пароль',
                  icon: Icons.lock_reset_rounded,
                  hintText: 'Введите новый пароль',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureNew = !_obscureNew;
                      });
                    },
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: _validateNewPassword,
              ),
              const SizedBox(height: 10),

              PasswordRequirements(password: _newPasswordController.text),
              const SizedBox(height: 16),

              TextFormField(
                controller: _newPassword2Controller,
                obscureText: _obscureNew2,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: _inputDecoration(
                  label: 'Подтверждение нового пароля',
                  icon: Icons.verified_user_outlined,
                  hintText: 'Повторите новый пароль',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureNew2 = !_obscureNew2;
                      });
                    },
                    icon: Icon(
                      _obscureNew2
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: _validateNewPassword2,
              ),
              const SizedBox(height: 28),

              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        )
                      : const Text('Изменить пароль'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}