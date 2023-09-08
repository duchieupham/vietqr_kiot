// ignore_for_file: constant_identifier_names

enum BlocStatus {
  NONE,
  LOADING,
  UNLOADING,
  ERROR,
  AWAIT,
  SUCCESS,
  DELETED,
  INSERT,
  DONE,
  DELETED_ERROR,
}

enum LoginType { NONE, SUCCESS, TOAST, ERROR, CHECK_EXIST, REGISTER }

enum TypeOTP { SUCCESS, FAILED, ERROR, AWAIT, NONE }

enum HomeType { NONE, TOKEN, UPLOAD, GET_LIST, ERROR }

enum TokenType {
  NONE,
  InValid,
  Valid,
  MainSystem,
  Internet,
  Expired,
  Logout,
  Logout_failed,
  Fcm_success,
  Fcm_failed,
}
