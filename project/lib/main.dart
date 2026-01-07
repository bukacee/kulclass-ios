import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// Removed: in_app_purchase import

import 'package:auralive/localization/locale_constant.dart';
import 'package:auralive/localization/localizations_delegate.dart';
import 'package:auralive/routes/app_pages.dart';
import 'package:auralive/routes/app_routes.dart';
import 'package:auralive/utils/color.dart';
import 'package:auralive/utils/constant.dart';
import 'package:auralive/utils/database.dart';
import 'package:auralive/utils/enums.dart';
import 'package:auralive/utils/internet_connection.dart';
import 'package:auralive/utils/notification_services.dart';
import 'package:auralive/utils/platform_device_id.dart';
import 'package:auralive/utils/utils.dart';

void main() async {
  // 1. Initialize Bindings ONLY
  WidgetsFlutterBinding.ensureInitialized();


  // 2. Init Storage (Fast)
  await GetStorage.init();

  
  await InternetConnection.init();
  

  
  // 3. Init Firebase (Required before app runs, usually fast enough)
  await Firebase.initializeApp();
  
  // 4. Setup Crashlytics (Fast)
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // 5. DO NOT wait for Device ID or FCM Token here.
  // Just launch the app. The Splash Screen will handle the rest.
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // Removed: purchaseStreamController

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
    if (state == AppLifecycleState.resumed) {
      Utils.isAppOpen.value = true;
      Utils.showLog("User Back To App...");
    }
    if (state == AppLifecycleState.inactive) {
      Utils.isAppOpen.value = false;
      Utils.showLog("User Try To Exit...");
    }
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        Utils.showLog("Preference LanguageCode => ${locale.languageCode}");
        Utils.showLog("GetX locale LanguageCode => ${Get.locale?.languageCode ?? ""}");
        Get.updateLocale(locale);
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: EnumLocal.txtAppName.name.tr,
      debugShowCheckedModeBanner: false,
      color: AppColor.white,
      translations: AppLanguages(),
      fallbackLocale: const Locale(AppConstant.languageEn, AppConstant.countryCodeEn),
      locale: const Locale(AppConstant.languageEn),
      defaultTransition: Transition.fade,
      getPages: AppPages.list,
      initialRoute: AppRoutes.initial,
    );
  }
}

// >>>>>> >>>>>> Sized Box Extension <<<<<< <<<<<<

extension HeightExtension on num {
  SizedBox get height => SizedBox(height: toDouble());
}

extension WidthExtension on num {
  SizedBox get width => SizedBox(width: toDouble());
}

Future<void> onInitializeCrashlytics() async {
  try {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    Utils.showLog("Initialize Crashlytics Failed !! => $e");
  }
}

Future<void> onInitializeBranchIo() async {
  try {
    await FlutterBranchSdk.init().then((value) {
      FlutterBranchSdk.validateSDKIntegration();
    });
  } catch (e) {
    Utils.showLog("Initialize Branch Io Failed !! => $e");
  }
}