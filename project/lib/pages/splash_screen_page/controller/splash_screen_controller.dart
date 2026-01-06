import 'dart:async';

import 'package:get/get.dart';
import 'package:shortie/pages/splash_screen_page/api/admin_setting_api.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/utils/branch_io_services.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/internet_connection.dart';
import 'package:shortie/utils/request.dart';
import 'package:shortie/utils/utils.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    init();
    super.onInit();
  }

  Future<void> init() async {
    await AppRequest.notificationPermission();

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
