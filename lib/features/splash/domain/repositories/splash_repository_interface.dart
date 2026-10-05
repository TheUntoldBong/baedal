import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/interface/repository_interface.dart';
import 'package:get/get_connect/http/src/response/response.dart';

abstract class SplashRepositoryInterface extends RepositoryInterface {
  Future<Response> getConfigData({required DataSourceEnum? source});
  Future<bool> initSharedData();
  void disableIntro();
  bool? showIntro();
  bool showLoginSuggestion();
  void disableLoginSuggestion();
  bool getSavedCookiesData();
  Future<void> saveCookiesData(bool data);
  void cookiesStatusChange(String? data);
  bool getAcceptCookiesStatus(String data);
  Future<Response> subscribeEmail(String email);
  void setThemeModeSharedPref(String themeMode);
  Future<String> getThemeModeSharedPref();
  bool getReferBottomSheetStatus();
  Future<void> saveReferBottomSheetStatus(bool data);
  bool handleInitialTopicSubscription();
}