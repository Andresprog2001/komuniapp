// lib/views/upload_content_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:komuniapp/controllers/upload_content_controller.dart';
import 'package:komuniapp/views/content_view.dart'; // Mantener si se usa en el BottomAppBar

class UploadContentView extends StatefulWidget {
  const UploadContentView({super.key});

  @override
  _UploadContentViewState createState() => _UploadContentViewState();
}

class _UploadContentViewState extends State<UploadContentView> {
  // <<-- ELIMINADO: Ya no se declaran TextEditingController aquí -->>
  // final _titleController = TextEditingController();
  // final _authorController = TextEditingController();
  // final _linkController = TextEditingController();

  // selectedCategory ya no es necesario aquí, el controlador lo manejará.

  final List<String> categories = [
    'Programación',
    'Matemáticas',
    'Cálculo',
    'Inglés',
    'Sociales',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uploadController = Provider.of<UploadContentController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'KomuniApp',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Ingreso de contenido',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: uploadController
                  .setTitle, // Actualizar el controlador directamente
              controller: TextEditingController(text: uploadController.title),
              decoration: const InputDecoration(
                hintText: 'Ingresa título del trabajo',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              // <<-- ELIMINADO: controller: ya no se usa -->>
              onChanged: uploadController
                  .setAuthor, // Actualizar el controlador directamente
              // <<-- Añadido initialValue para que refleje el estado del controlador -->>
              controller: TextEditingController(text: uploadController.author),
              decoration: const InputDecoration(
                hintText: 'Ingresa autor del trabajo',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              onChanged: uploadController
                  .setDescription, // Actualizar el controlador directamente
              // <<-- Añadido initialValue para que refleje el estado del controlador -->>
              controller: TextEditingController(
                text: uploadController.description,
              ),
              decoration: const InputDecoration(
                hintText: 'Ingresa la descripcion del contenido',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    // <<-- ELIMINADO: controller: ya no se usa -->>
                    onChanged: uploadController
                        .setFileUrl, // Actualizar el controlador directamente
                    // <<-- Añadido initialValue para que refleje el estado del controlador -->>
                    controller: TextEditingController(
                      text: uploadController.fileUrl,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Ingresa archivo o enlace',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Acción al buscar archivo (mantener como está o implementar lógica de selección de archivo)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Buscar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Categoría',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories.map((category) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: category,
                      groupValue: uploadController.category.isEmpty
                          ? null
                          : uploadController.category,
                      onChanged: (value) {
                        if (value != null) {
                          uploadController.setCategory(
                            value,
                          ); // Actualizar el controlador directamente
                        }
                      },
                    ),
                    Text(category, style: const TextStyle(color: Colors.black)),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Mensaje de error (si existe)
            if (uploadController.errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  uploadController.errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 14.0),
                  textAlign: TextAlign.center,
                ),
              ),
            Center(
              child: ElevatedButton(
                onPressed: uploadController.isLoading
                    ? null
                    : () async {
                        bool success = await uploadController.uploadContent();

                        if (!context.mounted) return;

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                '¡Contenido cargado exitosamente!',
                              ),
                              backgroundColor: Colors.green[700],
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(10),
                            ),
                          );
                          Navigator.pop(
                            context,
                          ); // Volver a la pantalla anterior
                        } else {
                          // El mensaje de error ya se muestra en el UI a través del Provider
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  foregroundColor: Colors.white,
                ),
                child: uploadController.isLoading
                    ? const CircularProgressIndicator(
                        // Mostrar indicador de carga
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('Cargar contenido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
