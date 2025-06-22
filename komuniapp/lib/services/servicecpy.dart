// komuniapp/views/content_detail_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:komuniapp/models/content_model.dart';
import 'package:komuniapp/controllers/upload_content_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class ContentDetailView extends StatefulWidget {
  final Content content;
  final bool
  fromRegisteredView; // true si viene de la vista de contenidos inscritos

  const ContentDetailView({
    Key? key,
    required this.content,
    this.fromRegisteredView = false,
  }) : super(key: key);

  @override
  State<ContentDetailView> createState() => _ContentDetailViewState();
}

class _ContentDetailViewState extends State<ContentDetailView> {
  @override
  void initState() {
    super.initState();

    if (!widget.fromRegisteredView) {
      // Verificar si el usuario ya está inscrito al contenido

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkInitialRegistrationStatus();
      });
    }
  }

  // Método para verificar el estado inicial de inscripción
  Future<void> _checkInitialRegistrationStatus() async {
    // Usamos Provider.of con listen: false porque solo necesitamos llamar a un método
    // y no queremos reconstruir el widget solo por este cambio.
    final contentController = Provider.of<UploadContentController>(
      context,
      listen: false,
    );

    if (widget.content.id != null) {
      await contentController.checkUserRegistrationStatus(widget.content.id);
    }
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        // Verificar si el widget está montado antes de mostrar SnackBar
        debugPrint('No se pudo abrir la URL: $uri');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el archivo.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final minCardHeight = screenHeight * 0.80;
    final cardWidth = screenWidth * 0.90;

    // Se mantiene como Provider.of, lo cual hará que todo el build se reconstruya
    // cuando el UploadContentController llame a notifyListeners().
    // Esto es NECESARIO para que la UI reaccione a los cambios en isCurrentlyRegistered
    final contentController = Provider.of<UploadContentController>(context);

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text(
          widget.content.title, // Usar widget.content en StatefulWidget
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: cardWidth,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minCardHeight),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sección de Título
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.content.title, // Usar widget.content
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),

                      // Sección de Categoría y Autor
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Categoría: ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: widget
                                      .content
                                      .category, // Usar widget.content
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Autor: ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: widget
                                      .content
                                      .author, // Usar widget.content
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                        ],
                      ),

                      // Sección de Descripción
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Descripción:',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.content.description, // Usar widget.content
                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Sección de Botones (Abrir Archivo e Inscribirse)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextButton(
                            onPressed: () {
                              _launchUrl(
                                context,
                                widget.content.fileUrl,
                              ); // Usar widget.content
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue.withOpacity(0.1),
                              foregroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                            ),
                            child: const Text(
                              'Abrir Archivo',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // ------------------------------------------------------------------
                          // Lógica para mostrar "¡Inscrito!" o el botón "Inscribirse"
                          if (contentController.isCurrentlyRegistered)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.shade400,
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 28,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    '¡Inscrito!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ElevatedButton(
                              onPressed: contentController.isRegistering
                                  ? null
                                  : () async {
                                      final contentId = widget
                                          .content
                                          .id; // Usar widget.content

                                      if (contentId == null) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Error: ID de contenido no válido.',
                                              ),
                                            ),
                                          );
                                        }
                                        return;
                                      }

                                      bool success = await contentController
                                          .registerForContent(contentId);

                                      if (mounted) {
                                        if (success) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                '¡Inscripción exitosa!',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                          // El contentController.isCurrentlyRegistered se actualiza y notifyListeners() es llamado.
                                          // Como ContentDetailView hace Provider.of(context), se reconstruirá y mostrará "¡Inscrito!".
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                contentController
                                                        .inscriptionErrorMessage ??
                                                    'Error al inscribirse.',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: contentController.isRegistering
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Inscribirse',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          const SizedBox(height: 15),

                          if (contentController.inscriptionErrorMessage !=
                                  null &&
                              contentController
                                  .inscriptionErrorMessage!
                                  .isNotEmpty &&
                              !contentController.isRegistering &&
                              !contentController.isCurrentlyRegistered)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                contentController.inscriptionErrorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
