import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:stackfood_multivendor/common/widgets/no_internet_screen_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/deep_link_body.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? notificationBody;
  final DeepLinkBody? linkBody;
  const SplashScreen({super.key, required this.notificationBody, required this.linkBody});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;
  Timer? _routeTimer;

  late AnimationController _entryController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _bottomFade;
  late Animation<double> _deliveryProgress;
  late Animation<double> _pulseGlow;

  @override
  void initState() {
    super.initState();

    _initAnimations();

    bool firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.mobile);

      if(!firstTime) {
        ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6000),
          content: Text(isConnected ? 'connected'.tr : 'no_connection'.tr, textAlign: TextAlign.center),
        ));
        if(isConnected) {
          _route();
        } else {
          Get.to(const NoInternetScreen());
        }
      }

      firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    if(AddressHelper.getAddressFromSharedPref() != null && (AddressHelper.getAddressFromSharedPref()!.zoneIds == null
        || AddressHelper.getAddressFromSharedPref()!.zoneData == null)) {
      AddressHelper.clearAddressFromSharedPref();
    }
    if(Get.find<AuthController>().isGuestLoggedIn() || Get.find<AuthController>().isLoggedIn()) {
      Get.find<CartController>().getCartBundleList();
    }

    // Prefetch config in background so data is ready
    Get.find<SplashController>().getConfigData(handleMaintenanceMode: false, notificationBody: widget.notificationBody);

    // Smooth timing so animations play cleanly before navigation
    _routeTimer = Timer(const Duration(milliseconds: 2700), () {
      if (mounted) {
        _route();
      }
    });
  }

  void _initAnimations() {
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.55, 0.90, curve: Curves.easeOut),
      ),
    );

    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.55, 0.90, curve: Curves.easeOutCubic),
      ),
    );

    _bottomFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );

    _deliveryProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _pulseGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _routeTimer?.cancel();
    _entryController.dispose();
    _pulseController.dispose();
    _onConnectivityChanged?.cancel();
    super.dispose();
  }

  void _route() {
    Get.find<SplashController>().getConfigData(handleMaintenanceMode: false, notificationBody: widget.notificationBody);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return Scaffold(
      key: _globalKey,
      body: GetBuilder<SplashController>(builder: (splashController) {
        if (!splashController.hasConnection) {
          return NoInternetScreen(child: SplashScreen(notificationBody: widget.notificationBody, linkBody: widget.linkBody));
        }

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark ? [
                const Color(0xFF0B1118),
                const Color(0xFF0F172A),
                const Color(0xFF0B1118),
              ] : [
                const Color(0xFFF8FAFC),
                const Color(0xFFF0F9FF),
                const Color(0xFFE0F2FE),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Ambient radial glow behind the center logo
              Positioned.fill(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _pulseGlow,
                    builder: (context, child) {
                      return Container(
                        width: 380,
                        height: 380,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              primaryColor.withValues(alpha: isDark ? (0.16 + _pulseGlow.value * 0.08) : (0.14 + _pulseGlow.value * 0.07)),
                              primaryColor.withValues(alpha: 0.0),
                            ],
                            radius: 0.65,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Decorative subtle background food motifs (low opacity for elegant depth)
              _buildBackgroundAccent(
                top: 70,
                left: 24,
                icon: Icons.lunch_dining_rounded,
                size: 34,
                isDark: isDark,
                primaryColor: primaryColor,
              ),
              _buildBackgroundAccent(
                top: 120,
                right: 32,
                icon: Icons.local_pizza_rounded,
                size: 40,
                isDark: isDark,
                primaryColor: primaryColor,
              ),
              _buildBackgroundAccent(
                bottom: 160,
                left: 36,
                icon: Icons.restaurant_rounded,
                size: 36,
                isDark: isDark,
                primaryColor: primaryColor,
              ),
              _buildBackgroundAccent(
                bottom: 210,
                right: 28,
                icon: Icons.ramen_dining_rounded,
                size: 38,
                isDark: isDark,
                primaryColor: primaryColor,
              ),

              // Main Center Content
              Center(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Logo Hero with pulsing halo
                        AnimatedBuilder(
                          animation: Listenable.merge([_entryController, _pulseController]),
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _logoFade,
                              child: ScaleTransition(
                                scale: _logoScale,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Outer breathing aura ring
                                    Container(
                                      width: 146 + (_pulseGlow.value * 18),
                                      height: 146 + (_pulseGlow.value * 18),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: primaryColor.withValues(
                                          alpha: (1.0 - _pulseGlow.value) * (isDark ? 0.22 : 0.18),
                                        ),
                                      ),
                                    ),

                                    // Secondary inner pulse ring
                                    Container(
                                      width: 132 + (_pulseGlow.value * 10),
                                      height: 132 + (_pulseGlow.value * 10),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: primaryColor.withValues(
                                          alpha: (1.0 - _pulseGlow.value) * (isDark ? 0.28 : 0.22),
                                        ),
                                      ),
                                    ),

                                    // Elevated Logo Badge Container
                                    Container(
                                      width: 120,
                                      height: 120,
                                      padding: const EdgeInsets.all(22),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDark ? const Color(0xFF212328) : Colors.white,
                                        border: Border.all(
                                          color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white,
                                          width: 2.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.22),
                                            blurRadius: 30,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 10),
                                          ),
                                          BoxShadow(
                                            color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(Images.logo, fit: BoxFit.contain),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                        // Logo Name Image with smooth slide & fade
                        FadeTransition(
                          opacity: _titleFade,
                          child: SlideTransition(
                            position: _titleSlide,
                            child: Image.asset(
                              Images.logoName,
                              width: 170,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        // Modern Food Delivery Tagline Pill Badge
                        FadeTransition(
                          opacity: _taglineFade,
                          child: SlideTransition(
                            position: _taglineSlide,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark ? [
                                    primaryColor.withValues(alpha: 0.20),
                                    primaryColor.withValues(alpha: 0.08),
                                  ] : [
                                    primaryColor.withValues(alpha: 0.12),
                                    primaryColor.withValues(alpha: 0.04),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.25),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.delivery_dining_rounded, size: 19, color: primaryColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Fast Delivery \u2022 Fresh & Hot Food',
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF333333),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Delivery Progress Indicator
              Positioned(
                bottom: 42,
                left: 36,
                right: 36,
                child: FadeTransition(
                  opacity: _bottomFade,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated Track with Delivery Scooter
                      AnimatedBuilder(
                        animation: _deliveryProgress,
                        builder: (context, child) {
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final totalWidth = constraints.maxWidth;
                              const iconBoxSize = 30.0;
                              final travelDistance = (totalWidth - iconBoxSize).clamp(0.0, double.infinity);
                              final currentPosition = travelDistance * _deliveryProgress.value;

                              return SizedBox(
                                height: 32,
                                child: Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    // Background Track
                                    Container(
                                      height: 4,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),

                                    // Active Fill Track
                                    Container(
                                      height: 4,
                                      width: currentPosition + (iconBoxSize / 2),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            primaryColor.withValues(alpha: 0.3),
                                            primaryColor,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),

                                    // Scooter Icon progressing along the track
                                    Positioned(
                                      left: currentPosition,
                                      child: Container(
                                        width: iconBoxSize,
                                        height: iconBoxSize,
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryColor.withValues(alpha: 0.45),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.moped_rounded,
                                          size: 17,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 10),

                      // Delivery Subtitle
                      Text(
                        'Serving the best tastes near you...',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black45,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBackgroundAccent({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required IconData icon,
    required double size,
    required bool isDark,
    required Color primaryColor,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size + 20,
        height: size + 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.white.withValues(alpha: 0.025) : primaryColor.withValues(alpha: 0.045),
        ),
        child: Icon(
          icon,
          size: size,
          color: isDark ? Colors.white.withValues(alpha: 0.06) : primaryColor.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}
