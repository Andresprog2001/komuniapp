// lib/views/content_detail_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:komuniapp/models/content_model.dart';
import 'package:komuniapp/controllers/upload_content_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class ContentDetailView extends StatefulWidget {
  final Content content;
  final bool fromRegisteredView;

  const ContentDetailView({
    super.key,
    required this.content,
    this.fromRegisteredView = false,
  });

  @override
  State<ContentDetailView> createState() => _ContentDetailViewState();
}

class _ContentDetailViewState extends State<ContentDetailView> {
  @override
  void initState() {
    super.initState();
    if (!widget.fromRegisteredView) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<UploadContentController>(
          context,
          listen: false,
        ).checkUserRegistrationStatus(widget.content.id.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.content.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 10),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 10),
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
                        text: widget.content.category, // Usar widget.content
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
                        text: widget.content.author, // Usar widget.content
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Descripción:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.content.description,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 30),
                // Botón para Abrir Archivo
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (await canLaunchUrl(
                        Uri.parse(widget.content.fileUrl),
                      )) {
                        await launchUrl(
                          Uri.parse(widget.content.fileUrl),
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No se pudo abrir el archivo.'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Abrir Archivo',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Lógica para el botón de Inscribirse/Inscrito/Cargando con los estilos exactos
                if (!widget.fromRegisteredView)
                  Consumer<UploadContentController>(
                    builder: (context, controller, child) {
                      if (controller.isRegistering) {
                        // Estado de carga (Spinner)
                        return Container(
                          width: double.infinity,
                          height:
                              50, // Altura para que el spinner se vea bien dentro del botón
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors
                                .grey[200], // Fondo gris claro como en la imagen
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade400,
                            ), // Borde opcional si lo deseas
                          ),
                          child: const CircularProgressIndicator(
                            color: Colors
                                .deepPurple, // Color del spinner, morado como el tema
                          ),
                        );
                      } else if (controller.isCurrentlyRegistered) {
                        // Estado "¡Inscrito!"
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100, // Fondo verde claro
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors
                                  .green
                                  .shade400, // Borde verde más oscuro
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green, // Icono verde
                                size: 28,
                              ),
                              SizedBox(width: 10),
                              Text(
                                '¡Inscrito!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green, // Texto verde
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (controller.inscriptionErrorMessage != null) {
                        // Si hay un error, mostrar el mensaje y el botón de Inscribirse
                        return Column(
                          children: [
                            Text(
                              controller.inscriptionErrorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  // <-- Make onPressed async here
                                  final contentId = widget.content.id;

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

                                  await controller.registerForContent(
                                    contentId,
                                  ); // <-- Await the call
                                  // The Consumer will rebuild the UI when notifyListeners() is called by the controller.
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.deepPurple, // Fondo morado
                                  foregroundColor: Colors.white, // Texto blanco
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Inscribirse',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Botón "Inscribirse"
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              // <-- Make onPressed async here
                              final contentId = widget.content.id;

                              if (contentId == null) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Error: ID de contenido no válido.',
                                      ),
                                    ),
                                  );
                                }
                                return;
                              }

                              await controller.registerForContent(
                                contentId,
                              ); // <-- Await the call
                              // The Consumer will rebuild the UI when notifyListeners() is called by the controller.
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.deepPurple, // Fondo morado
                              foregroundColor: Colors.white, // Texto blanco
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Inscribirse',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                // Fin de la lógica condicional del botón de inscripción
              ],
            ),
          ),
        ),
      ),
    );
  }
}
