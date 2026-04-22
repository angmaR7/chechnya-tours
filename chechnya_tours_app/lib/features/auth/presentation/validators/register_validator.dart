class RegisterValidator {
  static String? validateUsername(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return 'Введите логин';
    if (text.length < 3) return 'Логин должен быть не короче 3 символов';

    return null;
  }

  static String? validateFirstName(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return 'Введите имя';
    if (text.length < 2) return 'Имя слишком короткое';

    return null;
  }

  static String? validateLastName(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return 'Введите фамилию';
    if (text.length < 2) return 'Фамилия слишком короткая';

    return null;
  }

  static String? validateEmail(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return 'Введите email';

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(text)) {
      return 'Введите корректный email';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return 'Введите номер телефона';

    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10) {
      return 'Введите корректный номер телефона';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    final text = value ?? '';

    if (text.isEmpty) return 'Введите пароль';
    if (text.length < 8) return 'Минимум 8 символов';
    if (!hasLetter(text)) return 'Пароль должен содержать буквы';
    if (!hasDigit(text)) return 'Пароль должен содержать цифры';

    return null;
  }

  static String? validatePasswordConfirm(String? value, String password) {
    final text = value ?? '';

    if (text.isEmpty) return 'Подтвердите пароль';
    if (text != password) return 'Пароли не совпадают';

    return null;
  }

  static bool hasMinLength(String value) => value.length >= 8;

  static bool hasLetter(String value) {
    return RegExp(r'[A-Za-zА-Яа-я]').hasMatch(value);
  }

  static bool hasDigit(String value) {
    return RegExp(r'\d').hasMatch(value);
  }
}