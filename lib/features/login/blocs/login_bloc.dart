import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/stringify.dart';
import 'package:viet_qr_kiot/commons/enums/enum_type.dart';
import 'package:viet_qr_kiot/commons/utils/check_utils.dart';
import 'package:viet_qr_kiot/features/login/events/login_event.dart';
import 'package:viet_qr_kiot/features/login/repositories/login_repository.dart';
import 'package:viet_qr_kiot/features/login/states/login_state.dart';
import 'package:viet_qr_kiot/models/info_user_dto.dart';
import 'package:viet_qr_kiot/models/response_message_dto.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginEventByPhone>(_login);
    on<CheckExitsPhoneEvent>(_checkExitsPhone);
    on<UpdateEvent>(_updateEvent);
  }

  void _login(LoginEvent event, Emitter emit) async {
    try {
      if (event is LoginEventByPhone) {
        emit(state.copyWith(
            status: BlocStatus.LOADING, request: LoginType.NONE));
        bool check = await loginRepository.login(event.dto);
        if (check) {
          emit(state.copyWith(
              isToast: event.isToast,
              request: LoginType.TOAST,
              status: BlocStatus.UNLOADING));
        } else {
          emit(state.copyWith(
              request: LoginType.ERROR,
              msg: 'Sai mật khẩu. Vui lòng kiểm tra lại mật khẩu của bạn'));
        }
      }
    } catch (e) {
      emit(state.copyWith(request: LoginType.ERROR));
    }
  }

  void _checkExitsPhone(LoginEvent event, Emitter emit) async {
    try {
      if (event is CheckExitsPhoneEvent) {
        emit(state.copyWith(
            status: BlocStatus.LOADING, request: LoginType.NONE));
        final data = await loginRepository.checkExistPhone(event.phone);
        if (data is InfoUserDTO) {
          emit(
            state.copyWith(
                request: LoginType.CHECK_EXIST,
                status: BlocStatus.UNLOADING,
                infoUserDTO: data),
          );
        } else if (data is ResponseMessageDTO) {
          if (data.status == Stringify.RESPONSE_STATUS_CHECK) {
            String message = CheckUtils.instance.getCheckMessage(data.message);
            emit(
              state.copyWith(
                msg: message,
                request: LoginType.REGISTER,
                status: BlocStatus.UNLOADING,
                phone: event.phone,
              ),
            );
          }
        }
      }
    } catch (e) {
      emit(state.copyWith(request: LoginType.ERROR));
    }
  }

  void _updateEvent(LoginEvent event, Emitter emit) async {
    emit(state.copyWith(status: BlocStatus.NONE, request: LoginType.NONE));
  }
}

const LoginRepository loginRepository = LoginRepository();
