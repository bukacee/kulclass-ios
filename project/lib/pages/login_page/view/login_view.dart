import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:auralive/main.dart';
import 'package:auralive/pages/login_page/controller/login_controller.dart';
import 'package:auralive/routes/app_routes.dart';
import 'package:auralive/utils/asset.dart';
import 'package:auralive/utils/size_extension.dart';
import 'package:auralive/utils/color.dart';
import 'package:auralive/utils/constant.dart';
import 'package:auralive/utils/enums.dart';
import 'package:auralive/utils/font_style.dart';
import 'package:auralive/utils/utils.dart'; // Ensure Utils is imported for showToast
import 'package:url_launcher/url_launcher.dart'; 

class LoginView extends GetView<LoginController> {
  LoginView({super.key});

  // ✅ 1. Local State for the Checkbox
  final RxBool isAgreed = false.obs;

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
                  
                  // -------------------------------------------------------------
                  // ✅ 2. Terms & Conditions Checkbox Area
                  // -------------------------------------------------------------
                  20.height,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: isAgreed.value,
                            activeColor: AppColor.primary,
                            side: BorderSide(color: AppColor.white, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (value) {
                              isAgreed.value = value ?? false;
                            },
                          ),
                        ),
                      ),
                      10.width,
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: "I agree to the ",
                            style: AppFontStyle.styleW400(AppColor.white.withOpacity(0.8), 12),
                            children: [
                              TextSpan(
                                text: "Terms of Service",
                                style: AppFontStyle.styleW600(AppColor.primary, 12).copyWith(decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    final Uri url = Uri.parse("https://kulclass.com/terms");
      if (!await launchUrl(url)) {
        Utils.showToast("Could not launch Terms URL");
      }
                                  },
                              ),
                              TextSpan(
                                text: " and ",
                                style: AppFontStyle.styleW400(AppColor.white.withOpacity(0.8), 12),
                              ),
                              TextSpan(
                                text: "Privacy Policy",
                                style: AppFontStyle.styleW600(AppColor.primary, 12).copyWith(decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Open Privacy URL
                                    final Uri url = Uri.parse("https://kulclass.com/terms");
      if (!await launchUrl(url)) {
        Utils.showToast("Could not launch Terms URL");
      }
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // -------------------------------------------------------------

                  20.height,

                  // --- Quick Login Button ---
                  GestureDetector(
                    onTap: () {
                      // ✅ Check Agreement before Logging in
                      if (isAgreed.value) {
                        controller.onQuickLogin();
                      } else {
                        Utils.showToast("Please agree to the Terms & Guidelines first.");
                      }
                    },
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

                  // --- Divider ---
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColor.white.withOpacity(0.15))),
                      15.width,
                      Text(
                        EnumLocal.txtOr.name.tr,
                        style: AppFontStyle.styleW600(AppColor.white, 12),
                      ),
                      15.width,
                      Expanded(child: Divider(color: AppColor.white.withOpacity(0.15))),
                    ],
                  ),

                  15.height,

                  // --- Google Login Button ---
                  GestureDetector(
                    onTap: () {
                      // ✅ Check Agreement before Logging in
                      if (isAgreed.value) {
                        controller.onGoogleLogin();
                      } else {
                        Utils.showToast("Please agree to the Terms & Guidelines first.");
                      }
                    },
                    child: Container(
                      height: 56,
                      width: Get.width,
                      padding: EdgeInsets.only(left: 6, right: 52),
                      decoration: BoxDecoration(
                        color: AppColor.colorDarkPink,
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
                            child: Center(child: Image.asset(AppAsset.icGoogleLogo, width: 32)),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                EnumLocal.txtGoogle.name.tr,
                                style: AppFontStyle.styleW600(AppColor.white, 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  10.height,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}