import 'package:equatable/equatable.dart';


abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Error en el servidor.'});
}


class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Error de caché.'});
}


class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Recurso no encontrado.'});
}


class InvalidParamsFailure extends Failure {
  const InvalidParamsFailure({super.message = 'Parámetros inválidos.'});
}




class ConflictFailure extends Failure {
  const ConflictFailure({super.message = 'Conflicto de datos.'});
}


class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure({required String message}) : super(message: message);
}



class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No hay conexión a internet.'});
}


class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Error de autenticación.'});
}