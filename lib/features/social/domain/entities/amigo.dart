class Amigo {
  final String id;
  final String email;
  final String displayName;
  final String username;
  int cantidadParques;

  Amigo({
    required this.id,
    required this.email,
    required this.displayName,
    required this.username,
    this.cantidadParques = 0,
  });
}
