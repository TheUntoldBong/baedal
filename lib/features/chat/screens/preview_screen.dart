import 'package:chewie/chewie.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/chat/controllers/chat_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:video_player/video_player.dart';

class PreviewScreen extends StatefulWidget {
  final List<String> images;
  final int selectedIndex;
  const PreviewScreen({super.key, required this.images, required this.selectedIndex});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewController;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.selectedIndex;
    _pageController = PageController(initialPage: widget.selectedIndex);
    _loadVideo(_currentPage);
  }

  Future<void> _loadVideo(int pageIndex) async {
    final url = widget.images[pageIndex];
    if (!Get.find<ChatController>().isVideoExtension(url)) return;

    _chewController?.pause();
    _chewController?.dispose();
    _chewController = null;
    await _videoPlayerController?.dispose();
    _videoPlayerController = null;

    if (!mounted) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _videoPlayerController = controller;

    try {
      await controller.initialize();
    } catch (e) {
      debugPrint('Video init error: $e');
      if (mounted) setState(() {});
      return;
    }

    if (!mounted) return;

    setState(() {
      _chewController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        allowFullScreen: true,
        aspectRatio: controller.value.aspectRatio,
        placeholder: const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.error, color: context.textBaseMedium, size: 40),
                const SizedBox(height: 8),
                Text(
                  'this_video_is_not_supported_please_download_and_pay'.tr,
                  textAlign: TextAlign.center,
                  style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _chewController?.pause();
    _chewController?.dispose();
    _videoPlayerController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Scaffold(
      backgroundColor: isDesktop ? Colors.transparent : Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (i) {
                setState(() {
                  _currentPage = i;
                });
                _loadVideo(i);
              },
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                final url = widget.images[index];
                final isVideo = Get.find<ChatController>().isVideoExtension(url);

                if (isVideo) {
                  if (_chewController != null &&
                      _chewController!.videoPlayerController.value.isInitialized &&
                      index == _currentPage) {
                    return Center(child: Chewie(controller: _chewController!));
                  }
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                return PhotoView(
                  backgroundDecoration: BoxDecoration(
                    color: isDesktop ? Colors.transparent : Colors.black,
                  ),
                  tightMode: true,
                  imageProvider: NetworkImage(widget.images[index]),
                  heroAttributes: PhotoViewHeroAttributes(tag: widget.images[index]),
                );
              },
            ),

            Positioned(
              top: 10,
              right: 0,
              child: IconButton(
                splashRadius: 5,
                onPressed: () => Get.back(),
                icon: const Icon(Icons.clear, color: Colors.white),
              ),
            ),

            if (_currentPage > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isDesktop ? Colors.white : Colors.black),
                  ),
                  margin: EdgeInsets.only(left: Dimensions.paddingSmall),
                  child: CustomInkWellWidget(
                    onTap: _previousPage,
                    radius: 50,
                    padding: EdgeInsets.all(Dimensions.paddingSmall),
                    child: Icon(Icons.arrow_back, color: isDesktop ? Colors.white : Colors.black),
                  ),
                ),
              ),

            if (_currentPage < widget.images.length - 1)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isDesktop ? Colors.white : Colors.black),
                  ),
                  margin: EdgeInsets.only(right: Dimensions.paddingSmall),
                  child: CustomInkWellWidget(
                    onTap: _nextPage,
                    radius: 50,
                    padding: EdgeInsets.all(Dimensions.paddingSmall),
                    child: Icon(Icons.arrow_forward, color: isDesktop ? Colors.white : Colors.black),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < widget.images.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }
}
