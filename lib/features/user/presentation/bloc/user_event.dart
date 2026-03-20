import 'package:equatable/equatable.dart';

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
