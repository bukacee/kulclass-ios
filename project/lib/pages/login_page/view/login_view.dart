import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:auralive/main.dart';
import 'package:auralive/pages/login_page/controller/login_controller.dart';
import 'package:auralive/routes/app_routes.dart';
import 'package:auralive/utils/asset.dart';
import 'package:auralive/utils/color.dart';
import 'package:auralive/size_extension.dart';
import 'package:auralive/utils/constant.dart';
import 'package:auralive/utils/enums.dart';
import 'package:auralive/utils/font_style.dart';
import 'package:auralive/utils/database.dart';
import 'package:auralive/utils/internet_connection.dart';
import 'package:auralive/utils/utils.dart';


class LoginView extends GetView<LoginController> {
  LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    Future.delayed(
      Duration(milliseconds: 300),
      () => SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppColor.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
    );
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(AppAsset.imgLoginBg, height: Get.height, width: Get.width, fit: BoxFit.cover),
          Positioned(
            bottom: 0,
            child: Container(
              height: 600,
              width: Get.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.transparent, AppColor.black, AppColor.black, AppColor.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SizedBox(
            height: Get.height,
            width: Get.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    AppAsset.icAppIcon,
                    height: 180,
                    width: 180,
                  ),
                  25.height,
                  SizedBox(
                    width: Get.width / 1.2,
                    child: Text(
                      EnumLocal.txtLoginTitle.name.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 33,
                        color: AppColor.white,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w900,
                        fontFamily: AppConstant.appFontBold,
                      ),
                    ),
                  ),
                  5.height,
                  Text(
                    EnumLocal.txtLoginSubTitle.name.tr,
                    textAlign: TextAlign.center,
                    style: AppFontStyle.styleW400(AppColor.white, 14),
                  ),
                  20.height,
                  GestureDetector(
                    onTap: controller.onQuickLogin,
                    child: Container(
                      height: 56,
                      width: Get.width,
                      padding: EdgeInsets.only(left: 6, right: 52),
                      decoration: BoxDecoration(
                        gradient: AppColor.primaryLinearGradient,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: AppColor.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Image.asset(AppAsset.icQuickLogo, width: 24)),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                EnumLocal.txtQuickLogIn.name.tr,
                                style: AppFontStyle.styleW600(AppColor.white, 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  15.height,
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColor.white.withValues(alpha: 0.15))),
                      15.width,
                      Text(
                        EnumLocal.txtOr.name.tr,
                        style: AppFontStyle.styleW600(AppColor.white, 12),
                      ),
                      15.width,
                      Expanded(child: Divider(color: AppColor.white.withValues(alpha: 0.15))),
                    ],
                  ),
 //                 15.height,
// Row(
 // children: [
    // Mobile Login Button (Now occupies the full width)
    //     Expanded(
      //     child: GestureDetector(
        //     onTap: () => Get.toNamed(AppRoutes.mobileNumLoginPage),
        //     child: Container(
          //     height: 56,
               // Removed horizontal padding to let the inner row control alignment
          //     padding: EdgeInsets.symmetric(horizontal: 20),
          //     decoration: BoxDecoration(
            //     gradient: AppColor.primaryLinearGradient, // Use primary gradient for prominence
            //     borderRadius: BorderRadius.circular(30),
          //     ),
          //     child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center, // Center content horizontally
            //     children: [
              //     Container(
                //     height: 46,
                //     width: 46,
                //     decoration: BoxDecoration(
                  //     color: AppColor.white,
                  //     shape: BoxShape.circle,
                //     ),
                //     child: Center(
                  //     child: Image.asset(AppAsset.icMobile, width: 32),
                //     ),
              //     ),
              //     10.width, // Add spacing between icon and text
              //     Text(
                //     EnumLocal.txtMobile.name.tr,
                //     style: AppFontStyle.styleW600(AppColor.white, 16),
              //     ),
            //     ],
          //     ),
        //     ),
      //     ),
    //     ),
  //     ],
//     ),
                  10.height,
                 
                 
                 
                 
                 
                 
                 // ElevatedButton(
  // onPressed: () {
    // final logs = Utils.getLogs();  

    // Get.defaultDialog(
      // title: "Debug Info",
      // content: SizedBox(
        // height: 300, // adjust height as needed
        // child: SingleChildScrollView(
          // child: Column(
           //  crossAxisAlignment: CrossAxisAlignment.start,
            // children: [
             //  Text("Identity: ${Database.identity}"),
             //  Text("FCM Token: ${Database.fcmToken}"),
             //  Text("Connected: ${InternetConnection.isConnect.value}"),
             //  Text("API Response: ${controller.loginModel?.toJson()}"),
             //  const SizedBox(height: 10),
              // const Text(
                
                /// style: TextStyle(fontWeight: FontWeight.bold),
              // ),
               // Text(
                // logs.isEmpty ? "No logs captured yet." : logs,
                //style: const TextStyle(fontSize: 12),
              // ),
            // ],
          // ),
        // ),
      // ),
    // );
  // },
  // child: const Text("Show Debug Info"), 
// ),
                 
                 
                 
                 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
