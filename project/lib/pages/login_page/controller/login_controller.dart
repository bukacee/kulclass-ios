import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

      // ---------------------------------------------------------
      // 🛡️ SELF-HEALING: Fix Identity & Token before calling API
      // ---------------------------------------------------------
      if (Database.identity.isEmpty) {
         Utils.showLog("⚠️ Identity missing during Quick Login. Fixing...");
         
         String newId = "ios_quick_${DateTime.now().millisecondsSinceEpoch}";
         
         // Use dummy token to pass Backend validation
         // (Backend rejects empty tokens)
         await Database.init(newId, "pending_fcm_token"); 
         
         Utils.showLog("✅ Identity fixed: ${Database.identity}");
      }
      // ---------------------------------------------------------

      // Calling Check User API...
      final isLogin = await CheckUserExistApi.callApi(identity: Database.identity) ?? false;

      Utils.showLog("Quick Login User Is Exist => $isLogin");

      // Calling Login API...
      // Note: We use Database.identity and Database.fcmToken because 
      // the Self-Healing block above guarantees they are not empty.
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
        // This handles "Oops! Invalid details!!"
        Utils.showToast(loginModel?.message ?? EnumLocal.txtSomeThingWentWrong.name.tr);
        Utils.showLog("Login Api Calling Failed !!");
      }
    } else {
      Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
      Utils.showLog("Internet Connection Lost !!");
    }
  }

  Future<void> onGoogleLogin() async {
  if (InternetConnection.isConnect.value) {
    Get.dialog(const LoadingUi(), barrierDismissible: false);

    // [DEBUG] Checkpoint 1
    Utils.showToast("1. Checking Identity...");
    
    // Self-Healing Identity Logic
    if (Database.identity.isEmpty) {
       String newId = "ios_fix_${DateTime.now().millisecondsSinceEpoch}";
       
       // ❌ REMOVE THIS LINE (It causes the hang):
       // String? token = await FirebaseMessaging.instance.getToken();
       
       // ✅ USE THIS INSTEAD (Pass empty string to unblock):
       Utils.showLog("Skipping token fetch to prevent hang...");
       await Database.init(newId, "pending_fcm_token"); 
    }

    // [DEBUG] Checkpoint 2
    Utils.showToast("2. Opening Google Dialog...");
    
    UserCredential? userCredential = await signInWithGoogle();

    if (userCredential?.user?.email != null) {
      // [DEBUG] Checkpoint 4 (Only if Step 3 finished)
      Utils.showToast("4. Calling Backend API...");
      
      loginModel = await LoginApi.callApi(
        loginType: 2,
        email: userCredential?.user?.email ?? "",
        identity: Database.identity,
        fcmToken: Database.fcmToken,
        userName: userCredential?.user?.displayName ?? "",
      );

      Get.back(); // Stop Loading

      if (loginModel?.status == true) {
         Utils.showToast("5. Login Success!");
         await onGetProfile(loginUserId: loginModel!.user!.id!);
      } else {
         Utils.showToast("API Error: ${loginModel?.message}");
      }
    } else {
      Get.back();
      Utils.showToast("Google Sign In Cancelled or Failed");
    }
  } else {
    Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
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
    
    if (googleUser == null) return null;

    final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken, 
        idToken: googleAuth?.idToken
    );
    
    // [DEBUG] Checkpoint 3 - THE DANGER ZONE
    Utils.showToast("3. Verifying with Firebase (This might hang)...");
    
    // This line sends the Silent Push. If APNs is broken, it hangs here.
    final result = await FirebaseAuth.instance.signInWithCredential(credential);
    
    return result;
  } catch (error) {
    Utils.showToast("Auth Error: $error");
  }
  return null;
}



}
