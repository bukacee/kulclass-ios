import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auralive/pages/upload_reels_page/model/upload_reels_model.dart';
import 'package:auralive/utils/api.dart';
import 'package:auralive/utils/utils.dart';

class UploadReelsApi {
  static Future<UploadReelsModel?> callApi({
    required String loginUserId,
    required String videoImage, // Now receiving Local Path
    required String videoUrl,   // Now receiving Local Path
    required String videoTime,
    required String hashTag,
    required String caption,
    required String songId,
  }) async {
    Utils.showLog("Upload Reels Api Calling (Multipart)...");

    try {
      // 1. Use MultipartRequest instead of simple POST
      final uri = Uri.parse("${Api.uploadReels}?userId=$loginUserId");
      var request = http.MultipartRequest('POST', uri);

      // 2. Add Headers
      request.headers.addAll({
        "key": Api.secretKey,
        // ⚠️ Do NOT add "Content-Type": "application/json" here. 
        // MultipartRequest sets the correct boundary automatically.
      });

      // 3. Add Text Fields
      request.fields['caption'] = caption;
      request.fields['hashTagId'] = hashTag;
      request.fields['videoTime'] = videoTime;
      
      // Only send songId if it exists
      if (songId.isNotEmpty) {
        request.fields['songId'] = songId;
      }

      // 4. Add Files (This sends the ACTUAL file, not just the path string)
      if (videoUrl.isNotEmpty) {
        // 'videoUrl' is the field name. If your backend expects 'video', change this string.
        request.files.add(await http.MultipartFile.fromPath('videoUrl', videoUrl));
      }

      if (videoImage.isNotEmpty) {
        // 'videoImage' is the field name. If your backend expects 'image', change this string.
        request.files.add(await http.MultipartFile.fromPath('videoImage', videoImage));
      }

      Utils.showLog("Sending Video Data...");

      // 5. Send & Handle Response
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        Utils.showLog("Upload Reels Api Response => ${jsonResult}");
        return UploadReelsModel.fromJson(jsonResult);
      } else {
        Utils.showLog("Upload Reels Api Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      Utils.showLog("Upload Reels Api Exception => $e");
      return null;
    }
  }
}
