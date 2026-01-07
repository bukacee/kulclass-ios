import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:auralive/pages/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:auralive/routes/app_routes.dart';
import 'package:auralive/pages/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:auralive/utils/utils.dart';
import 'package:auralive/pages/login_page/controller/login_controller.dart';
import 'package:uuid/uuid.dart';

import 'constant.dart';

class Database {
  static final localStorage = GetStorage();

  // Keys for persistent storage
  static const _kIdentityKey = 'identity';
  static const _kFcmTokenKey = 'fcmToken';

  static FetchLoginUserProfileModel? fetchLoginUserProfileModel;

  /// Initialize Database with random UUIDs for identity & FCM token
  static Future<void> init({String? identity, String? fcmToken}) async {
    Utils.showLog("Local Database Initialize....");
 
 
  // --- Identity ---
  String? storedIdentity = identity ?? localStorage.read(_kIdentityKey);
  if (storedIdentity == null || storedIdentity.isEmpty) {
    storedIdentity = const Uuid().v4();
    await localStorage.write(_kIdentityKey, storedIdentity);
    Utils.showLog("⚡ Generated new identity: $storedIdentity");
  }

  // --- FCM token ---
  String? storedFcm = fcmToken ?? localStorage.read(_kFcmTokenKey);
  if (storedFcm == null || storedFcm.isEmpty) {
    storedFcm = const Uuid().v4();
    await localStorage.write(_kFcmTokenKey, storedFcm);
    Utils.showLog("⚡ Generated fake FCM token: $storedFcm");
  }


      Utils.showLog("✅ Database initialized: identity=$storedIdentity, fcmToken=$storedFcm");

    // Force UI refresh if LoginController is registered
    if (Get.isRegistered<LoginController>()) {
      Get.find<LoginController>().update();
    }
  }
   
  // >>> Getters
  static String get identity => localStorage.read(_kIdentityKey) ?? "";
  static String get fcmToken => localStorage.read(_kFcmTokenKey) ?? "";

  static bool get isNewUser => localStorage.read("isNewUser") ?? true;
  static int get loginType => localStorage.read("loginType") ?? 0;
  static String get loginUserId => localStorage.read("loginUserId") ?? "";
  static String get selectedLanguage => localStorage.read("language") ?? AppConstant.languageEn;
  static String get selectedCountryCode => localStorage.read("countryCode") ?? AppConstant.countryCodeEn;


  // >>> Setters
  static onSetIdentity(String identity) async => await localStorage.write(_kIdentityKey, identity);
  static onSetFcmToken(String fcmToken) async => await localStorage.write(_kFcmTokenKey, fcmToken);
  static onSetIsNewUser(bool isNewUser) async => await localStorage.write("isNewUser", isNewUser);
  static onSetLoginType(int loginType) async => localStorage.write("loginType", loginType);
  static onSetLoginUserId(String loginUserId) async => localStorage.write("loginUserId", loginUserId);

  // >>> Other database helpers (unchanged)
  static onSetSelectedLanguage(String language) async => await localStorage.write("language", language);
  static onSetSelectedCountryCode(String countryCode) async => await localStorage.write("countryCode", countryCode);
  static bool get isShowNotification => localStorage.read("isShowNotification") ?? true;
  static onSetNotification(bool isShowNotification) async => localStorage.write("isShowNotification", isShowNotification);
  static List get searchMessageUserHistory => localStorage.read("searchMessageUsers") ?? [];
  static onSetSearchMessageUserHistory(List searchMessageUsers) async => localStorage.write("searchMessageUsers", searchMessageUsers);
  static onSetIsPurchase(bool isPurchase) async => await localStorage.write("isPurchase", isPurchase);

  static String? networkImage(String image) => localStorage.read(image);
  static onSetNetworkImage(String image) async => localStorage.write(image, image);

  // >>> Logout
  static Future<void> onLogOut() async {
    final _identity = identity;
    final _fcmToken = fcmToken;

    if (loginType == 2) {
      Utils.showLog("Google Logout Success");
      await GoogleSignIn().signOut();
    }

    localStorage.erase();

    // Restore persistent identity & FCM token
    await onSetIdentity(_identity);
    await onSetFcmToken(_fcmToken);

    Get.offAllNamed(AppRoutes.loginPage);
  }
}
