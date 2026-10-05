import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_data_model.dart';

class FilterAdditionalDataModel{
  bool? fromPopularRestaurant;
  bool? showPriceWidget;
  bool? showCuisines;
  List<int>? selectedCuisineLst;
  Function(FilterDataModel)? callback;
  FilterAdditionalDataModel({this.fromPopularRestaurant, this.callback, this.showCuisines, this.showPriceWidget, this.selectedCuisineLst});
}
