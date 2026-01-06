import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shortie/pages/login_page/model/login_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/internet_connection.dart';
import 'package:shortie/utils/utils.dart';

class LoginApi {
  static Future<LoginModel?> callApi({
    required int loginType,
    required String email,
    required String identity,
    required String fcmToken,
    String? mobileNumber,
    String? userName,
  }) async {
    Utils.showLog("Login Api Calling...");

    final uri = Uri.parse(Api.login);

    final headers = {"key": Api.secretKey, "Content-Type": "application/json"};

    final body = mobileNumber != null
        ? json.encode(
            {
              'mobileNumber': mobileNumber,
              'loginType': loginType,
              'identity': identity,
              "fcmToken": fcmToken,
            },
          )
        : (userName == null)
            ? json.encode(
                {
                  'email': email,
                  'loginType': loginType,
                  'identity': identity,
                  "fcmToken": fcmToken,
                },
              )
            : json.encode(
                {
                  'email': email,
                  'loginType': loginType,
                  'identity': identity,
                  "fcmToken": fcmToken,
                  "name": userName,
                  "userName": userName,
                },
              );

    try {
      if (InternetConnection.isConnect.value) {
        Utils.showLog("Login Api Body => ${body}");

        final response = await http.post(uri, headers: headers, body: body);

        if (response.statusCode == 200) {
          Utils.showLog("Login Api Response => ${response.body}");
          final jsonResponse = json.decode(response.body);
          return LoginModel.fromJson(jsonResponse);
        } else {
          Utils.showLog(">>>>> Login Api StateCode Error <<<<<");
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
