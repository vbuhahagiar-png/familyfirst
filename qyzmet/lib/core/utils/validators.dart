class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Неверный формат email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    if (value.length < 8) {
      return 'Пароль должен быть не менее 8 символов';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Подтвердите пароль';
    }
    if (value != original) {
      return 'Пароли не совпадают';
    }
    return null;
  }

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return 'Обязательное поле${fieldName != null ? ': $fieldName' : ''}';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите номер телефона';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{10,13}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-()]'), ''))) {
      return 'Неверный формат номера телефона';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите имя';
    }
    if (value.trim().length < 2) {
      return 'Имя должно быть не менее 2 символов';
    }
    return null;
  }

  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите адрес';
    }
    if (value.trim().length < 10) {
      return 'Введите полный адрес';
    }
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите код';
    }
    if (value.length != 6) {
      return 'Код должен содержать 6 цифр';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Код должен содержать только цифры';
    }
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите цену';
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Введите корректную цену';
    }
    if (price < 500) {
      return 'Минимальная цена: 500 ₸';
    }
    return null;
  }

  static String? bio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Расскажите о себе';
    }
    if (value.trim().length < 20) {
      return 'Минимум 20 символов';
    }
    if (value.trim().length > 500) {
      return 'Максимум 500 символов';
    }
    return null;
  }
}
