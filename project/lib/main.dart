import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';
import 'package:auralive/pages/splash_screen_page/api/admin_setting_api.dart';
import 'package:auralive/localization/locale_constant.dart';
import 'package:auralive/localization/localizations_delegate.dart';
import 'package:auralive/routes/app_pages.dart';
import 'package:auralive/routes/app_routes.dart';
import 'package:auralive/utils/color.dart';
import 'package:auralive/size_extension.dart';
import 'package:auralive/utils/constant.dart';
import 'package:auralive/utils/database.dart';
import 'package:auralive/utils/enums.dart';
import 'package:auralive/utils/internet_connection.dart';
import 'package:auralive/utils/notification_services.dart';
import 'package:auralive/utils/platform_device_id.dart';
import 'package:auralive/utils/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:auralive/pages/login_page/controller/login_controller.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';


Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    try {
      Utils.showLog(">>> Initializing Firebase in BACKGROUND...");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e, s) {
      Utils.showLog("Firebase BACKGROUND init failed: $e");
      await FirebaseCrashlytics.instance.recordError(e, s, fatal: true);
      return;
    }
  }
  Utils.showLog("🔥 Background message: ${message.messageId}");
}

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    Utils.showLog("=== App starting... ===");

    try {
      Utils.showLog(">>> Firebase initializing...");
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      Utils.showLog("✅ Firebase initialized");

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await onInitializeCrashlytics();

      Utils.showLog(">>> Notification services initializing...");
      await NotificationServices.init();
      
      
      // New APNS Check block (required for iOS FCM reliability)
      if (Platform.isIOS) {
          try {
              // This call ensures the APNS token is fetched from the OS
              // before we proceed with FCM token generation/usage.
              String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
              if (apnsToken != null) {
                  Utils.showLog('✅ APNS Token retrieved successfully.');
              } else {
                  Utils.showLog('⚠️ APNS Token is null. (May be normal on simulator, or check Xcode capabilities)');
              }
          } catch (e) {
              Utils.showLog('❌ Error calling getAPNSToken(): $e');
          }
      }
      // ----------------------------------------------------
      
      
      
      // Mock FCM token refresh (for now just use random value)
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        Database.onSetFcmToken(newToken);
        Utils.showLog("🔄 FCM Token refreshed: $newToken");
      });

      Utils.showLog("✅ Notifications initialized");
      Utils.showLog(">>> Initializing Google Mobile Ads...");
      await MobileAds.instance.initialize();
      Utils.showLog("✅ Google Mobile Ads initialized");

    } catch (e, s) {
      Utils.showLog("❌ Firebase/Notification Init Failed: $e");
      await FirebaseCrashlytics.instance.recordError(e, s, fatal: true);
      return _fatalFallback(e);
    }

    try {
      Utils.showLog(">>> GetStorage init...");
      await GetStorage.init();
      Utils.showLog("✅ GetStorage done");

      Utils.showLog(">>> Internet connection init...");
      await InternetConnection.init();
      Utils.showLog("✅ Internet connection done");

      Utils.showLog(">>> Branch IO init...");
      await onInitializeBranchIo();
      Utils.showLog("✅ Branch IO done");
    } catch (e, s) {
      Utils.showLog("❌ Branch/Storage/Network Init Failed: $e");
      await FirebaseCrashlytics.instance.recordError(e, s);
    }
      
      
     
     // ... Code after Branch IO init block

// <<< START DEFERRED INITIALIZATION BLOCK >>>
Future.delayed(const Duration(seconds: 1), () async {
    // This code now runs asynchronously, preventing main thread hang

    try {
        Utils.showLog(">>> Platform IDs fetching (DEFERRED)...");

       // Initialize database with random identity and fake FCM token
await Database.init(); // use stored values if available


Utils.showLog("✅ Database initialized successfully with random identity and FCM token");
Utils.showLog("DeviceID: ${Database.identity} | Token: ${Database.fcmToken}");

    
 
        // Fetch stored identity and token after init to display and use
        final storedIdentity = Database.identity;
        final storedFcmToken = Database.fcmToken;

        Utils.showLog("Final stored Identity: $storedIdentity");
        Utils.showLog("Final stored FCM Token: $storedFcmToken");

 

    } catch (e, s) {
        Utils.showLog("❌ Error during PlatformID/Database.init (DEFERRED): $e");
        await FirebaseCrashlytics.instance.recordError(e, s);
    }
    
    // --- Admin Settings & Zego Init (DEPENDS ON PREVIOUS STEP) ---
    try {
        Utils.showLog(">>> Admin Settings fetching (DEFERRED)...");
        await AdminSettingsApi.callApi();
        Utils.showLog("✅ Admin Settings fetched");

        if (AdminSettingsApi.adminSettingModel?.data != null) {
            Utils.showLog(">>> Initializing Zego engine...");
            await Utils.onInitCreateEngine();
            Utils.showLog("✅ Zego engine initialized");
        } else {
            Utils.showLog("⚠️ Admin settings data null — skipping Zego");
        }
    } catch (e, s) {
        Utils.showLog("❌ AdminSettings/Zego Init Failed (DEFERRED): $e");
        await FirebaseCrashlytics.instance.recordError(e, s);
    }

});
   

   
    
    
    
    Utils.showLog(">>> Injecting LoginController into GetX...");
final loginController = Get.put(LoginController());
Utils.showLog("✅ LoginController injected");

// Default to onboarding
String initialRoute = AppRoutes.onBoardingPage;

if (Database.identity.isNotEmpty) {
  Utils.showLog("Existing identity found: ${Database.identity}. Attempting quick login...");
  try {
    await loginController.onQuickLogin();

    if (Database.fetchLoginUserProfileModel?.user?.id != null) {
      initialRoute = AppRoutes.bottomBarPage;
      Utils.showLog("Quick login successful. Routing to bottom bar page.");
    } else {
      Utils.showLog("Quick login failed. Staying on onboarding.");
    }
  } catch (e) {
    Utils.showLog("Quick login error: $e");
    // Stay on onboarding
  }
} else {
  Utils.showLog("No stored identity. Routing to onboarding page.");
}





// --- APPLE LOGIN BLOCK ---  <-- ADD THIS RIGHT HERE
if (initialRoute == AppRoutes.onBoardingPage) {
  Utils.showLog("Attempting silent Apple login...");

  try {
    bool canAppleLogin = await loginController.canAutoLoginWithApple();
    if (canAppleLogin) {
      await loginController.onAppleLogin(auto: true); // silent login
      if (Database.fetchLoginUserProfileModel?.user?.id != null) {
        initialRoute = AppRoutes.bottomBarPage;
        Utils.showLog("Silent Apple login successful. Routing to bottom bar page.");
      } else {
        Utils.showLog("Silent Apple login failed. Staying on onboarding.");
      }
    } else {
      Utils.showLog("Apple silent login not possible.");
    }
  } catch (e) {
    Utils.showLog("Silent Apple login error: $e");
    // Stay on onboarding
  }
}






// Launch app
Utils.showLog("🚀 Launching MyApp with route: $initialRoute");
runApp(MyApp(initialRoute: initialRoute));
    
    
    
    
    
    
    

  }, (error, stack) {
    Utils.showLog("💥 FATAL (runZonedGuarded): $error");
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

Widget _fatalFallback(Object e) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Text("Startup failed: $e"),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    Utils.isAppOpen.value = true;
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    Utils.isAppOpen.value = false;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Utils.showLog("App lifecycle: $state");
    Utils.isAppOpen.value = state == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        Get.updateLocale(locale);
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColor.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    return GetMaterialApp(
      title: EnumLocal.txtAppName.name.tr,
      debugShowCheckedModeBanner: false,
      color: AppColor.white,
      translations: AppLanguages(),
      fallbackLocale:
          const Locale(AppConstant.languageEn, AppConstant.countryCodeEn),
      locale: const Locale(AppConstant.languageEn),
      defaultTransition: Transition.fade,
      getPages: AppPages.list,
      initialRoute: widget.initialRoute,
    );
  }
}

Future<void> onInitializeCrashlytics() async {
  try {
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  } catch (e) {
    Utils.showLog("Crashlytics Init Failed: $e");
  }
}

Future<void> onInitializeBranchIo() async {
  try {
    await FlutterBranchSdk.init();
    if (kDebugMode) {
      FlutterBranchSdk.validateSDKIntegration();
    }
  } catch (e) {
    Utils.showLog("Branch IO Init Failed: $e");
  }
}