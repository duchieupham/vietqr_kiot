import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viet_qr_kiot/commons/utils/log.dart';
import 'package:viet_qr_kiot/features/logout/events/log_out_event.dart';
import 'package:viet_qr_kiot/features/logout/repositories/log_out_repository.dart';
import 'package:viet_qr_kiot/features/logout/states/log_out_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  LogoutBloc() : super(LogoutInitialState()) {
    on<LogoutEventSubmit>(_logOutSubmit);
  }
}

const LogoutRepository logoutRepository = LogoutRepository();

void _logOutSubmit(LogoutEvent event, Emitter emit) async {
  try {
    if (event is LogoutEventSubmit) {
      emit(LogoutLoadingState());
      bool check = await logoutRepository.logout();
      if (check) {
        emit(LogoutSuccessfulState());
      } else {
        emit(LogoutFailedState());
      }
    }
  } catch (e) {
    LOG.error(e.toString());
    emit(LogoutFailedState());
  }
}
