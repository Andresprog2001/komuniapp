import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:komuniapp/controllers/user_profile_controller.dart';
import 'package:komuniapp/models/user_profile_model.dart';
// user_api_service.dart ya no se importa directamente aquí,
// ya que el controlador se encarga de interactuar con él.
// import 'package:komuniaapp/services/user_api_service.dart';

class UserProfileView extends StatefulWidget {
  // Ya no se necesita ningún argumento en el constructor para la vista
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  @override
  void initState() {
    super.initState();
    // Registra una devolución de llamada para ejecutar después de que el primer cuadro haya sido renderizado.
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   // Obtiene la instancia de UserProfileController del árbol de widgets.
    //   // listen: false significa que este widget no se reconstruirá cuando el controlador notifique cambios,
    //   // ya que solo estamos llamando a un método en initState.
    //   final userProfileController = Provider.of<UserProfileController>(
    //     context,
    //     listen: false,
    //   );

    //   // Llama al método del controlador para cargar el perfil del usuario actual.
    //   // El controlador se encarga internamente de obtener el user_id de SharedPreferences.
    //   userProfileController.fetchUserProfile();
    // });
  }

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios en el UserProfileController para reconstruir la UI
    // cuando cambian los estados de carga, error o los datos del perfil.
    final userProfileController = Provider.of<UserProfileController>(context);

    return Scaffold(
      backgroundColor:
          Colors.white, // Fondo gris oscuro para la pantalla de perfil
      appBar: AppBar(
        title: const Text(
          'KomuniApp', // Título "KomuniApp"
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple, // Color de AppBar oscuro
        centerTitle: false, // No centrar el título
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Color del icono de retroceso
      ),
      body:
          // userProfileController
          //     .isLoading // Muestra un indicador de carga si los datos están cargando
          // ? const Center(child: CircularProgressIndicator())
          // : userProfileController
          //       .errorMessage
          //       .isNotEmpty // Muestra un mensaje de error si ocurre uno
          // ? Center(
          //     child: Padding(
          //       padding: const EdgeInsets.all(16.0),
          //       child: Text(
          //         userProfileController.errorMessage,
          //         style: const TextStyle(color: Colors.red, fontSize: 16),
          //         textAlign: TextAlign.center,
          //       ),
          //     ),
          //   )
          // : userProfileController.userProfile ==
          //       null // Muestra un mensaje si el perfil es nulo
          // ? const Center(
          //     child: Text('No se pudo cargar el perfil del usuario.'),
          //   )
          // : Center(
          //     // <<-- CENTRA EL CONTENIDO PRINCIPAL -->>
          //     child: SingleChildScrollView(
          //       // Permite el desplazamiento si el contenido es demasiado largo
          //       padding: const EdgeInsets.all(
          //         16.0,
          //       ), // Padding general alrededor de la tarjeta
          //       child: Card(
          //         // <<-- ÚNICA TARJETA CONTENIENDO TODOS LOS DATOS -->>
          //         margin: EdgeInsets
          //             .zero, // Elimina el margen de la tarjeta si el Center ya da padding
          //         elevation: 8, // Mayor sombra para dar más profundidad
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(
          //             18,
          //           ), // Bordes más redondeados para la tarjeta
          //         ),
          //         color: Colors.white, // Fondo de tarjeta blanco
          //         child: Padding(
          //           padding: const EdgeInsets.all(
          //             32,
          //           ), // Mayor padding dentro de la tarjeta
          //           child: Column(
          //             mainAxisSize:
          //                 MainAxisSize.min, // Ajusta la columna a su contenido
          //             crossAxisAlignment: CrossAxisAlignment
          //                 .center, // <<-- CENTRA LOS ELEMENTOS HORIZONTALMENTE -->>
          //             children: [
          //               // Imagen de perfil
          //               const CircleAvatar(
          //                 backgroundImage: NetworkImage(
          //                   'https://placehold.co/150x150/d3c2eb/59408e?text=User', // Puedes reemplazar con una imagen de usuario real
          //                 ),
          //                 radius: 60, // Tamaño del avatar aumentado
          //               ),
          //               const SizedBox(height: 24), // Espacio vertical
          //               // <<-- SECCIÓN DE NOMBRE CON ETIQUETA Y ESTILO AJUSTADO -->>
          //               const Text(
          //                 "Nombre",
          //                 style: TextStyle(
          //                   fontWeight: FontWeight.bold,
          //                   fontSize: 16,
          //                   color: Colors.black,
          //                 ), // Label en negrita, negro
          //               ),
          //               const SizedBox(height: 4),
          //               Text(
          //                 userProfileController.userProfile!.name,
          //                 style: const TextStyle(
          //                   fontSize: 18, // Tamaño de fuente ajustado
          //                   color: Colors.black, // Texto en negro normal
          //                 ),
          //               ),
          //               const SizedBox(
          //                 height: 16,
          //               ), // Espacio para separar secciones
          //               // <<-- SECCIÓN DE CORREO ELECTRÓNICO CON ETIQUETA Y ESTILO AJUSTADO -->>
          //               const Text(
          //                 "Correo Electrónico",
          //                 style: TextStyle(
          //                   fontWeight: FontWeight.bold,
          //                   fontSize: 16,
          //                   color: Colors.black,
          //                 ), // Label en negrita, negro
          //               ),
          //               const SizedBox(height: 4),
          //               Text(
          //                 userProfileController.userProfile!.email,
          //                 style: const TextStyle(
          //                   color: Colors.black, // Texto en negro normal
          //                   fontSize: 16,
          //                 ), // Tamaño de fuente ajustado
          //               ),
          //               const SizedBox(
          //                 height: 16,
          //               ), // Espacio antes de la fecha y género
          //               // <<-- SECCIÓN "ACTIVO DESDE" CON ETIQUETA Y ESTILO AJUSTADO -->>
          //               const Text(
          //                 // Etiqueta para "Activo desde"
          //                 "Activo desde",
          //                 style: TextStyle(
          //                   fontWeight: FontWeight.bold,
          //                   fontSize: 16,
          //                   color: Colors.black,
          //                 ), // Label en negrita, negro
          //               ),
          //               const SizedBox(height: 4),
          //               Text(
          //                 userProfileController.userProfile!.createdAt,
          //                 style: const TextStyle(
          //                   color: Colors.black, // Texto en negro normal
          //                   fontSize: 14,
          //                 ),
          //               ),
          //               const SizedBox(height: 16),
          //               // <<-- SECCIÓN DE GÉNERO CON ETIQUETA Y ESTILO AJUSTADO -->>
          //               const Text(
          //                 "Género",
          //                 style: TextStyle(
          //                   fontWeight: FontWeight.bold,
          //                   fontSize: 16,
          //                   color: Colors.black,
          //                 ), // Label en negrita, negro
          //               ),
          //               const SizedBox(height: 4),
          //               Text(
          //                 userProfileController.userProfile!.gender,
          //                 style: const TextStyle(
          //                   fontSize: 14,
          //                   color: Colors.black,
          //                 ), // Texto en negro normal
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          Center(
            // Este es el único 'child' directo del body
            // <<-- CENTRA EL CONTENIDO PRINCIPAL -->>
            child: SingleChildScrollView(
              // Permite el desplazamiento si el contenido es demasiado largo
              padding: const EdgeInsets.all(
                16.0,
              ), // Padding general alrededor de la tarjeta
              child: Card(
                // <<-- ÚNICA TARJETA CONTENIENDO TODOS LOS DATOS -->>
                margin: EdgeInsets
                    .zero, // Elimina el margen de la tarjeta si el Center ya da padding
                elevation: 8, // Mayor sombra para dar más profundidad
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    18,
                  ), // Bordes más redondeados para la tarjeta
                ),
                color: Colors.white, // Fondo de tarjeta blanco
                child: Padding(
                  padding: const EdgeInsets.all(
                    32,
                  ), // Mayor padding dentro de la tarjeta
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // Ajusta la columna a su contenido
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // <<-- CENTRA LOS ELEMENTOS HORIZONTALMENTE -->>
                    children: [
                      // Imagen de perfil
                      const CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://placehold.co/150x150/d3c2eb/59408e?text=User', // Puedes reemplazar con una imagen de usuario real
                        ),
                        radius: 60, // Tamaño del avatar aumentado
                      ),
                      const SizedBox(height: 24), // Espacio vertical
                      // <<-- SECCIÓN DE NOMBRE CON ETIQUETA Y ESTILO AJUSTADO -->>
                      const Text(
                        "Nombre",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ), // Label en negrita, negro
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Kevin Stiven Rodriguez Vargas", // Texto del nombre quemado
                        style: TextStyle(
                          fontSize: 18, // Tamaño de fuente ajustado
                          color: Colors.black, // Texto en negro normal
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ), // Espacio para separar secciones
                      // <<-- SECCIÓN DE CORREO ELECTRÓNICO CON ETIQUETA Y ESTILO AJUSTADO -->>
                      const Text(
                        "Correo Electrónico",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ), // Label en negrita, negro
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "kevinstivenrodriguezvargas@gmail.com", // Texto del correo quemado
                        style: TextStyle(
                          color: Colors.black, // Texto en negro normal
                          fontSize: 16,
                        ), // Tamaño de fuente ajustado
                      ),
                      const SizedBox(
                        height: 16,
                      ), // Espacio antes de la fecha y género
                      // <<-- SECCIÓN "ACTIVO DESDE" CON ETIQUETA Y ESTILO AJUSTADO -->>
                      const Text(
                        // Etiqueta para "Activo desde"
                        "Activo desde",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ), // Label en negrita, negro
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "10 de Junio del 2024", // Texto de la fecha quemado
                        style: TextStyle(
                          color: Colors.black, // Texto en negro normal
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // <<-- SECCIÓN DE GÉNERO CON ETIQUETA Y ESTILO AJUSTADO -->>
                      const Text(
                        "Género",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ), // Label en negrita, negro
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Masculino", // Texto del género quemado
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ), // Texto en negro normal
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
