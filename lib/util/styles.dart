import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:flutter/material.dart';

abstract class AppWeight {
  static const FontWeight regular  = FontWeight.w400;
  static const FontWeight medium   = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight strong   = FontWeight.w700;
}

class Tracking {
  final double extraSmall;
  final double small;
  final double defaultSize;
  final double large;
  final double extraLarge;
  final double overLarge;
  final double extraOverLarge;

  const Tracking({
    required this.extraSmall,
    required this.small,
    required this.defaultSize,
    required this.large,
    required this.extraLarge,
    required this.overLarge,
    required this.extraOverLarge,
  });

  const Tracking.uniform(double percent)
      : extraSmall = percent,
        small = percent,
        defaultSize = percent,
        large = percent,
        extraLarge = percent,
        overLarge = percent,
        extraOverLarge = percent;
}

const Tracking _headingTracking = Tracking(
  extraSmall: -0.02,
  small: -0.02,
  defaultSize: -0.02,
  large: -0.03,
  extraLarge: -0.04,
  overLarge: -0.04,
  extraOverLarge: -0.04,
);

const Tracking _subHeadingTracking = Tracking.uniform(-0.02);

const Tracking _bodyTracking = Tracking.uniform(0);

class TextScale {
  final FontWeight weight;
  final double height;
  final Tracking tracking;
  final Color? color;

  const TextScale._({
    required this.weight,
    required this.height,
    required this.tracking,
    this.color,
  });

  TextStyle get extraSmall => _sized(Dimensions.fontSizeExtraSmall, tracking.extraSmall);
  TextStyle get small => _sized(Dimensions.fontSizeSmall, tracking.small);
  TextStyle get defaultSize => _sized(Dimensions.fontSizeDefault, tracking.defaultSize);
  TextStyle get large => _sized(Dimensions.fontSizeLarge, tracking.large);
  TextStyle get extraLarge => _sized(Dimensions.fontSizeExtraLarge, tracking.extraLarge);
  TextStyle get overLarge => _sized(Dimensions.fontSizeOverLarge, tracking.overLarge);
  TextStyle get extraOverLarge => _sized(Dimensions.fontSizeExtraOverLarge, tracking.extraOverLarge);

  TextStyle _sized(double size, double trackingPercent) => TextStyle(
    fontFamily: AppConstants.fontFamily,
    fontWeight: weight,
    fontSize: size,
    height: height,
    letterSpacing: size * trackingPercent,
    color: color,
  );
}

extension TextStyleWeight on TextStyle {
  TextStyle get regular => copyWith(fontWeight: AppWeight.regular);
  TextStyle get medium => copyWith(fontWeight: AppWeight.medium);
  TextStyle get semiBold => copyWith(fontWeight: AppWeight.semiBold);
  TextStyle get strong => copyWith(fontWeight: AppWeight.strong);
}

extension TextStyleOverride on TextStyle {
  TextStyle overrideWith({Color? color, FontWeight? fontWeight}) =>
      copyWith(color: color, fontWeight: fontWeight);
}

const TextScale heading = TextScale._(
  weight: AppWeight.strong,
  height: Dimensions.fontHeightSmall,
  tracking: _headingTracking,
);

const TextScale subHeading = TextScale._(
  weight: AppWeight.regular,
  height: Dimensions.fontHeightDefault,
  tracking: _subHeadingTracking,
);

const TextScale body = TextScale._(
  weight: AppWeight.regular,
  height: Dimensions.fontHeightMedium,
  tracking: _bodyTracking,
);

extension AppTextStyle on BuildContext {

  TextScale get heading => TextScale._(
    weight: AppWeight.strong,
    height: Dimensions.fontHeightSmall,
    tracking: _headingTracking,
    color: textBaseDefault,
  );

  TextScale get subHeading => TextScale._(
    weight: AppWeight.regular,
    height: Dimensions.fontHeightDefault,
    tracking: _subHeadingTracking,
    color: textBaseDefault,
  );

  TextScale get body => TextScale._(
    weight: AppWeight.regular,
    height: Dimensions.fontHeightMedium,
    tracking: _bodyTracking,
    color: textBaseMedium,
  );
}

// Backward compatibility typography
const TextStyle robotoRegular = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w400,
);

const TextStyle robotoMedium = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w500,
);

const TextStyle robotoBold = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w700,
);

const TextStyle robotoBlack = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w900,
);
