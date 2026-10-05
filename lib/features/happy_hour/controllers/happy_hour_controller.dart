import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/happy_hour/domain/models/happy_hour_model.dart';
import 'package:stackfood_multivendor/features/happy_hour/domain/models/happy_hour_store_model.dart';
import 'package:stackfood_multivendor/features/happy_hour/domain/services/happy_hour_service_interface.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';

class HappyHourController extends GetxController with WidgetsBindingObserver implements GetxService {
  final HappyHourServiceInterface happyHourServiceInterface;
  HappyHourController({required this.happyHourServiceInterface});

  static const String timerBuilderId = 'happy_hour_timer';
  static const int _storePageSize = 10;

  HappyHourModel? _happyHour;
  HappyHourModel? get happyHour => _happyHour;

  Timer? _timer;
  DateTime? _fetchedAt;
  int _remainingAtFetch = 0;

  Duration _remaining = Duration.zero;
  Duration get remaining => _remaining;

  int? _dismissedHappyHourId;

  HappyHourStoreModel? _storeModel;
  HappyHourStoreModel? get storeModel => _storeModel;

  bool get isActive => _happyHour != null && (_happyHour?.isRunningNow ?? false) && _remaining > Duration.zero;
  bool get isDismissed => _happyHour != null && _dismissedHappyHourId == _happyHour!.id;

  int get storeCount => _happyHour?.storeCount ?? 0;

  double get discountPercentage => _happyHour?.discount ?? 0;

  String get discountLabel => _formatDiscount(discountPercentage);

  String _formatDiscount(double discount) {
    return discount % 1 == 0 ? discount.toStringAsFixed(0) : discount.toString();
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    getRunningHappyHour();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if(state == AppLifecycleState.resumed) {
      getRunningHappyHour();
    }
  }

  Future<void> getRunningHappyHour() async {
    final RunningHappyHourModel? model = await happyHourServiceInterface.getRunningHappyHour();
    if(model == null) {
      return;
    }

    if(!happyHourServiceInterface.isValidHappyHour(model)) {
      _clear();
      update();
      return;
    }

    final HappyHourModel next = model.happyHour!;
    final int remainingSeconds = happyHourServiceInterface.resolveRemainingSeconds(next);

    if(remainingSeconds <= 0) {
      _clear();
      update();
      return;
    }

    if(next.id != _happyHour?.id) {
      _dismissedHappyHourId = null;
      _storeModel = null;
    }
    _happyHour = next;
    _remainingAtFetch = remainingSeconds;
    _fetchedAt = DateTime.now();
    _startTimer();
    _tick();
    update();
  }

  void _clear() {
    _stopTimer();
    _happyHour = null;
    _storeModel = null;
    _fetchedAt = null;
    _remainingAtFetch = 0;
    _remaining = Duration.zero;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    if(_fetchedAt == null) {
      _remaining = Duration.zero;
      return;
    }
    final int left = _remainingAtFetch - DateTime.now().difference(_fetchedAt!).inSeconds;
    _remaining = left > 0 ? Duration(seconds: left) : Duration.zero;
    if(_remaining == Duration.zero) {
      _stopTimer();
      _onExpired();
    }
    update([timerBuilderId]);
  }

  void _onExpired() {
    getRunningHappyHour();
    final int? restaurantId = Get.find<RestaurantController>().restaurant?.id;
    if(restaurantId != null) {
      Get.find<CartController>().getCartDataOnline(restaurantId);
    } else {
      Get.find<CartController>().getCartBundleList();
    }
    update();
  }


  bool get showHomeBanner => isActive && !isDismissed;

  bool showRestaurantBanner(bool? isRestaurantHappyHourRunning) {
    return isActive && (isRestaurantHappyHourRunning ?? false);
  }

  double? get minOrderAmount => _happyHour?.minOrderAmount;

  bool get hasMinOrderRequirement => (minOrderAmount ?? 0) > 0;

  double remainingForDiscount(double subtotal) {
    final double? minOrder = minOrderAmount;
    if (minOrder == null || minOrder <= 0) {
      return 0;
    }
    final double remaining = minOrder - subtotal;
    return remaining > 0 ? remaining : 0;
  }

  double progressForDiscount(double subtotal) {
    final double? minOrder = minOrderAmount;
    if (minOrder == null || minOrder <= 0) {
      return 1;
    }
    return (subtotal / minOrder).clamp(0.0, 1.0);
  }

  Future<void> getStoreList(int offset, bool reload) async {
    if(offset == 1 && !reload && _storeModel != null) {
      return;
    }

    if(reload) {
      _storeModel = null;
      update();
    }

    final HappyHourStoreModel? model = await happyHourServiceInterface.getStoreList(offset: offset, limit: _storePageSize);
    if(model != null) {
      if(offset == 1) {
        _storeModel = model;
      } else if(_storeModel != null) {
        _storeModel!.totalSize = model.totalSize;
        _storeModel!.offset = model.offset;
        _storeModel!.restaurants ??= [];
        _storeModel!.restaurants!.addAll(model.restaurants ?? []);
      }
    }
    update();
  }

  double _bannerHeight = 0;
  double get bannerHeight => _bannerHeight;

  void reportHeight(double height) {
    if(height != _bannerHeight) {
      _bannerHeight = height;
      update();
    }
  }

  void dismiss() {
    _dismissedHappyHourId = _happyHour?.id;
    update();
  }

  String get formattedRemaining {
    final int minutes = _remaining.inMinutes;
    final int seconds = _remaining.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    _stopTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
