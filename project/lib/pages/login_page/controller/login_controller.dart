import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shortie/pages/login_page/api/check_user_exist_api.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/pages/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:shortie/pages/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/pages/login_page/api/login_api.dart';
import 'package:shortie/pages/login_page/model/login_model.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/internet_connection.dart';
import 'package:shortie/utils/utils.dart';

class LoginController extends GetxController {
  LoginModel? loginModel;
  FetchLoginUserProfileModel? fetchLoginUserProfileModel;

  List<String> randomNames = [
    "Emily Johnson",
    "Liam Smith",
    "Isabella Martinez",
    "Noah Brown",
    "Sofia Davis",
    "Oliver Wilson",
    "Mia Anderson",
    "James Thomas",
    "Ava Robinson",
    "Benjamin Lee",
    "Charlotte Miller",
    "Lucas Garcia",
    "Amelia White",
    "Ethan Harris",
    "Harper Clark",
    "Alexander Lewis",
    "Evelyn Walker",
    "Daniel Hall",
    "Grace Young",
    "Michael Allen",
  ];

  String onGetRandomName() {
    Random random = new Random();
    int index = random.nextInt(randomNames.length);
    return randomNames[index];
  }

  Future<void> onQuickLogin() async {
    if (InternetConnection.isConnect.value) {
      Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

      // Calling Sign Up Api...

      final isLogin = await CheckUserExistApi.callApi(identity: Database.identity) ?? false;

      Utils.showLog("Quick Login User Is Exist => ${isLogin}");

      loginModel = isLogin
          ? await LoginApi.callApi(
              loginType: 3,
              email: Database.identity,
              identity: Database.identity,
              fcmToken: Database.fcmToken,
            )
          : await LoginApi.callApi(
              loginType: 3,
              email: Database.identity,
              identity: Database.identity,
              fcmToken: Database.fcmToken,
              userName: onGetRandomName(),
            );

      Get.back(); // Stop Loading...

      if (loginModel?.status == true && loginModel?.user?.id != null) {
        await onGetProfile(loginUserId: loginModel!.user!.id!); // Get Profile Api...
      } else if (loginModel?.message == "You are blocked by the admin.") {
        Utils.showToast("${loginModel?.message}");
        Utils.showLog("User Blocked By Admin !!");
      } else {
        Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
        Utils.showLog("Login Api Calling Failed !!");
      }
    } else {
      Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
      Utils.showLog("Internet Connection Lost !!");
    }
  }

  Future<void> onGoogleLogin() async {
    if (InternetConnection.isConnect.value) {
      Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

      UserCredential? userCredential = await signInWithGoogle();

      if (userCredential?.user?.email != null && userCredential?.user?.displayName != null) {
        // Calling Sign Up Api...

        loginModel = await LoginApi.callApi(
          loginType: 2,
          email: userCredential?.user?.email ?? "",
          identity: Database.identity,
          fcmToken: Database.fcmToken,
          userName: userCredential?.user?.displayName ?? "",
        );

        Get.back(); // Stop Loading...

        if (loginModel?.status == true && loginModel?.user?.id != null) {
          await onGetProfile(loginUserId: loginModel!.user!.id!); // Get Profile Api...
        } else if (loginModel?.message == "You are blocked by the admin.") {
          Utils.showToast("${loginModel?.message}");
          Utils.showLog("User Blocked By Admin !!");
        } else {
          Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
          Utils.showLog("Login Api Calling Failed !!");
        }
      } else {
        Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
        Utils.showLog("Google Login Failed !!");
        Get.back(); // Stop Loading...
      }
    } else {
      Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
      Utils.showLog("Internet Connection Lost !!");
    }
  }

  Future<void> onGetProfile({required String loginUserId}) async {
    Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
    fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(loginUserId: loginUserId);
    Get.back(); // Stop Loading...

    if (fetchLoginUserProfileModel?.user?.id != null && fetchLoginUserProfileModel?.user?.loginType != null) {
      Database.onSetIsNewUser(false);
      Database.onSetLoginUserId(fetchLoginUserProfileModel!.user!.id!);
      Database.onSetLoginType(int.parse((fetchLoginUserProfileModel?.user?.loginType ?? 0).toString()));
      Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;

      if (fetchLoginUserProfileModel?.user?.country == "" || fetchLoginUserProfileModel?.user?.bio == "") {
        Get.toNamed(AppRoutes.fillProfilePage);
      } else {
        Get.offAllNamed(AppRoutes.bottomBarPage);
      }
    } else {
      Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
      Utils.showLog("Get Profile Api Calling Failed !!");
    }
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      final result = await FirebaseAuth.instance.signInWithCredential(credential);

      Utils.showLog("Google Login Email => ${result.user?.email}");

      Utils.showLog("Google Login isNewUser => ${result.additionalUserInfo?.isNewUser}");

      return result;
    } catch (error) {
      Utils.showLog("Google Login Error => $error");
    }
    return null;
  }
}
