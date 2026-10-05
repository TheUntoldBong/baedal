import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/features/splash/domain/repositories/splash_repository_interface.dart';
import 'package:stackfood_multivendor/helper/splash_route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashRepository implements SplashRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  SplashRepository({required this.apiClient, required this.sharedPreferences});


  @override
  Future<Response> getConfigData({required DataSourceEnum? source}) async {
    if (source == DataSourceEnum.local) {
      String? cachedData = sharedPreferences.getString('${AppConstants.configCacheKey}-v${AppConstants.appVersion}');
      if (cachedData != null) {
        return Response(statusCode: 200, body: jsonDecode(cachedData));
      } else {
        return await getConfigDataFromApi();
      }
    } else {
      return await getConfigDataFromApi();
    }
  }

  Future<Response> getConfigDataFromApi() async {
    Response response = await apiClient.getData(AppConstants.configUri);
    if (response.statusCode == 200) {
      sharedPreferences.setString('${AppConstants.configCacheKey}-v${AppConstants.appVersion}', jsonEncode(response.body));
    }
    return response;
  }

  @override
  Future<bool> initSharedData() {
    if(!sharedPreferences.containsKey(AppConstants.theme)) {
      sharedPreferences.setBool(AppConstants.theme, false);
    }
    if(!sharedPreferences.containsKey(AppConstants.countryCode)) {
      sharedPreferences.setString(AppConstants.countryCode, AppConstants.languages[0].countryCode!);
    }
    if(!sharedPreferences.containsKey(AppConstants.languageCode)) {
      sharedPreferences.setString(AppConstants.languageCode, AppConstants.languages[0].languageCode!);
    }
    if(!sharedPreferences.containsKey(AppConstants.cartList)) {
      sharedPreferences.setStringList(AppConstants.cartList, []);
    }
    if(!sharedPreferences.containsKey(AppConstants.searchHistory)) {
      sharedPreferences.setStringList(AppConstants.searchHistory, []);
    }
    if(!sharedPreferences.containsKey(AppConstants.searchCuisineHistory)) {
      sharedPreferences.setStringList(AppConstants.searchCuisineHistory, []);
    }
    if(!sharedPreferences.containsKey(AppConstants.notification)) {
      sharedPreferences.setBool(AppConstants.notification, true);
    }
    if(!sharedPreferences.containsKey(AppConstants.intro)) {
      sharedPreferences.setBool(AppConstants.intro, true);
    }
    if(!sharedPreferences.containsKey(AppConstants.suggestLogin)) {
      sharedPreferences.setBool(AppConstants.suggestLogin, true);
    }
    if(!sharedPreferences.containsKey(AppConstants.notificationCount)) {
      sharedPreferences.setInt(AppConstants.notificationCount, 0);
    }
    if(sharedPreferences.containsKey(AppConstants.referBottomSheet)) {
      sharedPreferences.setBool(AppConstants.referBottomSheet, true);
    }
    return Future.value(true);
  }

  @override
  void setThemeModeSharedPref(String themeMode) {
    sharedPreferences.setString(AppConstants.themeMode, themeMode);
  }

  @override
  Future<String> getThemeModeSharedPref() async {
    if(sharedPreferences.containsKey(AppConstants.themeMode)) {
      return sharedPreferences.getString(AppConstants.themeMode) ?? 'system';
    }
    if(sharedPreferences.containsKey(AppConstants.theme)) {
      return (sharedPreferences.getBool(AppConstants.theme) ?? false) ? 'dark' : 'light';
    }
    return 'system';
  }

  @override
  void disableIntro() {
    sharedPreferences.setBool(AppConstants.intro, false);
  }

  @override
  bool? showIntro() {
    return sharedPreferences.getBool(AppConstants.intro);
  }

  @override
  bool showLoginSuggestion() {
    return sharedPreferences.getBool(AppConstants.suggestLogin) ?? false;
  }

  @override
  void disableLoginSuggestion() {
    sharedPreferences.setBool(AppConstants.suggestLogin, false);
  }

  @override
  Future<void> saveCookiesData(bool data) async {
    try {
      await sharedPreferences.setBool(AppConstants.acceptCookies, data);
    } catch (e) {
      debugPrint('Save Cookies Data Fail, $e');
      rethrow;
    }
  }

  @override
  bool getSavedCookiesData() {
    return sharedPreferences.getBool(AppConstants.acceptCookies) ?? false;
  }

  @override
  void cookiesStatusChange(String? data) {
    if(data != null){
      sharedPreferences.setString(AppConstants.cookiesManagement, data);
    }
  }

  @override
  bool getAcceptCookiesStatus(String data) => sharedPreferences.getString(AppConstants.cookiesManagement) != null
      && sharedPreferences.getString(AppConstants.cookiesManagement) == data;


  @override
  Future<Response> subscribeEmail(String email) async {
    return await apiClient.postData(AppConstants.subscriptionUri, {'email': email});
  }

  @override
  bool handleInitialTopicSubscription() {
    try{
      if(!GetPlatform.isWeb) {
        FirebaseMessaging.instance.subscribeToTopic(AppConstants.topic);
        FirebaseMessaging.instance.subscribeToTopic(AppConstants.maintenanceModeTopic);
      }
      customLog('====Topic Subscription Successful');
      return true;
    }catch(e) {
      customLog('Topic Subscription Failed, $e');
      return false;
    }
  }

  @override
  bool getReferBottomSheetStatus() {
    return sharedPreferences.getBool(AppConstants.referBottomSheet) ?? true;
  }

  @override
  Future<void> saveReferBottomSheetStatus(bool data) async {
    try {
      await sharedPreferences.setBool(AppConstants.referBottomSheet, data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}