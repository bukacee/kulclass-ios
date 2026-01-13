import 'package:get/get.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:auralive/google_ad/google_ad_services.dart';
import 'package:auralive/pages/reels_page/api/fetch_reels_api.dart';
import 'package:auralive/pages/reels_page/model/fetch_reels_model.dart';
import 'package:auralive/routes/app_routes.dart';
import 'package:auralive/utils/branch_io_services.dart';
import 'package:auralive/utils/database.dart';
import 'package:auralive/utils/utils.dart'; // Ensure Utils is imported
import 'package:auralive/pages/splash_screen_page/api/create_report_api.dart';

import '../../bottom_bar_page/controller/bottom_bar_controller.dart';

class ReelsController extends GetxController {
  PreloadPageController preloadPageController = PreloadPageController();

  bool isLoadingReels = false;
  FetchReelsModel? fetchReelsModel;

  bool isPaginationLoading = false;

  List mainReels = []; 

  int currentPageIndex = 0;
  final quickAction = QuickActions();
  BottomBarController controller = Get.put(BottomBarController());

  @override
  void onInit() {
    super.onInit();

    quickAction.setShortcutItems([
      ShortcutItem(type: 'reel', localizedTitle: 'Reel', icon: "reel"),
      ShortcutItem(type: 'chat', localizedTitle: 'Chat', icon: "message"),
      ShortcutItem(type: 'feeds', localizedTitle: 'Feeds', icon: "feed"),
      ShortcutItem(type: 'search', localizedTitle: 'Search', icon: "search"),
    ]);

    quickAction.initialize(
      (type) {
        if (type == 'reel') {
          controller.onChangeBottomBar(0);
        } else if (type == 'chat') {
          controller.onChangeBottomBar(3);
        } else if (type == 'feeds') {
          controller.onChangeBottomBar(2);
        } else if (type == 'search') {
          Get.toNamed(AppRoutes.searchPage);
        }
      },
    );
  }

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
    
    // 1. First Attempt: Try to get the User's specific feed (Local/Personalized)
    fetchReelsModel = await FetchReelsApi.callApi(
      loginUserId: Database.loginUserId, 
      videoId: BranchIoServices.eventId
    );

    // -------------------------------------------------------------------------
    // ✅ THE FIX: The "Global/Guest" Safety Net
    // -------------------------------------------------------------------------
    // If the data is EMPTY (which happens for Apple Reviewers in empty regions),
    // we fetch again passing an EMPTY userId. This forces the backend
    // to return the GLOBAL Trending feed instead of an empty local feed.
    if (fetchReelsModel?.data == null || fetchReelsModel!.data!.isEmpty) {
      if (BranchIoServices.eventId.isEmpty) {
        fetchReelsModel = await FetchReelsApi.callApi(
          loginUserId: "", // <--- Empty ID forces Global/Guest Feed
          videoId: ""
        );
      }
    }
    // -------------------------------------------------------------------------

    if (fetchReelsModel?.data != null) {
      // ... (Rest of your existing logic for handling ads and pagination)
      if (fetchReelsModel!.data!.isNotEmpty) {
         final paginationData = fetchReelsModel?.data ?? [];
         // ... (Your ad injection logic)
         mainReels.addAll(paginationData);
         update(["onGetReels"]);
      }
    }
    
    if (mainReels.isEmpty) {
      update(["onGetReels"]);
    }
  }

  // -----------------------------------------------------------------------
  // ✅ ADDED: Function to Report and Hide Reel Immediately
  // -----------------------------------------------------------------------
  Future<void> onReportReel({required String reelId, required String reason}) async {
    // 1. Call API
    bool? isSuccess = await CreateReportApi.callApi(
      loginUserId: Database.loginUserId,
      reportReason: reason,
      eventType: 1, // 1 = Video Report
      eventId: reelId,
    );

    // 2. Hide Locally on Success
    if (isSuccess == true) {
      // Remove the item from the list where ID matches
      // Note: We check 'item != null' because ads are null
      mainReels.removeWhere((item) => item != null && item.id == reelId);
      
      // Update UI
      update(["onGetReels"]);
      Utils.showToast("Reel reported and hidden.");
    } else {
      Utils.showToast("Failed to report.");
    }
  }
}