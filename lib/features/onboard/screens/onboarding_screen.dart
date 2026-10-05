import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/onboard/controllers/onboard_controller.dart';
import 'package:stackfood_multivendor/features/onboard/domain/models/onboarding_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    Get.find<OnBoardingController>().getOnBoardingList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _configureToRouteInitialPage() async {
    Get.find<SplashController>().disableIntro();
    await Get.find<AuthController>().guestLogin();
    if (AddressHelper.getAddressFromSharedPref() != null) {
      Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
    } else {
      Get.find<SplashController>().navigateToLocationScreen('splash', offNamed: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFA5E6FF),
              Color(0xFFCBEBFE),
              Color(0xFFE4F4FE),
              Color(0xFFF3FAFE),
              Color(0xFFFFFFFF),
            ],
            stops: [0.0, 0.25, 0.55, 0.8, 1.0],
          ),
        ),
        child: SafeArea(
          child: GetBuilder<OnBoardingController>(
            builder: (onBoardingController) {
              if (onBoardingController.onBoardingList == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final List<OnBoardingModel> onBoardingList = onBoardingController.onBoardingList!;
              final int currentIndex = onBoardingController.selectedIndex;
              final bool isLastPage = currentIndex >= onBoardingList.length - 1;

              return Center(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(
                    children: [
                      // Top bar with Skip button
                      Padding(
                        padding: const EdgeInsets.only(
                          top: Dimensions.paddingSmall,
                          right: Dimensions.paddingLarge,
                          left: Dimensions.paddingLarge,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _SkipButton(
                            onTap: _configureToRouteInitialPage,
                          ),
                        ),
                      ),

                      // Illustrations carousel
                      Expanded(
                        flex: 6,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: onBoardingList.length,
                          onPageChanged: (index) {
                            onBoardingController.changeSelectIndex(index);
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Center(
                                child: Image.asset(
                                  onBoardingList[index].imageUrl,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Text content and navigation controls
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),

                              // Title with highlighted keyword
                              _buildHighlightedTitle(
                                context,
                                onBoardingList[currentIndex].title,
                                currentIndex,
                              ),
                              const SizedBox(height: 12),

                              // Description subtitle
                              Text(
                                onBoardingList[currentIndex].description.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.45,
                                  color: Color(0xFF64748B),
                                  fontFamily: AppConstants.fontFamily,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                              ),

                              const Spacer(),

                              // Page Indicator Dots
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(onBoardingList.length, (index) {
                                  final bool isSelected = currentIndex == index;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: isSelected ? 22 : 6,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF0284C7)
                                          : const Color(0xFFBAE6FD),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  );
                                }),
                              ),

                              const SizedBox(height: 24),

                              // Bottom Buttons: Back & Next
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Back Button
                                  _CircularNavButton(
                                    icon: Icons.arrow_back,
                                    backgroundColor: const Color(0xFFE2E8F0).withValues(alpha: 0.65),
                                    iconColor: const Color(0xFF0F172A),
                                    onTap: () {
                                      if (currentIndex > 0) {
                                        _pageController.previousPage(
                                          duration: const Duration(milliseconds: 400),
                                          curve: Curves.easeInOut,
                                        );
                                      } else {
                                        Get.back();
                                      }
                                    },
                                  ),

                                  const SizedBox(width: 24),

                                  // Forward / Next Button
                                  _CircularNavButton(
                                    icon: isLastPage ? Icons.check : Icons.arrow_forward,
                                    backgroundColor: const Color(0xFF0284C7),
                                    iconColor: Colors.white,
                                    hasShadow: true,
                                    onTap: () {
                                      if (isLastPage) {
                                        _configureToRouteInitialPage();
                                      } else {
                                        _pageController.nextPage(
                                          duration: const Duration(milliseconds: 400),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedTitle(BuildContext context, String rawTitleKey, int index) {
    final String translated = rawTitleKey.tr;
    const TextStyle baseStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w800,
      color: Color(0xFF0F172A),
      fontFamily: AppConstants.fontFamily,
      letterSpacing: -0.3,
    );
    final TextStyle highlightStyle = baseStyle.copyWith(
      color: const Color(0xFF0284C7),
    );

    // Keywords to highlight in sky blue across supported languages
    const List<String> keywords = [
      'Location',
      'Yummy Food',
      'On-Time',
      'ubicación',
      'Comida Deliciosa',
      'Entregas Puntuales',
      'موقعك',
      'طعامًا لذيذًا',
      'الوقت المحدد',
      'লোকেশন',
      'মজাদার খাবার',
      'সময়মতো',
    ];

    String? matchedKeyword;
    for (final kw in keywords) {
      if (translated.toLowerCase().contains(kw.toLowerCase())) {
        matchedKeyword = kw;
        break;
      }
    }

    if (matchedKeyword != null) {
      final int startIndex = translated.toLowerCase().indexOf(matchedKeyword.toLowerCase());
      final int endIndex = startIndex + matchedKeyword.length;
      final String prefix = translated.substring(0, startIndex);
      final String highlight = translated.substring(startIndex, endIndex);
      final String suffix = translated.substring(endIndex);

      return RichText(
        textAlign: TextAlign.center,
        maxLines: 2,
        text: TextSpan(
          children: [
            TextSpan(text: prefix, style: baseStyle),
            TextSpan(text: highlight, style: highlightStyle),
            TextSpan(text: suffix, style: baseStyle),
          ],
        ),
      );
    }

    return Text(
      translated,
      style: baseStyle,
      textAlign: TextAlign.center,
      maxLines: 2,
    );
  }
}

class _SkipButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SkipButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          child: Text(
            'skip'.tr,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularNavButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;
  final bool hasShadow;

  const _CircularNavButton({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
    this.hasShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.38),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 52,
            height: 52,
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
