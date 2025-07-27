class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (${statusCode ?? 'No status code'})';
}

class CacheException implements Exception {
  final String message;

  CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class NotFoundException implements Exception {
  final String message;

  NotFoundException({required this.message});

  @override
  String toString() => 'NotFoundException: $message';
}

class PermissionDeniedException implements Exception {
  final String message;

  PermissionDeniedException({required this.message});

  @override
  String toString() => 'PermissionDeniedException: $message';
}

class ConflictException implements Exception {
  final String message;

  ConflictException({required this.message});

  @override
  String toString() => 'ConflictException: $message';
}

class FormatException implements Exception {
  final String message;

  FormatException({required this.message});

  @override
  String toString() => 'FormatException: $message';
}