// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:shortie/custom/custom_fetch_user_coin.dart';
// import 'package:shortie/custom/custom_format_number.dart';
// import 'package:shortie/custom/custom_range_picker.dart';
// import 'package:shortie/ui/gradient_text_ui.dart';
// import 'package:shortie/ui/no_data_found_ui.dart';
// import 'package:shortie/main.dart';
// import 'package:shortie/pages/my_wallet_page/controller/my_wallet_controller.dart';
// import 'package:shortie/routes/app_routes.dart';
// import 'package:shortie/pages/my_wallet_page/widget/my_wallet_widget.dart';
// import 'package:shortie/shimmer/coin_history_shimmer_ui.dart';
// import 'package:shortie/shimmer/my_wallet_shimmer_ui.dart';
// import 'package:shortie/utils/asset.dart';
// import 'package:shortie/utils/color.dart';
// import 'package:shortie/utils/enums.dart';
// import 'package:shortie/utils/font_style.dart';
// import 'package:shortie/utils/utils.dart';
//
// class MyWalletView extends StatelessWidget {
//   const MyWalletView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<MyWalletController>();
//
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(60),
//         child: AppBar(
//           automaticallyImplyLeading: false,
//           backgroundColor: AppColor.white,
//           shadowColor: AppColor.black.withOpacity(0.4),
//           surfaceTintColor: AppColor.white,
//           flexibleSpace: MyWalletAppBar(),
//         ),
//       ),
//       body: NestedScrollView(
//         headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
//           return <Widget>[
//             SliverAppBar(
//               pinned: true,
//               floating: true,
//               automaticallyImplyLeading: false,
//               backgroundColor: AppColor.white,
//               expandedHeight: 400,
//               surfaceTintColor: AppColor.transparent,
//               flexibleSpace: FlexibleSpaceBar(
//                 background: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 15),
//                   child: Obx(
//                     () => CustomFetchUserCoin.isLoading.value
//                         ? MyWalletShimmerUi()
//                         : Column(
//                             children: [
//                               Divider(color: AppColor.colorGreyHasTagText.withOpacity(0.1), height: 1),
//                               20.height,
//                               Center(
//                                 child: Container(
//                                   height: 160,
//                                   width: 160,
//                                   decoration: BoxDecoration(
//                                     gradient: AppColor.yellowGradient,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Center(
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         border: Border.all(color: AppColor.white, width: 8),
//                                       ),
//                                       child: Image.asset(AppAsset.icWithdrawCoin, width: 128),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               10.height,
//                               Text(
//                                 "${CustomFormatNumber.convert(CustomFetchUserCoin.coin.value)}",
//                                 style: AppFontStyle.styleW700(AppColor.colorOrange, 30),
//                               ),
//                               Text(
//                                 EnumLocal.txtAvailableCoinBalance.name.tr,
//                                 style: AppFontStyle.styleW500(AppColor.colorGreyHasTagText, 14),
//                               ),
//                               18.height,
//                               GestureDetector(
//                                 onTap: () => Get.toNamed(AppRoutes.rechargePage)?.then(
//                                   (value) => CustomFetchUserCoin.init(),
//                                 ),
//                                 child: Container(
//                                   height: 56,
//                                   width: Get.width,
//                                   margin: EdgeInsets.symmetric(horizontal: 15),
//                                   decoration: BoxDecoration(
//                                     gradient: AppColor.primaryLinearGradient,
//                                     borderRadius: BorderRadius.circular(30),
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Text(
//                                         EnumLocal.txtRechargeCoin.name.tr,
//                                         style: AppFontStyle.styleW600(AppColor.white, 18),
//                                       ),
//                                       8.width,
//                                       Image.asset(AppAsset.icDoubleArrowRight, color: AppColor.white, width: 22),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               20.height,
//                               Divider(color: AppColor.colorGreyHasTagText.withOpacity(0.1), height: 1),
//                             ],
//                           ),
//                   ),
//                 ),
//               ),
//               bottom: PreferredSize(
//                 preferredSize: const Size.fromHeight(70),
//                 child: Container(
//                   color: AppColor.white,
//                   height: 70,
//                   padding: EdgeInsets.symmetric(horizontal: 15),
//                   alignment: Alignment.center,
//                   child: Row(
//                     children: [
//                       Image.asset(AppAsset.icCoinHistory, width: 26),
//                       10.width,
//                       GradientTextUi(
//                         EnumLocal.txtCoinHistory.name.tr,
//                         style: AppFontStyle.styleW700(AppColor.primary, 16),
//                         gradient: AppColor.primaryLinearGradient,
//                       ),
//                       Spacer(),
//                       GestureDetector(
//                         onTap: () async {
//                           DateTimeRange? dateTimeRange = await CustomRangePicker.onShow(context);
//                           if (dateTimeRange != null) {
//                             String startDate = DateFormat('yyyy-MM-dd').format(dateTimeRange.start);
//                             String endDate = DateFormat('yyyy-MM-dd').format(dateTimeRange.end);
//
//                             final range = "${DateFormat('dd MMM').format(dateTimeRange.start)} - ${DateFormat('dd MMM').format(dateTimeRange.end)}";
//
//                             Utils.showLog("Selected Date Range => $range");
//
//                             controller.onChangeDate(startDate: startDate, endDate: endDate, rangeDate: range);
//
//                             controller.onGetCoinHistory();
//                           }
//                         },
//                         child: Container(
//                           height: 35,
//                           padding: EdgeInsets.symmetric(horizontal: 12),
//                           decoration: BoxDecoration(
//                             color: AppColor.white,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: AppColor.colorBorderGrey.withOpacity(0.6)),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               GetBuilder<MyWalletController>(
//                                 id: "onChangeDate",
//                                 builder: (controller) => Text(
//                                   controller.rangeDate,
//                                   style: AppFontStyle.styleW500(AppColor.colorDarkGrey, 12),
//                                 ),
//                               ),
//                               8.width,
//                               SizedBox(
//                                 height: 35,
//                                 width: 12,
//                                 child: Stack(
//                                   alignment: Alignment.center,
//                                   children: [
//                                     Positioned(top: 12.5, child: Icon(Icons.keyboard_arrow_down_outlined, size: 19)),
//                                     Positioned(top: 3.5, child: Icon(Icons.keyboard_arrow_up_rounded, size: 20)),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ];
//         },
//         body: GetBuilder<MyWalletController>(
//           id: "onGetCoinHistory",
//           builder: (controller) => controller.isLoading
//               ? CoinHistoryShimmerUi()
//               : controller.coinHistory.isEmpty
//                   ? NoDataFoundUi(iconSize: 160, fontSize: 19)
//                   : RefreshIndicator(
//                       onRefresh: () => controller.init(),
//                       color: AppColor.primary,
//                       child: ListView.builder(
//                           shrinkWrap: true,
//                           padding: EdgeInsets.only(left: 15, right: 15, top: 12),
//                           itemCount: controller.coinHistory.length,
//                           physics: NeverScrollableScrollPhysics(),
//                           itemBuilder: (context, index) {
//                             final historyIndex = controller.coinHistory[index];
//                             return HistoryItemUi(
//                               isPaymentComplete: (historyIndex.type == 1 && historyIndex.isIncome == true) ||
//                                   (historyIndex.type == 2) ||
//                                   (historyIndex.type == 5 && historyIndex.isIncome == true),
//                               title: historyIndex.type == 1 // Gift Send Receive...
//                                   ? historyIndex.isIncome == true
//                                       ? EnumLocal.txtReceiveGiftCoin.name.tr
//                                       : EnumLocal.txtSendGiftCoin.name.tr
//                                   : historyIndex.type == 2 // Coin Plan Purchase...
//                                       ? EnumLocal.txtRechargeCoin.name.tr
//                                       : historyIndex.type == 3 // Withdraw Coin...
//                                           ? historyIndex.payoutStatus == 1
//                                               ? EnumLocal.txtPendingWithdrawal.name.tr
//                                               : historyIndex.payoutStatus == 3
//                                                   ? EnumLocal.txtCancelWithdrawal.name.tr
//                                                   : EnumLocal.txtWithdrawal.name.tr
//                                           : historyIndex.type == 4 // Random Video Call...
//                                               ? ""
//                                               : historyIndex.type == 5 // Welcome Bonus...
//                                                   ? EnumLocal.txtWelcomeBonusCoin.name.tr
//                                                   : "",
//                               date: historyIndex.date ?? "",
//                               uniqueId: historyIndex.uniqueId ?? "",
//                               coin:
//                                   (historyIndex.type == 1 && historyIndex.isIncome == true) || (historyIndex.type == 2) || (historyIndex.type == 5 && historyIndex.isIncome == true)
//                                       ? "+ ${CustomFormatNumber.convert(historyIndex.coin ?? 0)}"
//                                       : "- ${CustomFormatNumber.convert(historyIndex.coin ?? 0)}",
//                               reason: historyIndex.reason ?? "",
//                               giftTitle: historyIndex.type == 1
//                                   ? RichText(
//                                       overflow: TextOverflow.ellipsis,
//                                       maxLines: 1,
//                                       text: TextSpan(
//                                         text: historyIndex.isIncome == true ? EnumLocal.txtReceiveGiftCoin.name.tr : EnumLocal.txtSendGiftCoin.name.tr,
//                                         style: AppFontStyle.styleW700(
//                                             (historyIndex.type == 1 && historyIndex.isIncome == true) ? AppColor.colorClosedGreen : AppColor.colorRedContainer, 13),
//                                         children: [
//                                           TextSpan(
//                                             text: historyIndex.isIncome == true ? " (${historyIndex.senderName})" : " (${historyIndex.receiverName})",
//                                             style: AppFontStyle.styleW400(AppColor.colorGreyHasTagText, 11.5),
//                                           ),
//                                         ],
//                                       ),
//                                     )
//                                   : null,
//                             );
//                           }),
//                     ),
//         ),
//       ),
//     );
//   }
// }
//
// class HistoryItemUi extends StatelessWidget {
//   const HistoryItemUi({
//     super.key,
//     required this.isPaymentComplete,
//     required this.title,
//     required this.date,
//     required this.uniqueId,
//     required this.coin,
//     required this.reason,
//     required this.giftTitle,
//   });
//
//   final String title;
//   final String date;
//   final String uniqueId;
//   final String coin;
//   final bool isPaymentComplete;
//   final String reason;
//   final Widget? giftTitle;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: reason == "" ? 70 : 80,
//       width: Get.width,
//       margin: EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         color: AppColor.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: AppColor.colorBorderGrey.withOpacity(0.6)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           10.width,
//           Container(
//             height: 48,
//             width: 48,
//             decoration: BoxDecoration(
//               color: AppColor.white,
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(color: AppColor.colorBorderGrey.withOpacity(0.4)),
//             ),
//             child: Center(
//               child: Image.asset(AppAsset.icWithdrawCoin, width: 32),
//             ),
//           ),
//           10.width,
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 giftTitle ??
//                     Text(
//                       title,
//                       style: AppFontStyle.styleW700(isPaymentComplete ? AppColor.colorClosedGreen : AppColor.colorRedContainer, 13),
//                     ),
//                 Text(
//                   date,
//                   style: AppFontStyle.styleW500(AppColor.colorGreyHasTagText, 10),
//                 ),
//                 2.height,
//                 Text(
//                   "ID : $uniqueId",
//                   style: AppFontStyle.styleW500(AppColor.colorGreyHasTagText, 10),
//                 ),
//                 Visibility(
//                   visible: reason != "",
//                   child: SizedBox(
//                     width: Get.width / 2,
//                     child: Text(
//                       "Reason : $reason",
//                       maxLines: 1,
//                       style: AppFontStyle.styleW500(AppColor.colorGreyHasTagText, 10),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           10.width,
//           Container(
//             height: 32,
//             padding: EdgeInsets.symmetric(horizontal: 15),
//             decoration: BoxDecoration(
//               color: isPaymentComplete ? AppColor.colorGreenBg.withOpacity(0.8) : AppColor.colorRedBg.withOpacity(0.8),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Center(
//               child: Text(
//                 coin,
//                 style: AppFontStyle.styleW700(isPaymentComplete ? AppColor.colorClosedGreen : AppColor.colorRedContainer, 15),
//               ),
//             ),
//           ),
//           10.width,
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shortie/custom/custom_fetch_user_coin.dart';
import 'package:shortie/custom/custom_format_number.dart';
import 'package:shortie/custom/custom_range_picker.dart';
import 'package:shortie/ui/gradient_text_ui.dart';
import 'package:shortie/ui/no_data_found_ui.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/my_wallet_page/controller/my_wallet_controller.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/pages/my_wallet_page/widget/my_wallet_widget.dart';
import 'package:shortie/shimmer/coin_history_shimmer_ui.dart';
import 'package:shortie/shimmer/my_wallet_shimmer_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/utils.dart';

class MyWalletView extends StatelessWidget {
  const MyWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyWalletController>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColor.white,
          shadowColor: AppColor.black.withOpacity(0.4),
          surfaceTintColor: AppColor.white,
          flexibleSpace: MyWalletAppBar(),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: true,
              floating: true,
              automaticallyImplyLeading: false,
              backgroundColor: AppColor.white,
              expandedHeight: 400,
              surfaceTintColor: AppColor.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Obx(
                    () => CustomFetchUserCoin.isLoading.value
                        ? MyWalletShimmerUi()
                        : Column(
                            children: [
                              Divider(color: AppColor.colorGreyHasTagText.withOpacity(0.1), height: 1),
                              20.height,
                              Center(
                                child: Container(
                                  height: 160,
                                  width: 160,
                                  decoration: BoxDecoration(
                                    gradient: AppColor.yellowGradient,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColor.white, width: 8),
                                      ),
                                      child: Image.asset(AppAsset.icWithdrawCoin, width: 128),
                                    ),
                                  ),
                                ),
                              ),
                              10.height,
                              Text(
                                "${CustomFormatNumber.convert(CustomFetchUserCoin.coin.value)}",
                                style: AppFontStyle.styleW700(AppColor.colorOrange, 30),
                              ),
                              Text(
                                EnumLocal.txtAvailableCoinBalance.name.tr,
                                style: AppFontStyle.styleW500(AppColor.colorGreyHasTagText, 14),
                              ),
                              18.height,
                              GestureDetector(
                                onTap: () => Get.toNamed(AppRoutes.rechargePage)?.then(
                                  (value) => CustomFetchUserCoin.init(),
                                ),
                                child: Container(
                                  height: 56,
                                  width: Get.width,
                                  margin: EdgeInsets.symmetric(horizontal: 15),
                                  decoration: BoxDecoration(
                                    gradient: AppColor.primaryLinearGradient,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        EnumLocal.txtRechargeCoin.name.tr,
                                        style: AppFontStyle.styleW600(AppColor.white, 18),
                                      ),
                                      8.width,
                                      Image.asset(AppAsset.icDoubleArrowRight, color: AppColor.white, width: 22),
                                    ],
                                  ),
                                ),
                              ),
                              20.height,
                              Divider(color: AppColor.colorGreyHasTagText.withOpacity(0.1), height: 1),
                            ],
                          ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: Container(
                  color: AppColor.white,
                  height: 70,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Image.asset(AppAsset.icCoinHistory, width: 26),
                      10.width,
                      GradientTextUi(
                        EnumLocal.txtCoinHistory.name.tr,
                        style: AppFontStyle.styleW700(AppColor.primary, 16),
                        gradient: AppColor.primaryLinearGradient,
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () async {
                          DateTimeRange? dateTimeRange = await CustomRangePicker.onShow(context);
                          if (dateTimeRange != null) {
                            String startDate = DateFormat('yyyy-MM-dd').format(dateTimeRange.start);
                            String endDate = DateFormat('yyyy-MM-dd').format(dateTimeRange.end);

                            final range =
                                "${DateFormat('dd MMM').format(dateTimeRange.start)} - ${DateFormat('dd MMM').format(dateTimeRange.end)}";

                            Utils.showLog("Selected Date Range => $range");

                            controller.onChangeDate(startDate: startDate, endDate: endDate, rangeDate: range);

                            controller.onGetCoinHistory();
                          }
                        },
                        child: Container(
                          height: 35,
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColor.colorBorderGrey.withOpacity(0.6)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GetBuilder<MyWalletController>(
                                id: "onChangeDate",
                                builder: (controller) => Text(
                                  controller.rangeDate,
                                  style: AppFontStyle.styleW500(AppColor.colorDarkGrey, 12),
                                ),
                              ),
                              8.width,
                              SizedBox(
                                height: 35,
                                width: 12,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(top: 12.5, child: Icon(Icons.keyboard_arrow_down_outlined, size: 19)),
                                    Positioned(top: 3.5, child: Icon(Icons.keyboard_arrow_up_rounded, size: 20)),
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
              ),
            ),
          ];
        },
        body: GetBuilder<MyWalletController>(
          id: "onGetCoinHistory",
          builder: (controller) => controller.isLoading
              ? CoinHistoryShimmerUi()
              : controller.coinHistory.isEmpty
                  ? NoDataFoundUi(iconSize: 160, fontSize: 19)
                  : RefreshIndicator(
                      onRefresh: () => controller.init(),
                      color: AppColor.primary,
                      child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.only(left: 15, right: 15, top: 12),
                          itemCount: controller.coinHistory.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final historyIndex = controller.coinHistory[index];
                            return HistoryItemUi(
                              title: historyTitle(historyIndex.type ?? 0, historyIndex.isIncome ?? false,
                                  historyIndex.payoutStatus ?? 0),
                              isPaymentComplete: historyIndex.isIncome ?? false,
                              // isPaymentComplete: (historyIndex.type == 1 && historyIndex.isIncome == true) || (historyIndex.type == 2) || (historyIndex.type == 5 && historyIndex.isIncome == true),
                              // title: historyIndex.type == 1 // Gift Send Receive...
                              //     ? historyIndex.isIncome == true
                              //         ? EnumLocal.txtReceiveGiftCoin.name.tr
                              //         : EnumLocal.txtSendGiftCoin.name.tr
                              //     : historyIndex.type == 2 // Coin Plan Purchase...
                              //         ? EnumLocal.txtRechargeCoin.name.tr
                              //         : historyIndex.type == 3 // Withdraw Coin...
                              //             ? historyIndex.payoutStatus == 1
                              //                 ? EnumLocal.txtPendingWithdrawal.name.tr
                              //                 : historyIndex.payoutStatus == 3
                              //                     ? EnumLocal.txtCancelWithdrawal.name.tr
                              //                     : EnumLocal.txtWithdrawal.name.tr
                              //             : historyIndex.type == 4 // Referral Bonus...
                              //                 ? EnumLocal.txtReferralCoin.name.tr
                              //                 : historyIndex.type == 5 // Welcome Bonus...
                              //                     ? EnumLocal.txtWelcomeBonusCoin.name.tr
                              //                     : "",
                              date: historyIndex.date ?? "",
                              uniqueId: historyIndex.uniqueId ?? "",
                              // coin: (historyIndex.type == 1 && historyIndex.isIncome == true) || (historyIndex.type == 2) || (historyIndex.type == 5 && historyIndex.isIncome == true)
                              coin: (historyIndex.type == 3 && historyIndex.payoutStatus != 2
                                      ? ""
                                      : (historyIndex.isIncome == true ? "+" : "-")) +
                                  CustomFormatNumber.convert(historyIndex.coin ?? 0),

                              // historyIndex.isIncome == true ? "+ ${CustomFormatNumber.convert(historyIndex.coin ?? 0)}" : "- ${CustomFormatNumber.convert(historyIndex.coin ?? 0)}",
                              reason: historyIndex.reason ?? "",

                              giftTitle: historyIndex.type == 1
                                  ? RichText(
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      text: TextSpan(
                                        text: historyIndex.isIncome == true
                                            ? EnumLocal.txtReceiveGiftCoin.name.tr
                                            : EnumLocal.txtSendGiftCoin.name.tr,
                                        style: AppFontStyle.styleW700(
                                            (historyIndex.type == 1 && historyIndex.isIncome == true)
                                                ? AppColor.colorClosedGreen
                                                : AppColor.colorRedContainer,
                                            13),
                                        children: [
                                          TextSpan(
                                            text: historyIndex.isIncome == true
                                                ? " (${historyIndex.senderName})"
                                                : " (${historyIndex.receiverName})",
                                            style: AppFontStyle.styleW400(AppColor.colorGreyHasTagText, 11.5),
                                          ),
                                        ],
                                      ),
                                    )
                                  : null,
                            );
                          }),
                    ),
        ),
      ),
    );
  }
}

class HistoryItemUi extends StatelessWidget {
  const HistoryItemUi({
    super.key,
    required this.isPaymentComplete,
    required this.title,
    required this.date,
    required this.uniqueId,
    required this.coin,
    required this.reason,
    required this.giftTitle,
  });

  final String title;
  final String date;
  final String uniqueId;
  final String coin;
  final bool isPaymentComplete;
  final String reason;
  final Widget? giftTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: reason == "" ? 70 : 80,
      width: Get.width,
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.colorBorderGrey.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          10.width,
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColor.colorBorderGrey.withOpacity(0.4)),
            ),
            child: Center(
              child: Image.asset(AppAsset.icWithdrawCoin, width: 32),
            ),
          ),
          10.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                giftTitle ??
                    Text(
                      title,
                      style: AppFontStyle.styleW700(
                          isPaymentComplete ? AppColor.colorClosedGreen : AppColor.colorRedContainer, 13),
                    ),
                Text(
                  date,
                  style: AppFontStyle.styleW500(AppColor.colorGreyHasTagText, 10),
                ),
                2.height,
                Text(
                  "ID : $uniqueId",
                  style: AppFontStyle.styleW500(AppColor.colorGreyHasTagText, 10),
                ),
                Visibility(
                  visible: reason != "",
                  child: SizedBox(
                    width: Get.width / 2,
                    child: Text(
                      "Reason : $reason",
                      maxLines: 1,
                      style: AppFontStyle.styleW500(AppColor.colorGreyHasTagText, 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          10.width,
          Container(
            height: 32,
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: isPaymentComplete ? AppColor.colorGreenBg.withOpacity(0.8) : AppColor.colorRedBg.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                coin,
                style: AppFontStyle.styleW700(
                    isPaymentComplete ? AppColor.colorClosedGreen : AppColor.colorRedContainer, 15),
              ),
            ),
          ),
          10.width,
        ],
      ),
    );
  }
}

String historyTitle(int type, bool isIncome, int status) {
  // status 1 > pending 2 > complete 3 > cancel
  String value = "";

  switch (type) {
    case 1:
      {
        value = isIncome ? EnumLocal.txtReceiveGiftCoin.name.tr : EnumLocal.txtSendGiftCoin.name.tr;
      }
    case 2:
      {
        value = EnumLocal.txtRechargeCoin.name.tr;
      }
    case 3:
      {
        value = status == 1
            ? EnumLocal.txtPendingWithdrawal.name.tr
            : status == 2
                ? EnumLocal.txtWithdrawal.name.tr
                : status == 3
                    ? EnumLocal.txtCancelWithdrawal.name.tr
                    : "";
      }
    case 4:
      {
        value = EnumLocal.txtWelcomeBonusCoin.name.tr;
      }
  }

  return value;
}
