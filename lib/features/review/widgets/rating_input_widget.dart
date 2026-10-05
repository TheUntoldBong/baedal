import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

class RatingInputWidget extends StatelessWidget {
  final int rating;
  final bool isEnabled;
  final ValueChanged<int> onRated;

  static const int _starCount = 5;
  static const double _starSize = 28;

  const RatingInputWidget({super.key, required this.rating, required this.onRated, this.isEnabled = true});

  @override
  Widget build(BuildContext context) {
    return Row(children: List<Widget>.generate(_starCount, (index) {
      return Padding(
        padding: EdgeInsets.only(right: index == _starCount - 1 ? 0 : Dimensions.paddingSmall),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          onTap: isEnabled ? () => onRated(index + 1) : null,
          child: Icon(
            rating < (index + 1) ? Icons.star_border_rounded : Icons.star_rounded,
            size: _starSize,
            color: rating < (index + 1) ? context.iconBaseLight : context.primary,
          ),
        ),
      );
    }));
  }
}
