import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shortie/pages/message_request_page/model/fetch_message_request_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class FetchMessageRequestApi {
  static Future<FetchMessageRequestModel?> callApi({required String loginUserId}) async {
    Utils.showLog("Get User Message Request Api Calling...");

    final uri = Uri.parse("${Api.fetchMessageRequest}?userId=$loginUserId");

    final headers = {"key": Api.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        Utils.showLog("Get User Message Request Api Response => ${response.body}");

        return FetchMessageRequestModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Get User Message Request Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Get User Message Request Api Error => $error");
    }
    return null;
  }
}
