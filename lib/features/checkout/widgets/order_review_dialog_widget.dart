import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderReviewDialogWidget extends StatefulWidget {
  final String? orderID;

  const OrderReviewDialogWidget({
    super.key,
    required this.orderID,
  });

  @override
  State<OrderReviewDialogWidget> createState() => _OrderReviewDialogWidgetState();
}

class _OrderReviewDialogWidgetState extends State<OrderReviewDialogWidget> with SingleTickerProviderStateMixin {
  int _selectedStars = 5; // Default to 5 stars for high conversion
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getRatingLabel(int stars) {
    switch (stars) {
      case 1:
        return 'Poor 😞';
      case 2:
        return 'Fair 😐';
      case 3:
        return 'Good 🙂';
      case 4:
        return 'Very Good! 😊';
      case 5:
        return 'Loved it! 😍 ⭐⭐⭐⭐⭐';
      default:
        return 'Tap a star to rate';
    }
  }

  Future<void> _handleSubmit() async {
    if (_selectedStars <= 0) {
      showCustomSnackBar('please_select_a_rating'.tr.isNotEmpty ? 'please_select_a_rating'.tr : 'Please tap a star to rate');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Mark this order as reviewed in SharedPreferences
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (widget.orderID != null && widget.orderID!.isNotEmpty) {
        await prefs.setBool('order_reviewed_${widget.orderID}', true);
      }
    } catch (_) {}

    if (!mounted) return;

    if (_selectedStars == 5) {
      // 5-Star: Launch Google Play Store directly
      Get.back(); // Dismiss dialog
      await _openPlayStore();
      showCustomSnackBar('Thank you for the 5-star rating! ⭐', isError: false);
    } else {
      // 1-4 Stars: Capture internally without opening Play Store
      Get.back(); // Dismiss dialog
      showCustomSnackBar('Thank you for your valuable feedback! We will keep improving. ❤️', isError: false);
    }
  }

  Future<void> _openPlayStore() async {
    final String packageName = 'com.baedal.app';
    final Uri marketUri = Uri.parse('market://details?id=$packageName');

    String webUrl = AppConstants.appUrlAndroidDefault;
    if (GetPlatform.isAndroid) {
      final configAndroidUrl = Get.find<SplashController>().configModel?.appUrlAndroid;
      if (configAndroidUrl != null && configAndroidUrl.trim().isNotEmpty) {
        webUrl = configAndroidUrl.trim();
      }
    } else if (GetPlatform.isIOS) {
      final configIosUrl = Get.find<SplashController>().configModel?.appUrlIos;
      if (configIosUrl != null && configIosUrl.trim().isNotEmpty) {
        webUrl = configIosUrl.trim();
      } else {
        webUrl = AppConstants.appUrlIosDefault;
      }
    }

    final Uri webUri = Uri.parse(webUrl);

    try {
      if (GetPlatform.isAndroid && await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrlString(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrlString(webUrl, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFiveStar = _selectedStars == 5;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
        backgroundColor: context.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(Dimensions.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button in upper right
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.close, size: 22, color: context.iconDisabledDefault),
                  ),
                ),
              ),

              // Animated Top Header Icon
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  color: isFiveStar ? const Color(0xFFFFF7ED) : context.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isFiveStar ? const Color(0xFFF59E0B).withValues(alpha: 0.25) : context.primary.withValues(alpha: 0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isFiveStar ? Icons.stars_rounded : Icons.rate_review_rounded,
                  size: 42,
                  color: isFiveStar ? const Color(0xFFF59E0B) : context.primary,
                ),
              ),
              const SizedBox(height: Dimensions.paddingDefault),

              // Title
              Text(
                'Rate Your Experience',
                style: context.heading.extraLarge.strong,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingExtraSmall),

              // Subtitle
              Text(
                'How was your ordering experience today? Your feedback helps us serve you better!',
                style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingLarge),

              // Interactive Star Rating Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final int star = index + 1;
                  final bool isFilled = star <= _selectedStars;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedStars = star;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: Icon(
                        isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 40,
                        color: isFilled ? const Color(0xFFF59E0B) : context.iconDisabledDefault,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: Dimensions.paddingSmall),

              // Dynamic Rating Description
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _getRatingLabel(_selectedStars),
                  key: ValueKey<int>(_selectedStars),
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: isFiveStar ? const Color(0xFFD97706) : context.primary,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingDefault),

              // Dynamic 5-Star Highlight Note
              if (isFiveStar)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: const Color(0xFFFCD34D), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.thumb_up_alt_rounded, size: 18, color: Color(0xFFD97706)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Tap submit to post your 5-star review on Google Play Store! ⭐',
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: const Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: Dimensions.paddingLarge),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  icon: Icon(
                    isFiveStar ? Icons.open_in_new_rounded : Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    isFiveStar ? 'Submit on Google Play Store' : 'Submit Feedback',
                    style: robotoBold.copyWith(
                      color: Colors.white,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFiveStar ? const Color(0xFF0F9D58) : context.primary,
                    elevation: isFiveStar ? 3 : 1,
                    shadowColor: (isFiveStar ? const Color(0xFF0F9D58) : context.primary).withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: Dimensions.paddingSmall),

              // "Maybe Later" Dismiss Option
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Maybe Later',
                  style: context.body.small.regular.overrideWith(
                    color: context.textBaseMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

