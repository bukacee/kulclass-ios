import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auralive/custom/custom_fetch_user_coin.dart';
import 'package:auralive/pages/preview_shorts_video_page/model/preview_shorts_video_model.dart';
import 'package:auralive/pages/profile_page/api/delete_post_api.dart';
import 'package:auralive/pages/profile_page/api/delete_reels_api.dart';
import 'package:auralive/pages/profile_page/api/fetch_profile_api.dart';
import 'package:auralive/pages/profile_page/api/fetch_profile_collection_api.dart';
import 'package:auralive/pages/profile_page/api/fetch_profile_post_api.dart';
import 'package:auralive/pages/profile_page/api/fetch_profile_video_api.dart';
import 'package:auralive/pages/profile_page/model/delete_post_model.dart';
import 'package:auralive/pages/profile_page/model/delete_reels_model.dart';
import 'package:auralive/pages/profile_page/model/fetch_profile_collection_model.dart';
import 'package:auralive/pages/profile_page/model/fetch_profile_model.dart';
import 'package:auralive/pages/profile_page/model/fetch_profile_post_model.dart';
import 'package:auralive/pages/profile_page/model/fetch_profile_video_model.dart';
import 'package:auralive/routes/app_routes.dart';
import 'package:auralive/ui/delete_post_dialog_ui.dart';
import 'package:auralive/ui/delete_reels_dialog_ui.dart';
import 'package:auralive/ui/loading_ui.dart';
import 'package:auralive/utils/database.dart';
import 'package:auralive/utils/enums.dart';
import 'package:auralive/utils/utils.dart';
import 'package:auralive/utils/currency_helper.dart';
import 'package:get_storage/get_storage.dart';
import 'package:auralive/pages/login_page/controller/login_controller.dart';
// ✅ Import API
import 'package:auralive/pages/splash_screen_page/api/create_report_api.dart';

class ProfileController extends GetxController with GetTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  TabController? tabController;

  late String viewerCountry;

  // Currency Logic
  double coinAmountUSD = 0.0;
  RxDouble coinOwnerCurrency = 0.0.obs;
  RxString ownerCurrencyCode = 'USD'.obs;

  RxBool isTabBarPinned = false.obs;

  // Profile Data
  FetchProfileModel? fetchProfileModel;
  bool isLoadingProfile = false;
  bool isFollow = false;

  // Video Data
  bool isLoadingVideo = true;
  FetchProfileVideoModel? fetchProfileVideoModel;
  List<ProfileVideoData> videoCollection = [];

  // Post Data
  bool isLoadingPost = true;
  FetchProfilePostModel? fetchProfilePostModel;
  List<ProfilePostData> postCollection = [];

  // Collection Data
  bool isLoadingCollection = true;
  FetchProfileCollectionModel? fetchProfileCollectionModel;
  List<ProfileCollectionData> giftCollection = [];

  DeletePostModel? deletePostModel;
  DeleteReelsModel? deleteReelsModel;

  @override
  void onClose() {
    scrollController.removeListener(onScroll);
    scrollController.dispose();
    super.onClose();
  }

  @override
  Future<void> onInit() async {
    tabController = TabController(length: 3, vsync: this);
    tabController?.addListener(onChangeTabBar);
    scrollController.addListener(onScroll);

    super.onInit();
  }

  Future<void> init() async {
    tabController?.index = 0;

    isLoadingVideo = true;
    isLoadingPost = true;
    isLoadingCollection = true;

    onGetProfile(userId: Database.loginUserId);
    onGetVideo(userId: Database.loginUserId);
    CustomFetchUserCoin.init();
  }

  void onScroll() {
    isTabBarPinned.value = scrollController.offset > 75;
  }

  bool isChangingTab = false;

  Future<void> onChangeTabBar() async {
    isChangingTab = true;
    await 400.milliseconds.delay();

    if (isChangingTab) {
      isChangingTab = false;

      if (tabController?.index == 0) {
        if (isLoadingVideo) onGetVideo(userId: Database.loginUserId);
      } else if (tabController?.index == 1) {
        if (isLoadingPost) onGetPost(userId: Database.loginUserId);
      } else if (tabController?.index == 2) {
        if (isLoadingCollection) onGetCollection(userId: Database.loginUserId);
      }
    }
  }

  Future<void> onGetProfile({required String userId}) async {
    isLoadingProfile = true;
    update(["onGetProfile"]);

    fetchProfileModel = await FetchProfileApi.callApi(
      loginUserId: Database.loginUserId,
      otherUserId: userId,
    );

    if (fetchProfileModel?.userProfileData?.user?.name != null) {
      isLoadingProfile = false;
      update(["onGetProfile"]);

      coinAmountUSD = double.tryParse(CustomFetchUserCoin.coin.value.toString()) ?? 0.0;
      final ownerCountryRaw = fetchProfileModel?.userProfileData?.user?.country ?? '';
      ownerCurrencyCode.value = CurrencyHelper.getCurrencyCodeFromCountry(ownerCountryRaw);

      coinOwnerCurrency.value = await CurrencyHelper.convert(
        coinAmountUSD,
        'USD',
        ownerCurrencyCode.value,
      );
    }
  }

  Future<void> onGetVideo({required String userId}) async {
    isLoadingVideo = true;
    videoCollection.clear();
    update(["onGetVideo"]);
    fetchProfileVideoModel = await FetchProfileVideoApi.callApi(loginUserId: Database.loginUserId, toUserId: userId);
    if (fetchProfileVideoModel?.data != null) {
      videoCollection.clear();
      videoCollection.addAll(fetchProfileVideoModel?.data ?? []);
    }
    isLoadingVideo = false;
    update(["onGetVideo"]);
  }

  Future<void> onGetPost({required String userId}) async {
    isLoadingPost = true;
    postCollection.clear();
    update(["onGetPost"]);
    fetchProfilePostModel = await FetchProfilePostApi.callApi(userId: userId);
    if (fetchProfilePostModel?.data != null) {
      postCollection.clear();
      postCollection.addAll(fetchProfilePostModel?.data ?? []);
    }
    isLoadingPost = false;
    update(["onGetPost"]);
  }

  Future<void> onGetCollection({required String userId}) async {
    isLoadingCollection = true;
    giftCollection.clear();
    update(["onGetCollection"]);
    fetchProfileCollectionModel = await FetchProfileCollectionApi.callApi(userId: userId);
    if (fetchProfileCollectionModel?.data != null) {
      giftCollection.clear();
      giftCollection.addAll(fetchProfileCollectionModel?.data ?? []);
    }
    isLoadingCollection = false;
    update(["onGetCollection"]);
  }

  Future<void> onClickEditProfile() async {
    Get.toNamed(AppRoutes.editProfilePage)?.then(
      (value) => onGetProfile(userId: Database.loginUserId),
    );
  }

  Future<void> onClickFollowing() async {
    Get.toNamed(
      AppRoutes.connectionPage,
      arguments: {
        "userId": Database.loginUserId,
        "name": fetchProfileModel?.userProfileData?.user?.name ?? "",
        "userName": fetchProfileModel?.userProfileData?.user?.userName ?? "",
        "image": fetchProfileModel?.userProfileData?.user?.image ?? "",
        "isProfileImageBanned": fetchProfileModel?.userProfileData?.user?.isProfileImageBanned ?? "",
        "type": 0,
      },
    );
  }

  Future<void> onClickFollowers() async {
    Get.toNamed(
      AppRoutes.connectionPage,
      arguments: {
        "userId": Database.loginUserId,
        "name": fetchProfileModel?.userProfileData?.user?.name ?? "",
        "userName": fetchProfileModel?.userProfileData?.user?.userName ?? "",
        "image": fetchProfileModel?.userProfileData?.user?.image ?? "",
        "isProfileImageBanned": fetchProfileModel?.userProfileData?.user?.isProfileImageBanned ?? "",
        "type": 1,
      },
    );
  }

  Future<void> onClickReels(int index) async {
    List<PreviewShortsVideoModel> mainShorts = [];
    for (int i = 0; i < videoCollection.length; i++) {
      final video = videoCollection[i];
      mainShorts.add(
        PreviewShortsVideoModel(
          name: video.name.toString(),
          userId: video.userId.toString(),
          userName: video.userName.toString(),
          userImage: video.userImage.toString(),
          videoId: video.id.toString(),
          videoUrl: video.videoUrl.toString(),
          videoImage: video.videoImage.toString(),
          caption: video.caption.toString(),
          hashTag: video.hashTag ?? [],
          isLike: video.isLike ?? false,
          likes: video.totalLikes ?? 0,
          comments: video.totalComments ?? 0,
          isBanned: video.isBanned ?? false,
          songId: video.songId ?? "",
          isProfileImageBanned: video.isProfileImageBanned ?? false,
        ),
      );
    }
    Get.toNamed(AppRoutes.previewShortsVideoPage, arguments: {"index": index, "video": mainShorts, "previousPageIsAudioWiseVideoPage": false});
  }

  void onClickDeleteReels({required String videoId}) {
    DeleteReelsDialogUi.onShow(callBack: () => onDeleteReels(videoId: videoId));
  }

  Future<void> onDeleteReels({required String videoId}) async {
    try {
      Get.dialog(LoadingUi(), barrierDismissible: false);
      deleteReelsModel = await DeleteReelsApi.callApi(videoId: videoId);
      Get.close(3);
      Utils.showToast(deleteReelsModel?.message ?? "");
      init();
    } catch (e) {
      Get.close(2);
      Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
    }
  }

  void onClickDeletePost({required String postId}) {
    DeletePostDialogUi.onShow(callBack: () => onDeletePost(postId: postId));
  }

  Future<void> onDeletePost({required String postId}) async {
    try {
      Get.dialog(LoadingUi(), barrierDismissible: false);
      deletePostModel = await DeletePostApi.callApi(postId: postId);
      Get.close(3);
      Utils.showToast(deletePostModel?.message ?? "");
      init();
    } catch (e) {
      Get.close(2);
      Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
    }
  }

  // -----------------------------------------------------------------------
  // ✅ REPORT & HIDE FUNCTIONS (You were missing these!)
  // -----------------------------------------------------------------------

  // 1. Report Video (Hide from collection)
  Future<void> onReportVideo(String videoId, String reason) async {
    bool? success = await CreateReportApi.callApi(
      loginUserId: Database.loginUserId,
      reportReason: reason,
      eventType: 1, // 1 = Video
      eventId: videoId,
    );
    if (success == true) {
      videoCollection.removeWhere((item) => item.id == videoId);
      update(["onGetVideo"]);
      Utils.showToast("Video reported and hidden.");
    }
  }

  // 2. Report Post (Hide from collection)
  Future<void> onReportPost(String postId, String reason) async {
    bool? success = await CreateReportApi.callApi(
      loginUserId: Database.loginUserId,
      reportReason: reason,
      eventType: 2, // 2 = Post
      eventId: postId,
    );
    if (success == true) {
      postCollection.removeWhere((item) => item.id == postId);
      update(["onGetPost"]);
      Utils.showToast("Post reported and hidden.");
    }
  }

  // 3. Report User (Navigate back)
  Future<void> onReportUser(String userId, String reason) async {
    bool? success = await CreateReportApi.callApi(
      loginUserId: Database.loginUserId,
      reportReason: reason,
      eventType: 3, // 3 = User
      eventId: userId,
    );
    if (success == true) {
      Utils.showToast("User reported.");
      Get.back(); // Leave page
    }
  }
}