import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shortie/pages/profile_page/model/delete_reels_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class DeleteReelsApi {
  static Future<DeleteReelsModel?> callApi({required String videoId}) async {
    Utils.showLog("Delete Reels Api Calling... ");

    final uri = Uri.parse("${Api.deleteReels}?videoId=$videoId");

    final headers = {"key": Api.secretKey};

    try {
      var response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        Utils.showLog("Delete Reels Api Response => ${response.body}");

        return DeleteReelsModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Delete Reels Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Delete Reels Api Error => $error");
    }
    return null;
  }
}
