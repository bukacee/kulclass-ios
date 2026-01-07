import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auralive/ui/preview_network_image_ui.dart';
import 'package:auralive/ui/app_button_ui.dart';
import 'package:auralive/main.dart';
import 'package:auralive/pages/fill_profile_page/controller/fill_profile_controller.dart';
import 'package:auralive/pages/fill_profile_page/widget/fill_profile_widget.dart';
import 'package:auralive/utils/asset.dart';
import 'package:auralive/utils/color.dart';
import 'package:auralive/size_extension.dart';
import 'package:auralive/utils/database.dart';
import 'package:auralive/utils/enums.dart';
import 'package:auralive/utils/font_style.dart';

class FillProfileView extends GetView<FillProfileController> {
  const FillProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => Database.onLogOut(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColor.white,
          shadowColor: AppColor.black.withOpacity(0.4),
          surfaceTintColor: AppColor.transparent,
          flexibleSpace: FillProfileAppBarUi(title: EnumLocal.txtFillProfile.name.tr),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                15.height,


                Center(
  child: Column(
    children: [
      Container(
        height: 124,
        width: 124,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColor.colorBorder,
            width: 1.5,
          ),
        ),
        child: ClipOval(
          child: controller.profileImage.isNotEmpty
              ? PreviewNetworkImageUi(image: controller.profileImage)
              : Image.asset(
                  AppAsset.icProfilePlaceHolder, // optional local fallback
                  fit: BoxFit.cover,
                ),
        ),
      ),
      14.height,
Text(
  "New user? Clear the dummy data and enter your details to sign up.\n"
  "If you already have an account and this is a new device, enter your registered details to log in.\n"
  "If you have used this device before, simply save your profile.",
  textAlign: TextAlign.center,
  style: AppFontStyle.styleW400(
    AppColor.coloGreyText,
    13,
  ),
),

    ],
  ),
),

                

                40.height,
                FillProfileFieldUi(
                  enabled: true,
                  title: EnumLocal.txtFullName.name.tr,
                  maxLines: 1,
                  keyboardType: TextInputType.name,
                  controller: controller.fullNameController,
                  contentTopPadding: 15,
                  suffixIcon: SizedBox(
                    height: 20,
                    width: 20,
                    child: Center(
                      child: Image.asset(AppAsset.icEditPen, height: 20, width: 20),
                    ),
                  ),
                ),
                15.height,
                UserNameFieldUi(
                  enabled: true,
                  contentPadding: 15,
                  keyboardType: TextInputType.name,
                  controller: controller.userNameController,
                  title: "Username: (Please do not use symbols eg. @).",
                  maxLines: 1,
                  onChange: (p0) => controller.onChangeUserName(),
                  suffixIcon: SizedBox(
                    height: 20,
                    width: 20,
                    child: Obx(
                      () => Center(
                        child: controller.isCheckingUserName.value
                            ? Padding(
                                padding: const EdgeInsets.all(15),
                                child: CircularProgressIndicator(color: AppColor.primary, strokeWidth: 3),
                              )
                            : controller.isValidUserName == null
                                ? Image.asset(AppAsset.icEditPen, height: 20, width: 20)
                                : controller.isValidUserName == true
                                    ? Icon(
                                        Icons.done_all,
                                        color: AppColor.colorClosedGreen,
                                      )
                                    : Image.asset(AppAsset.icClose, color: Colors.red, height: 20, width: 20),
                      ),
                    ),
                  ),
                ),
                
15.height,
FillProfileFieldUi(
  enabled: true, // ✅ required
  controller: controller.tempPasswordController,
  keyboardType: TextInputType.visiblePassword,
  title: "Password (for new devices only)",
  maxLines: 1,
  contentTopPadding: 5,
),


                15.height,
                FillProfileFieldUi(
                  enabled: false,
                  keyboardType: TextInputType.number,
                  controller: controller.idCodeController,
                  title: EnumLocal.txtIdentificationCode.name.tr,
                  maxLines: 1,
                  contentTopPadding: 5,
                ),

                15.height,
                GetBuilder<FillProfileController>(
                  id: "onChangeCountry",
                  builder: (controller) => FillProfileCountyFieldUi(
                    title: EnumLocal.txtCountry.name.tr,
                    flag: controller.selectedCountry["flag"]!,
                    country: controller.selectedCountry["name"]!,
                  ),
                ),
                15.height,
                FillProfileFieldUi(
                  enabled: true,
                  keyboardType: TextInputType.text,
                  controller: controller.bioDetailsController,
                  title: EnumLocal.txtBioDetails.name.tr,
                  contentTopPadding: 5,
                  height: 100,
                  isOptional: true,
                  maxLines: 3,
                ),
                15.height,
   //             Text(
   //               EnumLocal.txtGender.name.tr,
   //               style: AppFontStyle.styleW500(AppColor.coloGreyText, 14),
   //             ),
  //              5.height,
  //              GetBuilder<FillProfileController>(
  //                id: "onChangeGender",
  //                builder: (logic) => Row(
  //                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                  children: [
  //                    FillProfileRadioItem(
  //                      isSelected: logic.selectedGender == "male",
  //                      title: EnumLocal.txtMale.name.tr,
  //                      callback: () => logic.onChangeGender("male"),
  //                    ),
  //                    FillProfileRadioItem(
  //                      isSelected: logic.selectedGender == "female",
  //                      title: EnumLocal.txtFemale.name.tr,
  //                      callback: () => logic.onChangeGender("female"),
  //                    ),
  //                    FillProfileRadioItem(
  //                      isSelected: logic.selectedGender == "other",
  //                      title: EnumLocal.txtOther.name.tr,
  //                      callback: () => logic.onChangeGender("other"),
  //                    ),
  //                  ],
  //                ),
  //              ),
                15.height,
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          child: AppButtonUi(
            height: 56,
            color: AppColor.primary,
            title: EnumLocal.txtSaveProfile.name.tr,
            gradient: AppColor.primaryLinearGradient,
            fontSize: 18,
            callback: controller.onSaveProfile,
          ),
        ),
      ),
    );
  }
}
