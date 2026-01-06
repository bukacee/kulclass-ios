import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shortie/pages/feed_page/view/feed_view.dart';
import 'package:shortie/pages/message_page/view/message_view.dart';
import 'package:shortie/pages/profile_page/view/profile_view.dart';
import 'package:shortie/pages/reels_page/view/reels_view.dart';
import 'package:shortie/pages/stream_page/view/stream_view.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/ui/send_gift_on_video_bottom_sheet_ui.dart';
import 'package:shortie/utils/branch_io_services.dart';
import 'package:shortie/utils/socket_services.dart';

class BottomBarController extends GetxController {
  int selectedTabIndex = 0;
  PageController pageController = PageController();

  @override
  void onInit() {
    init();
    super.onInit();
  }

  void init() async {
    selectedTabIndex = 0;

    await SocketServices.socketConnect();

    SendGiftOnVideoBottomSheetUi.onGetGift();

    if (BranchIoServices.eventType == "Post") {
      await 500.milliseconds.delay();
      onChangeBottomBar(2);
    } else if (BranchIoServices.eventType == "Profile") {
      await 500.milliseconds.delay();
      onChangeBottomBar(2);
      if (BranchIoServices.eventId != "") {
        Get.toNamed(AppRoutes.previewUserProfilePage, arguments: BranchIoServices.eventId);
      }
    }
  }

  List bottomBarPages = [
    const ReelsView(),
    const StreamView(),
    const FeedView(),
    const MessageView(),
    const ProfileView(),
  ];

  void onChangeBottomBar(int index) {
    if (index != selectedTabIndex) {
      selectedTabIndex = index;
      update(["onChangeBottomBar"]);
    }
  }
}
