import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/home/controllers/advertisement_controller.dart';
import 'package:stackfood_multivendor/features/home/domain/models/advertisement_model.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:video_player/video_player.dart';

 const double _infoHeight = 117;
 const double _buttonHeight = 28;

class FeaturedStoreListSection extends StatefulWidget {
  const FeaturedStoreListSection({super.key});

  @override
  State<FeaturedStoreListSection> createState() => _FeaturedStoreListSectionState();
}

class _FeaturedStoreListSectionState extends State<FeaturedStoreListSection> {

  static const Duration _imageDwell = Duration(seconds: 4);
  static const Duration _postVideoDelay = Duration(seconds: 2);

  static const Duration _videoStartTimeout = Duration(seconds: 8);

  static const Duration _playbackSlack = Duration(seconds: 5);

  final CarouselSliderController _carouselController = CarouselSliderController();

  List<AdvertisementModel> _ads = const [];
  int _currentIndex = 0;
  bool _started = false;

  Timer? _dwellTimer;
  Timer? _delayTimer;
  bool _pendingAdvance = false;
  bool _userEngaged = false;

  @override
  void dispose() {
    _dwellTimer?.cancel();
    _delayTimer?.cancel();
    super.dispose();
  }

  bool _isVideoAd(AdvertisementModel ad) => ad.addType == 'video_promotion' && (ad.videoAttachmentFullUrl?.isNotEmpty ?? false);

  void _scheduleFor(int index) {
    _dwellTimer?.cancel();
    _delayTimer?.cancel();
    _pendingAdvance = false;
    _userEngaged = false;

    if(_ads.length < 2 || index < 0 || index >= _ads.length) return;

    if(_isVideoAd(_ads[index])) {
      _dwellTimer = Timer(_videoStartTimeout, _advanceAfterVideo);
    } else {
      _dwellTimer = Timer(_imageDwell, _advance);
    }
  }

  void _onVideoStarted(int index, Duration duration) {
    if(index != _currentIndex || _pendingAdvance) return;
    if(duration <= Duration.zero) return;

    _dwellTimer?.cancel();
    _dwellTimer = Timer(duration + _playbackSlack, _advanceAfterVideo);
  }

  void _onVideoEngagedChanged(int index, bool engaged, Duration remaining) {
    if(index != _currentIndex) return;

    _userEngaged = engaged;
    _dwellTimer?.cancel();
    _delayTimer?.cancel();

    if(engaged) {
      _pendingAdvance = false;
      return;
    }
    if(remaining <= Duration.zero) {
      _advanceAfterVideo();
    } else {
      _dwellTimer = Timer(remaining + _playbackSlack, _advanceAfterVideo);
    }
  }

  void _advanceAfterVideo() {
    if(_pendingAdvance || _userEngaged) return;
    _pendingAdvance = true;
    _dwellTimer?.cancel();
    _delayTimer?.cancel();
    _delayTimer = Timer(_postVideoDelay, _advance);
  }

  void _onVideoCompleted(int index) {
    if(index == _currentIndex) _advanceAfterVideo();
  }

  void _advance() {
    if(!mounted) return;
    _carouselController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdvertisementController>(builder: (advertisementController) {
      final List<AdvertisementModel>? list = advertisementController.advertisementList;

      if(list != null && list.isEmpty) return const SizedBox.shrink();

      if(list != null) {
        _ads = list;
        if(!_started) {
          _started = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if(mounted) _scheduleFor(_currentIndex);
          });
        }
      }

      final double cardWidth =  300.0;
      final double mediaHeight = 185;
      final double listHeight = mediaHeight + _infoHeight;

      return Padding(
        padding: const EdgeInsets.only(bottom: Dimensions.paddingLarge),
        child: Stack(children: [

        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [context.bgWarningMedium, context.surfaceContainer],
              ),
            ),
          ),
        ),

        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.paddingLarge, Dimensions.paddingExtraLarge,
              Dimensions.paddingLarge, 0,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('highlights_for_you'.tr, style: context.heading.extraLarge),
              const _SponsoredChip(),
            ]),
          ),
          const SizedBox(height: Dimensions.paddingDefault),

          SizedBox(
            height: listHeight + Dimensions.paddingLarge,
            child: list == null
                ? ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                    itemCount: 3,
                    separatorBuilder: (_, _) => const SizedBox(width: Dimensions.paddingMedium),
                    itemBuilder: (_, _) => _FeaturedStoreShimmerCard(width: cardWidth, mediaHeight: mediaHeight),
                  )
                : CarouselSlider.builder(
                    carouselController: _carouselController,
                    itemCount: list.length,
                    options: CarouselOptions(
                      height: listHeight,
                      viewportFraction: ((cardWidth + Dimensions.paddingMedium * 2) / MediaQuery.sizeOf(context).width).clamp(0.1, 1.0),
                      enableInfiniteScroll: list.length > 1,
                      autoPlay: false,
                      enlargeCenterPage: false,
                      padEnds: false,
                      disableCenter: true,
                      onPageChanged: (index, reason) {
                        setState(() => _currentIndex = index);
                        _scheduleFor(index);
                      },
                    ),
                    itemBuilder: (context, index, realIndex) => Padding(
                      padding: EdgeInsets.only(left: index == _currentIndex ? Dimensions.paddingLarge : Dimensions.paddingMedium),
                      child: _FeaturedStoreCard(
                        advertisement: list[index],
                        width: cardWidth,
                        mediaHeight: mediaHeight,
                        isActive: index == _currentIndex,
                        onVideoStarted: (duration) => _onVideoStarted(index, duration),
                        onVideoCompleted: () => _onVideoCompleted(index),
                        onVideoEngagedChanged: (engaged, remaining) => _onVideoEngagedChanged(index, engaged, remaining),
                      ),
                    ),
                  ),
          ),

        ]),
      ]),
    );
    });
  }
}

class _SponsoredChip extends StatelessWidget {
  const _SponsoredChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: 4),
      decoration: BoxDecoration(
        color: context.bgWarningLight,
        border: Border.all(color: context.outline),
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
      ),
      child: Text(
        'sponsored'.tr,
        style: context.subHeading.small.overrideWith(color: context.textBaseMedium),
      ),
    );
  }
}

class _FeaturedStoreCard extends StatelessWidget {
  final AdvertisementModel advertisement;
  final double width;
  final double mediaHeight;
  final bool isActive;
  final ValueChanged<Duration> onVideoStarted;
  final VoidCallback onVideoCompleted;
  final void Function(bool engaged, Duration remaining) onVideoEngagedChanged;
  const _FeaturedStoreCard({
    required this.advertisement, required this.width, required this.mediaHeight, required this.isActive,
    required this.onVideoStarted, required this.onVideoCompleted, required this.onVideoEngagedChanged,
  });

  void _openRestaurant() {
    Get.toNamed(
      RouteHelper.getRestaurantRoute(advertisement.restaurantId),
      arguments: RestaurantScreen(restaurant: Restaurant(id: advertisement.restaurantId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isVideo = advertisement.addType == 'video_promotion';

    return Container(
        width: width,
        margin: const EdgeInsets.only(bottom: Dimensions.paddingLarge),
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [
            BoxShadow(color: context.shadow, blurRadius: 8, offset: const Offset(0, 1)),
            BoxShadow(color: context.shadow, blurRadius: 2, offset: const Offset(0, 1)),
          ],
        ),
        child: Column(children: [
          Container(
            height: mediaHeight, width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
              boxShadow: [
                BoxShadow(color: context.shadow, blurRadius: 2, offset: const Offset(0, 2)),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
              child: (isVideo && (advertisement.videoAttachmentFullUrl?.isNotEmpty ?? false))
                  ? _AdVideoMedia(
                      videoUrl: advertisement.videoAttachmentFullUrl!, isActive: isActive,
                      onStarted: onVideoStarted, onCompleted: onVideoCompleted,
                      onEngagedChanged: onVideoEngagedChanged,
                    )
                  : Container(
                    decoration: BoxDecoration(
                      color: context.surfaceContainer,
                      borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                    ),
                    child: CustomImageWidget(
                        image: advertisement.coverImageFullUrl ?? '', isFood: true,
                        fit: BoxFit.fill, height: mediaHeight, width: double.infinity,
                      ),
                  ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingDefault,
                Dimensions.paddingDefault,
                Dimensions.paddingDefault,
                Dimensions.paddingDefault,
              ),
              child: isVideo ? _videoInfo(context) : _storeInfo(context),
            ),
          ),
        ]),
      );
  }


  Widget seeMoreButton(BuildContext context) {
    return Row(
      children: [

        if(advertisement.restaurantId != null) _FavouriteButton(restaurantId: advertisement.restaurantId!),
        const SizedBox(width: Dimensions.paddingSmall),

        InkWell(
          onTap: _openRestaurant,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Container(
            height: _buttonHeight,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall,),
            decoration: BoxDecoration(
              color: context.primary,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Center(child: Text('see_menu'.tr, style: context.subHeading.small.overrideWith(fontWeight: AppWeight.semiBold, color: context.onPrimary))),
          ),
        ),
      ],
    );
  }

  Widget _videoInfo(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        advertisement.title ?? '',
        style: context.heading.defaultSize,
        maxLines: 1, overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: Dimensions.padding2xSmall),

      Expanded(
        child: Text(
          advertisement.description ?? '',
          style: context.subHeading.small.overrideWith(color: context.textBaseMedium),
          maxLines: 2, overflow: TextOverflow.ellipsis,
        ),
      ),
      SizedBox(height: Dimensions.padding2xSmall),

      Row(children: [

      CustomAssetImageWidget(Images.starFill, color: context.iconWarningLight, height: 13, width: 13,),
      const SizedBox(width: 3),
      Text(
        (advertisement.averageRating ?? 0).toStringAsFixed(1),
        style: context.subHeading.defaultSize.strong,
      ),

        const SizedBox(width: 4),
        Text(
          '(${advertisement.reviewsCommentsCount ?? 0}+ ${'rev'.tr})',
          style: context.subHeading.defaultSize.overrideWith(color: context.textBaseMedium),
        ),

        const Spacer(),
        seeMoreButton(context),

      ])

    ]);
  }

  Widget _storeInfo(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
            border: Border.all(color: context.outline),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
            child: CustomImageWidget(
              image: advertisement.profileImageFullUrl ?? '', isRestaurant: true,
              height: 42, width: 42, fit: BoxFit.fill,
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSmall),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              advertisement.title ?? '',
              style: context.heading.defaultSize,
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),

            Text(
              advertisement.description ?? '',
              style: context.subHeading.small.overrideWith(color: context.textBaseMedium),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
          ]),
        ),

      ]),

      SizedBox(height: Dimensions.paddingSmall,),
      Row(children: [

        if(advertisement.isRatingActive == 1) ...[
          CustomAssetImageWidget(Images.starFill, color: context.iconWarningLight, height: 13, width: 13,),
          const SizedBox(width: 3),
          Text(
            (advertisement.averageRating ?? 0).toStringAsFixed(1),
            style: context.subHeading.defaultSize.strong,
          ),

          if(advertisement.isReviewActive == 1) ...[
            const SizedBox(width: 4),
            Text(
              '(${advertisement.reviewsCommentsCount ?? 0}+ ${'rev'.tr})',
              style: context.subHeading.defaultSize.overrideWith(color: context.textBaseMedium),
            ),
          ],
        ],

        const Spacer(),

        seeMoreButton(context),

      ]),

    ]);
  }
}

class _FavouriteButton extends StatelessWidget {
  final int restaurantId;
  const _FavouriteButton({required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FavouriteController>(builder: (favouriteController) {
      final bool isWished = favouriteController.wishRestIdList.contains(restaurantId);
      return CustomFavouriteWidget(id: restaurantId, isWished: isWished, bgColor: context.bgWarningLight, isRestaurant: true, widgetSize: _buttonHeight, size: 16, );
    });
  }
}

class _AdVideoMedia extends StatefulWidget {
  final String videoUrl;
  final bool isActive;
  final ValueChanged<Duration> onStarted;
  final VoidCallback onCompleted;

  final void Function(bool engaged, Duration remaining) onEngagedChanged;

  const _AdVideoMedia({
    required this.videoUrl, required this.isActive,
    required this.onStarted, required this.onCompleted, required this.onEngagedChanged,
  });

  @override
  State<_AdVideoMedia> createState() => _AdVideoMediaState();
}

class _AdVideoMediaState extends State<_AdVideoMedia> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _completed = false;
  bool _reportedStart = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _videoPlayerController = controller;
    controller.addListener(_onVideoProgress);
    await controller.initialize();
    _chewieController = ChewieController(
      videoPlayerController: controller,
      autoPlay: widget.isActive,
      aspectRatio: controller.value.aspectRatio,
      customControls: _AdVideoControls(
        controller: controller,
        onEngagedChanged: widget.onEngagedChanged,
      ),
    );
    _chewieController?.setVolume(0);
    if(mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant _AdVideoMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.isActive == oldWidget.isActive) return;

    final controller = _videoPlayerController;
    if(controller == null || !controller.value.isInitialized) return;

    if(widget.isActive) {
      _completed = false;
      _reportedStart = false;
      controller.seekTo(Duration.zero);
      controller.play();
    } else {
      controller.pause();
      controller.seekTo(Duration.zero);
    }
  }

  void _onVideoProgress() {
    if(!widget.isActive || _completed) return;

    final value = _videoPlayerController?.value;
    if(value == null || !value.isInitialized || value.duration <= Duration.zero) return;

    if(!_reportedStart && value.isPlaying && value.position > Duration.zero) {
      _reportedStart = true;
      widget.onStarted(value.duration);
    }

    if(value.position >= value.duration) {
      _completed = true;
      widget.onCompleted();
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(_onVideoProgress);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chewie = _chewieController;
    return (chewie != null && chewie.videoPlayerController.value.isInitialized)
        ? Chewie(controller: chewie)
        : Container(
            color: context.surfaceContainer,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(strokeWidth: 3),
          );
  }
}

class _AdVideoControls extends StatefulWidget {
  final VideoPlayerController controller;
  final void Function(bool engaged, Duration remaining) onEngagedChanged;
  const _AdVideoControls({required this.controller, required this.onEngagedChanged});

  @override
  State<_AdVideoControls> createState() => _AdVideoControlsState();
}

class _AdVideoControlsState extends State<_AdVideoControls> {
  static const Duration _autoHide = Duration(seconds: 4);
  static const Duration _fade = Duration(milliseconds: 200);
  static const double _restingBarHeight = 3;

  bool _expanded = false;
  bool _engaged = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncEngagement);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    widget.controller.removeListener(_syncEngagement);
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _restartHideTimer();
    _syncEngagement();
  }

  void _restartHideTimer() {
    _hideTimer?.cancel();
    if(!_expanded) return;
    _hideTimer = Timer(_autoHide, () {
      if(!mounted) return;
      setState(() => _expanded = false);
      _syncEngagement();
    });
  }

  void _syncEngagement() {
    final VideoPlayerValue value = widget.controller.value;
    final bool engaged = _expanded || (value.isInitialized && !value.isPlaying && value.position > Duration.zero && value.position < value.duration);
    if(engaged == _engaged) return;

    _engaged = engaged;
    final Duration remaining = value.duration - value.position;
    widget.onEngagedChanged(engaged, remaining > Duration.zero ? remaining : Duration.zero);
  }

  void _togglePlayback() {
    final VideoPlayerController controller = widget.controller;
    controller.value.isPlaying ? controller.pause() : controller.play();
    _restartHideTimer();
    _syncEngagement();
  }

  void _toggleMute() {
    final VideoPlayerController controller = widget.controller;
    controller.setVolume(controller.value.volume == 0 ? 1 : 0);
    _restartHideTimer();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggle,
      child: Stack(fit: StackFit.expand, children: [

        AnimatedOpacity(
          opacity: _expanded ? 1 : 0,
          duration: _fade,
          child: IgnorePointer(ignoring: !_expanded, child: _expandedControls(context)),
        ),

        Positioned(
          left: 0, right: 0, bottom: 0,
          child: AnimatedOpacity(
            opacity: _expanded ? 0 : 1,
            duration: _fade,
            child: _restingBar(context),
          ),
        ),

      ]),
    );
  }

  Widget _restingBar(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) {
        final int total = value.duration.inMilliseconds;
        final double progress = total <= 0 ? 0 : (value.position.inMilliseconds / total).clamp(0.0, 1.0);

        return Container(
          height: _restingBarHeight,
          color: Colors.white.withValues(alpha: 0.28),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress, heightFactor: 1,
            child: Container(color: context.primary),
          ),
        );
      },
    );
  }

  Widget _expandedControls(BuildContext context) {
    final bool isMuted = widget.controller.value.volume == 0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.0), Colors.black.withValues(alpha: 0.45)],
        ),
      ),
      child: Stack(children: [

        Center(
          child: GestureDetector(
            onTap: _togglePlayback,
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSmall),
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), shape: BoxShape.circle),
              child: ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: widget.controller,
                builder: (context, value, _) => Icon(
                  value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white, size: 28,
                ),
              ),
            ),
          ),
        ),

        Positioned(
          left: Dimensions.paddingSmall, right: Dimensions.paddingSmall, bottom: Dimensions.padding2xSmall,
          child: Row(children: [

            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: widget.controller,
              builder: (context, value, _) => Text(
                '${_stamp(value.position)} / ${_stamp(value.duration)}',
                style: context.body.extraSmall.regular.overrideWith(color: Colors.white),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSmall),

            Expanded(
              child: VideoProgressIndicator(
                widget.controller,
                allowScrubbing: true,
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
                colors: VideoProgressColors(
                  playedColor: context.primary,
                  bufferedColor: Colors.white.withValues(alpha: 0.4),
                  backgroundColor: Colors.white.withValues(alpha: 0.24),
                ),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSmall),

            GestureDetector(
              onTap: _toggleMute,
              child: Icon(isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white, size: 20),
            ),

          ]),
        ),

      ]),
    );
  }

  String _stamp(Duration duration) {
    final String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _FeaturedStoreShimmerCard extends StatelessWidget {
  final double width;
  final double mediaHeight;
  const _FeaturedStoreShimmerCard({required this.width, required this.mediaHeight});

  @override
  Widget build(BuildContext context) {
    final Color block = context.shadow;

    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(vertical: Dimensions.padding2xSmall),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Container(
            height: mediaHeight, width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: block,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
            ),
            child: const Icon(Icons.play_circle, color: Colors.white, size: 45),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingDefault),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(height: 52, width: 52, decoration: BoxDecoration(color: block, shape: BoxShape.circle)),
                const SizedBox(width: Dimensions.paddingSmall),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(height: 14, width: double.infinity, color: block),
                  const SizedBox(height: 6),
                  Container(height: 12, width: 120, color: block),
                ])),
              ]),
              const SizedBox(height: Dimensions.paddingDefault),
              Container(height: _buttonHeight, width: double.infinity, decoration: BoxDecoration(color: block, borderRadius: BorderRadius.circular(Dimensions.radiusSmall))),
            ]),
          ),

        ]),
      ),
    );
  }
}
