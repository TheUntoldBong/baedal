import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, debugPrint;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/cookies_view_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/pro/controllers/pro_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/deep_link_body.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/notification_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/theme/dark_theme.dart';
import 'package:flutter/services.dart';
import 'package:stackfood_multivendor/theme/light_theme.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/messages.dart';

import 'helper/get_di.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }


  DeepLinkBody? linkBody;

  if(GetPlatform.isWeb) {
    await Firebase.initializeApp(options: const FirebaseOptions(
      apiKey: "AIzaSyBBwQ_XQuW4j1Gg9L3tbLcyaOKBJ7qL2NU",
      authDomain: "baedal-food-delivery.firebaseapp.com",
      projectId: "baedal-food-delivery",
      storageBucket: "baedal-food-delivery.firebasestorage.app",
      messagingSenderId: "369896627923",
      appId: "1:369896627923:web:3108cae6fbfad2ef9dbe26",
    ));
  }else if(GetPlatform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAgvlMn5x9qMnT_F2uICNoXU33-KshJmQs',
        appId: '1:369896627923:android:92e1485db6222b129dbe26',
        messagingSenderId: '369896627923',
        projectId: 'baedal-food-delivery',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  Map<String, Map<String, String>> languages = await di.init();

  NotificationBodyModel? body;
  try {
    if (GetPlatform.isMobile) {
      final RemoteMessage? remoteMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  }catch(_) {}

  if (ResponsiveHelper.isWeb()) {
    await FacebookAuth.instance.webAndDesktopInitialize(
      appId: "452131619626499",
      cookie: true,
      xfbml: true,
      version: "v13.0",
    );
  }
  runApp(MyApp(languages: languages, body: body, linkBody: linkBody));
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBodyModel? body;
  final DeepLinkBody? linkBody;
  const MyApp({super.key, required this.languages, required this.body, required this.linkBody});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    _route();
  }

  Future<void> _route() async {
    if(GetPlatform.isWeb) {
      Get.find<SplashController>().initSharedData();
      if(!Get.find<AuthController>().isLoggedIn() && !Get.find<AuthController>().isGuestLoggedIn()) {
        await Get.find<AuthController>().guestLogin();
      }
      if(AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) {
        Get.find<CartController>().getCartBundleList();
      }
      Get.find<SplashController>().getConfigData(fromMainFunction: true);
      if (Get.find<AuthController>().isLoggedIn()) {
        Get.find<AuthController>().updateToken();
        await Get.find<FavouriteController>().getFavouriteList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetBuilder<SplashController>(builder: (splashController) {
          return (GetPlatform.isWeb && splashController.configModel == null) ? const SizedBox() : GetMaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: Get.key,
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
            ),
            theme: themeController.darkTheme ? dark : light,
            locale: localizeController.locale,
            translations: Messages(languages: widget.languages),
            fallbackLocale: Locale(AppConstants.languages[0].languageCode!, AppConstants.languages[0].countryCode),
            initialRoute: GetPlatform.isWeb ? RouteHelper.getInitialRoute() : RouteHelper.getSplashRoute(widget.body, widget.linkBody),
            getPages: RouteHelper.routes,
            routingCallback: (routing) {
              if(kDebugMode && routing != null) {
                debugPrint('[nav] current=${routing.current}  previous=${routing.previous}  '
                    'isBack=${routing.isBack}  removed=${routing.removed}  '
                    'sheet=${routing.isBottomSheet} dialog=${routing.isDialog}');
              }
              if(routing == null || (routing.isBottomSheet ?? false) || (routing.isDialog ?? false)) return;
              if(Get.isRegistered<ProController>()) {
                Get.find<ProController>().maybeShowRenewOnRoute(routing.current);
              }
            },
            defaultTransition: GetPlatform.isWeb ? Transition.fadeIn : Transition.topLevel,
            transitionDuration: const Duration(milliseconds: 500),
            builder: (BuildContext context, widget) {
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: themeController.darkTheme ? darkSystemUiOverlayStyle : lightSystemUiOverlayStyle,
                child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)), child: Material(
                child: SafeArea(
                  top: false, bottom: GetPlatform.isAndroid,
                  child: Stack(children: [
                    widget!,

                    GetBuilder<SplashController>(builder: (splashController){

                      if(!splashController.savedCookiesData || !splashController.getAcceptCookiesStatus(splashController.configModel?.cookiesText ?? "")){
                        return ResponsiveHelper.isWeb() ? const Align(alignment: Alignment.bottomCenter, child: CookiesViewWidget()) : const SizedBox();
                      }else{
                        return const SizedBox();
                      }
                    })
                  ]),
                )),
              ));
            }
          );
        });
      });
    });
  }
}