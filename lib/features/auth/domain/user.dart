import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String _displayName;
  final int createdAtMs;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    String? displayName,
    required this.createdAtMs,
    this.profileImageUrl,
  }) : _displayName = displayName ??
            [firstName, lastName]
                .where((s) => s != null && s.isNotEmpty)
                .join(' ');

  String get displayName =>
      _displayName.isNotEmpty ? _displayName : email.split('@').first;

  @override
  List<Object?> get props =>
      [id, email, firstName, lastName, _displayName, createdAtMs, profileImageUrl];
}
