import 'package:get/get.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:auralive/pages/preview_shorts_video_page/model/preview_shorts_video_model.dart';
// ... inside PreviewShortsVideoController ...
import 'package:auralive/pages/splash_screen_page/api/create_report_api.dart'; // Import API
import 'package:auralive/utils/utils.dart';       // ✅ ADD THIS
import 'package:auralive/utils/database.dart';    // ✅ ADD THIS



class PreviewShortsVideoController extends GetxController {
  bool isLoading = false;
  int currentPageIndex = 0;
  List<PreviewShortsVideoModel> mainShorts = [];
  PreloadPageController preloadPageController = PreloadPageController();

  bool previousPageIsAudioWiseVideoPage = false;

  @override
  void onInit() {
    onGetShorts();
    super.onInit();
  }

  void onGetShorts() async {
    isLoading = true;
    if (Get.arguments["video"] != null) {
      mainShorts.addAll(Get.arguments["video"]);
    }
    isLoading = false;
    update(["onGetShorts"]);
    currentPageIndex = Get.arguments["index"];
    previousPageIsAudioWiseVideoPage = Get.arguments["previousPageIsAudioWiseVideoPage"];
    preloadPageController = PreloadPageController(initialPage: currentPageIndex);
  }

  void onChangePage(int index) async {
    currentPageIndex = index;
    update(["onChangePage"]);
  }

  // ✅ ADD THIS FUNCTION
  Future<void> onReportVideo(String videoId, String reason) async {
    bool? success = await CreateReportApi.callApi(
      loginUserId: Database.loginUserId,
      reportReason: reason,
      eventType: 1, // 1 = Video
      eventId: videoId,
    );
    if (success == true) {
      // mainShorts.removeWhere((element) => element.videoId == videoId);
      update();
      Utils.showToast("Video reported and hidden.");
      Get.back(); // Close preview
    }
  }

}
