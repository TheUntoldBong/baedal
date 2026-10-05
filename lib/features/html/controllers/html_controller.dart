import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/html/domain/services/html_service_interface.dart';
import 'package:stackfood_multivendor/features/html/enums/html_type.dart';
import 'package:get/get.dart';

class HtmlController extends GetxController implements GetxService {
  final HtmlServiceInterface htmlServiceInterface;

  HtmlController({required this.htmlServiceInterface});

  String? _htmlTitle;
  String? get htmlTitle => _htmlTitle;

  String? _htmlText;
  String? get htmlText => _htmlText;

  void resetHtmlText() {
    _htmlTitle = null;
    _htmlText = null;
    update();
  }

  Future<void> getHtmlText(HtmlType htmlType) async {
    final htmlContent = await htmlServiceInterface.getHtmlText(htmlType, Get.find<LocalizationController>().locale.languageCode);
    _htmlTitle = htmlContent?.title;
    _htmlText = htmlContent?.content;
    update();
  }

}