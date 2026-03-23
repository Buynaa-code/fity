import 'package:equatable/equatable.dart';
import '../../domain/enums/user_role.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUser extends UserEvent {
  const LoadUser();
}

class RefreshUser extends UserEvent {
  const RefreshUser();
}

class SignOut extends UserEvent {
  const SignOut();
}

class UpdateUserRole extends UserEvent {
  final UserRole role;

  const UpdateUserRole(this.role);

  @override
  List<Object?> get props => [role];
}
