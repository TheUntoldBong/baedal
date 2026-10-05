import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';


class RatingBarWidget extends StatelessWidget {
  final double? rating;
  final double size;
  final int? ratingCount;
  final int? reviewCount;
  const RatingBarWidget({super.key, required this.rating, required this.ratingCount, this.size = 18, this.reviewCount});

  @override
  Widget build(BuildContext context) {
    List<Widget> starList = [];

    int realNumber = rating!.floor();
    int partNumber = ((rating! - realNumber) * 10).ceil();

    for (int i = 0; i < 5; i++) {
      if (i < realNumber) {
        starList.add(Icon(Icons.star_rounded, color: context.primary, size: size));
      } else if (i == realNumber) {
        starList.add(SizedBox(
          height: size,
          width: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Icon(Icons.star_rounded, color: context.primary, size: size),
              ClipRect(
                clipper: _Clipper(part: partNumber),
                child: Icon(Icons.star_rounded, color: Colors.grey, size: size),
              )
            ],
          ),
        ));
      } else {
        starList.add(Icon(Icons.star_rounded, color: Colors.grey, size: size));
      }
    }
    ratingCount != null ? starList.add(Padding(
      padding: const EdgeInsets.only(left: Dimensions.padding2xSmall),
      child: Text(
        '($ratingCount)', textDirection: TextDirection.ltr,
        style: context.body.small.regular.overrideWith(color: context.textBaseMedium).copyWith(fontSize: size*0.8),
      ),
    )) : const SizedBox();

    reviewCount != null && (reviewCount! > 0) ? starList.add(Padding(
      padding: const EdgeInsets.only(left: Dimensions.padding2xSmall),
      child: Text(
        '($reviewCount) ${'reviews'.tr}', textDirection: TextDirection.ltr,
        style: context.body.small.regular.overrideWith(color: Colors.blue).copyWith(fontSize: size * 0.8, decoration: TextDecoration.underline, decorationColor: Colors.blue),
      ),
    )) : const SizedBox();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: starList,
    );
  }
}

class _Clipper extends CustomClipper<Rect> {
  final int part;

  _Clipper({required this.part});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(
      (size.width / 10) * part,
      0.0,
      size.width,
      size.height,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}
