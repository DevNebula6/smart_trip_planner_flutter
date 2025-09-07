abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

// Custom exceptions
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  
  const ServerException(this.message, {this.statusCode});
}

class NetworkException implements Exception {
  final String message;
  
  const NetworkException(this.message);
}

class CacheException implements Exception {
  final String message;
  
  const CacheException(this.message);
}

class ValidationException implements Exception {
  final String message;
  
  const ValidationException(this.message);
}

class AuthenticationException implements Exception {
  final String message;
  
  const AuthenticationException(this.message);
}
class AIAgentException implements Exception {
  final String message;
  AIAgentException(this.message);
  
  @override
  String toString() => 'AIAgentException: $message';
}