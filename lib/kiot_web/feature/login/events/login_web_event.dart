import 'package:equatable/equatable.dart';
import 'package:viet_qr_kiot/features/login/blocs/login_bloc.dart';
import 'package:viet_qr_kiot/models/account_login_dto.dart';
import 'package:viet_qr_kiot/models/code_login_dto.dart';

class LoginWebEvent extends Equatable {
  const LoginWebEvent();

  @override
  List<Object?> get props => [];
}

class LoginEventByPhone extends LoginWebEvent {
  final AccountLoginDTO dto;
  final bool isToast;

  const LoginEventByPhone({required this.dto, this.isToast = false});

  @override
  List<Object?> get props => [dto];
}

// class LoginEventGetUserInformation extends LoginEvent {
//   final String userId;

//   const LoginEventGetUserInformation({required this.userId});

//   @override
//   List<Object?> get props => [userId];
// }

class LoginEventInsertCode extends LoginWebEvent {
  final String code;
  final LoginBloc loginBloc;

  const LoginEventInsertCode({required this.code, required this.loginBloc});

  @override
  List<Object?> get props => [code, loginBloc];
}

class LoginEventListen extends LoginWebEvent {
  final String code;
  final LoginBloc loginBloc;

  const LoginEventListen({required this.code, required this.loginBloc});

  @override
  List<Object?> get props => [code, loginBloc];
}

class LoginEventReceived extends LoginWebEvent {
  final CodeLoginDTO dto;

  const LoginEventReceived({required this.dto});

  @override
  List<Object?> get props => [dto];
}

class LoginEventUpdateCode extends LoginWebEvent {
  final String code;
  final String userId;

  const LoginEventUpdateCode({required this.code, required this.userId});

  @override
  List<Object?> get props => [code, userId];
}

class CheckExitsPhoneEvent extends LoginWebEvent {
  final String phone;

  const CheckExitsPhoneEvent({required this.phone});

  @override
  List<Object?> get props => [phone];
}

class UpdateEvent extends LoginWebEvent {}
