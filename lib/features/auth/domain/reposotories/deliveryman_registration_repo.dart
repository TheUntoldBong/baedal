import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/shift_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/vehicle_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/zone_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/reposotories/deliveryman_registration_repo_interface.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class DeliverymanRegistrationRepo implements DeliverymanRegistrationRepoInterface{
  final ApiClient apiClient;
  DeliverymanRegistrationRepo({required this.apiClient});

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
  Future<List<ZoneModel>?> getList({int? offset, bool? forDeliveryRegistration}) async{
    List<ZoneModel>? zoneList ;
    Response response = await apiClient.getData(AppConstants.zoneListUri);
    if(response.statusCode == 200) {
      zoneList = [];
      response.body.forEach((zone) => zoneList!.add(ZoneModel.fromJson(zone)));
    }
    return zoneList;
  }

  @override
  Future<List<VehicleModel>?> getVehicleList() async {
    List<VehicleModel>? vehicles;
    Response response = await apiClient.getData(AppConstants.vehiclesUri);
    if (response.statusCode == 200) {
      vehicles = [];
      response.body.forEach((vehicle) => vehicles!.add(VehicleModel.fromJson(vehicle)));
    }
    return vehicles;
  }

  @override
  Future<List<ShiftModel>?> getShiftList() async {
    List<ShiftModel>? shifts;
    Response response = await apiClient.getData(AppConstants.shiftsUri);
    if (response.statusCode == 200) {
      shifts = [];
      response.body.forEach((shift) => shifts!.add(ShiftModel.fromJson(shift)));
    }
    return shifts;
  }

  @override
  Future<Response> registerDeliveryMan(Map<String, String> data, List<MultipartBody> multiParts, List<MultipartDocument> additionalDocument) async {
    return await apiClient.postMultipartData(AppConstants.dmRegisterUri, data, multiParts, additionalDocument);
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}