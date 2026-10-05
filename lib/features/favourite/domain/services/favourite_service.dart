import 'package:stackfood_multivendor/features/favourite/domain/repositories/favourite_repository_interface.dart';
import 'package:stackfood_multivendor/features/favourite/domain/services/favourite_service_interface.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class FavouriteService implements FavouriteServiceInterface {
  final FavouriteRepositoryInterface favouriteRepositoryInterface;
  FavouriteService({required this.favouriteRepositoryInterface});

  @override
  Future<Response> addFavouriteList(int? id, bool isRestaurant) async {
    return await favouriteRepositoryInterface.add(null, isRestaurant: isRestaurant, id: id);
  }

  @override
  Future<Response> removeFavouriteList(int? id, bool isRestaurant) async {
    return await favouriteRepositoryInterface.delete(id, isRestaurant: isRestaurant);
  }

  @override
  Future<Response> getFavouriteList() async {
    return await favouriteRepositoryInterface.getList();
  }

  @override
  Future<Response> clearAll({required bool isFood}) async {
    return await favouriteRepositoryInterface.clearAll(isFood: isFood);
  }

}