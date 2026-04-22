import 'package:flutter/material.dart';

import '../../../../core/ui/app_messages.dart';
import '../../data/services/auth_service.dart';
import '../validators/register_validator.dart';
import '../widgets/password_requirements.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _isLoading = false;
  bool _hasSubmitted = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);

    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();

    super.dispose();
  }

  void _onPasswordChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String _mapRegisterError(Object error) {
    final text = error.toString().toLowerCase();

    if (text.contains('username')) {
      return 'Пользователь с таким логином уже существует';
    }

    if (text.contains('email')) {
      return 'Пользователь с таким email уже существует';
    }

    if (text.contains('phone')) {
      return 'Проверьте номер телефона';
    }

    if (text.contains('password')) {
      return 'Пароль не соответствует требованиям';
    }

    if (text.contains('network') ||
        text.contains('socket') ||
        text.contains('connection')) {
      return 'Не удалось подключиться к серверу';
    }

    return 'Не удалось зарегистрироваться';
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
      await _authService.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
        password2: _passwordConfirmController.text,
      );

      if (!mounted) return;

      AppMessages.success(context, 'Регистрация прошла успешно');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      AppMessages.error(context, _mapRegisterError(e));
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
        title: const Text('Регистрация'),
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
                'Создайте аккаунт',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Заполните данные, чтобы начать пользоваться приложением',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _usernameController,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: 'Логин',
                  icon: Icons.alternate_email_rounded,
                  hintText: 'Например, traveler01',
                ),
                validator: RegisterValidator.validateUsername,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _firstNameController,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: 'Имя',
                  icon: Icons.person_outline_rounded,
                ),
                validator: RegisterValidator.validateFirstName,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _lastNameController,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: 'Фамилия',
                  icon: Icons.badge_outlined,
                ),
                validator: RegisterValidator.validateLastName,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: 'Email',
                  icon: Icons.email_outlined,
                  hintText: 'example@mail.com',
                ),
                validator: RegisterValidator.validateEmail,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: 'Телефон',
                  icon: Icons.phone_outlined,
                  hintText: '+7 900 000 00 00',
                ),
                validator: RegisterValidator.validatePhone,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: 'Пароль',
                  icon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: RegisterValidator.validatePassword,
              ),
              const SizedBox(height: 10),

              PasswordRequirements(password: _passwordController.text),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordConfirmController,
                obscureText: _obscurePasswordConfirm,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: _inputDecoration(
                  label: 'Подтверждение пароля',
                  icon: Icons.lock_reset_rounded,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePasswordConfirm = !_obscurePasswordConfirm;
                      });
                    },
                    icon: Icon(
                      _obscurePasswordConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) => RegisterValidator.validatePasswordConfirm(
                  value,
                  _passwordController.text,
                ),
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
                      : const Text('Зарегистрироваться'),
                ),
              ),

              const SizedBox(height: 14),

              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
                child: const Text('У меня уже есть аккаунт'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}