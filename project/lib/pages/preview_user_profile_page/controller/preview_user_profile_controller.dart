import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/pages/connection_page/api/follow_unfollow_api.dart';
import 'package:shortie/pages/preview_shorts_video_page/model/preview_shorts_video_model.dart';
import 'package:shortie/pages/profile_page/api/fetch_profile_api.dart';
import 'package:shortie/pages/profile_page/api/fetch_profile_collection_api.dart';
import 'package:shortie/pages/profile_page/api/fetch_profile_post_api.dart';
import 'package:shortie/pages/profile_page/api/fetch_profile_video_api.dart';
import 'package:shortie/pages/profile_page/model/fetch_profile_collection_model.dart';
import 'package:shortie/pages/profile_page/model/fetch_profile_model.dart';
import 'package:shortie/pages/profile_page/model/fetch_profile_post_model.dart';
import 'package:shortie/pages/profile_page/model/fetch_profile_video_model.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/utils.dart';

class PreviewUserProfileController extends GetxController with GetTickerProviderStateMixin {
  TabController? tabController;

  // >>>>> Get Other User Profile...
  FetchProfileModel? fetchProfileModel;
  bool isLoadingProfile = false;
  bool isFollow = false;

  // >>>>> Get Other User Video...
  bool isLoadingVideo = true;
  FetchProfileVideoModel? fetchProfileVideoModel;
  List<ProfileVideoData> videoCollection = [];

  // >>>>> Get Other User Post...
  bool isLoadingPost = true;
  FetchProfilePostModel? fetchProfilePostModel;
  List<ProfilePostData> postCollection = [];

  // >>>>> Get Other User Collection(Gift)...
  bool isLoadingCollection = true;
  FetchProfileCollectionModel? fetchProfileCollectionModel;
  List<ProfileCollectionData> giftCollection = [];

  String userId = ""; //  Other User Id...

  @override
  Future<void> onInit() async {
    tabController = TabController(length: 3, vsync: this);
    tabController?.addListener(onChangeTabBar);
    Utils.showLog("Preview User Profile Controller Initialize");
    if (Get.arguments != null) {
      userId = Get.arguments;
    }
    init();
    super.onInit();
  }

  @override
  Future<void> onClose() async {
    tabController?.removeListener(onChangeTabBar);
    Utils.showLog("Preview User Profile Controller Dispose");
    super.onClose();
  }

  Future<void> init() async {
    isLoadingVideo = true;
    isLoadingPost = true;
    isLoadingCollection = true;

    onGetProfile(userId: userId);
    onGetVideo(userId: userId);
  }

  bool isChangingTab = false; // This is use to fixing two time api calling bug...

  Future<void> onChangeTabBar() async {
    isChangingTab = true;

    await 400.milliseconds.delay();

    if (isChangingTab) {
      isChangingTab = false;

      if (tabController?.index == 0) {
        Utils.showLog("Tab Change To Reels => ${tabController?.index}");
        if (isLoadingVideo) {
          onGetVideo(userId: userId);
        }
      } else if (tabController?.index == 1) {
        Utils.showLog("Tab Change To Feeds => ${tabController?.index}");

        if (isLoadingPost) {
          onGetPost(userId: userId);
        }
      } else if (tabController?.index == 2) {
        Utils.showLog("Tab Change To Collections => ${tabController?.index}");

        if (isLoadingCollection) {
          onGetCollection(userId: userId);
        }
      }
    }
  }

  Future<void> onGetProfile({required String userId}) async {
    isLoadingProfile = true;
    update(["onGetProfile"]);
    fetchProfileModel = await FetchProfileApi.callApi(loginUserId: Database.loginUserId, otherUserId: userId);
    if (fetchProfileModel?.userProfileData?.user?.name != null) {
      isLoadingProfile = false;
      isFollow = fetchProfileModel?.userProfileData?.user?.isFollow ?? false;
      update(["onGetProfile"]);
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

  Future<void> onClickFollow() async {
    if (userId != Database.loginUserId) {
      isFollow = !isFollow;
      update(["onClickFollow"]);
      await FollowUnfollowApi.callApi(loginUserId: Database.loginUserId, userId: userId);
    } else {
      Utils.showToast(EnumLocal.txtYouCantFollowYourOwnAccount.name.tr);
    }
  }

  Future<void> onClickReels(int index) async {
    List<PreviewShortsVideoModel> mainShorts = [];
    for (int index = 0; index < videoCollection.length; index++) {
      final video = videoCollection[index];
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
}
