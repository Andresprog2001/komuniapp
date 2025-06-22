// lib/views/upload_content_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:komuniapp/controllers/upload_content_controller.dart';
import 'package:komuniapp/views/content_view.dart'; // Mantener si se usa en el BottomAppBar
import 'package:file_picker/file_picker.dart'; // <<<--- AÑADIR ESTA IMPORTACIÓN

class UploadContentView extends StatefulWidget {
  const UploadContentView({super.key});

  @override
  _UploadContentViewState createState() => _UploadContentViewState();
}

class _UploadContentViewState extends State<UploadContentView> {
  // =========================================================================
  // TextEditingControllers para cada TextField
  // Esto permite controlar el texto programáticamente, especialmente para el campo del archivo.
  // =========================================================================
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _authorController;
  late TextEditingController
  _fileDisplayController; // Para mostrar el nombre del archivo

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
    // =========================================================================
    // Inicializar los TextEditingControllers en initState
    // Y conectarlos con los valores actuales del controlador (Provider).
    // =========================================================================
    final uploadController = Provider.of<UploadContentController>(
      context,
      listen: false,
    );
    _titleController = TextEditingController(text: uploadController.title);
    _descriptionController = TextEditingController(
      text: uploadController.description,
    );
    _authorController = TextEditingController(text: uploadController.author);
    _fileDisplayController = TextEditingController(
      text: uploadController.fileUrl,
    ); // Inicializar con el nombre del archivo actual
  }

  @override
  void dispose() {
    // =========================================================================
    //  Desechar los TextEditingControllers en dispose
    // =========================================================================
    _titleController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    _fileDisplayController.dispose();
    super.dispose();
  }

  // metodo para seleccionar un archivo
  Future<void> _pickFile() async {
    final uploadController = Provider.of<UploadContentController>(
      context,
      listen: false,
    );
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type:
          FileType.custom, // Puedes especificar tipos: .pdf, .docx, .mp4, etc.
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'xls',
        'xlsx',
        'txt',
        'mp4',
        'mov',
        'avi',
        'jpg',
        'jpeg',
        'png',
        'gif',
      ], // Ejemplos de extensiones
      allowMultiple: false, // Solo permitir seleccionar un archivo
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      if (file.bytes != null) {
        uploadController.setSelectedFile(file.bytes, file.name);
        _fileDisplayController.text =
            file.name; // Actualizar el TextField con el nombre del archivo
      } else {
        // Manejar el caso donde los bytes no están disponibles (ej. web con archivos muy grandes)
        uploadController.setErrorMessage(
          'No se pudo leer el archivo. Intenta de nuevo.',
        );
      }
    } else {
      // El usuario canceló la selección de archivos
      uploadController.clearSelectedFile();
      _fileDisplayController.clear(); // Limpiar el TextField si se cancela
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios en el UploadContentController
    final uploadController = Provider.of<UploadContentController>(context);

    if (_titleController.text != uploadController.title) {
      _titleController.text = uploadController.title;
      _titleController.selection = TextSelection.fromPosition(
        TextPosition(offset: _titleController.text.length),
      );
    }
    if (_descriptionController.text != uploadController.description) {
      _descriptionController.text = uploadController.description;
      _descriptionController.selection = TextSelection.fromPosition(
        TextPosition(offset: _descriptionController.text.length),
      );
    }
    if (_authorController.text != uploadController.author) {
      _authorController.text = uploadController.author;
      _authorController.selection = TextSelection.fromPosition(
        TextPosition(offset: _authorController.text.length),
      );
    }
    if (_fileDisplayController.text != uploadController.fileUrl) {
      // <<<--- CAMBIO CLAVE 5: Usar fileUrl
      _fileDisplayController.text = uploadController.fileUrl;
      _fileDisplayController.selection = TextSelection.fromPosition(
        TextPosition(offset: _fileDisplayController.text.length),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'KomuniApp',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Usar const para IconThemeData
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
              controller: _titleController, // <<<--- Asignar controller
              onChanged: uploadController.setTitle,
              decoration: const InputDecoration(
                hintText: 'Ingresa título del trabajo',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _authorController, // <<<--- Asignar controller
              onChanged: uploadController.setAuthor,
              decoration: const InputDecoration(
                hintText: 'Ingresa autor del trabajo',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _descriptionController,
              onChanged: uploadController.setDescription,
              maxLines: 5, // Permite un número ilimitado de líneas
              keyboardType: TextInputType.multiline,
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
                    controller:
                        _fileDisplayController, // <<<--- Asignar controller para el nombre del archivo
                    readOnly:
                        true, // Para que el usuario no pueda escribir aquí
                    decoration: const InputDecoration(
                      hintText: 'Selecciona un archivo...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed:
                      _pickFile, // <<<--- Llamar a la nueva función _pickFile
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Seleccionar Archivo',
                  ), // <<<--- Cambiar texto del botón
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
                          uploadController.setCategory(value);
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
                          Navigator.pushReplacementNamed(
                            context,
                            "/contents",
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
