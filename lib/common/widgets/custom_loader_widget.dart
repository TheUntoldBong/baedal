import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';


class CustomLoaderWidget extends StatelessWidget {
  const CustomLoaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Container(
      height: 100, width: 100,
      decoration: BoxDecoration(color: context.surfaceContainer, borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall)),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    ));
  }
}
