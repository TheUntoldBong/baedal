import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/pro/controllers/pro_controller.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_plan_model.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';

class ProHelper {
  ProHelper._();

  static bool get  systemProStatus => Get.find<SplashController>().proStaus;
  static bool get userProStatus => Get.find<ProfileController>().isPro;
  static bool get showUnsubscribedBanner => systemProStatus;
  static bool get showActiveBenefitBanner => userProStatus;
  static ProActiveOfferModel? get activeOfferModel => Get.find<ProController>().activeOfferModel;
  static bool get benefitStatus => activeOfferModel?.status ?? false;


  static bool meetsProMinOrder(ProActiveBenefit? benefit, double subTotal) {
    if(benefitStatus) {
      return benefit?.minOrderStatus != true || subTotal >= (benefit?.minOrderAmount ?? 0);
    }
    else{
      return true;
    }
  }

  static double getProMinOrderRemaining(ProActiveBenefit? benefit, double subTotal) {
    final double remaining = (benefit?.minOrderAmount ?? 0) - subTotal;
    return remaining > 0 ? PriceConverter.toFixed(remaining) : 0;
  }

  static double _capProDiscount(double base, ProActiveBenefit benefit) {
    if (base < 0) return 0;
    double proDiscount = base * ((benefit.percentage ?? 0) / 100);
    if (benefit.maxAmount != null && benefit.maxAmount! > 0 && proDiscount > benefit.maxAmount!) {
      proDiscount = benefit.maxAmount!;
    }
    if (proDiscount > base) proDiscount = base;
    return PriceConverter.toFixed(proDiscount);
  }

  static double getProDiscount({required double subTotal, required double discount, required double couponDiscount}) {
    final ProActiveBenefit? benefit = activeOfferModel?.benefit;
    if (benefit == null || benefit.type != ProBenefitType.discount || !benefitStatus) return 0;
    if (!meetsProMinOrder(benefit, subTotal)) return 0;
    return _capProDiscount(subTotal - discount - couponDiscount, benefit);
  }

  static double getProDiscountPreview(ProActiveBenefit? benefit, double subTotal) {
    if (benefit == null || benefit.type != ProBenefitType.discount) return 0;
    if (!meetsProMinOrder(benefit, subTotal)) return 0;
    return _capProDiscount(subTotal, benefit);
  }

  static double getProDeliveryDiscount({required double deliveryCharge, required double subTotal, required double discount, required double couponDiscount}) {
    final ProActiveBenefit? benefit = activeOfferModel?.benefit;
    if (benefit == null || benefit.type != ProBenefitType.deliveryFee || !benefitStatus) return 0;
    if (deliveryCharge <= 0) return 0;

    if (benefit.offerType == ProOfferType.fullFree) {
      if (!meetsProMinOrder(benefit, subTotal)) return 0;
      return PriceConverter.toFixed(deliveryCharge);
    }

    final double chargeDiscount = deliveryCharge * ((benefit.chargeDiscountPercentage ?? 0) / 100);
    return PriceConverter.toFixed(chargeDiscount);
  }

  static double getOrderSavedAmount(OrderModel order) {
    switch (order.benefitType) {
      case ProBenefitType.deliveryFee:
        return order.deliveryFeeReductionAmount ?? 0;
      case ProBenefitType.discount:
        return order.proDiscount ?? 0;
      case ProBenefitType.coupon:
        return order.couponDiscountAmount ?? 0;
      case null:
        return 0;
    }
  }

  static List<Map<String, String>> getPlanBenefitItems(PlanBenefits? benefits) {
    final List<Map<String, String>> items = [];
    if (benefits == null) return items;

    if (benefits.discount?.active == 1) {
      final double pct = benefits.discount?.percentage ?? 0;
      final double max = benefits.discount?.maxAmount ?? 0;
      items.add({
        'title': '${'discount_on_all_orders'.tr} (${pct.toStringAsFixed(0)}%)',
        'subtitle': '${'get_up_to'.tr} ${PriceConverter.convertPrice(max)} ${'discount'.tr}',
      });
    }
    if (benefits.deliveryFee?.active == 1) {
      items.add({'title': 'free_delivery'.tr, 'subtitle': 'enjoy_unlimited_free_deliveries'.tr});
    }
    if (benefits.coupon?.active == true) {
      items.add({'title': 'exclusive_coupon_on_order'.tr, 'subtitle': 'unlock_exclusive_coupon_deals'.tr});
    }
    return items;
  }


  static List<Map<String, String>> getActiveBenefitItems() {
    ProActiveBenefit? benefit = activeOfferModel?.benefit;
    if (benefit == null) return [];
    final ProBenefitType? type = benefit.type;

    if (type == ProBenefitType.discount && (benefit.percentage != null && benefit.percentage! > 0)) {
      final double pct = benefit.percentage ?? 0;
      final double max = benefit.maxAmount ?? 0;
      return [{
        'title': '${'discount_on_all_orders'.tr} (${pct.toStringAsFixed(0)}%)',
        'subtitle': '${'get_up_to'.tr} ${PriceConverter.convertPrice(max)} ${'discount'.tr}${(benefit.minOrderStatus ?? false) ? ', ${'minimum_order_amount'.tr} ${PriceConverter.convertPrice(benefit.minOrderAmount)}' : ""}',
      }];
    }
    if (type == ProBenefitType.deliveryFee) {
      return [{
        'title': (benefit.offerType == ProOfferType.fullFree) ? 'free_delivery'.tr : 'delivery_fee_discount'.tr,
        'subtitle': (benefit.offerType == ProOfferType.fullFree)
            ? '${'enjoy_unlimited_free_deliveries'.tr}${(benefit.minOrderStatus ?? false) ? ', ${'minimum_order_amount'.tr} ${PriceConverter.convertPrice(benefit.minOrderAmount)}' : ""}'
            : '${'enjoy'.tr} ${benefit.chargeDiscountPercentage}% ${'discount_on_every_delivery'.tr}',
      }];
    }
    if (type == ProBenefitType.coupon) {
      return [{'title': 'exclusive_coupon_on_order'.tr, 'subtitle': 'unlock_exclusive_coupon_deals'.tr}];
    }
    return [];
  }

  static String getBenefitDisplayName(ProBenefitType? type) {
    switch (type) {
      case ProBenefitType.discount:
        return 'pro_discount'.tr;
      case ProBenefitType.deliveryFee:
        return 'pro_delivery_fee'.tr;
      case ProBenefitType.coupon:
        return 'pro_coupon'.tr;
      case null:
        return 'pro_benefit'.tr;
    }
  }


  static String getDurationKey(PlanItem plan) {
    return plan.durationLabel?.trim().isNotEmpty == true ? plan.durationLabel! : (plan.duration?.toString() ?? '');
  }


  static List<MapEntry<int, PlanItem>> getUniqueDurationPlans(List<PlanItem> plans) {
    final List<MapEntry<int, PlanItem>> durationPlans = [];
    final Set<String> keys = {};
    for (int index = 0; index < plans.length; index++) {
      final String key = getDurationKey(plans[index]);
      if (keys.add(key)) {
        durationPlans.add(MapEntry(index, plans[index]));
      }
    }
    return durationPlans;
  }


  static List<MapEntry<int, PlanItem>> getSelectedDurationPlans(List<PlanItem> plans, PlanItem selectedPlan) {
    final String selectedDuration = getDurationKey(selectedPlan);
    final List<MapEntry<int, PlanItem>> result = [];
    for (int index = 0; index < plans.length; index++) {
      if (getDurationKey(plans[index]) == selectedDuration) {
        result.add(MapEntry(index, plans[index]));
      }
    }
    return result;
  }

  static bool isFullFreeDelivery(double subTotal) {
    ProActiveBenefit? proBenefit = activeOfferModel?.benefit;
    proBenefit?.minOrderStatus != true || subTotal >= (proBenefit?.minOrderAmount ?? 0);
    return userProStatus
        && benefitStatus
        && proBenefit?.type == ProBenefitType.deliveryFee
        && (proBenefit?.offerType == ProOfferType.fullFree || (proBenefit?.chargeDiscountPercentage ?? 0) >= 100)
        && meetsProMinOrder(proBenefit, subTotal);
  }
}
