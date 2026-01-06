import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shortie/pages/message_page/model/fetch_message_user_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class FetchMessageUserApi {
  static int startPagination = 0;
  static int limitPagination = 20;

  static Future<FetchMessageUserModel?> callApi({required String loginUserId}) async {
    Utils.showLog("Get Message User Api Calling...");

    startPagination += 1;

    final uri = Uri.parse("${Api.messageUser}?userId=$loginUserId&start=$startPagination&limit=$limitPagination");

    Utils.showLog("Get Message User Api Response => ${uri}");

    final headers = {"key": Api.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        Utils.showLog("Get Message User Api Response => ${response.body}");

        return FetchMessageUserModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Get Message User Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Get Message User Api Error => $error");
    }
    return null;
  }
}
