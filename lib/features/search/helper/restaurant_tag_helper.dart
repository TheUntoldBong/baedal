import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:get/get.dart';

class RestaurantTagHelper {
  String currencySymbol = Get.find<SplashController>().configModel!.currencySymbol!;

  static List<Map<String, String?>> offerTags(Restaurant restaurant, {bool showDiscount = true}) {
    List<Map<String, String?>> tags = [];

    double discount = restaurant.discount?.discount ?? 0;
    if(showDiscount && discount > 0) {
      String discountType = restaurant.discount!.discountType ?? 'percent';
      tags.add({'text': '$discount${discountType == 'percent' ? '%' : ''}', 'icon': Images.percentTag});
    }

    RestaurantOffer? bogo = _bestBogoOffer(restaurant);
    if(bogo != null) {
      String bogoText = (bogo.buyQty != null && bogo.getQty != null)
          ? '${'buy'.tr} ${bogo.buyQty} ${'get'.tr} ${bogo.getQty} ${'free'.tr}'
          : (bogo.name ?? '');
      if(bogoText.isNotEmpty) {
        tags.add({'text': bogoText, 'icon': Images.bogoOfferIcon});
      }
    }

    for (RestaurantCoupon coupon in restaurant.coupons ?? []) {
      double couponDiscount = coupon.discount ?? 0;
      if(couponDiscount <= 0) continue;

      String text = coupon.discountType == 'amount'
          ? PriceConverter.convertPrice(couponDiscount)
          : '${couponDiscount.toStringAsFixed(couponDiscount % 1 == 0 ? 0 : 1)}%';
      tags.add({'text': '$text ${'off'.tr}', 'icon': Images.couponBadge});
    }

    if(restaurant.freeDelivery == true) {
      tags.add({'text': 'free_delivery'.tr, 'icon': Images.freeDelivery});
    }

    for (String tag in restaurant.tags ?? []) {
      if(tag.toLowerCase() != 'ad') {
        tags.add({'text': tag, 'icon': null});
      }
    }

    return tags;
  }

  static RestaurantOffer? _bestBogoOffer(Restaurant restaurant) {
    RestaurantOffer? best;
    for (RestaurantOffer offer in restaurant.offers ?? []) {
      if(offer.type != 'bogo') continue;
      if(best == null || _isStrongerBogo(offer, best)) {
        best = offer;
      }
    }
    return best;
  }

  static bool _isStrongerBogo(RestaurantOffer offer, RestaurantOffer best) {
    bool hasQuantities = offer.buyQty != null && offer.getQty != null;
    bool bestHasQuantities = best.buyQty != null && best.getQty != null;
    if(hasQuantities != bestHasQuantities) {
      return hasQuantities;
    }
    if(!hasQuantities) {
      return false;
    }
    if(offer.getQty != best.getQty) {
      return offer.getQty! > best.getQty!;
    }
    return offer.buyQty! < best.buyQty!;
  }
}
