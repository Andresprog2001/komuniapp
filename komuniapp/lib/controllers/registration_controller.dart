// Este archivo maneja la lógica de negocio y la interacción entre el modelo y la vista de registro.
import 'package:flutter/material.dart';
import 'package:komuniapp/models/registration_model.dart';
import 'package:komuniapp/services/user_api_service.dart';

class RegistrationController extends ChangeNotifier {
  final RegistrationModel _model = RegistrationModel();
  final UserApiService _apiService = UserApiService();
  bool _isLoading = false;

  String get fullName => _model.fullName;
  String get email => _model.email;
  String get password => _model.password;
  String get gender => _model.gender;
  bool get termsAccepted => _model.termsAccepted;
  String get errorMessage => _model.errorMessage;
  bool get isLoading => _isLoading;

  void setFullName(String value) {
    _model.setFullName(value);
  }

  void setEmail(String value) {
    _model.setEmail(value);
  }

  void setPassword(String value) {
    _model.setPassword(value);
  }

  void setGender(String? value) {
    if (value != null) {
      _model.setGender(value);
    }
    // Notificar para actualizar los RadioListTile
  }

  void setTermsAccepted(bool? value) {
    _model.setTermsAccepted(value ?? false);
    // Notificar para actualizar el Checkbox
  }

  Future<bool> registerUser() async {
    _isLoading = true;
    _model.errorMessage = ''; // Limpiar errores previos antes de intentar

    if (!_model.validateRegistration()) {
      _isLoading = false;

      return false;
    }

    try {
      // <<-- AHORA LLAMAMOS AL SERVICIO API REAL -->>
      final success = await _apiService.registerUser(_model);
      _isLoading = false;

      return success;
    } catch (e) {
      // Manejar el error reportado por el servicio
      _model.errorMessage = e.toString().replaceFirst(
        'Exception: ',
        '',
      ); // Limpiar "Exception: "
      _isLoading = false;

      return false;
    }
  }
}
