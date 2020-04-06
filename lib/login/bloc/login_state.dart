part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();

  @override
  List<Object> get props => [];
}

class PerformingLoading extends LoginState {
  const PerformingLoading();

  @override
  List<Object> get props => [];
}

class LoginWithError extends LoginState {
  final String error;

  const LoginWithError(this.error);

  @override
  List<Object> get props => [error];
}

class SuccesfulLogin extends LoginState {
  final bool wasUserInfoFound;

  const SuccesfulLogin(this.wasUserInfoFound);

  @override
  List<Object> get props => [wasUserInfoFound];
}
