import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shortie/pages/preview_hash_tag_page/model/fetch_hash_tag_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class FetchHashTagApi {
  static Future<FetchHashTagModel?> callApi({required String hashTag}) async {
    Utils.showLog("Fetch HastTag Api Calling... Search => $hashTag");

    final uri = Uri.parse("${Api.hashTagBottomSheet}?hashTag=$hashTag");

    final headers = {"key": Api.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        Utils.showLog("Fetch HastTag Api Response => ${response.body}");

        return FetchHashTagModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Fetch HastTag Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Fetch HastTag Api Error => $error");
    }
    return null;
  }
}
