import 'package:http/http.dart' as http;
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/utils.dart';

class FollowUnfollowApi {
  static Future<void> callApi({required String loginUserId, required String userId}) async {
    Utils.showLog("Follow-Unfollow Api Calling...");

    final uri = Uri.parse("${Api.followUnfollow}?fromUserId=$loginUserId&toUserId=$userId");

    Utils.showLog("Follow-Unfollow Url => $uri");

    final headers = {"key": Api.secretKey};

    try {
      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        Utils.showLog("Follow-Unfollow Api Response => ${response.body}");
      } else {
        Utils.showLog("Follow-Unfollow Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Follow-Unfollow Api Error => $error");
    }
  }
}
