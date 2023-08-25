import 'dart:convert';

import 'package:viet_qr_kiot/main.dart';
import 'package:viet_qr_kiot/models/account_information_dto.dart';
import 'package:viet_qr_kiot/models/info_user_dto.dart';

class UserInformationHelper {
  const UserInformationHelper._privateConsrtructor();

  static const UserInformationHelper _instance =
      UserInformationHelper._privateConsrtructor();

  static UserInformationHelper get instance => _instance;

  Future<void> initialUserInformationHelper() async {
    const AccountInformationDTO accountInformationDTO = AccountInformationDTO(
      userId: '',
      firstName: '',
      middleName: '',
      lastName: '',
      birthDate: '',
      gender: 0,
      address: '',
      email: '',
      imgId: '',
    );
    await sharedPrefs.setString('USER_ID', '');
    await sharedPrefs.setString('PHONE_NO', '');
    await sharedPrefs.setString(
        'ACCOUNT_INFORMATION', accountInformationDTO.toSPJson().toString());
  }

  Future<void> setUserId(String userId) async {
    await sharedPrefs.setString('USER_ID', userId);
  }

  Future<void> setPhoneNo(String phoneNo) async {
    await sharedPrefs.setString('PHONE_NO', phoneNo);
  }

  String getPhoneNo() {
    return sharedPrefs.getString('PHONE_NO')!;
  }

  Future<void> setAccountInformation(AccountInformationDTO dto) async {
    await sharedPrefs.setString(
        'ACCOUNT_INFORMATION', dto.toSPJson().toString());
  }

  AccountInformationDTO getAccountInformation() {
    return AccountInformationDTO.fromJson(
        json.decode(sharedPrefs.getString('ACCOUNT_INFORMATION')!));
  }

  String getUserId() {
    return sharedPrefs.getString('USER_ID')!;
  }

  String getUserFullname() {
    return ('${getAccountInformation().lastName} ${getAccountInformation().middleName} ${getAccountInformation().firstName}')
        .trim();
  }

  Future<void> setLoginAccount(List<String> list) async {
    await sharedPrefs.setStringList('LOGIN_ACCOUNT', list);
  }

  List<InfoUserDTO> getLoginAccount() {
    return ListLoginAccountDTO.fromJson(
            sharedPrefs.getStringList('LOGIN_ACCOUNT'))
        .list;
  }
}
