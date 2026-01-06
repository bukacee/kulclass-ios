import 'package:get/get.dart';
import 'package:preload_page_view/preload_page_view.dart';

import 'package:shortie/pages/reels_page/api/fetch_reels_api.dart';
import 'package:shortie/pages/reels_page/model/fetch_reels_model.dart';
import 'package:shortie/utils/branch_io_services.dart';
import 'package:shortie/utils/database.dart';

class ReelsController extends GetxController {
  PreloadPageController preloadPageController = PreloadPageController();

  bool isLoadingReels = false;
  FetchReelsModel? fetchReelsModel;

  bool isPaginationLoading = false;

  List<Data> mainReels = [];

  int currentPageIndex = 0;

  Future<void> init() async {
    currentPageIndex = 0;
    mainReels.clear();
    FetchReelsApi.startPagination = 0;
    isLoadingReels = true;
    update(["onGetReels"]);
    await onGetReels();
    isLoadingReels = false;
  }

  void onPagination(int value) async {
    if ((mainReels.length - 1) == value) {
      if (isPaginationLoading == false) {
        isPaginationLoading = true;
        update(["onPagination"]);
        await onGetReels();
        isPaginationLoading = false;
        update(["onPagination"]);
      }
    }
  }

  void onChangePage(int index) async {
    currentPageIndex = index;
    update(["onChangePage"]);
  }

  Future<void> onGetReels() async {
    fetchReelsModel = null;
    fetchReelsModel = await FetchReelsApi.callApi(loginUserId: Database.loginUserId, videoId: BranchIoServices.eventId);

    if (fetchReelsModel?.data != null) {
      if (fetchReelsModel!.data!.isNotEmpty) {
        final paginationData = fetchReelsModel?.data ?? [];

        mainReels.addAll(paginationData);

        update(["onGetReels"]);
      }
    }
    if (mainReels.isEmpty) {
      update(["onGetReels"]);
    }
  }
}
