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

class LoginController extends GetxController {
  LoginModel? loginModel;
  FetchLoginUserProfileModel? fetchLoginUserProfileModel;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final List<String> randomNames = [
    "Emily Johnson","Liam Smith","Isabella Martinez","Noah Brown","Sofia Davis",
    "Oliver Wilson","Mia Anderson","James Thomas","Ava Robinson","Benjamin Lee",
    "Charlotte Miller","Lucas Garcia","Amelia White","Ethan Harris","Harper Clark",
    "Alexander Lewis","Evelyn Walker","Daniel Hall","Grace Young","Michael Allen"
  ];

  String onGetRandomName() {
    final index = Random().nextInt(randomNames.length);
    return randomNames[index];
  }

  /// ------------------- QUICK LOGIN -------------------
  Future<void> onQuickLogin() async {
    if (!InternetConnection.isConnect.value) {
      _showToastAndLog(EnumLocal.txtConnectionLost.name.tr, "Internet Connection Lost !!");
      return;
    }

    Get.dialog(const LoadingUi(), barrierDismissible: false);
    Utils.showLog("QuickLogin check: identity=${Database.identity}, fcm=${Database.fcmToken}");

    final isLogin = await CheckUserExistApi.callApi(identity: Database.identity) ?? false;
    Utils.showLog("Quick Login User Exists => $isLogin");

    loginModel = await LoginApi.callApi(
      loginType: 3,
      email: "${Database.identity}@kulclass.com",
      identity: Database.identity,
      fcmToken: Database.fcmToken,
      userName: isLogin ? null : onGetRandomName(),
    );

    Get.back(); // Stop loading
    await _handleLoginResponse();
  }

  /// ------------------- GOOGLE LOGIN -------------------
  Future<void> onGoogleLogin() async {
    if (!InternetConnection.isConnect.value) {
      _showToastAndLog("No internet connection. Please try again.", "Internet Connection Lost");
      return;
    }

    Get.dialog(const LoadingUi(), barrierDismissible: false);

    UserCredential? userCredential = await _signInWithGoogle();
    if (userCredential == null) {
      Get.back();
      return;
    }

    final email = userCredential.user?.email;
    final name = userCredential.user?.displayName;

    if (email == null || name == null) {
      Utils.showToast("Could not get Google account details. Please try again.");
      Get.back();
      return;
    }

    loginModel = await LoginApi.callApi(
      loginType: 2,
      email: email,
      identity: Database.identity,
      fcmToken: Database.fcmToken,
      userName: name,
    );

    Get.back();
    await _handleLoginResponse();
  }

  /// ------------------- APPLE LOGIN -------------------
  Future<void> onAppleLogin({bool auto = false}) async {
    if (!InternetConnection.isConnect.value) {
      if (!auto) _showToastAndLog("No internet connection. Please try again.", "Internet Connection Lost");
      return;
    }

    if (!auto) Get.dialog(const LoadingUi(), barrierDismissible: false);

    UserCredential? userCredential = await _signInWithApple();
    if (userCredential == null) {
      if (!auto) Get.back();
      return;
    }

    final email = userCredential.user?.email ?? "${Database.identity}@kulclass.com";
    final name = userCredential.user?.displayName ?? onGetRandomName();

    loginModel = await LoginApi.callApi(
      loginType: 2,
      email: email,
      identity: Database.identity,
      fcmToken: Database.fcmToken,
      userName: name,
    );

    if (!auto) Get.back();
    await _handleLoginResponse();
  }

  /// ------------------- HANDLE LOGIN RESPONSE -------------------
  Future<void> _handleLoginResponse() async {
    if (loginModel?.status == true && loginModel?.user?.id != null) {
      await onGetProfile(loginUserId: loginModel!.user!.id!);
    } else if (loginModel?.message == "You are blocked by the admin.") {
      _showToastAndLog("${loginModel?.message}", "User Blocked By Admin !!");
    } else {
      _showToastAndLog("Something went wrong. Please try again.", "Login API failed");
    }
  }

  /// ------------------- GET PROFILE -------------------
  Future<void> onGetProfile({required String loginUserId}) async {
    Get.dialog(const LoadingUi(), barrierDismissible: false);

    fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(loginUserId: loginUserId);
    Get.back();

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
      _showToastAndLog(EnumLocal.txtSomeThingWentWrong.name.tr, "Get Profile API failed");
    }
  }

  /// ------------------- GOOGLE SIGN-IN -------------------
  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null || googleAuth.idToken == null) return null;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken!,
        idToken: googleAuth.idToken!,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      Utils.showLog("Google Login Error: $e");
      Utils.showToast("Something went wrong with Google sign-in.");
      return null;
    }
  }

  /// ------------------- APPLE SIGN-IN -------------------
  Future<UserCredential?> _signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    } catch (e) {
      Utils.showLog("Apple Login Error: $e");
      Utils.showToast("Something went wrong with Apple sign-in.");
      return null;
    }
  }

  /// ------------------- SILENT AUTO LOGIN FOR APPLE -------------------
  Future<bool> canAutoLoginWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(scopes: []);
      return credential.identityToken != null;
    } catch (e) {
      Utils.showLog("Apple silent login not possible: $e");
      return false;
    }
  }

  /// ------------------- HELPER -------------------
  void _showToastAndLog(String toast, String log) {
    Utils.showToast(toast);
    Utils.showLog(log);
  }

  String get viewerCountry => fetchLoginUserProfileModel?.user?.country ?? "United States";
}
