import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/main.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';

class MyWalletAppBar extends StatelessWidget {
  const MyWalletAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: AppColor.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                    color: AppColor.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Image.asset(AppAsset.icBack, width: 25)),
                ),
              ),
              5.width,
              Text(
                EnumLocal.txtMyWallet.name.tr,
                style: AppFontStyle.styleW700(AppColor.black, 19),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.withdrawPage);
                },
                child: Container(
                  height: 38,
                  width: 116,
                  decoration: BoxDecoration(
                    gradient: AppColor.primaryLinearGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AppAsset.icWithdraw, width: 22),
                      5.width,
                      Text(
                        EnumLocal.txtWithdraw.name.tr,
                        style: AppFontStyle.styleW600(AppColor.white, 14),
                      ),
                    ],
                  ),
                ),
              ),
              10.width,
            ],
          ),
        ),
      ),
    );
  }
}
