import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
class RegistrationStepperWidget extends StatelessWidget {
  final String status;
  const RegistrationStepperWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    int state = 0;
     if(status == 'business') {
      state = 1;
    }else if(status == 'payment') {
      state = 2;
    }else if(status == 'complete') {
      state = 3;
    }
    return Row(children: [
      RegistrationStepper(
        title: 'general_information'.tr, isActive: true, haveLeftBar: false, haveRightBar: true, rightActive: true, onGoing: state == 0,
      ),
      RegistrationStepper(
        title: 'business_plan'.tr, isActive: state > 1, haveLeftBar: true, haveRightBar: true, rightActive: state > 1, onGoing: state == 1, processing: state != 3 && state != 0,
      ),
      RegistrationStepper(
        title: 'complete'.tr, isActive: state == 3, haveLeftBar: true, haveRightBar: false, rightActive: state == 3,
      ),
    ]);
  }
}

class RegistrationStepper extends StatelessWidget {
  final bool isActive;
  final bool haveLeftBar;
  final bool haveRightBar;
  final String title;
  final bool rightActive;
  final bool onGoing;
  final bool processing;
  const RegistrationStepper({super.key, required this.isActive, required this.haveLeftBar, required this.haveRightBar,
    required this.title, required this.rightActive, this.onGoing = false, this.processing = false});

  @override
  Widget build(BuildContext context) {
    final bool leftHighlighted = onGoing || isActive;
    Color iconColor = leftHighlighted ? context.primary : context.iconBaseMedium;
    return Expanded(
      child: Column(children: [

        Row(children: [
          Expanded(child: haveLeftBar ? Divider(color: leftHighlighted ? context.primary : null, thickness: 2) : const SizedBox()),
          Icon( onGoing ? Icons.adjust : processing ? Icons.adjust : rightActive ? Icons.check_circle : Icons.circle_outlined, color: iconColor, size: 40),
          Expanded(child: haveRightBar ? Divider(color: rightActive ? context.primary : null, thickness: 2) : const SizedBox()),
        ]),

        const SizedBox(height: Dimensions.padding2xSmall),

        SizedBox(
          height: 30,
          child: Text(
            title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
            style: context.subHeading.extraSmall.medium.overrideWith(color: context.primary),
          ),
        ),
      ]),
    );
  }
}
