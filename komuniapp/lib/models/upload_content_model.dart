// lib/models/upload_content_model.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';

class UploadContentModel extends ChangeNotifier {
  String _title = '';
  String _description = '';
  String _author = '';
  String _fileUrl = '';
  Uint8List? _fileBytes;
  String _category = '';
  String _errorMessage = '';

  String get title => _title;
  String get description => _description;
  String get author => _author;
  String get fileUrl => _fileUrl;
  Uint8List? get fileBytes => _fileBytes;
  String get category => _category;
  String get errorMessage => _errorMessage;

  set errorMessage(String message) {
    _errorMessage = message;
  }

  void setTitle(String value) {
    _title = value;
  }

  void setDescription(String value) {
    _description = value;
  }

  void setAuthor(String value) {
    _author = value;
  }

  void setFileUrl(String value) {
    _fileUrl = value;
  }

  void setFileBytes(Uint8List? bytes) {
    _fileBytes = bytes;
  }

  void setCategory(String value) {
    _category = value;
  }

  void setErrorMessage(String value) {
    _category = value;
  }

  /// Valida los campos del formulario de subida de contenido.
  bool validateContent() {
    _errorMessage = '';
    if (_title.isEmpty) {
      _errorMessage = 'El título no puede estar vacío.';
      return false;
    }
    if (_description.isEmpty) {
      _errorMessage = 'La descripción no puede estar vacía.';
      return false;
    }
    if (_author.isEmpty) {
      _errorMessage = 'El autor no puede estar vacío.';
      return false;
    }
    if (_fileUrl.isEmpty) {
      _errorMessage = 'El enlace o archivo no puede estar vacío.';
      return false;
    }
    // if (_fileBytes == null || _fileUrl.isEmpty) {
    //   _errorMessage = 'Por favor, selecciona un archivo para cargar.';
    //   return false;
    // }

    if (_category.isEmpty) {
      _errorMessage = 'Selecciona una categoría.';
      return false;
    }
    return true;
  }

  /// Convierte el modelo a un mapa JSON para enviar al backend.
  Map<String, dynamic> toJson() {
    return {
      'title': _title,
      'description': _description,
      'author': _author,
      'file_url': _fileUrl,
      'file_bytes': _fileBytes != null ? _fileBytes!.toString() : null,
      'category': _category,
    };
  }
}
