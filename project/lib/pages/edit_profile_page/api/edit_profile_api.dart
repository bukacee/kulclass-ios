import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auralive/pages/edit_profile_page/model/edit_profile_model.dart';
import 'package:auralive/utils/api.dart';
import 'package:auralive/utils/utils.dart';

class EditProfileApi {
  static Future<EditProfileModel?> callApi({
    required String loginUserId,
    String? image,
    required String name,
    required String userName,
    required String country,
    required String bio,
    required String gender,
    required String countryFlagImage,
    required int sub,
  }) async {
    Utils.showLog("Edit Profile Api Calling...");

    try {
      if (loginUserId.isEmpty) {
        Utils.showLog("❌ ERROR: loginUserId is EMPTY!");
        return null;
      }

      var headers = {'key': Api.secretKey};

      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse("${Api.editProfile}?userId=$loginUserId"),
      );

      request.fields.addAll({
        'name': name,
        'userName': userName,
        'gender': gender,
        'bio': bio,
        'country': country,
        'countryFlagImage': countryFlagImage,
        'sub': sub.toString(),
      });

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image));
      }

      request.headers.addAll(headers);

      final response = await request.send();

      final body = await response.stream.bytesToString();
      Utils.showLog("📨 Edit Profile RAW Response => $body");

      final decoded = jsonDecode(body);

      // Accept ALL 2xx success codes
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return EditProfileModel.fromJson(decoded);
      }

      Utils.showLog("❌ Server Error ${response.statusCode}: $decoded");
      return EditProfileModel.fromJson(decoded); // return error model too

    } catch (e) {
      Utils.showLog("🔥 Edit Profile Api Crash => $e");
      return null;
    }
  }
}
