// lib/controllers/upload_content_controller.dart
import 'package:flutter/material.dart';
import 'package:komuniapp/models/upload_content_model.dart';
import 'package:komuniapp/models/content_model.dart';

import 'package:komuniapp/services/content_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

class UploadContentController extends ChangeNotifier {
  final UploadContentModel _model = UploadContentModel();
  final ContentApiService _apiService = ContentApiService();
  bool _isLoading = false;
  String? _inscriptionErrorMessage;
  bool _isRegistering = false;
  bool _isCurrentlyRegistered = false;
  String? _currentUserId;
  List<Content> _userRegisteredContents = [];

  bool _isLoadingRegisteredContents =
      false; // Indicador de carga ESPECÍFICO para la lista de contenidos inscritos
  String?
  _registeredContentsErrorMessage; // Mensaje de error al cargar la lista de contenidos inscritos

  bool get isRegistering => _isRegistering;
  bool get isCurrentlyRegistered => _isCurrentlyRegistered;

  String? get inscriptionErrorMessage => _inscriptionErrorMessage;
  String get title => _model.title;
  String get description => _model.description;
  String get author => _model.author;
  String get fileUrl => _model.fileUrl; // <<-- CAMBIO: 'file' a 'fileUrl'
  String get category => _model.category;
  String get errorMessage => _model.errorMessage;
  bool get isLoading => _isLoading;

  List<Content> get userRegisteredContents => _userRegisteredContents;
  bool get isLoadingRegisteredContents => _isLoadingRegisteredContents;
  String? get registeredContentsErrorMessage => _registeredContentsErrorMessage;

  UploadContentController() {
    // _initializeUserId();
  }

  void setTitle(String value) {
    _model.setTitle(value);
  }

  void setDescription(String value) {
    _model.setDescription(value);
  }

  void setAuthor(String value) {
    _model.setAuthor(value);
  }

  void setFileUrl(String value) {
    _model.setFileUrl(value);
  }

  void setErrorMessage(String message) {
    _model.errorMessage = message;
    notifyListeners();
  }

  void setSelectedFile(Uint8List? bytes, String? fileName) {
    _model.setFileBytes(bytes); // Guardamos los bytes en el modelo
    _model.setFileUrl(
      fileName ?? '',
    ); // Guardamos el nombre del archivo en el modelo
    _model.errorMessage = ''; // Limpiar error relacionado con el archivo
    notifyListeners();
  }

  void setCategory(String? value) {
    if (value != null) {
      _model.setCategory(value);
    }
    notifyListeners();
  }

  void clearSelectedFile() {
    _model.setFileBytes(null); // Limpiar los bytes del modelo
    _model.setFileUrl(''); // Limpiar el nombre del archivo del modelo
    _model.errorMessage = '';
    notifyListeners();
  }

  /// Realiza la subida de contenido al backend.
  Future<bool> uploadContent() async {
    _isLoading = true;
    _model.errorMessage = '';
    notifyListeners();

    if (!_model.validateContent()) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final success = await _apiService.uploadContent(_model);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _model.errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Realiza la inscripción de un usuario a un contenido.
  Future<bool> registerForContent(contentId) async {
    _isRegistering = true;
    _inscriptionErrorMessage = null;
    notifyListeners();
    contentId = int.tryParse(contentId);
    try {
      final success = await _apiService.inscribeUserToContent(contentId);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (success) {
        _isCurrentlyRegistered = true; // Si la API dice éxito, marcar como true
        _isRegistering = false;
        _inscriptionErrorMessage = null;
      } else {
        // Si la API devuelve false, significa que no se inscribió (ej. ya estaba inscrito o error en backend)
        _isCurrentlyRegistered = false;
        // Puedes intentar obtener un mensaje de error más específico de tu API si lo proporciona
        _inscriptionErrorMessage =
            "No se pudo completar la inscripción. Posiblemente ya estás inscrito.";
      }
      notifyListeners();

      return true; // Retorna el resultado del servicio API

      // return success; // Retorna el resultado del servicio API
    } catch (e) {
      // Captura cualquier excepción lanzada por el servicio API (incluyendo mensajes de error personalizados)
      _inscriptionErrorMessage = e.toString().replaceFirst('Exception: ', '');
      _isRegistering = false;
      notifyListeners(); // Notifica que la operación ha terminado y hay un error

      return false; // Retorna false si hubo un error
    }
  }

  /// Estructura del método para verificar el estado de registro de un usuario en un contenido.
  Future<void> checkUserRegistrationStatus(String contentId) async {
    // Verifica si el ID del usuario actual ya está cargado.
    // Si _currentUserId es nulo, intenta obtenerlo del servicio de API.
    if (_currentUserId == null) {
      _currentUserId = await _apiService.getUserIdFromToken();

      if (_currentUserId == null) {
        // Si aún después de intentar, el ID es nulo, maneja el error y sal.
        _inscriptionErrorMessage =
            'No se pudo obtener el ID del usuario logueado para verificar el estado.';
        _isCurrentlyRegistered = false;
        notifyListeners();
        return; // Salir del método si no hay userId.
      }
    }

    // Restablecer el mensaje de error y activar el estado de carga.
    _inscriptionErrorMessage = null;
    _isRegistering = true;

    try {
      bool registered = await _apiService.isUserRegisteredForContent(
        contentId,
        _currentUserId!,
      );

      //  Actualizar el estado de _currentUserId controlador con la respuesta del servicio.
      _isCurrentlyRegistered = registered;
      notifyListeners();
    } catch (e) {
      debugPrint('Error al verificar estado de registro: $e');
      _inscriptionErrorMessage =
          'Error al verificar la inscripción: ${e.toString().contains('Exception:') ? e.toString().split('Exception:').last.trim() : e.toString()}';
      _isCurrentlyRegistered = false;
    } finally {
      // Finalizar el estado de carga y notificar a la UI.
      _isRegistering = false;
      notifyListeners(); // Notificar a la UI para que se actualice (ej. ocultar spinner, mostrar botón/estado)
    }
  }

  // Método para obtener los contenidos INSCRITOS del usuario actual
  Future<void> fetchUserRegisteredContents() async {
    _isLoadingRegisteredContents =
        true; // Indicador de carga ESPECÍFICO para contenidos inscritos
    _registeredContentsErrorMessage =
        null; // Mensaje de error ESPECÍFICO para contenidos inscritos
    _userRegisteredContents = []; // Limpia la lista antes de cargar
    notifyListeners(); // Notifica a la UI para mostrar el spinner

    try {
      // Llama al API para los contenidos INSCRITOS (el backend filtra por el token JWT)
      _userRegisteredContents = await _apiService.fetchUserRegisteredContents();
      // No hay _filteredContents aquí, a menos que quieras un filtro adicional para los contenidos ya inscritos.
    } catch (e) {
      _registeredContentsErrorMessage = e.toString().replaceFirst(
        'Exception: ',
        '',
      ); // Asigna error ESPECÍFICO
      _userRegisteredContents =
          []; // Asegura que la lista esté vacía en caso de error
    } finally {
      _isLoadingRegisteredContents = false; // Desactiva carga ESPECÍFICA
      notifyListeners();
    }
  }

  // Método para limpiar el mensaje de error de inscripción
  void clearInscriptionError() {
    _inscriptionErrorMessage = null;
    notifyListeners();
  }

  // Método para limpiar los campos del formulario después de una subida exitosa
  void clearForm() {
    _model.setTitle('');
    _model.setDescription('');
    _model.setAuthor('');
    _model.setFileUrl('');
    _model.setCategory('');
    _model.errorMessage = '';
    notifyListeners();
  }
}
