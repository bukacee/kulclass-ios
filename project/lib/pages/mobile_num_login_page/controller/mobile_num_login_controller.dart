import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/utils.dart';

class MobileNumLoginController extends GetxController {
  TextEditingController mobileController = TextEditingController();

  String countryCode = "91";

  String verificationId = "";

  bool isLoading = false;

  Future<void> onVerify() async {
    FocusManager.instance.primaryFocus?.unfocus();

    Utils.showLog("Mobile Number => ${mobileController.text}");

    if (mobileController.text.trim().isEmpty) {
      Utils.showToast(EnumLocal.txtPleaseEnterMobileNumber.name.tr, AppColor.coloGreyText);
    } else {
      final String phoneNumber = "+$countryCode${mobileController.text.trim()}";

      try {
        isLoading = true;
        Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) {
            Utils.showLog("Verification Complete");
          },
          verificationFailed: (FirebaseAuthException e) {
            if (e.code == "invalid-phone-number") {
              Utils.showToast(EnumLocal.txtPleaseEnterCorrectMobileNumber.name.tr, AppColor.coloGreyText);
            } else {
              Utils.showLog("Verification Mobile Number Failed => $e");
              Utils.showToast(e.message ?? "");
            }

            if (Get.currentRoute == AppRoutes.mobileNumLoginPage && isLoading) {
              Get.back(); // Start Loading...
              isLoading = false;
              Utils.showLog("Verification Failed => $e");
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            this.verificationId = verificationId;

            Utils.showToast(EnumLocal.txtVerificationCodeSend.name.tr, AppColor.coloGreyText);

            if (Get.currentRoute == AppRoutes.mobileNumLoginPage && isLoading) {
              Get.back(); // Start Loading...
              isLoading = false;
              Utils.showLog("Verification Id => ${this.verificationId}");
            }

            Get.toNamed(AppRoutes.verificationOtpPage, arguments: {"phoneNumber": phoneNumber, "verificationId": verificationId});
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            if (Get.currentRoute == AppRoutes.mobileNumLoginPage && isLoading) {
              Get.back(); // Start Loading...
              isLoading = false;
              Utils.showLog("Time Out Otp => ${verificationId}");
              Utils.showToast(EnumLocal.txtVerificationTimeout.name.tr, AppColor.coloGreyText);
            }
          },
        );
      } catch (e) {
        if (Get.currentRoute == AppRoutes.mobileNumLoginPage && isLoading) {
          Get.back(); // Start Loading...
          isLoading = false;
          Utils.showLog("Verification Mobile Number Failed => $e");
        }
      }
    }
  }
}
