import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/social_log_in_body_model.dart';
import 'package:stackfood_multivendor/interface/repository_interface.dart';
import 'package:get/get_connect/http/src/response/response.dart';

abstract class AuthRepoInterface<SignUpModel> extends RepositoryInterface<SignUpModel>{

  Future<bool> saveUserToken(String token, {bool alreadyInApp = false});
  Future<Response> updateToken({String notificationDeviceToken = ''});
  Future<bool> clearGuestId();
  String getUserCountryCode();
  String getUserNumber();
  String getUserPassword();
  String getGuestId();
  Future<Response> registration(SignUpModel signUpModel);
  Future<Response> login({required String emailOrPhone, required String password, required String loginType, required String fieldType});
  Future<Response> otpLogin({required String phone, required String otp, required String loginType, required String verified});
  Future<Response> updatePersonalInfo({required String name, required String? phone, required String loginType, required String? email, required String? referCode});
  Future<void> saveUserNumberAndPassword({required String number, required String password, required String countryCode, required String otpPoneNumber});
  Future<bool> clearUserNumberAndPassword();
  Future<ResponseModel> guestLogin();
  Future<bool> saveGuestId(String id);
  bool isGuestLoggedIn();
  Future<Response> loginWithSocialMedia(SocialLogInBodyModel socialLogInModel);
  bool isLoggedIn();
  Future<bool> clearSharedData({bool removeToken = true});
  bool isNotificationActive();
  Future<void> setNotificationActive(bool isActive);
  String getUserToken();
  Future<bool> saveGuestContactNumber(String number);
  String getGuestContactNumber();
  String getUserOtpPhoneNumber();
}