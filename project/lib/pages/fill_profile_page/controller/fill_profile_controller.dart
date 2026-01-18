import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:auralive/custom/custom_image_picker.dart';
import 'package:auralive/pages/splash_screen_page/api/check_user_name_api.dart';
import 'package:auralive/pages/splash_screen_page/model/check_user_name_model.dart';
import 'package:auralive/ui/image_picker_bottom_sheet_ui.dart';
import 'package:auralive/ui/loading_ui.dart';
import 'package:auralive/pages/edit_profile_page/api/edit_profile_api.dart';
import 'package:auralive/pages/edit_profile_page/model/edit_profile_model.dart';
import 'package:auralive/pages/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:auralive/routes/app_routes.dart';
import 'package:auralive/utils/custom_username.dart';
import 'package:auralive/utils/size_extension.dart';
import 'package:auralive/utils/database.dart';
import 'package:auralive/utils/enums.dart';
import 'package:auralive/utils/internet_connection.dart';
import 'package:auralive/utils/utils.dart';

class FillProfileController extends GetxController {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController idCodeController = TextEditingController();
  TextEditingController bioDetailsController = TextEditingController();

  

Map<String, String> selectedCountry = {"flag": "🇺🇸", "name": "United States"};


  String selectedGender = "male";

  EditProfileModel? editProfileModel;

  String profileImage = "";

  String? pickImage;

  bool? isValidUserName;
  RxBool isCheckingUserName = false.obs;
  CheckUserNameModel? checkUserNameModel;

  int randomNumber = 00;

  @override
  void onInit() {
    init();
    super.onInit();
  }

 Future<void> init() async {
    final profile = Database.fetchLoginUserProfileModel?.user;

    profileImage = profile?.image ?? "";

    // ✅ FIX: CHECK ARGUMENTS FOR GOOGLE/APPLE NAME
    String nameFromArgs = "";
    if (Get.arguments != null && Get.arguments is Map) {
       nameFromArgs = Get.arguments['socialName'] ?? "";
    }

    // Use DB Name if available, otherwise use Social Name, otherwise empty
    String finalName = (profile?.name != null && profile!.name!.isNotEmpty) 
        ? profile!.name! 
        : nameFromArgs;

    fullNameController = TextEditingController(text: finalName);

    // ✅ LOGIC: If username exists in DB, use it. 
    // If not, try to generate one from the Full Name we just found.
    if (profile?.userName != null && profile!.userName!.isNotEmpty) {
       userNameController = TextEditingController(text: profile!.userName!);
    } else {
       // Only generate a random username if we actually have a name to base it on
       if (finalName.isNotEmpty) {
          userNameController.text = await RandomNumberFormatter().formatFinalText(finalName, randomNumber);
       } else {
          userNameController.text = "";
       }
    }
    
    idCodeController = TextEditingController(text: profile?.uniqueId ?? "");
    bioDetailsController = TextEditingController(text: profile?.bio ?? "");
    selectedGender = profile?.gender?.toLowerCase() ?? "male";

    // Trigger validation to check if the generated username is valid
    onChangeUserName();

    selectedCountry = {
      "flag": (profile?.countryFlagImage == null || profile?.countryFlagImage == "") ? "🇮🇳" : profile!.countryFlagImage!,
      "name": (profile?.country == null || profile?.country == "") ? "India" : profile!.country!,
    };
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

  Future<void> onChangeUserName() async {
    if (userNameController.text.trim().isNotEmpty) {
      await 500.milliseconds.delay();

      isCheckingUserName.value = true;
      checkUserNameModel = await CheckUserNameApi.callApi(
          loginUserId: Database.loginUserId, userName: "@${userNameController.text.trim()}");
      isValidUserName = checkUserNameModel?.status ?? false;

      isCheckingUserName.value = false;
    } else {
      isValidUserName = false;
      isCheckingUserName.value = false;
    }
  }

  Future<void> onChangeGender(String gender) async {
    selectedGender = gender;
    update(["onChangeGender"]);
  }

  Future<void> onChangeCountry(Map<String, String> country) async {
    selectedCountry = country;
    update(["onChangeCountry"]);

    Utils.showLog("Selected Country => $selectedCountry");
  }

  Future<void> onSaveProfile() async {
    await onChangeUserName();
    Utils.showLog("Click On Save Profile => ${Database.loginUserId}");

    FocusManager.instance.primaryFocus?.unfocus();

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
          country: selectedCountry["name"]!,
          bio: bioDetailsController.text,
          gender: selectedGender,
          countryFlagImage: selectedCountry["flag"]!,
        );

        Get.back(); // Stop Loading...

        if (editProfileModel?.status == true && editProfileModel?.user?.name != null) {
          Utils.showToast(EnumLocal.txtProfileUpdateSuccessfully.name.tr);

          Get.offAllNamed(AppRoutes.bottomBarPage);

          Database.fetchLoginUserProfileModel =
              await FetchLoginUserProfileApi.callApi(loginUserId: Database.loginUserId);
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
