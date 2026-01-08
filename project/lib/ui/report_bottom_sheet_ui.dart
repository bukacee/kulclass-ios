import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auralive/main.dart';
// ❌ REMOVED: CreateReportApi import (Controller handles it now)
import 'package:auralive/pages/splash_screen_page/api/fetch_report_api.dart';
import 'package:auralive/pages/splash_screen_page/model/fetch_report_model.dart';
import 'package:auralive/shimmer/report_bottom_sheet_shimmer_ui.dart';
import 'package:auralive/utils/asset.dart';
import 'package:auralive/utils/color.dart';
import 'package:auralive/size_extension.dart';
import 'package:auralive/utils/enums.dart';
import 'package:auralive/utils/font_style.dart';

class ReportBottomSheetUi {
  static RxInt selectedReportType = 0.obs;
  static RxBool isLoading = false.obs;
  static FetchReportModel? fetchReportModel;
  static List<Data> reportTypes = [];

  // ✅ FETCH REASONS (Kept this logic)
  static Future<void> onGetReports() async {
    if (reportTypes.isEmpty) {
      isLoading.value = true;
      fetchReportModel = await FetchReportApi.callApi();

      if (fetchReportModel?.data != null) {
        reportTypes.addAll(fetchReportModel?.data ?? []);
      }
      isLoading.value = false;
    }
  }

  // ✅ UPDATED SHOW METHOD
  static void show({
    required BuildContext context,
    required Function(String reason) onReport, // <--- THE NEW CALLBACK
  }) async {
    onGetReports();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: AppColor.transparent,
      builder: (context) => Container(
        height: 500,
        width: Get.width,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 65,
              color: AppColor.grey_100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 4,
                        width: 35,
                        decoration: BoxDecoration(
                          color: AppColor.colorTextDarkGrey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      10.height,
                      Text(
                        EnumLocal.txtReport.name.tr,
                        style: AppFontStyle.styleW700(AppColor.black, 17),
                      ),
                    ],
                  ).paddingOnly(left: 50),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 30,
                      width: 30,
                      margin: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.transparent,
                        border: Border.all(color: AppColor.black),
                      ),
                      child: Center(
                        child: Image.asset(
                          width: 18,
                          AppAsset.icClose,
                          color: AppColor.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => isLoading.value
                  ? Expanded(child: ReportBottomSheetShimmerUi())
                  : Expanded(
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          itemCount: reportTypes.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => selectedReportType.value = index,
                              child: Container(
                                height: 46,
                                color: AppColor.transparent,
                                padding: const EdgeInsets.only(left: 15),
                                child: Row(
                                  children: [
                                    Obx(() => ReportRadioButtonUi(isSelected: selectedReportType.value == index)),
                                    12.width,
                                    Text(
                                      reportTypes[index].title ?? "",
                                      style: AppFontStyle.styleW500(AppColor.black, 16),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ),
            Obx(
              () => Visibility(
                visible: !isLoading.value,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // CANCEL BUTTON
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColor.colorTabBar.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            EnumLocal.txtCancel.name.tr,
                            style: AppFontStyle.styleW700(AppColor.colorTabBar, 16),
                          ),
                        ),
                      ),
                      15.width,
                      
                      // ✅ REPORT BUTTON (Now calls the callback)
                      GestureDetector(
                        onTap: () {
                          // 1. Close the sheet
                          Get.back(); 
                          
                          // 2. Get the reason string
                          String reason = "";
                          if (reportTypes.isNotEmpty && selectedReportType.value < reportTypes.length) {
                             reason = reportTypes[selectedReportType.value].title ?? "";
                          }
                          
                          // 3. Pass reason to the Controller to handle API + Hiding
                          onReport(reason); 
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: AppColor.primaryLinearGradient,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            EnumLocal.txtReport.name.tr,
                            style: AppFontStyle.styleW700(AppColor.white, 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportRadioButtonUi extends StatelessWidget {
  const ReportRadioButtonUi({super.key, required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      color: AppColor.transparent,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? null : AppColor.transparent,
              gradient: isSelected ? AppColor.primaryLinearGradient : null,
            ),
            child: Container(
              height: 20,
              width: 20,
              margin: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? null : AppColor.colorGreyBg,
                border: Border.all(color: isSelected ? AppColor.white : AppColor.primary.withOpacity(0.5), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}