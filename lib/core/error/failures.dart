import 'package:equatable/equatable.dart';

/// Base abstract class for all application failures.
/// It extends [Equatable] to allow for easy comparison of failure objects.
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}


/// Represents an error originating from the server or API.
class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Error en el servidor.'});
}

/// Represents an error related to caching operations (e.g., reading/writing from local storage).
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Error de caché.'});
}

/// Represents a scenario where a requested resource was not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Recurso no encontrado.'});
}

/// Represents an error due to invalid or missing parameters.
class InvalidParamsFailure extends Failure {
  const InvalidParamsFailure({super.message = 'Parámetros inválidos.'});
}

// --- Additional common failure types you might need ---

/// Represents a conflict (e.g., trying to create a resource that already exists).
class ConflictFailure extends Failure {
  const ConflictFailure({super.message = 'Conflicto de datos.'});
}

/// Represents a scenario where the user does not have the necessary permissions.
class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure({required String message}) : super(message: message);
}


/// Represents a general network-related issue (e.g., no internet connection).
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No hay conexión a internet.'});
}

/// Represents an authentication failure (e.g., wrong credentials, token expired).
class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Error de autenticación.'});
}