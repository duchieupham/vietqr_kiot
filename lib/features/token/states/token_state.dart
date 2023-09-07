import 'package:equatable/equatable.dart';
import 'package:viet_qr_kiot/models/qr_generated_dto.dart';

class TokenState extends Equatable {
  const TokenState();

  @override
  List<Object?> get props => [];
}

class TokenInitialState extends TokenState {}

class TokenValidState extends TokenState {}

class TokenInvalidState extends TokenState {}

class TokenFcmUpdateSuccessState extends TokenState {}

class TokenFcmUpdateFailedState extends TokenState {}

class GetListQrSuccessState extends TokenState {
  final List<QRGeneratedDTO> qrList;
  const GetListQrSuccessState(this.qrList);

  @override
  List<Object?> get props => [qrList];
}

class GetListQrFailedState extends TokenState {}

class UploadImageLoadingState extends TokenState {}

class UploadImageFailedState extends TokenState {}

class UploadImageSuccessState extends TokenState {}
