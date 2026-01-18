import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // ⚠️ Make sure to import this!
import 'package:auralive/pages/upload_reels_page/model/upload_reels_model.dart';
import 'package:auralive/utils/api.dart';
import 'package:auralive/utils/utils.dart';

class UploadReelsApi {
  static Future<UploadReelsModel?> callApi({
    required String loginUserId,
    required String videoImage,
    required String videoUrl,
    required String videoTime,
    required String hashTag,
    required String caption,
    required String songId,
  }) async {
    Utils.showLog("Upload Reels Api Calling (Multipart)...");

    try {
      final uri = Uri.parse("${Api.uploadReels}?userId=$loginUserId");
      var request = http.MultipartRequest('POST', uri);

      // Headers
      request.headers.addAll({
        "key": Api.secretKey,
      });

      // Text Fields
      request.fields['caption'] = caption;
      request.fields['hashTagId'] = hashTag;
      request.fields['videoTime'] = videoTime;
      if (songId.isNotEmpty) {
        request.fields['songId'] = songId;
      }

      // ⚠️ FIX: Explicitly set Content-Type to avoid Backend rejection
      if (videoUrl.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'videoUrl', 
          videoUrl,
          contentType: MediaType('video', 'mp4'), // Forces server to accept it as video
        ));
      }

      if (videoImage.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'videoImage', 
          videoImage,
          contentType: MediaType('image', 'jpeg'), // Forces server to accept it as image
        ));
      }

      Utils.showLog("Sending Video Data...");

      // Send Request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // ⚠️ LOGGING: Check this log in your Debug Console if it fails again!
      Utils.showLog("Upload Status Code: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        Utils.showLog("Upload Success: ${jsonResult}");
        return UploadReelsModel.fromJson(jsonResult);
      } else if (response.statusCode == 413) {
        // 413 = Payload Too Large
        Utils.showLog("❌ ERROR: Video file is too large for the server.");
        return null;
      } else {
        Utils.showLog("❌ Upload Error: ${response.body}");
        return null;
      }
    } catch (e) {
      Utils.showLog("Upload Exception => $e");
      return null;
    }
  }
}
