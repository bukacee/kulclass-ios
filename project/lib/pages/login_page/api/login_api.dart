import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:auralive/pages/login_page/model/login_model.dart';
import 'package:auralive/utils/api.dart';
import 'package:auralive/utils/enums.dart';
import 'package:auralive/utils/internet_connection.dart';
import 'package:auralive/utils/utils.dart';

class LoginApi {
  static Future<LoginModel?> callApi({
    required int loginType,
    required String email,
    required String identity,
    required String fcmToken,
    String? mobileNumber,
    String? name,
    String? userName,
    String? image,
    String? gender,
  }) async {
    Utils.showLog("Login Api Calling...");

    final uri = Uri.parse(Api.login);

    final headers = {"key": Api.secretKey, "Content-Type": "application/json"};

    Map<String, dynamic> data = {'loginType': loginType, 'identity': identity, "fcmToken": fcmToken};

    (mobileNumber != null) ? data.addAll({'mobileNumber': mobileNumber}) : data.addAll({'email': email});

    if (name != null && userName != null)
      data.addAll({
        "name": name,
        "userName": userName,
      });

    if (image != null) data.addAll({"image": image});

    if (gender != null) data.addAll({"gender": gender});

    Utils.showLog("********** LOGIN BODY => $data");

    final body = json.encode(data);

    // final body = mobileNumber != null
    //     ? json.encode(
    //           {
    //             'mobileNumber': mobileNumber,
    //             'loginType': loginType,
    //             'identity': identity,
    //             "fcmToken": fcmToken,
    //           },
    //         )
    //     : (userName == null)
    //           ? json.encode(
    //                 {
    //                   'email': email,
    //                   'loginType': loginType,
    //                   'identity': identity,
    //                   "fcmToken": fcmToken,
    //                 },
    //               )
    //           : json.encode(
    //                 {
    //                   'email': email,
    //                   'loginType': loginType,
    //                   'identity': identity,
    //                   "fcmToken": fcmToken,
    //                   "name": userName,
    //                   "userName": userName,
    //                 },
    //               );

    try {
      if (InternetConnection.isConnect.value) {
        Utils.showLog("Login Api Body => $body");
        
   

        final response = await http.post(uri, headers: headers, body: body);

        if (response.statusCode == 200) {
          Utils.showLog("Login Api Response => ${response.body}");
          final jsonResponse = json.decode(response.body);
          return LoginModel.fromJson(jsonResponse);
        } else {
          Utils.showLog(">>>>> Login Api StateCode Error: ${response.statusCode} <<<<<");
          // 💡 CRITICAL: Attempt to parse the server's error body into a LoginModel 
          // This is crucial if your server sends the error message in the body even on non-200 status.
          try {
            final jsonResponse = json.decode(response.body);
            // Return the error model so the Controller can read the message
            return LoginModel.fromJson(jsonResponse); 
          } catch (_) {
            // If parsing fails (e.g., server returned a plain text 500 error), 
            // return null to trigger the generic 'something went wrong' in the controller.
            return null;
          }
        }
      } else {
        Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
      }
    } catch (error) {
      Utils.showLog("Login Api Error => $error");
    }
    return null;
  }
}
