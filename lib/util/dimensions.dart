import 'package:get/get.dart';

class Dimensions {
  static double fontSizeExtraSmall = Get.context!.width >= 1300 ? 12 : 10;
  static double fontSizeSmall = Get.context!.width >= 1300 ? 14 : 12;
  static double fontSizeDefault = Get.context!.width >= 1300 ? 16 : 14;
  static double fontSizeLarge = Get.context!.width >= 1300 ? 18 : 16;
  static double fontSizeExtraLarge = Get.context!.width >= 1300 ? 20 : 18;
  static double fontSizeOverLarge = Get.context!.width >= 1300 ? 24 : 20;
  static double fontSizeExtraOverLarge = Get.context!.width >= 1300 ? 26 : 24;

  static const double fontHeightExtraSmall = 1;
  static const double fontHeightSmall = 1.1;
  static const double fontHeightDefault = 1.2;
  static const double fontHeightMedium = 1.3;

  static const double paddingOverSmall = 2.0;
  static const double padding2xSmall = 4.0;
  static const double paddingExtraSmall = 6.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 12.0;
  static const double paddingDefault = 16.0;
  static const double paddingLarge = 20.0;
  static const double paddingExtraLarge = 24.0;
  static const double paddingOverLarge = 32.0;
  static const double paddingSizeExtraOverLarge = 36.0;

  // Backward compatibility aliases
  static const double paddingSizeExtraSmall = paddingExtraSmall;
  static const double paddingSizeSmall = paddingSmall;
  static const double paddingSizeDefault = paddingDefault;
  static const double paddingSizeLarge = paddingLarge;
  static const double paddingSizeExtraLarge = paddingExtraLarge;
  static const double paddingSizeOverLarge = paddingOverLarge;

  static const double radiusExtraSmall = 4.0;
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 8.0;
  static const double radiusDefault = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusExtraLarge = 20.0;
  static const double radiusOverLarge = 28.0;

  static const double webMaxWidth = 1170;
  static const int messageInputLength = 250;
  static const double pickMapIconSize = 100.0;
  static const double maxLimitOfFileSentINConversation = 25;
  static const double maxLimitOfTotalFileSent = 5;
  static const double maxSizeOfASingleFile = 10;
  static const double maxImageSend = 10;
  static const double limitOfPickedVideoSizeInMB = 50;

  static const double menuIconSize = 25;
}
