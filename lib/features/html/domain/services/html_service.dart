import 'package:stackfood_multivendor/features/html/domain/models/html_content_model.dart';
import 'package:stackfood_multivendor/features/html/domain/repositories/html_repository_interface.dart';
import 'package:stackfood_multivendor/features/html/domain/services/html_service_interface.dart';
import 'package:stackfood_multivendor/features/html/enums/html_type.dart';
import 'package:get/get_connect.dart';

class HtmlService implements HtmlServiceInterface {
  final HtmlRepositoryInterface htmlRepositoryInterface;
  HtmlService({required this.htmlRepositoryInterface});

  @override
  Future<HtmlContentModel?> getHtmlText(HtmlType htmlType, String languageCode) async {
    Response response = await htmlRepositoryInterface.getHtmlText(htmlType, languageCode);
    if (response.statusCode == 200) {
      if (response.body is Map) {
        String? pageTitle = response.body['page_title']?.toString();
        String? pageDescription = response.body['page_description']?.toString() ?? '';

        if (pageDescription.isNotEmpty) {
          pageDescription = pageDescription.replaceAll('href=', 'target="_blank" href=');
        }

        return HtmlContentModel(
          title: pageTitle,
          content: pageDescription,
        );
      } else if (response.body != null && response.body.isNotEmpty && response.body is String) {
        return HtmlContentModel(content: response.body);
      }
    }
    return null;
  }
}