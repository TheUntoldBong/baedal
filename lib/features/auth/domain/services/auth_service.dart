import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/auth_response_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/signup_body_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/social_log_in_body_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/reposotories/auth_repo_interface.dart';
import 'package:stackfood_multivendor/features/auth/domain/services/auth_service_interface.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService implements AuthServiceInterface{
  final AuthRepoInterface authRepoInterface;
  AuthService({required this.authRepoInterface});

  @override
  Future<ResponseModel> registration(SignUpBodyModel signUpModel) async {
    Response response = await authRepoInterface.registration(signUpModel);
    if(response.statusCode == 200){
      AuthResponseModel authResponse = AuthResponseModel.fromJson(response.body);
      await _updateHeaderFunctionality(authResponse, alreadyInApp: false);
      return ResponseModel(true, authResponse.token??'', authResponseModel: authResponse);
    } else {
      return ResponseModel(false, response.statusText, code: response.body['errors'] != null ? response.body['errors'][0]['code'] : null);
    }
  }

  @override
  Future<ResponseModel> login({required String emailOrPhone, required String password, required String loginType, required String fieldType, bool alreadyInApp = false}) async {
    Response response = await authRepoInterface.login(emailOrPhone: emailOrPhone, password: password, loginType: loginType, fieldType: fieldType);
    if (response.statusCode == 200) {
      AuthResponseModel authResponse = AuthResponseModel.fromJson(response.body);
      await _updateHeaderFunctionality(authResponse, alreadyInApp: alreadyInApp);
      return ResponseModel(true, authResponse.token??'', authResponseModel: authResponse);
    } else {
      return ResponseModel(false, response.statusText, code: response.body['errors'] != null ? response.body['errors'][0]['code'] : null);
    }
  }

  @override
  Future<ResponseModel> otpLogin({required String phone, required String otp, required String loginType, required String verified, bool alreadyInApp = false}) async {
    Response response = await authRepoInterface.otpLogin(phone: phone, otp: otp, loginType: loginType, verified: verified);
    if (response.statusCode == 200) {
      AuthResponseModel authResponse = AuthResponseModel.fromJson(response.body);
      await _updateHeaderFunctionality(authResponse, alreadyInApp: alreadyInApp);
      return ResponseModel(true, authResponse.token??'', authResponseModel: authResponse);
    } else {
      return ResponseModel(false, response.statusText, code: response.body['errors'] != null ? response.body['errors'][0]['code'] : null);
    }
  }

  @override
  Future<ResponseModel> updatePersonalInfo({required String name, required String? phone, required String loginType, required String? email, required String? referCode, bool alreadyInApp = false}) async {
    Response response = await authRepoInterface.updatePersonalInfo(name: name, phone: phone, email: email, loginType: loginType, referCode: referCode);
    if (response.statusCode == 200) {
      AuthResponseModel authResponse = AuthResponseModel.fromJson(response.body);
      await _updateHeaderFunctionality(authResponse, alreadyInApp: alreadyInApp);
      return ResponseModel(true, authResponse.token??'', authResponseModel: authResponse);
    } else {
      return ResponseModel(false, response.statusText, code: response.body['errors'] != null ? response.body['errors'][0]['code'] : null);
    }
  }

  Future<void> _updateHeaderFunctionality(AuthResponseModel authResponse, {bool alreadyInApp = false}) async {
    if(authResponse.isEmailVerified! && authResponse.isPhoneVerified! && authResponse.isPersonalInfo! && authResponse.token != null && authResponse.isExistUser == null) {
      authRepoInterface.saveUserToken(authResponse.token??'', alreadyInApp: alreadyInApp);
      await authRepoInterface.updateToken();
      await authRepoInterface.clearGuestId();
    }
  }

  @override
  Future<ResponseModel> guestLogin() async {
    return await authRepoInterface.guestLogin();
  }

  @override
  void saveUserNumberAndPassword({required String number, required String password, required String countryCode, required String otpPoneNumber}) {
    authRepoInterface.saveUserNumberAndPassword(number: number, password: password, countryCode: countryCode, otpPoneNumber: otpPoneNumber);
  }

  @override
  Future<bool> clearUserNumberAndPassword() async {
    return authRepoInterface.clearUserNumberAndPassword();
  }

  @override
  String getUserCountryCode() {
    return authRepoInterface.getUserCountryCode();
  }

  @override
  String getUserNumber() {
    return authRepoInterface.getUserNumber();
  }

  @override
  String getUserPassword() {
    return authRepoInterface.getUserPassword();
  }

  @override
  Future<ResponseModel> loginWithSocialMedia(SocialLogInBodyModel socialLogInModel, {bool isCustomerVerificationOn = false}) async {
    Response response = await authRepoInterface.loginWithSocialMedia(socialLogInModel);
    if (response.statusCode == 200) {
      AuthResponseModel authResponse = AuthResponseModel.fromJson(response.body);
      await _updateHeaderFunctionality(authResponse);
      return ResponseModel(true, authResponse.token??'', authResponseModel: authResponse);
    } else {
      return ResponseModel(false, response.statusText, code: response.body['errors'] != null ? response.body['errors'][0]['code'] : null);
    }
  }

  @override
  Future<void> updateToken() async {
    await authRepoInterface.updateToken();
  }

  @override
  bool isLoggedIn() {
    return authRepoInterface.isLoggedIn();
  }

  @override
  String getGuestId() {
    return authRepoInterface.getGuestId();
  }

  @override
  bool isGuestLoggedIn() {
    return authRepoInterface.isGuestLoggedIn();
  }

  @override
  Future<void> socialLogout() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    googleSignIn.disconnect();
    await FacebookAuth.instance.logOut();
  }

  @override
  Future<bool> clearSharedData({bool removeToken = true}) async {
    return await authRepoInterface.clearSharedData(removeToken: removeToken);
  }

  @override
  Future<bool> setNotificationActive(bool isActive) async {
    await authRepoInterface.setNotificationActive(isActive);
    return isActive;
  }

  @override
  bool isNotificationActive() {
    return authRepoInterface.isNotificationActive();
  }

  @override
  String getUserToken() {
    return authRepoInterface.getUserToken();
  }

  @override
  Future<void> saveGuestNumber(String number) async {
     authRepoInterface.saveGuestContactNumber(number);
  }

  @override
  String getGuestNumber() {
    return authRepoInterface.getGuestContactNumber();
  }

  @override
  String getUserOtpPhoneNumber() {
    return authRepoInterface.getUserOtpPhoneNumber();
  }

}