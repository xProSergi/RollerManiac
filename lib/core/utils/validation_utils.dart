class ValidationUtils {
  static final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  );

  static final RegExp passwordRegex = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$'
  );

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'El correo electrónico es requerido';
    }
    if (!emailRegex.hasMatch(email)) {
      return 'El correo electrónico no es válido';
    }
    return null;
  }

  static String? validatePassword(String? password, {bool isLogin = false}) {
    if (password == null || password.isEmpty) {
      return 'La contraseña es requerida';
    }


    if (isLogin) {
      return null;
    }

    // En registro y cambio de contraseña validamos el formato completo
    if (!passwordRegex.hasMatch(password)) {
      return 'La contraseña debe tener al menos 8 caracteres, una letra, un número y un carácter especial';
    }
    return null;
  }
}