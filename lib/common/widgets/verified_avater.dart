import 'dart:async';
import 'dart:math' as math;

import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/util/images.dart';

class RestaurantVerifiedAvatar extends StatefulWidget {
  final String? imageUrl;
  final bool isVerified;
  final double size;
  final Duration interval;

  const RestaurantVerifiedAvatar({
    super.key,
    this.imageUrl,
    this.isVerified = false,
    this.size = 18,
    this.interval = const Duration(seconds: 2),
  });

  @override
  State<RestaurantVerifiedAvatar> createState() => _RestaurantVerifiedAvatarState();
}

class _RestaurantVerifiedAvatarState extends State<RestaurantVerifiedAvatar> {
  final math.Random _random = math.Random();
  Timer? _timer;
  bool _showBadge = false;
  Duration _switchDuration = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _startTimerIfNeeded();
  }

  @override
  void didUpdateWidget(covariant RestaurantVerifiedAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isVerified != widget.isVerified || oldWidget.interval != widget.interval) {
      _timer?.cancel();
      _showBadge = false;
      _startTimerIfNeeded();
    }
  }

  void _startTimerIfNeeded() {
    if (!widget.isVerified) {
      return;
    }
    _scheduleNext();
  }

  void _scheduleNext() {
    final int baseMs = math.max(1, widget.interval.inMilliseconds);
    final int halfBaseMs = (baseMs * 0.5).round();
    final Duration nextDelay = Duration(milliseconds: halfBaseMs + _random.nextInt(baseMs));
    _timer = Timer(nextDelay, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _switchDuration = Duration(milliseconds: 200 + _random.nextInt(1000));
        _showBadge = !_showBadge;
      });
      _scheduleNext();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildAvatar() {
    final double s = widget.size;
    final bool hasImage = widget.imageUrl != null && widget.imageUrl!.isNotEmpty;

    return ClipOval(
      child: hasImage
          ? CustomImageWidget(
              image: widget.imageUrl!,
              height: s,
              width: s,
              fit: BoxFit.cover,
              placeholder: Images.restaurantPlaceholder,
            )
          : CustomAssetImageWidget(
              Images.storeIcon,
              height: s,
              width: s,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _buildBadge() {
    return CustomAssetImageWidget(
      Images.verifiedIcon,
      height: widget.size - 3,
      width: widget.size - 3,
      fit: BoxFit.cover,
      color: context.iconInfoMedium,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double s = widget.size;

    if (!widget.isVerified) {
      return SizedBox(height: s, width: s, child: _buildAvatar());
    }

    return SizedBox(
      height: s,
      width: s,
      child: AnimatedSwitcher(
        duration: _switchDuration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final Animation<double> rotation = Tween<double>(begin: math.pi / 2, end: 0).animate(animation);
          return AnimatedBuilder(
            animation: rotation,
            child: child,
            builder: (context, c) => Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(rotation.value),
              child: Opacity(opacity: animation.value, child: c),
            ),
          );
        },
        child: _showBadge
            ? KeyedSubtree(
                key: const ValueKey('badge'),
                child: _buildBadge(),
              )
            : KeyedSubtree(
                key: const ValueKey('avatar'),
                child: _buildAvatar(),
              ),
      ),
    );
  }
}
