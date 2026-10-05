import 'package:stackfood_multivendor/features/coupon/domain/models/coupon_model.dart';
import 'package:stackfood_multivendor/features/coupon/domain/models/customer_coupon_model.dart';
import 'package:stackfood_multivendor/interface/repository_interface.dart';
import 'package:get/get_connect/http/src/response/response.dart';

abstract class CouponRepositoryInterface extends RepositoryInterface{
  Future<List<CouponModel>?> getRestaurantCouponList(int restaurantId);
  Future<CustomerCouponModel?> getCouponList({int? customerId, int? restaurantId, int? orderRestaurantId, double? orderAmount});
  Future<Response> applyCoupon({required String couponCode, int? restaurantID, double? orderAmount});
}