import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shortie/custom/custom_image_picker.dart';
import 'package:shortie/pages/splash_screen_page/api/check_user_name_api.dart';
import 'package:shortie/pages/splash_screen_page/model/check_user_name_model.dart';
import 'package:shortie/ui/image_picker_bottom_sheet_ui.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/pages/edit_profile_page/api/edit_profile_api.dart';
import 'package:shortie/pages/edit_profile_page/model/edit_profile_model.dart';
import 'package:shortie/pages/edit_profile_page/widget/edit_profile_widget.dart';
import 'package:shortie/pages/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/internet_connection.dart';
import 'package:shortie/utils/utils.dart';

class EditProfileController extends GetxController {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController idCodeController = TextEditingController();
  TextEditingController bioDetailsController = TextEditingController();

  EditProfileModel? editProfileModel;

  bool? isValidUserName;
  RxBool isCheckingUserName = false.obs;
  CheckUserNameModel? checkUserNameModel;

  String selectedGender = "male";

  String profileImage = "";

  bool isBanned = false;

  String? pickImage;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  Future<void> init() async {
    final profile = Database.fetchLoginUserProfileModel?.user;

    profileImage = profile?.image ?? "";
    fullNameController = TextEditingController(text: profile?.name ?? "");
    userNameController = TextEditingController(text: profile?.userName ?? "");
    idCodeController = TextEditingController(text: profile?.uniqueId ?? "");
    bioDetailsController = TextEditingController(text: profile?.bio ?? "");
    selectedGender = profile?.gender?.toLowerCase() ?? "male";
    isBanned = profile?.isProfileImageBanned ?? false;

    Utils.flagController = TextEditingController(text: (profile?.countryFlagImage == null || profile?.countryFlagImage == "") ? "🇮🇳" : profile!.countryFlagImage!);

    Utils.countryController = TextEditingController(text: (profile?.country == null || profile?.country == "") ? "India" : profile!.country!);
  }

  Future<void> onChangeUserName() async {
    if (userNameController.text.trim().isNotEmpty) {
      await 500.milliseconds.delay();

      isCheckingUserName.value = true;
      checkUserNameModel = await CheckUserNameApi.callApi(loginUserId: Database.loginUserId, userName: userNameController.text.trim());
      isValidUserName = checkUserNameModel?.status ?? false;

      isCheckingUserName.value = false;
    } else {
      isValidUserName = false;
      isCheckingUserName.value = false;
    }
  }

  Future<void> onPickImage(BuildContext context) async {
    await ImagePickerBottomSheetUi.show(
      context: context,
      onClickCamera: () async {
        final imagePath = await CustomImagePicker.pickImage(ImageSource.camera);

        if (imagePath != null) {
          pickImage = imagePath;
          update(["onPickImage"]);
        }
      },
      onClickGallery: () async {
        final imagePath = await CustomImagePicker.pickImage(ImageSource.gallery);

        if (imagePath != null) {
          pickImage = imagePath;
          update(["onPickImage"]);
        }
      },
    );
  }

  Future<void> onChangeGender(String gender) async {
    selectedGender = gender;
    update(["onChangeGender"]);
  }

  Future<void> onChangeCountry(BuildContext context) async {
    CustomCountryPicker.pickCountry(context);

    await 2.seconds.delay();
    update(["onChangeCountry"]);
    await 2.seconds.delay();
    update(["onChangeCountry"]);

    Utils.showLog("Selected Country => ${Utils.flagController.text} : ${Utils.countryController.text}");
  }

  Future<void> onSaveProfile() async {
    Utils.showLog("Click On Save Profile => ${Database.loginUserId}");

    if (profileImage == "" && pickImage == null) {
      Utils.showToast(EnumLocal.txtPleaseSelectProfileImage.name.tr);
    } else if (fullNameController.text.trim().isEmpty) {
      Utils.showToast(EnumLocal.txtPleaseEnterFullName.name.tr);
    } else if (userNameController.text.trim().isEmpty) {
      Utils.showToast(EnumLocal.txtPleaseEnterUserName.name.tr);
    } else if (isValidUserName == false) {
      Utils.showToast("This username is already taken by another user.");
    }
    // else if (bioDetailsController.text.trim().isEmpty) { //  TODO => This is use to Validation...
    //   Utils.showToast(EnumLocal.txtPleaseEnterBioDetails.name.tr);
    // }
    else {
      if (InternetConnection.isConnect.value) {
        Get.dialog(PopScope(canPop: false, child: const LoadingUi()), barrierDismissible: false); // Start Loading...
        editProfileModel = await EditProfileApi.callApi(
          image: pickImage,
          loginUserId: Database.loginUserId,
          name: fullNameController.text,
          userName: userNameController.text,
          country: Utils.countryController.text,
          bio: bioDetailsController.text,
          gender: selectedGender,
          countryFlagImage: Utils.flagController.text,
        );
        Get.back(); // Stop Loading...
        if (editProfileModel?.status == true && editProfileModel?.user?.name != null) {
          Utils.showToast(EnumLocal.txtProfileUpdateSuccessfully.name.tr);
          Get.back();
          Database.fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(loginUserId: Database.loginUserId);
        } else {
          Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
        }
      } else {
        Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
        Utils.showLog("Internet Connection Lost !!");
      }
    }
  }
}
