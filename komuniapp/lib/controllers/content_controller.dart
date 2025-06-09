// lib/controllers/educational_content_controller.dart
import 'package:flutter/material.dart';
import 'package:komuniapp/models/content_model.dart'; // Importa el modelo
import 'package:komuniapp/services/content_api_service.dart';

class ContentController extends ChangeNotifier {
  final ContentApiService _apiService = ContentApiService();
  List<Content> _allContents = [];
  List<Content> _filteredContents = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Content> get filteredContents => _filteredContents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ContentController() {
    fetchContents();
  }

  Future<void> fetchContents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allContents = await _apiService.fetchContents();
      _filteredContents = _allContents;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterContents(String query) {
    final lowerQuery = query.toLowerCase();
    _filteredContents = _allContents.where((content) {
      // Estas propiedades ya son las correctas en el modelo (fileUrl)
      return content.title.toLowerCase().contains(lowerQuery) ||
          content.author.toLowerCase().contains(lowerQuery) ||
          content.category.toLowerCase().contains(lowerQuery);
    }).toList();
    notifyListeners();
  }
}
