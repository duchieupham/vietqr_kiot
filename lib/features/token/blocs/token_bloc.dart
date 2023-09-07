import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/stringify.dart';
import 'package:viet_qr_kiot/commons/utils/log.dart';
import 'package:viet_qr_kiot/features/token/events/token_event.dart';
import 'package:viet_qr_kiot/features/token/repositories/token_repository.dart';
import 'package:viet_qr_kiot/features/token/states/token_state.dart';
import 'package:viet_qr_kiot/models/qr_generated_dto.dart';
import 'package:viet_qr_kiot/models/response_message_dto.dart';

class TokenBloc extends Bloc<TokenEvent, TokenState> {
  TokenBloc() : super(TokenInitialState()) {
    on<TokenEventCheckValid>(_checkValidToken);
    on<TokenFcmUpdateEvent>(_updateFcmToken);
    on<GetListQrEvent>(_getListQR);
    on<UploadImageEvent>(_uploadImage);
  }
}

const TokenRepository tokenRepository = TokenRepository();

void _checkValidToken(TokenEvent event, Emitter emit) async {
  try {
    if (event is TokenEventCheckValid) {
      bool check = await tokenRepository.checkValidToken();
      if (check) {
        emit(TokenValidState());
      } else {
        emit(TokenInvalidState());
      }
    }
  } catch (e) {
    LOG.error(e.toString());
    emit(TokenInvalidState());
  }
}

void _updateFcmToken(TokenEvent event, Emitter emit) async {
  try {
    if (event is TokenFcmUpdateEvent) {
      bool check = await tokenRepository.updateFcmToken();
      if (check) {
        emit(TokenFcmUpdateSuccessState());
      } else {
        emit(TokenFcmUpdateFailedState());
      }
    }
  } catch (e) {
    LOG.error(e.toString());
    emit(TokenFcmUpdateFailedState());
  }
}

void _getListQR(TokenEvent event, Emitter emit) async {
  List<QRGeneratedDTO> qrList = [];
  try {
    if (event is GetListQrEvent) {
      qrList = await tokenRepository.getListQR();
      if (qrList.isNotEmpty) {
        emit(GetListQrSuccessState(qrList));
      } else {
        emit(GetListQrFailedState());
      }
    }
  } catch (e) {
    LOG.error(e.toString());
    emit(GetListQrFailedState());
  }
}

void _uploadImage(TokenEvent event, Emitter emit) async {
  try {
    if (event is UploadImageEvent) {
      emit(UploadImageLoadingState());
      final ResponseMessageDTO result =
          await tokenRepository.upLoadImage(event.param, event.imageByte);
      if (result.status == Stringify.RESPONSE_STATUS_SUCCESS) {
        emit(UploadImageSuccessState());
      } else {
        emit(UploadImageFailedState());
      }
    }
  } catch (e) {
    emit(UploadImageFailedState());
    LOG.error(e.toString());
  }
}
