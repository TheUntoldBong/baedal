import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/dashboard/domain/services/dashboard_service_interface.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';

class DashboardController extends GetxController implements GetxService {
  final DashboardServiceInterface dashboardServiceInterface;
  DashboardController({required this.dashboardServiceInterface});

  bool _showLocationSuggestion = true;
  bool get showLocationSuggestion => _showLocationSuggestion;

  void Function(int index)? _pageSelector;

  void registerPageSelector(void Function(int index) selector) => _pageSelector = selector;

  void removePageSelector(void Function(int index) selector) {
    if (_pageSelector == selector) _pageSelector = null;
  }

  void selectTab(int index) {
    if (_pageSelector != null) {
      _pageSelector!(index);
    } else {
      Get.offAllNamed(RouteHelper.getInitialRoute());
    }
  }

  void hideSuggestedLocation(){
    _showLocationSuggestion = !_showLocationSuggestion;
  }

  Future<bool> checkLocationActive() async {
    return false;
  }

  Future<bool> saveRegistrationSuccessfulSharedPref(bool status) async {
    return await dashboardServiceInterface.saveRegistrationSuccessful(status);
  }

  Future<bool> saveIsRestaurantRegistrationSharedPref(bool status) async {
    return await dashboardServiceInterface.saveIsRestaurantRegistration(status);
  }

  bool getRegistrationSuccessfulSharedPref() {
    return dashboardServiceInterface.getRegistrationSuccessful();
  }

  bool getIsRestaurantRegistrationSharedPref() {
    return dashboardServiceInterface.getIsRestaurantRegistration();
  }
}