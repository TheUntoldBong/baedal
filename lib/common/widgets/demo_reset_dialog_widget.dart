import 'dart:async';

import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';
class DemoResetDialogWidget extends StatefulWidget {
  const DemoResetDialogWidget({super.key});

  @override
  State<DemoResetDialogWidget> createState() => _DemoResetDialogWidgetState();
}

class _DemoResetDialogWidgetState extends State<DemoResetDialogWidget> {
  bool _isLoading = false;
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();

    _startTimer();

  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  void _startTimer() {
    _seconds = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds - 1;
      if(_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
        _seconds = 0;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return DialogSheetBody(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: context.surfaceContainer,
        ),
        width: 500,
        padding: const EdgeInsets.all(Dimensions.paddingLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, color: context.primary, size: 55),
          const SizedBox(height: Dimensions.paddingLarge),

          Text('session_time_out'.tr, style: context.heading.extraLarge.strong),
          const SizedBox(height: Dimensions.paddingLarge),

          Text(
            'though_it_is_demo_text'.tr,
            textAlign: TextAlign.center,
            style: context.body.defaultSize.medium,
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

          CustomButtonWidget(isLoading: _isLoading, buttonText: 'okay'.tr, onPressed: () async {
            if (_seconds == 0) {
              setState(() {
                _isLoading = true;
              });
              await Get.find<SplashController>().getConfigData(fromDemoReset: true);

              setState(() {
                _isLoading = false;
              });

            } else {
              showCustomSnackBar('${'our_demo_system_is_resetting_please_wait'.tr} $_seconds ${'second'.tr}');
            }
          }),
        ]),
      ));
  }
}
