import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/notification_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/theme/dark_theme.dart';
import 'package:sixam_mart/theme/light_theme.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/messages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/home/widgets/cookies_view.dart';
import 'package:url_strategy/url_strategy.dart';
import 'firebase_options.dart';
import 'helper/get_di.dart' as di;

// import 'package:js/js.dart';
//
// @JS('removePreloader') // Link to the JavaScript function
// external void removePreloader();
//
// void callPreloaderRemoveScript() {
//   removePreloader();
// }

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

setModuleRestaurant() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences,
      fenix: true); // fenix: true keeps it alive
  // await sharedPreferences.clear();

  print("Module setting to 1////////////////////////////////////////");
  await sharedPreferences.setString(
    AppConstants.moduleId,
    AppConstants.restaurantModuleId,
  );
  // await sharedPreferences.setString(
  //     AppConstants.cacheModuleId, AppConstants.restaurantModuleId);
  print("Module settled to 2////////////////////////////////////////");
  print("Module settled to 2////////////////////////////////////////");
  final id = sharedPreferences.getString(AppConstants.moduleId);
  String? cacheModuleID;
  if (sharedPreferences.containsKey(AppConstants.cacheModuleId)) {
    cacheModuleID = sharedPreferences.getString(AppConstants.cacheModuleId);
  } else {
    log("cacheModuleID is null");
  }
  log("Module ID now: ///////////////");
  log("Module ID: ${id.toString()}");
  log(cacheModuleID.toString());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setModuleRestaurant();

  if (ResponsiveHelper.isMobilePhone()) {
    HttpOverrides.global = MyHttpOverrides();
  }

  // Initialize SharedPreferences
  // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  // Get.lazyPut(() => sharedPreferences, fenix: true);

  // --- Print all SharedPreferences keys START ---
  // try {
  //   // Get the SharedPreferences instance (could also use the 'sharedPreferences' variable above directly)
  //   SharedPreferences prefs = Get.find<
  //       SharedPreferences>(); // Or: SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   // Get all keys
  //   Set<String> keys = prefs.getKeys();
  //
  //   if (keys.isEmpty) {
  //     print('SharedPreferences: No keys found.');
  //   } else {
  //     print('SharedPreferences: All stored keys:');
  //     for (String key in keys) {
  //       // You can also print the value if you want, but be mindful of the type
  //       dynamic value = prefs.get(key);
  //       print('  - Key: $key, Value: $value (Type: ${value.runtimeType})');
  //       // print('  - Key: $key');
  //     }
  //   }
  // } catch (e) {
  //   print('SharedPreferences: Error retrieving keys: $e');
  // }
  // setPathUrlStrategy();

  /*///Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };


  ///Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };*/
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // if (GetPlatform.isWeb) {
  //   await Firebase.initializeApp(
  //       options: const FirebaseOptions(
  //           apiKey: "AIzaSyDQ3lxAHoKaXQl2xZ0WEZXPQbB2D67n7uI",
  //           authDomain: "jouan-8e433.firebaseapp.com",
  //           projectId: "jouan-8e433",
  //           storageBucket: "jouan-8e433.firebasestorage.app",
  //           messagingSenderId: "1008785511526",
  //           appId: "1:1008785511526:web:b2a643531d09b04581c9a7",
  //           measurementId: "G-WDL20VD0DV"));
  // } else if (GetPlatform.isAndroid) {
  //   await Firebase.initializeApp(
  //     options: const FirebaseOptions(
  //       apiKey: "AIzaSyCWSwN2fqrwrjVhKhvb6lxDLH5FqbWklBo",
  //       appId: "1:1008785511526:android:713f4951b76c41c981c9a7",
  //       messagingSenderId: "1008785511526",
  //       projectId: "jouan-8e433",
  //     ),
  //   );
  // } else {
  //   await Firebase.initializeApp();
  // }

  Map<String, Map<String, String>> languages = await di.init();

  NotificationBodyModel? body;
  try {
    if (GetPlatform.isMobile) {
      // await setModuleRestaurant();
      final RemoteMessage? remoteMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  } catch (_) {}

  if (ResponsiveHelper.isWeb()) {
    await FacebookAuth.instance.webAndDesktopInitialize(
      appId: "380903914182154",
      cookie: true,
      xfbml: true,
      version: "v15.0",
    );
  }

  runApp(MyApp(languages: languages, body: body));
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBodyModel? body;

  const MyApp({super.key, required this.languages, required this.body});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    _route();
  }

  void _route() async {
    if (GetPlatform.isWeb) {
      Get.find<SplashController>().initSharedData();
      if (AddressHelper.getUserAddressFromSharedPref() != null &&
          AddressHelper.getUserAddressFromSharedPref()!.zoneIds == null) {
        Get.find<AuthController>().clearSharedAddress();
      }

      if (!AuthHelper.isLoggedIn() &&
          !AuthHelper
              .isGuestLoggedIn() /*&& !ResponsiveHelper.isDesktop(Get.context!)*/) {
        await Get.find<AuthController>().guestLogin();
      }

      if ((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) &&
          Get.find<SplashController>().cacheModule != null) {
        Get.find<CartController>().getCartDataOnline();
      }

      Get.find<SplashController>().getConfigData(
          loadLandingData: (GetPlatform.isWeb &&
              AddressHelper.getUserAddressFromSharedPref() == null),
          fromMainFunction: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetBuilder<SplashController>(builder: (splashController) {
          return (GetPlatform.isWeb && splashController.configModel == null)
              ? const SizedBox()
              : GetMaterialApp(
                  title: AppConstants.appName,
                  debugShowCheckedModeBanner: false,
                  navigatorKey: Get.key,
                  scrollBehavior: const MaterialScrollBehavior().copyWith(
                    dragDevices: {
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.touch
                    },
                  ),
                  theme: themeController.darkTheme ? dark() : light(),
                  locale: localizeController.locale,
                  translations: Messages(languages: widget.languages),
                  fallbackLocale: Locale(
                      AppConstants.languages[0].languageCode!,
                      AppConstants.languages[0].countryCode),
                  initialRoute: GetPlatform.isWeb
                      ? RouteHelper.getInitialRoute()
                      : RouteHelper.getSplashRoute(widget.body),
                  // : RouteHelper.getSignUpRoute(),
                  getPages: RouteHelper.routes,
                  defaultTransition: Transition.topLevel,
                  transitionDuration: const Duration(milliseconds: 500),
                  builder: (BuildContext context, widget) {
                    return MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(textScaler: const TextScaler.linear(1)),
                        child: Material(
                          child: Stack(children: [
                            widget!,
                            GetBuilder<SplashController>(
                                builder: (splashController) {
                              if (!splashController.savedCookiesData &&
                                  !splashController.getAcceptCookiesStatus(
                                      splashController.configModel != null
                                          ? splashController
                                              .configModel!.cookiesText!
                                          : '')) {
                                return ResponsiveHelper.isWeb()
                                    ? const Align(
                                        alignment: Alignment.bottomCenter,
                                        child: CookiesView())
                                    : const SizedBox();
                              } else {
                                return const SizedBox();
                              }
                            })
                          ]),
                        ));
                  },
                );
        });
      });
    });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
