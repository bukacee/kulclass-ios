import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shortie/pages/splash_screen_page/controller/splash_screen_controller.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: AppColor.transparent,
      ),
    );
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Image.asset(
            AppAsset.imgSplashScreen,
            height: Get.height,
            width: Get.width,
            fit: BoxFit.cover,
          ),
          Container(
            height: 50,
            color: AppColor.transparent,
            child: SpinKitCircle(
              color: AppColor.primary,
              size: 60,
            ),
          ).paddingOnly(bottom: 50),
          // LoadingAnimationWidget.beat(color: AppColor.primary, size: 50).paddingOnly(bottom: 50),
        ],
      ),
    );
  }
}
