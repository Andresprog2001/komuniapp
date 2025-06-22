// komuniapp/views/registered_content_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:komuniapp/models/content_model.dart'; // Asegúrate de que este path es correcto
import 'package:komuniapp/controllers/upload_content_controller.dart';
import 'package:komuniapp/views/content_detail_view.dart'; // Necesitas importar ContentDetailView para la navegación

class RegisteredContentView extends StatefulWidget {
  const RegisteredContentView({Key? key}) : super(key: key);

  @override
  State<RegisteredContentView> createState() => _RegisteredContentViewState();
}

class _RegisteredContentViewState extends State<RegisteredContentView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Llama al método fetchUserRegisteredContents del UploadContentController
      Provider.of<UploadContentController>(
        context,
        listen: false,
      ).fetchUserRegisteredContents();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios en el UploadContentController para actualizar la lista
    final uploadContentController = Provider.of<UploadContentController>(
      context,
    );

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text(
          'Mis Contenidos Inscritos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: uploadContentController.isLoadingRegisteredContents
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : uploadContentController
                .userRegisteredContents
                .isEmpty // Usa la lista de contenidos registrados del controlador
          ? const Center(
              child: Text(
                'Aún no te has inscrito a ningún contenido.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: uploadContentController.userRegisteredContents.length,
              itemBuilder: (context, index) {
                final content =
                    uploadContentController.userRegisteredContents[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Categoría: ${content.category}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Autor: ${content.author}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navega a ContentDetailView para ver los detalles
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ContentDetailView(
                                    content: content,
                                    fromRegisteredView: true,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Ver Detalles'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
