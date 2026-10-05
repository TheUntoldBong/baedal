import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';
import 'package:get/get_connect/http/src/response/response.dart';

abstract class SplashServiceInterface {
  Future<Response> getConfigData({required DataSourceEnum? source});
  ConfigModel? prepareConfigData(Response response);
  Future<bool> initSharedData();
  bool? showIntro();
  void disableIntro();
  bool showLoginSuggestion();
  void disableLoginSuggestion();
  Future<void> saveCookiesData(bool data);
  bool getCookiesData();
  void cookiesStatusChange(String? data);
  bool getAcceptCookiesStatus(String data);
  Future<bool> subscribeMail(String email);
  void saveThemeMode(String themeMode);
  Future<String> loadThemeMode();
  bool getReferBottomSheetStatus();
  Future<void> saveReferBottomSheetStatus(bool data);
  bool handleInitialTopicSubscription();
}