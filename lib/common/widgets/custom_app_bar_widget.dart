import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/enums/veg_type.dart';
import 'package:stackfood_multivendor/common/widgets/cart_widget.dart';
import 'package:stackfood_multivendor/common/widgets/veg_filter_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CustomAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isBackButtonExist;
  final Function? onBackPressed;
  final bool showCart;
  final Color? bgColor;
  final Function(VegType value)? onVegFilterTap;
  final VegType? type;
  final List<Widget>? actions;
  final bool centerTitle;
  final String? storeName;
  final String? storeLogo;
  final int? itemCount;
  final VoidCallback? onDeleteTap;
  final double elevation;
  final IconData? leadingIcon;

  const CustomAppBarWidget({super.key, required this.title, this.isBackButtonExist = true, this.onBackPressed,
    this.showCart = false, this.bgColor, this.onVegFilterTap, this.type, this.actions, this.centerTitle = false,
    this.storeName, this.storeLogo, this.itemCount, this.onDeleteTap, this.elevation = 1, this.leadingIcon});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: context.heading.extraLarge.strong.overrideWith(color: bgColor == null ? Theme.of(context).textTheme.bodyLarge!.color : context.surfaceContainer)),
      centerTitle: centerTitle,
      titleSpacing: isBackButtonExist ? 0 : null,
      leading: isBackButtonExist ? IconButton(
        icon: Icon(leadingIcon ?? Icons.arrow_back_outlined, size: 20),
        color: bgColor == null ? Theme.of(context).textTheme.bodyLarge!.color : context.surfaceContainer,
        onPressed: () => onBackPressed != null ? onBackPressed!() : Navigator.pop(context),
      ) : null,
      backgroundColor: bgColor ?? context.surfaceContainer,
      surfaceTintColor: context.surfaceContainer,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: elevation > 0 ? Border(bottom: BorderSide(color: context.outline)) : null,
      actions: showCart || onVegFilterTap != null ? [
        showCart ? IconButton(
          onPressed: () => Get.toNamed(RouteHelper.getCartBundleListRoute()),
          icon: CartWidget(color: context.primary, size: 25),
        ) : const SizedBox(),

        onVegFilterTap != null ? VegFilterWidget(
          type: type,
          onSelected: onVegFilterTap,
          fromAppBar: true,
          iconColor: context.primary,

        ) : const SizedBox(),

        const SizedBox(width: Dimensions.paddingSmall),

        if(onVegFilterTap == null)
        ...[
          ...?actions,
          const SizedBox(width: Dimensions.paddingSmall),
        ]
      ] : actions ?? [const SizedBox()],
    );
  }

  static Size sizeOf(BuildContext? context) => Size(Dimensions.webMaxWidth, ResponsiveHelper.isDesktop(context) ? 100 : 50);
  @override
  Size get preferredSize => sizeOf(Get.context);
}
