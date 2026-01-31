import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

final class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

final class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

final class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    this.statusCode,
    super.code,
  });

  @override
  List<Object?> get props => [...super.props, statusCode];
}

final class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

final class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure({
    required super.message,
    this.fieldErrors,
    super.code,
  });

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

final class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code});
}
