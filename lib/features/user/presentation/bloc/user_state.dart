import 'package:equatable/equatable.dart';

enum UserStatus { initial, loading, loaded, error, unauthenticated }

class UserState extends Equatable {
  final String? userId;
  final String userName;
  final String? email;
  final String? photoUrl;
  final UserStatus status;
  final String? errorMessage;

  const UserState({
    this.userId,
    this.userName = '',
    this.email,
    this.photoUrl,
    this.status = UserStatus.initial,
    this.errorMessage,
  });

  bool get isAuthenticated => status == UserStatus.loaded && userId != null;

  String get displayName => userName.isNotEmpty ? userName : 'User';

  String get initials {
    if (userName.isEmpty) return 'U';
    final parts = userName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return userName[0].toUpperCase();
  }

  UserState copyWith({
    String? userId,
    String? userName,
    String? email,
    String? photoUrl,
    UserStatus? status,
    String? errorMessage,
  }) {
    return UserState(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        userName,
        email,
        photoUrl,
        status,
        errorMessage,
      ];
}
