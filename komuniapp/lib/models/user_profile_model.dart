class UserProfile {
  final String name;
  final String email;
  final String createdAt;
  final String gender;

  UserProfile({
    required this.name,
    required this.email,
    required this.createdAt,
    required this.gender,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      // Asegúrate que el nombre de la clave coincida con el backend
      name: json['name'],
      email: json['email'],
      createdAt: json['created_at'],
      // Convertir la lista de intereses, manejando si es nula
      gender: json['gender'],
    );
  }
}
