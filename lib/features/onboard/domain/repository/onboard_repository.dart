import 'package:stackfood_multivendor/features/onboard/domain/models/onboarding_model.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'onboard_repository_interface.dart';

class OnboardRepository implements OnboardRepositoryInterface {

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
  Future<List<OnBoardingModel>> getList({int? offset}) async {
    List<OnBoardingModel> onBoardingList = [
      OnBoardingModel(Images.onboarding_1, 'on_boarding_1_title', 'on_boarding_1_description'),
      OnBoardingModel(Images.onboarding_2, 'on_boarding_2_title', 'on_boarding_2_description'),
      OnBoardingModel(Images.onboarding_3, 'on_boarding_3_title', 'on_boarding_3_description'),
    ];
    return onBoardingList;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}