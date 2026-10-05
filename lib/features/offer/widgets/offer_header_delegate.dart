part of '../screen/offer_screen.dart';

class _OfferHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final String iconPath;
  final int resultCount;
  final int tabIndex;
  final ValueChanged<int> onTabChanged;
  final bool isSearchMode;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchSubmit;
  final VoidCallback onFilterTap;
  final bool isLoading;

  _OfferHeaderDelegate({
    required this.title, required this.iconPath, required this.resultCount, required this.tabIndex, required this.onTabChanged,
    required this.isSearchMode, required this.searchController, required this.searchFocusNode,
    required this.onSearchToggle, required this.onSearchSubmit, required this.onFilterTap, required this.isLoading,
  });

  static const double _backRowHeight = 40;
  static const double _titleBlockHeight = 64;
  static const double _collapsedTitleRowHeight = 48;
  static const double _chipsRowHeight = 54;

  static double get _topAreaExpandedHeight => _backRowHeight + _titleBlockHeight;
  static double get _collapseRange => _topAreaExpandedHeight - _collapsedTitleRowHeight;

  static double collapseProgress(double shrinkOffset) =>
      _collapseRange > 0 ? (shrinkOffset / _collapseRange).clamp(0.0, 1.0) : 0.0;

  static Color backgroundColorAt(BuildContext context, double t) =>
      Color.lerp(context.surface, context.surfaceContainer, t)!;

  @override
  double get minExtent => _collapsedTitleRowHeight + _chipsRowHeight;

  @override
  double get maxExtent => _topAreaExpandedHeight + _chipsRowHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    double t = collapseProgress(shrinkOffset);
    double topAreaHeight = _collapsedTitleRowHeight + _collapseRange * (1 - t);

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: backgroundColorAt(context, t),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            SizedBox(
              height: topAreaHeight,
              child: ClipRect(
                child: Stack(children: [

                  Positioned(top: 0, left: 0, right: 0, child: Opacity(
                    opacity: 1 - t,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(height: Dimensions.paddingSmall),
                      SizedBox(
                        height: _backRowHeight,
                        child: InkWell(
                          onTap: () => Get.back(),
                          child: Icon(Icons.arrow_back, size: 22),
                        ),
                      ),
                      SizedBox(
                        height: _titleBlockHeight,
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(title, style: context.heading.extraOverLarge.strong),
                              isLoading ? const SizedBox.shrink()
                              : Text(
                                  '$resultCount ${'results'.tr}',
                                  style: context.subHeading.defaultSize.regular.overrideWith(color: context.textBaseMedium)
                                ),
                            ]),
                          ),
                          _AnimatedOfferIcon(iconPath: iconPath),
                        ]),
                      ),
                    ]),
                  )),

                  Positioned(top: 0, left: 0, right: 0, child: Opacity(
                    opacity: t,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(height: Dimensions.paddingSmall),
                      SizedBox(
                        height: _backRowHeight,
                        child: Row(children: [
                          InkWell(
                            onTap: () => Get.back(),
                            child: Icon(Icons.arrow_back, size: 22),
                          ),
                          const SizedBox(width: Dimensions.padding2xSmall),
                          Text(title, style: context.heading.extraLarge.strong),
                        ]),
                      ),
                    ]),
                  )),

                ]),
              ),
            ),

            SizedBox(
              height: _chipsRowHeight-1,
              child: Row(children: [
                Expanded(
                  child: ClipRect(
                    child: Stack(alignment: Alignment.centerLeft, children: [
                      AnimatedSlide(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOutCubic,
                        offset: isSearchMode ? const Offset(-1, 0) : Offset.zero,
                        child: IgnorePointer(
                          ignoring: isSearchMode,
                          child: Row(children: [
                            _filterChip(context, 0, 'all'.tr),
                            const SizedBox(width: Dimensions.paddingSmall),
                            _filterChip(context, 1, 'food'.tr),
                            const SizedBox(width: Dimensions.paddingSmall),
                            _filterChip(context, 2, 'restaurants'.tr),
                            const Spacer(),
                            InkWell(
                              onTap: onSearchToggle,
                              child: Padding(padding: const EdgeInsets.all(Dimensions.padding2xSmall), child: CustomAssetImageWidget(Images.search, height: 20, width: 20, color: Get.context?.iconBaseDefault)),
                            ),
                          ]),
                        ),
                      ),
                      AnimatedSlide(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOutCubic,
                        offset: isSearchMode ? Offset.zero : const Offset(1, 0),
                        child: IgnorePointer(
                          ignoring: !isSearchMode,
                          child: _buildSearchField(context),
                        ),
                      ),
                    ]),
                  ),
                ),
                SizedBox(width: Dimensions.paddingSmall),
                InkWell(
                  onTap: onFilterTap,
                  child: CustomAssetImageWidget(Images.sortIcon, width: 20, height: 20),
                ),
              ]),
            ),
          ]),
        ),
        Divider(height: 1, thickness: 1,),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(color: context.outline),
      ),
      child: Row(children: [
        const SizedBox(width: Dimensions.paddingSmall),
        CustomAssetImageWidget(Images.search, height: 20, width: 20, color: context.iconBaseDefault,),
        const SizedBox(width: Dimensions.paddingSmall),
        Expanded(
          child: TextField(
            controller: searchController,
            focusNode: searchFocusNode,
            style: context.subHeading.defaultSize.regular,
            textInputAction: TextInputAction.search,
            onSubmitted: onSearchSubmit,
            decoration: InputDecoration(
              hintText: 'search_in_offers'.tr,
              hintStyle: context.subHeading.defaultSize.regular.overrideWith(color: context.textBaseMedium),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        InkWell(
          onTap: onSearchToggle,
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.padding2xSmall),
            child: Icon(Icons.close, size: 20, color: context.iconBaseDefault),
          ),
        ),
      ]),
    );
  }

  Widget _filterChip(BuildContext context, int index, String label) {
    bool isSelected = tabIndex == index;
    return InkWell(
      onTap: () => onTabChanged(index),
      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingExtraSmall),
        decoration: BoxDecoration(
          color: isSelected ? context.primary : null,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(color: isSelected ? context.primary : context.outline),
        ),
        child: Text(
          label,
          style: isSelected? context.subHeading.defaultSize.semiBold.overrideWith(color: Theme.of(context).colorScheme.onPrimary) : context.subHeading.defaultSize.medium.overrideWith(color: context.textBaseMedium),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _OfferHeaderDelegate oldDelegate) {
    return oldDelegate.resultCount != resultCount || oldDelegate.tabIndex != tabIndex || oldDelegate.isSearchMode != isSearchMode
        || oldDelegate.title != title || oldDelegate.iconPath != iconPath || oldDelegate.isLoading != isLoading;
  }
}

class _AnimatedOfferIcon extends StatefulWidget {
  final String iconPath;
  const _AnimatedOfferIcon({required this.iconPath});

  @override
  State<_AnimatedOfferIcon> createState() => _AnimatedOfferIconState();
}

class _AnimatedOfferIconState extends State<_AnimatedOfferIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;

  static const double _startOffsetY = 90;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));

    _slideAnimation = Tween<double>(begin: _startOffsetY, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.9, curve: Curves.easeOutCubic)),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _rotationAnimation = Tween<double>(begin: -0.4, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _fadeAnimation.value,
        child: Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.scale(scale: _scaleAnimation.value, child: child),
          ),
        ),
      ),
      child: CustomAssetImageWidget(widget.iconPath, width: 48, height: 48),
    );
  }
}
