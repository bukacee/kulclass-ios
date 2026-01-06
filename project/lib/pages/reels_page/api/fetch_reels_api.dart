import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shortie/pages/reels_page/model/fetch_reels_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class FetchReelsApi {
  static int startPagination = 0;
  static int limitPagination = 20;

  static Future<FetchReelsModel?> callApi({required String loginUserId, required String videoId}) async {
    Utils.showLog("Get Reels Api Calling... ");

    startPagination += 1;

    Utils.showLog("Get Reels Pagination Page => $startPagination");

    final uri = Uri.parse("${Api.fetchReels}?start=$startPagination&limit=$limitPagination&userId=$loginUserId&videoId=$videoId");
    Utils.showLog("Get Reels Api Url => $uri");

    final headers = {"key": Api.secretKey};

    try {
      var response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        Utils.showLog("Get Reels Api Response => ${response.body}");
        return FetchReelsModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Get Reels Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Get Reels Api Error => $error");
    }
    return null;
  }
}
