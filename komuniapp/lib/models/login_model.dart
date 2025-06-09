class LoginModel {
  String _email = '';
  String _password = '';
  String _errorMessage = '';

  String get email => _email;
  String get password => _password;
  String get errorMessage => _errorMessage;

  void setEmail(String value) {
    _email = value;
  }

  void setPassword(String value) {
    _password = value;
  }

  set errorMessage(String message) {
    _errorMessage = message;
  }

  /// Valida las credenciales de inicio de sesión.
  bool validateCredentials() {
    _errorMessage = ''; // Limpiar mensajes de error previos

    if (_email.isEmpty) {
      _errorMessage = 'El usuario no puede estar vacío.';
      return false;
    }
    if (_password.isEmpty) {
      _errorMessage = 'La contraseña no puede estar vacía.';
      return false;
    }

    return true;
  }
}
