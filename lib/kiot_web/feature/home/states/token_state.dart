import 'package:equatable/equatable.dart';
import 'package:viet_qr_kiot/commons/enums/enum_type.dart';
import 'package:viet_qr_kiot/models/qr_generated_dto.dart';

class TokenState extends Equatable {
  final String? msg;
  final BlocStatus status;
  final HomeType request;
  final TokenType typeToken;
  final List<QRGeneratedDTO> qrList;

  const TokenState({
    this.msg,
    this.status = BlocStatus.NONE,
    this.request = HomeType.NONE,
    this.typeToken = TokenType.NONE,
    required this.qrList,
  });

  TokenState copyWith({
    BlocStatus? status,
    String? msg,
    HomeType? request,
    TokenType? typeToken,
    List<QRGeneratedDTO>? qrList,
  }) {
    return TokenState(
      status: status ?? this.status,
      msg: msg ?? this.msg,
      request: request ?? this.request,
      typeToken: typeToken ?? this.typeToken,
      qrList: qrList ?? this.qrList,
    );
  }

  @override
  List<Object?> get props => [
        status,
        msg,
        request,
      ];
}
