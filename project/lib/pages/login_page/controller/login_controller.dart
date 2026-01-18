import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:auralive/pages/login_page/api/check_user_exist_api.dart';
import 'package:auralive/ui/loading_ui.dart';
import 'package:auralive/pages/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:auralive/pages/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:auralive/routes/app_routes.dart';
import 'package:auralive/pages/login_page/api/login_api.dart';
import 'package:auralive/pages/login_page/model/login_model.dart';
import 'package:auralive/utils/database.dart';
import 'package:auralive/utils/enums.dart';
import 'package:auralive/utils/internet_connection.dart';
import 'package:auralive/utils/utils.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

class LoginController extends GetxController {
  LoginModel? loginModel;
  FetchLoginUserProfileModel? fetchLoginUserProfileModel;

  List<String> randomNames = [
    "Emily Johnson", "Liam Smith", "Isabella Martinez", "Noah Brown",
    "Sofia Davis", "Oliver Wilson", "Mia Anderson", "James Thomas",
    "Ava Robinson", "Benjamin Lee", "Charlotte Miller", "Lucas Garcia",
    "Amelia White", "Ethan Harris", "Harper Clark", "Alexander Lewis",
    "Evelyn Walker", "Daniel Hall", "Grace Young", "Michael Allen",
  ];

  String onGetRandomName() {
    Random random = new Random();
    int index = random.nextInt(randomNames.length);
    return randomNames[index];
  }

  Future<void> onQuickLogin() async {
    if (InternetConnection.isConnect.value) {
      Get.dialog(const LoadingUi(), barrierDismissible: false);

      if (Database.identity.isEmpty) {
        Utils.showLog("⚠️ Identity missing during Quick Login. Fixing...");
        String newId = "ios_quick_${DateTime.now().millisecondsSinceEpoch}";
        await Database.init(newId, "pending_fcm_token");
      }

      final isLogin = await CheckUserExistApi.callApi(identity: Database.identity) ?? false;
      Utils.showLog("Quick Login User Is Exist => $isLogin");

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

      Get.back();

      if (loginModel?.status == true && loginModel?.user?.id != null) {
        await onGetProfile(loginUserId: loginModel!.user!.id!);
      } else if (loginModel?.message == "You are blocked by the admin.") {
        Utils.showToast("${loginModel?.message}");
      } else {
        Utils.showToast(loginModel?.message ?? EnumLocal.txtSomeThingWentWrong.name.tr);
      }
    } else {
      Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
    }
  }

  // -----------------------------------------------------------------------
  // ✅ GOOGLE LOGIN
  // -----------------------------------------------------------------------
  Future<void> onGoogleLogin() async {
    if (InternetConnection.isConnect.value) {
      Get.dialog(const LoadingUi(), barrierDismissible: false);

      if (Database.identity.isEmpty) {
        String newId = "ios_fix_${DateTime.now().millisecondsSinceEpoch}";
        await Database.init(newId, "pending_fcm_token");
      }

      UserCredential? userCredential = await signInWithGoogle();

      if (userCredential?.user?.email != null) {
        String email = userCredential?.user?.email ?? "";
        String name = userCredential?.user?.displayName ?? "";

        // Attempt Login WITHOUT userName first
        loginModel = await LoginApi.callApi(
          loginType: 2,
          email: email,
          identity: Database.identity,
          fcmToken: Database.fcmToken,
        );

        // If Login Failed (User not found), Attempt Register
        if (loginModel?.status == false) {
          Utils.showLog("User not found, registering new Google user...");
          loginModel = await LoginApi.callApi(
            loginType: 2,
            email: email,
            identity: Database.identity,
            fcmToken: Database.fcmToken,
            userName: name.isNotEmpty ? name : onGetRandomName(),
          );
        }

        Get.back();

        if (loginModel?.status == true) {
          Utils.showToast("Welcome to KulClass!");
          if (loginModel?.user?.id != null) {
            // ✅ Fix: Passing 'name' correctly here
            await onGetProfile(loginUserId: loginModel!.user!.id!, socialName: name);
          }
        } else {
          Utils.showToast(loginModel?.message ?? "Login Failed");
        }
      } else {
        Get.back();
        Utils.showToast("Google Sign In Cancelled or Failed");
      }
    } else {
      Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
    }
  }

  // -----------------------------------------------------------------------
  // ✅ APPLE LOGIN
  // -----------------------------------------------------------------------
  Future<void> onAppleLogin() async {
    if (InternetConnection.isConnect.value) {
      try {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        Get.dialog(const LoadingUi(), barrierDismissible: false);

        if (Database.identity.isEmpty) {
          String newId = "ios_fix_${DateTime.now().millisecondsSinceEpoch}";
          await Database.init(newId, "pending_fcm_token");
        }

        String identity = credential.userIdentifier ?? "";
        String email = credential.email ?? "";
        String firstName = credential.givenName ?? "";
        String lastName = credential.familyName ?? "";
        String fullName = (firstName.isEmpty && lastName.isEmpty)
            ? "Apple User"
            : "$firstName $lastName".trim();

        // Attempt Login WITHOUT userName
        loginModel = await LoginApi.callApi(
          loginType: 3,
          identity: identity,
          email: email.isNotEmpty ? email : identity,
          fcmToken: Database.fcmToken,
        );

        // If Login Failed (User not found), Attempt Register
        if (loginModel?.status == false) {
          Utils.showLog("User not found, registering new Apple user...");
          loginModel = await LoginApi.callApi(
            loginType: 3,
            identity: identity,
            email: email.isNotEmpty ? email : identity,
            fcmToken: Database.fcmToken,
            userName: fullName,
          );
        }

        Get.back();

        if (loginModel?.status == true) {
          Utils.showToast("Welcome to KulClass!");
          if (loginModel?.user?.id != null) {
            // ✅ Fix: Passing 'fullName' (not name) here
            await onGetProfile(loginUserId: loginModel!.user!.id!, socialName: fullName);
          }
        } else {
          Utils.showToast(loginModel?.message ?? "Login Failed");
        }

      } catch (error) {
        Get.back();
        if (error is SignInWithAppleAuthorizationException) {
          if (error.code == AuthorizationErrorCode.canceled) {
            Utils.showToast("Apple Sign In Cancelled");
          } else {
            Utils.showToast("Apple Sign In Failed: ${error.message}");
          }
        } else {
          Utils.showToast("Error: $error");
        }
      }
    } else {
      Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
    }
  }

  // -----------------------------------------------------------------------
  // ✅ ON GET PROFILE (UPDATED DEFINITION)
  // -----------------------------------------------------------------------
  Future<void> onGetProfile({required String loginUserId, String? socialName}) async {
    Get.dialog(const LoadingUi(), barrierDismissible: false);
    fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(loginUserId: loginUserId);
    Get.back();

    if (fetchLoginUserProfileModel?.user?.id != null && fetchLoginUserProfileModel?.user?.loginType != null) {
      Database.onSetIsNewUser(false);
      Database.onSetLoginUserId(fetchLoginUserProfileModel!.user!.id!);
      Database.onSetLoginType(int.parse((fetchLoginUserProfileModel?.user?.loginType ?? 0).toString()));
      Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;

      if (fetchLoginUserProfileModel?.user?.country == "" || fetchLoginUserProfileModel?.user?.bio == "") {
        // ✅ Fix: 'socialName' is now defined in the arguments
        Get.toNamed(
          AppRoutes.fillProfilePage,
          arguments: {'socialName': socialName ?? ""}
        );
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
      if (googleUser == null) return null;

      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken
      );

      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      return result;
    } catch (error) {
      Utils.showToast("Auth Error: $error");
    }
    return null;
  }
}
