import 'package:equatable/equatable.dart';

sealed class AppException extends Equatable implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalException,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [message, code];
}

final class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });
}

final class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });
}

final class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    this.statusCode,
    super.code,
    super.originalException,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [...super.props, statusCode];
}

final class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });
}

final class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required super.message,
    this.fieldErrors,
    super.code,
    super.originalException,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

final class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });
}
