import 'package:equatable/equatable.dart';
import 'package:viet_qr_kiot/models/qr_generated_dto.dart';
import 'package:viet_qr_kiot/commons/enums/enum_type.dart';

class TokenState extends Equatable {
  final String? msg;
  final BlocStatus status;
  final HomeType request;
  final TokenType typeToken;

  const TokenState({
    this.msg,
    this.status = BlocStatus.NONE,
    this.request = HomeType.NONE,
    this.typeToken = TokenType.NONE,
  });

  TokenState copyWith({
    BlocStatus? status,
    String? msg,
    HomeType? request,
    TokenType? typeToken,
  }) {
    return TokenState(
      status: status ?? this.status,
      msg: msg ?? this.msg,
      request: request ?? this.request,
      typeToken: typeToken ?? this.typeToken,
    );
  }

  @override
  List<Object?> get props => [
        status,
        msg,
        request,
      ];
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
