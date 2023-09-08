import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viet_qr_kiot/commons/enums/enum_type.dart';
import 'package:viet_qr_kiot/commons/utils/log.dart';
import 'package:viet_qr_kiot/features/logout/repositories/log_out_repository.dart';
import 'package:viet_qr_kiot/features/token/events/token_event.dart';
import 'package:viet_qr_kiot/features/token/repositories/token_repository.dart';
import 'package:viet_qr_kiot/features/token/states/token_state.dart';

class TokenBloc extends Bloc<TokenEvent, TokenState> {
  TokenBloc() : super(const TokenState()) {
    on<TokenEventCheckValid>(_checkValidToken);
    on<TokenFcmUpdateEvent>(_updateFcmToken);
    on<TokenEventLogout>(_logout);
  }

  void _checkValidToken(TokenEvent event, Emitter emit) async {
    try {
      if (event is TokenEventCheckValid) {
        emit(state.copyWith(status: BlocStatus.NONE, request: HomeType.NONE));
        int check = await tokenRepository.checkValidToken();
        TokenType type = TokenType.NONE;
        if (check == 0) {
          type = TokenType.InValid;
        } else if (check == 1) {
          type = TokenType.Valid;
        } else if (check == 2) {
          type = TokenType.MainSystem;
        } else if (check == 3) {
          type = TokenType.Internet;
        } else if (check == 4) {
          type = TokenType.Expired;
        }

        emit(state.copyWith(
            status: BlocStatus.NONE, request: HomeType.TOKEN, typeToken: type));
      }
    } catch (e) {
      LOG.error(e.toString());
      emit(state.copyWith(
          status: BlocStatus.NONE,
          request: HomeType.TOKEN,
          typeToken: TokenType.InValid));
    }
  }

  void _updateFcmToken(TokenEvent event, Emitter emit) async {
    try {
      if (event is TokenFcmUpdateEvent) {
        emit(state.copyWith(status: BlocStatus.NONE, request: HomeType.NONE));
        bool check = await tokenRepository.updateFcmToken();
        TokenType type = TokenType.NONE;
        if (check) {
          type = TokenType.Fcm_success;
        } else {
          type = TokenType.Fcm_failed;
        }
        emit(state.copyWith(
            status: BlocStatus.NONE, request: HomeType.TOKEN, typeToken: type));
      }
    } catch (e) {
      LOG.error(e.toString());
      emit(state.copyWith(
          status: BlocStatus.NONE,
          request: HomeType.TOKEN,
          typeToken: TokenType.Fcm_failed));
    }
  }

  void _logout(TokenEvent event, Emitter emit) async {
    try {
      if (event is TokenEventLogout) {
        emit(state.copyWith(status: BlocStatus.NONE, request: HomeType.NONE));
        bool check = await logoutRepository.logout();
        TokenType type = TokenType.NONE;
        if (check) {
          type = TokenType.Logout;
        } else {
          type = TokenType.Logout_failed;
        }

        emit(state.copyWith(
            status: BlocStatus.NONE, request: HomeType.TOKEN, typeToken: type));
      }
    } catch (e) {
      LOG.error(e.toString());
      emit(state.copyWith(
          status: BlocStatus.NONE,
          request: HomeType.TOKEN,
          typeToken: TokenType.Logout_failed));
    }
  }
}

const TokenRepository tokenRepository = TokenRepository();
const LogoutRepository logoutRepository = LogoutRepository();
