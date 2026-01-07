import 'dart:async';

import 'package:get/get.dart';
import 'package:auralive/pages/splash_screen_page/api/admin_setting_api.dart';
import 'package:auralive/routes/app_routes.dart';
import 'package:auralive/utils/branch_io_services.dart';
import 'package:auralive/utils/database.dart';
import 'package:auralive/utils/enums.dart';
import 'package:auralive/utils/internet_connection.dart';
import 'package:auralive/utils/request.dart';
import 'package:auralive/utils/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:auralive/utils/platform_device_id.dart';
import 'package:get_storage/get_storage.dart'; 


class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> init() async {
    // 1. Initialize standard stuff
    await AppRequest.notificationPermission();
    
    // 2. Initialize Device ID & Push (Safe)
    await _initializeDeviceAndPush();

    // 3. Start the "Connectivity Check Loop"
    // Instead of checking once and failing, this will keep checking until it succeeds.
    _checkConnectionAndProceed();
  }

  // ✅ NEW: Recursive function to handle connection retries
  Future<void> _checkConnectionAndProceed() async {
    if (InternetConnection.isConnect.value) {
      // We have internet! Proceed to API calls.
      await _fetchAdminSettings();
    } else {
      // No internet. Show toast and retry.
      Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
      Utils.showLog("Internet Connection Lost !! Retrying in 2 seconds...");

      // WAIT 2 SECONDS AND TRY AGAIN
      await Future.delayed(const Duration(seconds: 2));
      _checkConnectionAndProceed(); // <--- This line creates the loop
    }
  }

  // ✅ NEW: Extracted API logic for cleaner code
  Future<void> _fetchAdminSettings() async {
    await AdminSettingsApi.callApi(); // Get Admin Setting Data...

    if (AdminSettingsApi.adminSettingModel?.data != null) {
      await Utils.onInitCreateEngine(); // Init Live...
      await Utils.onInitPayment(); // Init Payment...

      await splashScreen();
    } else {
      // API Failed. Show error.
      // OPTIONAL: You could also add a retry here if you want.
      Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
      Utils.showLog("Admin Setting Api Calling Failed !!");
      
      // If the API fails completely, you might want to retry this step too:
      // await Future.delayed(Duration(seconds: 3));
      // _fetchAdminSettings();
    }
  }


Future<void> _initializeDeviceAndPush() async {
  try {
    final box = GetStorage();
    String? finalIdentity;

    // 1. Check if we already have a saved ID from a previous launch
    String? savedId = box.read('persistent_device_id');

    if (savedId != null && savedId.isNotEmpty) {
      // ✅ FOUND: Use the existing ID (The app "remembers" the user)
      finalIdentity = savedId;
      Utils.showLog("Using saved persistent ID => $finalIdentity");
    } else {
      // ❌ NOT FOUND: This is the first launch (or cache cleared)
      
      // Try to get real Device ID from OS
      String? platformId = await PlatformDeviceId.getDeviceId;

      if (platformId != null && platformId.isNotEmpty) {
        finalIdentity = platformId;
      } else {
        // Fallback: Generate a random ID once
        finalIdentity = "ios_id_${DateTime.now().millisecondsSinceEpoch}";
      }

      // 💾 SAVE IT: Store this ID so we reuse it next time
      await box.write('persistent_device_id', finalIdentity);
      Utils.showLog("Generated and saved new ID => $finalIdentity");
    }

    // 2. Get FCM Token
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    
    // 3. Initialize Database with the STABLE identity
    await Database.init(finalIdentity, fcmToken ?? "");
    
    // 4. Init Branch
    await FlutterBranchSdk.init();

  } catch (e) {
    Utils.showLog("Error initializing device/push: $e");
  }
}
  Future<void> splashScreen() async {
    Timer(
      const Duration(milliseconds: 100),
      () {
        // Check User Is Login Or Not...
        if (Database.isNewUser == false && Database.fetchLoginUserProfileModel?.user?.id != null) {
          BranchIoServices.onListenBranchIoLinks();
          Get.offAllNamed(AppRoutes.bottomBarPage);
        } else {
          Get.offAllNamed(AppRoutes.onBoardingPage);
        }
      },
    );
  }
}