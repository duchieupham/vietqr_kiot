import 'package:equatable/equatable.dart';
import 'package:viet_qr_kiot/models/account_login_dto.dart';

class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterEventSubmit extends RegisterEvent {
  final AccountLoginDTO dto;

  const RegisterEventSubmit({required this.dto});

  @override
  List<Object?> get props => [dto];
}
