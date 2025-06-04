class LoginModel {
  String _username = '';
  String _password = '';
  String _errorMessage = '';

  String get username => _username;
  String get password => _password;
  String get errorMessage => _errorMessage;

  void setUsername(String value) {
    _username = value;
  }

  void setPassword(String value) {
    _password = value;
  }

  /// Valida las credenciales de inicio de sesión.
  bool validateCredentials() {
    _errorMessage = ''; // Limpiar mensajes de error previos

    if (_username.isEmpty) {
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
