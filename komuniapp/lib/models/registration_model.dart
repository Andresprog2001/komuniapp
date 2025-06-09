import 'dart:convert';

// Este archivo define el modelo de datos y la lógica de validación para el registro.
class RegistrationModel {
  String _name = '';
  String _email = '';
  String _password = '';
  String _gender = ''; // 'Masculino' o 'Femenino'
  bool _termsAccepted = false;
  String _errorMessage = '';

  String get name => _name;
  String get email => _email;
  String get password => _password;
  String get gender => _gender;
  bool get termsAccepted => _termsAccepted;
  String get errorMessage => _errorMessage;

  set errorMessage(String message) {
    _errorMessage = message;
  }

  void setName(String value) {
    _name = value;
  }

  void setEmail(String value) {
    _email = value;
  }

  void setPassword(String value) {
    _password = value;
  }

  void setGender(String value) {
    _gender = value;
  }

  void setTermsAccepted(bool value) {
    _termsAccepted = value;
  }

  /// Método para convertir el modelo en un mapa para JSON
  Map<String, dynamic> toJson() {
    return {
      'name': _name,
      'email': _email,
      'password': _password,
      'gender': _gender,
      'terms_accepted': _termsAccepted,
    };
  }

  /// Valida los datos de registro.
  bool validateRegistration() {
    _errorMessage = ''; // Limpiar mensajes de error previos

    if (_name.isEmpty) {
      _errorMessage = 'El nombre completo no puede estar vacío.';
      return false;
    }
    if (_email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_email)) {
      _errorMessage = 'Ingresa un correo electrónico válido.';
      return false;
    }
    if (_password.isEmpty || _password.length < 6) {
      _errorMessage = 'La contraseña debe tener al menos 6 caracteres.';
      return false;
    }
    if (_gender.isEmpty) {
      _errorMessage = 'Selecciona un género.';
      return false;
    }

    ///if (!_termsAccepted) {
    ///_errorMessage = 'Debes aceptar los términos y condiciones.';
    ///return false;
    ///}
    return true;
  }
}
