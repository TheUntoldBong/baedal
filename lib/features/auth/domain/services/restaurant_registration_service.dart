import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/business/domain/models/package_model.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/reposotories/restaurant_registration_repo_interface.dart';
import 'package:stackfood_multivendor/features/auth/domain/services/restaurant_registration_service_interface.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class RestaurantRegistrationService implements RestaurantRegistrationServiceInterface {
  final RestaurantRegistrationRepoInterface restaurantRegistrationRepoInterface;

  RestaurantRegistrationService({required this.restaurantRegistrationRepoInterface});

  @override
  Future<XFile?> picLogoFromGallery() async {
    XFile? pLogo;
    XFile? pickLogo = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(pickLogo != null) {
      List<String> supportedFormat = ['image/jpg', 'image/jpeg', 'image/png', 'image/webp', 'image/gif'];
      if(!supportedFormat.contains(pickLogo.mimeType) && GetPlatform.isWeb) {
        showCustomSnackBar('please_select_valid_image_file'.tr);
        return null;
      }

      await pickLogo.length().then((value) {
        if(value > 2000000) {
          pLogo = null;
          showCustomSnackBar('max_file_size_2_mb'.tr);
        }else {
          pLogo = pickLogo;
        }
      });
    }
    return pLogo;
  }

  @override
  Future<FilePickerResult?> picFile(MediaData mediaData) async {
    List<String> permission = [];
    if(mediaData.image == 1) {
      permission.add('jpg');
    }
    if(mediaData.pdf == 1) {
      permission.add('pdf');
    }
    if(mediaData.docs == 1) {
      permission.add('doc');
    }

    FilePickerResult? result;

    if(GetPlatform.isWeb){
      result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
      );
    }else{
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: permission,
        allowMultiple: false,
      );
    }
    if(result != null && result.files.isNotEmpty) {

      List<String> supportedFormat = ['jpg', 'jpeg', 'png', 'webp', 'gif', 'pdf', 'doc', 'docx'];
      if(!supportedFormat.contains(result.files.single.extension) && GetPlatform.isWeb) {
        showCustomSnackBar('please_select_valid_file'.tr);
        return null;
      }

      if(result.files.single.size > 2000000) {
        result = null;
        showCustomSnackBar('max_file_size_2_mb'.tr);
      } else {
        return result;
      }
    }
    return result;
  }

  @override
  List<MultipartDocument> prepareMultipartDocuments(List<String> inputTypeList, List<FilePickerResult> additionalDocuments) {
    List<MultipartDocument> multiPartsDocuments = [];
    List<String> dataName = [];
    for(String data in inputTypeList) {
      dataName.add('additional_documents[$data]');
    }
    for(FilePickerResult file in additionalDocuments) {
      int index = additionalDocuments.indexOf(file);
      multiPartsDocuments.add(MultipartDocument('${dataName[index]}[]', file));
    }
    return multiPartsDocuments;
  }

  @override
  Future<Response> registerRestaurant(Map<String, String> data, XFile? logo, XFile? cover, List<MultipartDocument> additionalDocument) async {
    return await restaurantRegistrationRepoInterface.registerRestaurant(data, logo, cover, additionalDocument);
  }

  @override
  Future<bool> checkInZone(String? lat, String? lng, int zoneId) async {
    return await restaurantRegistrationRepoInterface.checkInZone(lat, lng, zoneId);
  }

  @override
  Future<PackageModel?> getPackageList() async {
    return await restaurantRegistrationRepoInterface.getList();
  }

}