// lib/controllers/upload_content_controller.dart
import 'package:flutter/material.dart';
import 'package:komuniapp/models/upload_content_model.dart';
import 'package:komuniapp/services/content_api_service.dart';

class UploadContentController extends ChangeNotifier {
  final UploadContentModel _model = UploadContentModel();
  final ContentApiService _apiService = ContentApiService();
  bool _isLoading = false;

  String get title => _model.title;
  String get description => _model.description;
  String get author => _model.author;
  String get fileUrl => _model.fileUrl; // <<-- CAMBIO: 'file' a 'fileUrl'
  String get category => _model.category;
  String get errorMessage => _model.errorMessage;
  bool get isLoading => _isLoading;

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
  } // <<-- CAMBIO: 'setFile' a 'setFileUrl'

  void setCategory(String? value) {
    if (value != null) {
      _model.setCategory(value);
    }
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
