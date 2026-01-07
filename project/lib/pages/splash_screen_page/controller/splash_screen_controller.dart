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

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> init() async {
    // 1. Initialize standard stuff
    await AppRequest.notificationPermission();
    
    // 2. MOVE THE MAIN.DART LOGIC HERE
    await _initializeDeviceAndPush();

    // 3. Proceed with your existing Admin/API checks
    if (InternetConnection.isConnect.value) {
      await AdminSettingsApi.callApi(); // Get Admin Setting Data...
      if (AdminSettingsApi.adminSettingModel?.data != null) {
        await Utils.onInitCreateEngine(); // Init Live...

        await Utils.onInitPayment(); // Init Payment...

        await splashScreen();
      } else {
        Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
        Utils.showLog("Admin Setting Api Calling Failed !!");
      }
    } else {
      Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
      Utils.showLog("Internet Connection Lost !!");
    }
  }


  Future<void> _initializeDeviceAndPush() async {
    try {
      // Get Device ID safely
      String? identity = await PlatformDeviceId.getDeviceId;
      
      // Get FCM Token
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      
      Utils.showLog("Device Id => $identity");
      
      if (identity != null) {
        // Now init your DB
        await Database.init(identity, fcmToken ?? "");
      }
    } catch (e) {
      Utils.showLog("Error initializing device/push: $e");
    }
  }

  Future<void> splashScreen() async {
    Timer(
      Duration(milliseconds: 100),
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
