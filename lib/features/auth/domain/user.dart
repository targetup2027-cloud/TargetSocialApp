import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final int createdAtMs;
  final String? profileImageUrl;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAtMs,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [id, email, displayName, createdAtMs, profileImageUrl];
}
