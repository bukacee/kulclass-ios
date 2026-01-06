import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/main.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';

class NoDataFoundUi extends StatelessWidget {
  const NoDataFoundUi({
    super.key,
    required this.iconSize,
    required this.fontSize,
  });

  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppAsset.icNoDataFound, width: iconSize),
          15.height,
          Text(
            EnumLocal.txtNoDataFound.name.tr,
            style: AppFontStyle.styleW500(AppColor.colorGreyHasTagText, fontSize),
          ),
        ],
      ),
    );
  }
}
