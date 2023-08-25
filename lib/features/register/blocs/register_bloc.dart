import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/stringify.dart';
import 'package:viet_qr_kiot/commons/enums/enum_type.dart';
import 'package:viet_qr_kiot/commons/utils/error_utils.dart';
import 'package:viet_qr_kiot/features/register/events/register_event.dart';
import 'package:viet_qr_kiot/features/register/repositories/register_repository.dart';
import 'package:viet_qr_kiot/features/register/states/register_state.dart';
import 'package:viet_qr_kiot/models/response_message_dto.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitialState()) {
    on<RegisterEventSubmit>(_register);
    on<RegisterEventSentOTP>(_sentOtp);
    // on<RegisterEventReSentOTP>(_reSentOtp);
  }

  void _register(RegisterEvent event, Emitter emit) async {
    try {
      if (event is RegisterEventSubmit) {
        emit(RegisterLoadingState());
        ResponseMessageDTO responseMessageDTO =
            await registerRepository.register(event.dto);
        if (responseMessageDTO.status == Stringify.RESPONSE_STATUS_SUCCESS) {
          emit(RegisterSuccessState());
        } else {
          String msg =
              ErrorUtils.instance.getErrorMessage(responseMessageDTO.message);
          emit(RegisterFailedState(msg: msg));
        }
      }
    } catch (e) {
      emit(const RegisterFailedState(
          msg: 'Không thể đăng ký. Vui lòng kiểm tra lại kết nối.'));
    }
  }

  void _sentOtp(RegisterEvent event, Emitter<RegisterState> emit) {
    try {
      if (event is RegisterEventSentOTP) {
        emit(RegisterSentOTPLoadingState());
        if (event.typeOTP == TypeOTP.SUCCESS) {
          emit(RegisterSentOTPSuccessState());
        } else if (event.typeOTP == TypeOTP.FAILED) {
          emit(const RegisterSentOTPFailedState(
              msg: 'Có lỗi xảy ra. Vui lòng kiểm tra lại kết nối.'));
        }
      }
    } catch (e) {
      emit(const RegisterSentOTPFailedState(
          msg: 'Có lỗi xảy ra. Vui lòng kiểm tra lại kết nối.'));
    }
  }
//
// void _reSentOtp(RegisterEvent event, Emitter<RegisterState> emit) {
//   try {
//     if (event is RegisterEventReSentOTP) {
//       emit(RegisterSentOTPLoadingState());
//       if (event.typeOTP == TypeOTP.SUCCESS) {
//         emit(RegisterReSentOTPSuccessState());
//       } else if (event.typeOTP == TypeOTP.FAILED) {
//         emit(const RegisterReSentOTPFailedState(
//             msg: 'Có lỗi xảy ra. Vui lòng kiểm tra lại kết nối.'));
//       }
//     }
//   } catch (e) {
//     print('Error at register - RegisterBloc: $e');
//     emit(const RegisterReSentOTPFailedState(
//         msg: 'Có lỗi xảy ra. Vui lòng kiểm tra lại kết nối.'));
//   }
// }
}

const RegisterRepository registerRepository = RegisterRepository();
