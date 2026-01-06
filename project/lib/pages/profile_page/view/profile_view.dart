import 'dart:async';
import 'dart:developer';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/custom/custom_fetch_user_coin.dart';
import 'package:shortie/custom/custom_format_number.dart';
import 'package:shortie/pages/bottom_bar_page/controller/bottom_bar_controller.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/ui/preview_country_flag_ui.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/shimmer/profile_shimmer_ui.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/profile_page/controller/profile_controller.dart';
import 'package:shortie/pages/profile_page/widget/profile_widget.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.init();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Get.find<BottomBarController>().onChangeBottomBar(0);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.white,
          automaticallyImplyLeading: false,
          shadowColor: AppColor.black.withOpacity(0.4),
          surfaceTintColor: AppColor.transparent,
          flexibleSpace: const Center(child: ProfileAppBarUi()),
        ),
        body: RefreshIndicator(
          notificationPredicate: (notification) {
            return notification.depth == 2;
          },
          onRefresh: () async => await controller.init(),
          child: NestedScrollView(
            controller: controller.scrollController,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      GetBuilder<ProfileController>(
                        id: "onGetProfile",
                        builder: (controller) => controller.isLoadingProfile
                            ? ProfileShimmerUi()
                            : Container(
                                color: AppColor.white,
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    15.height,
                                    Row(
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: AppColor.primaryLinearGradient,
                                          ),
                                          child: GestureDetector(
                                            onTap: controller.onClickEditProfile,
                                            child: Container(
                                              height: 100,
                                              width: 100,
                                              margin: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(color: AppColor.white, width: 1.5),
                                              ),
                                              child: Stack(
                                                clipBehavior: Clip.none,
                                                alignment: Alignment.bottomRight,
                                                children: [
                                                  Container(
                                                    height: 100,
                                                    width: 100,
                                                    clipBehavior: Clip.antiAlias,
                                                    decoration: BoxDecoration(shape: BoxShape.circle),
                                                    child:
                                                        Image.asset(AppAsset.icProfilePlaceHolder, fit: BoxFit.cover),
                                                  ),
                                                  Container(
                                                    height: 100,
                                                    width: 100,
                                                    clipBehavior: Clip.antiAlias,
                                                    decoration: BoxDecoration(shape: BoxShape.circle),
                                                    child: PreviewNetworkImageUi(
                                                        image:
                                                            controller.fetchProfileModel?.userProfileData?.user?.image),
                                                  ),
                                                  Visibility(
                                                    visible: controller.fetchProfileModel?.userProfileData?.user
                                                            ?.isProfileImageBanned ??
                                                        false,
                                                    child: Container(
                                                      clipBehavior: Clip.antiAlias,
                                                      decoration: BoxDecoration(shape: BoxShape.circle),
                                                      child: BlurryContainer(
                                                        height: 100,
                                                        width: 100,
                                                        blur: 3,
                                                        borderRadius: BorderRadius.circular(50),
                                                        color: AppColor.black.withOpacity(0.3),
                                                        child: Offstage(),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 5,
                                                    right: -10,
                                                    child: Container(
                                                      height: 36,
                                                      width: 36,
                                                      padding: const EdgeInsets.all(7),
                                                      decoration: BoxDecoration(
                                                        color: AppColor.white,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(color: AppColor.colorBorder, width: 1.5),
                                                      ),
                                                      alignment: Alignment.center,
                                                      child: Image.asset(AppAsset.icEdit),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        18.width,
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Flexible(
                                                    fit: FlexFit.loose,
                                                    child: Text(
                                                      maxLines: 1,
                                                      controller.fetchProfileModel?.userProfileData?.user?.name ?? "",
                                                      style: AppFontStyle.styleW700(AppColor.black, 18),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        Database.fetchLoginUserProfileModel?.user?.isVerified ?? false,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 3),
                                                      child: Image.asset(AppAsset.icBlueTick, width: 20),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                controller.fetchProfileModel?.userProfileData?.user?.userName ?? "",
                                                style: AppFontStyle.styleW400(AppColor.colorGreyHasTagText, 13),
                                              ),
                                              5.height,
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  PreviewCountryFlagUi.show(controller
                                                      .fetchProfileModel?.userProfileData?.user?.countryFlagImage),
                                                  10.width,
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                                                    decoration: BoxDecoration(
                                                      color: AppColor.secondary,
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Image.asset(
                                                          ((controller.fetchProfileModel?.userProfileData?.user?.gender
                                                                          ?.toLowerCase() ??
                                                                      "male") ==
                                                                  "male")
                                                              ? AppAsset.icMale
                                                              : AppAsset.icFemale,
                                                          width: 14,
                                                          color: AppColor.white,
                                                        ),
                                                        5.width,
                                                        Text(
                                                          ((controller.fetchProfileModel?.userProfileData?.user?.gender
                                                                          ?.toLowerCase() ??
                                                                      "male") ==
                                                                  "male")
                                                              ? EnumLocal.txtMale.name.tr
                                                              : EnumLocal.txtFemale.name.tr,
                                                          style: AppFontStyle.styleW600(AppColor.white, 12),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    10.height,
                                    Visibility(
                                      visible:
                                          controller.fetchProfileModel?.userProfileData?.user?.bio?.trim().isNotEmpty ??
                                              false,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          controller.fetchProfileModel?.userProfileData?.user?.bio?.trim() ?? "",
                                          style: AppFontStyle.styleW400(AppColor.black, 13),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 75,
                                      width: Get.width,
                                      color: AppColor.white,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  CustomFormatNumber.convert(controller
                                                          .fetchProfileModel?.userProfileData?.totalLikesOfVideoPost ??
                                                      0),
                                                  style: AppFontStyle.styleW700(AppColor.black, 18),
                                                ),
                                                2.height,
                                                Text(
                                                  EnumLocal.txtLikes.name.tr,
                                                  style: AppFontStyle.styleW400(AppColor.coloGreyText, 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                          VerticalDivider(
                                            indent: 20,
                                            endIndent: 20,
                                            width: 0,
                                            thickness: 2,
                                            color: AppColor.coloGreyText.withOpacity(0.2),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: controller.onClickFollowing,
                                              child: Container(
                                                color: AppColor.transparent,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      CustomFormatNumber.convert(controller
                                                              .fetchProfileModel?.userProfileData?.totalFollowing ??
                                                          0),
                                                      style: AppFontStyle.styleW700(AppColor.black, 18),
                                                    ),
                                                    2.height,
                                                    Text(
                                                      EnumLocal.txtFollowing.name.tr,
                                                      style: AppFontStyle.styleW400(AppColor.coloGreyText, 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          VerticalDivider(
                                            indent: 20,
                                            endIndent: 20,
                                            width: 0,
                                            thickness: 2,
                                            color: AppColor.coloGreyText.withOpacity(0.2),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: controller.onClickFollowers,
                                              child: Container(
                                                color: AppColor.transparent,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      CustomFormatNumber.convert(controller
                                                              .fetchProfileModel?.userProfileData?.totalFollowers ??
                                                          0),
                                                      style: AppFontStyle.styleW700(AppColor.black, 18),
                                                    ),
                                                    2.height,
                                                    Text(
                                                      EnumLocal.txtFollowers.name.tr,
                                                      style: AppFontStyle.styleW400(AppColor.coloGreyText, 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    5.height,
                                    Container(
                                      height: 102,
                                      width: Get.width,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        gradient: AppColor.primaryLinearGradient,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Stack(
                                        children: [
                                          SizedBox(
                                            height: 102,
                                            width: Get.width,
                                            child: Image.asset(
                                              AppAsset.icWithdrawBg,
                                              fit: BoxFit.cover,
                                              opacity: AlwaysStoppedAnimation(0.6),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 25),
                                            child: SizedBox(
                                              height: 102,
                                              width: Get.width,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        EnumLocal.txtAvailableCoin.name.tr,
                                                        style: AppFontStyle.styleW600(AppColor.white, 18),
                                                      ),
                                                      5.height,
                                                      Row(
                                                        children: [
                                                          Obx(
                                                            () => Text(
                                                              CustomFormatNumber.convert(
                                                                  CustomFetchUserCoin.coin.value),
                                                              style: AppFontStyle.styleW700(AppColor.white, 35),
                                                            ),
                                                          ),
                                                          15.width,
                                                          GestureDetector(
                                                            onTap: () => Get.toNamed(AppRoutes.myWalletPage),
                                                            child: Container(
                                                              height: 32,
                                                              padding: EdgeInsets.symmetric(horizontal: 15),
                                                              decoration: BoxDecoration(
                                                                color: AppColor.white,
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Text(
                                                                    EnumLocal.txtMyWallet.name.tr,
                                                                    style: AppFontStyle.styleW700(
                                                                        AppColor.colorDarkOrange, 13),
                                                                  ),
                                                                  10.width,
                                                                  Image.asset(
                                                                    AppAsset.icDoubleArrowRightWithoutRadius,
                                                                    width: 14,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Spacer(),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(color: AppColor.white, width: 4),
                                                    ),
                                                    child: Image.asset(AppAsset.icWithdrawCoin, width: 60),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                PreferredSize(
                  preferredSize: const Size.fromHeight(75),
                  child: SliverAppBar(
                    pinned: true,
                    floating: true,
                    automaticallyImplyLeading: false,
                    backgroundColor: AppColor.white,
                    surfaceTintColor: AppColor.transparent,
                    toolbarHeight: 0,
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(75),
                      child: Container(
                        decoration: BoxDecoration(color: AppColor.white),
                        child: TabBar(
                          controller: controller.tabController,
                          labelColor: AppColor.colorTabBar,
                          labelStyle: AppFontStyle.styleW600(AppColor.black.withOpacity(0.8), 13),
                          unselectedLabelColor: AppColor.colorUnselectedIcon,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorWeight: 2,
                          indicatorPadding: const EdgeInsets.only(top: 72, right: 10, left: 10),
                          indicator: const BoxDecoration(
                            gradient: AppColor.primaryLinearGradient,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          tabs: <Tab>[
                            Tab(
                              icon: const ImageIcon(AssetImage(AppAsset.icReels), size: 30),
                              text: EnumLocal.txtReels.name.tr,
                            ),
                            Tab(
                              icon: const ImageIcon(AssetImage(AppAsset.icFeeds), size: 30),
                              text: EnumLocal.txtFeeds.name.tr,
                            ),
                            Tab(
                              icon: const ImageIcon(AssetImage(AppAsset.icCollections), size: 30),
                              text: EnumLocal.txtCollections.name.tr,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: controller.tabController,
              physics: const BouncingScrollPhysics(),
              children: const [
                ReelsTabView(),
                FeedsTabView(),
                CollectionsTabView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// SliverAppBar(
//   pinned: true,
//   floating: true,
//   automaticallyImplyLeading: false,
//   backgroundColor: AppColor.white,
//   expandedHeight: 485,
//   surfaceTintColor: AppColor.transparent,
//   flexibleSpace: LayoutBuilder(builder: (context, constraints) {
//     final double offset = constraints.biggest.height;
//
//     Timer(
//       Duration(milliseconds: 10),
//       () {
//         controller.isTabBarPinned.value = offset <= (kToolbarHeight + Get.statusBarHeight);
//       },
//     );
//     return FlexibleSpaceBar(
//       background: GetBuilder<ProfileController>(
//         id: "onGetProfile",
//         builder: (controller) => controller.isLoadingProfile
//             ? ProfileShimmerUi()
//             : Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 15),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Container(
//                       decoration: const BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient: AppColor.primaryLinearGradient,
//                       ),
//                       child: GestureDetector(
//                         onTap: controller.onClickEditProfile,
//                         child: Container(
//                           height: 124,
//                           width: 124,
//                           margin: const EdgeInsets.all(2),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(color: AppColor.white, width: 1.5),
//                           ),
//                           child: Stack(
//                             alignment: Alignment.bottomRight,
//                             children: [
//                               Container(
//                                 height: 124,
//                                 width: 124,
//                                 clipBehavior: Clip.antiAlias,
//                                 decoration: BoxDecoration(shape: BoxShape.circle),
//                                 child: Image.asset(AppAsset.icProfilePlaceHolder, fit: BoxFit.cover),
//                               ),
//                               Container(
//                                 height: 124,
//                                 width: 124,
//                                 clipBehavior: Clip.antiAlias,
//                                 decoration: BoxDecoration(shape: BoxShape.circle),
//                                 child: PreviewNetworkImageUi(image: controller.fetchProfileModel?.userProfileData?.user?.image),
//                               ),
//                               Visibility(
//                                 visible: controller.fetchProfileModel?.userProfileData?.user?.isProfileImageBanned ?? false,
//                                 child: Container(
//                                   clipBehavior: Clip.antiAlias,
//                                   decoration: BoxDecoration(shape: BoxShape.circle),
//                                   child: BlurryContainer(
//                                     height: 124,
//                                     width: 124,
//                                     blur: 3,
//                                     borderRadius: BorderRadius.circular(50),
//                                     color: AppColor.black.withOpacity(0.3),
//                                     child: Offstage(),
//                                   ),
//                                 ),
//                               ),
//                               Container(
//                                 height: 36,
//                                 width: 36,
//                                 padding: const EdgeInsets.all(7),
//                                 decoration: BoxDecoration(
//                                   color: AppColor.white,
//                                   shape: BoxShape.circle,
//                                   border: Border.all(color: AppColor.colorBorder, width: 1.5),
//                                 ),
//                                 alignment: Alignment.center,
//                                 child: Image.asset(AppAsset.icEdit),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     10.height,
//                     SizedBox(
//                       width: Get.width,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Flexible(
//                             fit: FlexFit.loose,
//                             child: Text(
//                               maxLines: 1,
//                               controller.fetchProfileModel?.userProfileData?.user?.name ?? "",
//                               style: AppFontStyle.styleW700(AppColor.black, 18),
//                             ),
//                           ),
//                           Visibility(
//                             visible: Database.fetchLoginUserProfileModel?.user?.isVerified ?? false,
//                             child: Padding(
//                               padding: const EdgeInsets.only(left: 3),
//                               child: Image.asset(AppAsset.icBlueTick, width: 20),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Text(
//                       controller.fetchProfileModel?.userProfileData?.user?.userName ?? "",
//                       style: AppFontStyle.styleW400(AppColor.colorGreyHasTagText, 13),
//                     ),
//                     10.height,
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         PreviewCountryFlagUi.show(controller.fetchProfileModel?.userProfileData?.user?.countryFlagImage),
//                         10.width,
//                         Container(
//                           padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
//                           decoration: BoxDecoration(
//                             color: AppColor.secondary,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Image.asset(
//                                 ((controller.fetchProfileModel?.userProfileData?.user?.gender?.toLowerCase() ?? "male") == "male")
//                                     ? AppAsset.icMale
//                                     : AppAsset.icFemale,
//                                 width: 14,
//                                 color: AppColor.white,
//                               ),
//                               5.width,
//                               Text(
//                                 ((controller.fetchProfileModel?.userProfileData?.user?.gender?.toLowerCase() ?? "male") == "male")
//                                     ? EnumLocal.txtMale.name.tr
//                                     : EnumLocal.txtFemale.name.tr,
//                                 style: AppFontStyle.styleW600(AppColor.white, 12),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     Container(
//                       height: 75,
//                       width: Get.width,
//                       color: AppColor.white,
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   CustomFormatNumber.convert(controller.fetchProfileModel?.userProfileData?.totalLikesOfVideoPost ?? 0),
//                                   style: AppFontStyle.styleW700(AppColor.black, 18),
//                                 ),
//                                 2.height,
//                                 Text(
//                                   EnumLocal.txtLikes.name.tr,
//                                   style: AppFontStyle.styleW400(AppColor.coloGreyText, 12),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           VerticalDivider(
//                             indent: 20,
//                             endIndent: 20,
//                             width: 0,
//                             thickness: 2,
//                             color: AppColor.coloGreyText.withOpacity(0.2),
//                           ),
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: controller.onClickFollowing,
//                               child: Container(
//                                 color: AppColor.transparent,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       CustomFormatNumber.convert(controller.fetchProfileModel?.userProfileData?.totalFollowing ?? 0),
//                                       style: AppFontStyle.styleW700(AppColor.black, 18),
//                                     ),
//                                     2.height,
//                                     Text(
//                                       EnumLocal.txtFollowing.name.tr,
//                                       style: AppFontStyle.styleW400(AppColor.coloGreyText, 12),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           VerticalDivider(
//                             indent: 20,
//                             endIndent: 20,
//                             width: 0,
//                             thickness: 2,
//                             color: AppColor.coloGreyText.withOpacity(0.2),
//                           ),
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: controller.onClickFollowers,
//                               child: Container(
//                                 color: AppColor.transparent,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       CustomFormatNumber.convert(controller.fetchProfileModel?.userProfileData?.totalFollowers ?? 0),
//                                       style: AppFontStyle.styleW700(AppColor.black, 18),
//                                     ),
//                                     2.height,
//                                     Text(
//                                       EnumLocal.txtFollowers.name.tr,
//                                       style: AppFontStyle.styleW400(AppColor.coloGreyText, 12),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     5.height,
//                     Container(
//                       height: 102,
//                       width: Get.width,
//                       clipBehavior: Clip.antiAlias,
//                       decoration: BoxDecoration(
//                         gradient: AppColor.primaryLinearGradient,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Stack(
//                         children: [
//                           SizedBox(
//                             height: 102,
//                             width: Get.width,
//                             child: Image.asset(
//                               AppAsset.icWithdrawBg,
//                               fit: BoxFit.cover,
//                               opacity: AlwaysStoppedAnimation(0.6),
//                             ),
//                           ),
//                           Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 25),
//                             child: SizedBox(
//                               height: 102,
//                               width: Get.width,
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Text(
//                                         EnumLocal.txtAvailableCoin.name.tr,
//                                         style: AppFontStyle.styleW600(AppColor.white, 18),
//                                       ),
//                                       5.height,
//                                       Row(
//                                         children: [
//                                           Obx(
//                                             () => Text(
//                                               CustomFormatNumber.convert(CustomFetchUserCoin.coin.value),
//                                               style: AppFontStyle.styleW700(AppColor.white, 35),
//                                             ),
//                                           ),
//                                           15.width,
//                                           GestureDetector(
//                                             onTap: () => Get.toNamed(AppRoutes.myWalletPage),
//                                             child: Container(
//                                               height: 32,
//                                               padding: EdgeInsets.symmetric(horizontal: 15),
//                                               decoration: BoxDecoration(
//                                                 color: AppColor.white,
//                                                 borderRadius: BorderRadius.circular(8),
//                                               ),
//                                               child: Row(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: [
//                                                   Text(
//                                                     EnumLocal.txtMyWallet.name.tr,
//                                                     style: AppFontStyle.styleW700(AppColor.colorDarkOrange, 13),
//                                                   ),
//                                                   10.width,
//                                                   Image.asset(
//                                                     AppAsset.icDoubleArrowRightWithoutRadius,
//                                                     width: 14,
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                   Spacer(),
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       shape: BoxShape.circle,
//                                       border: Border.all(color: AppColor.white, width: 4),
//                                     ),
//                                     child: Image.asset(AppAsset.icWithdrawCoin, width: 60),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }),
//   // bottom: PreferredSize(
//   //   preferredSize: const Size.fromHeight(75),
//   //   child: Container(
//   //     decoration: BoxDecoration(color: AppColor.white),
//   //     child: TabBar(
//   //       controller: controller.tabController,
//   //       labelColor: AppColor.colorTabBar,
//   //       labelStyle: AppFontStyle.styleW600(AppColor.black.withOpacity(0.8), 13),
//   //       unselectedLabelColor: AppColor.colorUnselectedIcon,
//   //       indicatorSize: TabBarIndicatorSize.tab,
//   //       indicatorWeight: 2,
//   //       indicatorPadding: const EdgeInsets.only(top: 72, right: 10, left: 10),
//   //       indicator: const BoxDecoration(
//   //         gradient: AppColor.primaryLinearGradient,
//   //         borderRadius: BorderRadius.all(Radius.circular(5)),
//   //       ),
//   //       tabs: <Tab>[
//   //         Tab(
//   //           icon: const ImageIcon(AssetImage(AppAsset.icReels), size: 30),
//   //           text: EnumLocal.txtReels.name.tr,
//   //         ),
//   //         Tab(
//   //           icon: const ImageIcon(AssetImage(AppAsset.icFeeds), size: 30),
//   //           text: EnumLocal.txtFeeds.name.tr,
//   //         ),
//   //         Tab(
//   //           icon: const ImageIcon(AssetImage(AppAsset.icCollections), size: 30),
//   //           text: EnumLocal.txtCollections.name.tr,
//   //         ),
//   //       ],
//   //     ),
//   //   ),
//   // ),
// ),
