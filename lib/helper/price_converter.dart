import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class PriceConverter {
  static String convertPrice(double? price, {double? discount, String? discountType, bool forDM = false, bool isVariation = false, bool compact = false}) {
    if(discount != null && discountType != null){
      if(discountType == 'amount' && !isVariation) {
        price = price! - discount;
      }else if(discountType == 'percent') {
        price = price! - ((discount / 100) * price);
      }
    }

    int digitAfterDecimalPoint = Get.find<SplashController>().configModel!.digitAfterDecimalPoint ?? 2;


    bool isRightSide = Get.find<SplashController>().configModel!.currencySymbolDirection == 'right';

    String amount = (compact && price!.abs() >= _compactThreshold) ? compactNumber(price)
      : (toFixed(price!)).toStringAsFixed(forDM ? 0 : digitAfterDecimalPoint)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    return '${isRightSide ? '' : '${Get.find<SplashController>().configModel!.currencySymbol!} '}'
      '$amount'
      '${isRightSide ? ' ${Get.find<SplashController>().configModel!.currencySymbol!}' : ''}';
  }

  static const double _compactThreshold = 99999;
  static const List<double> _compactUnits = [1000000000000, 1000000000, 1000000, 1000];
  static const List<String> _compactSuffixes = ['T', 'B', 'M', 'K'];

  static String compactNumber(num value) {
    final double val = value.toDouble();
    final double abs = val.abs();

    if(abs < _compactThreshold) {
      return _trimTrailingZero(val.toStringAsFixed(val == val.truncateToDouble() ? 0 : Get.find<SplashController>().configModel!.digitAfterDecimalPoint ?? 2))
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    }

    for(int i = 0; i < _compactUnits.length; i++) {
      if(abs >= _compactUnits[i]) {
        final double scaled = (val / _compactUnits[i] * 10).truncateToDouble() / 10;
        return '${_trimTrailingZero(scaled.toStringAsFixed(1))}${_compactSuffixes[i]}';
      }
    }
    return val.toStringAsFixed(0);
  }

  static String _trimTrailingZero(String value) {
    return value.contains('.') ? value.replaceFirst(RegExp(r'\.?0+$'), '') : value;
  }

  static Widget convertAnimationPrice(double? price, {double? discount, String? discountType, bool forDM = false, TextStyle? textStyle}) {
    if(price == null) return const SizedBox();
    if(discount != null && discountType != null){
      if(discountType == 'amount') {
        price = price - discount;
      }else if(discountType == 'percent') {
        price = price - ((discount / 100) * price);
      }
    }
    final config = Get.find<SplashController>().configModel;
    bool isRightSide = config?.currencySymbolDirection == 'right';
    String currencySymbol = config?.currencySymbol ?? '';
    int digitAfterDecimalPoint = config?.digitAfterDecimalPoint ?? 2;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedFlipCounter(
        duration: const Duration(milliseconds: 500),
        value: toFixed(price),
        textStyle: textStyle ?? (Get.context != null ? Get.context!.body.defaultSize.medium : const TextStyle()),
        fractionDigits: forDM ? 0 : digitAfterDecimalPoint,
        prefix: isRightSide ? '' : currencySymbol,
        suffix: isRightSide ? currencySymbol : '',
      ),
    );
  }


  static double? convertWithDiscount(double? price, double? discount, String? discountType, {bool isVariation = false}) {
    if(price == null) return null;
    if(discountType == 'amount' && !isVariation) {
      price = price - (discount ?? 0);
    }else if(discountType == 'percent') {
      price = price - (((discount ?? 0) / 100) * price);
    }
    return price;
  }

  static double calculation(double amount, double? discount, String type, int quantity) {
    double calculatedAmount = 0;
    if(type == 'amount') {
      calculatedAmount = (discount ?? 0) * quantity;
    }else if(type == 'percent') {
      calculatedAmount = ((discount ?? 0) / 100) * (amount * quantity);
    }
    return calculatedAmount;
  }

  static String percentageCalculation(String price, String discount, String discountType) {
    String symbol = Get.find<SplashController>().configModel?.currencySymbol ?? '';
    return '$discount${discountType == 'percent' ? '%' : symbol} OFF';
  }

  static double toFixed(double val) {
    int digits = Get.find<SplashController>().configModel?.digitAfterDecimalPoint ?? 2;
    num mod = power(10, digits);
    return (((val * mod).toPrecision(digits)).floor().toDouble() / mod);
  }

  static int power(int x, int n) {
    int retval = 1;
    for (int i = 0; i < n; i++) {
      retval *= x;
    }
    return retval;
  }

}