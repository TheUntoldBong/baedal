import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';

class CustomFavouriteWidget extends StatefulWidget {
  final int id;
  final bool isRestaurant;
  final bool isWished;
  final double? size;
  final double? widgetSize;
  final Color? bgColor;
  final bool isCircular;
  const CustomFavouriteWidget({super.key, required this.id, this.isRestaurant = false, required this.isWished, this.size = 25, this.widgetSize, this.bgColor, this.isCircular = false});

  @override
  State<CustomFavouriteWidget> createState() => _CustomFavouriteWidgetState();
}

class _CustomFavouriteWidgetState extends State<CustomFavouriteWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FavouriteController>(builder: (favouriteController) {
      return InkWell(
        splashColor: Colors.transparent,
        onTap: favouriteController.isDisable ? null : () {
          if(AuthHelper.isLoggedIn()) {
            _decideWished(widget.isWished, favouriteController);
          }else {
            showCustomSnackBar('you_are_not_logged_in'.tr);
          }
          _controller.reverse().then((value) => _controller.forward());
        },
        child: Container(
          width: widget.widgetSize, height: widget.widgetSize,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 3),
          decoration: BoxDecoration(color: widget.bgColor ?? context.surfaceContainer, shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.isCircular ? null : BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: [BoxShadow(color: context.shadow, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: ScaleTransition(
            scale: Tween(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
            child: CustomAssetImageWidget(widget.isWished ? Images.navFavouriteSelected : Images.navFavourite, height: widget.size, width: widget.size, color: widget.isWished ? context.primary : Theme.of(context).colorScheme.error,),
          ),
        ),
      );
    });
  }

  void _decideWished(bool isWished, FavouriteController favouriteController) {
    isWished ? favouriteController.removeFromFavouriteList(widget.id, widget.isRestaurant)
        : favouriteController.addToFavouriteList(widget.id, widget.isRestaurant);
  }
}
