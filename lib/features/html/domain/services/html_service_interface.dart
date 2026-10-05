import 'package:stackfood_multivendor/features/html/domain/models/html_content_model.dart';
import 'package:stackfood_multivendor/features/html/enums/html_type.dart';

abstract class HtmlServiceInterface{
  Future<HtmlContentModel?> getHtmlText(HtmlType htmlType, String languageCode);
}