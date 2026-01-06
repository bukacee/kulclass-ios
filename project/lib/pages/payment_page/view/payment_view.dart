import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/ui/app_button_ui.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/payment_page/controller/payment_controller.dart';
import 'package:shortie/pages/payment_page/widget/payment_widget.dart';
import 'package:shortie/ui/simple_app_bar_ui.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/utils.dart';

class PaymentView extends StatelessWidget {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColor.white,
          shadowColor: AppColor.black.withOpacity(0.4),
          flexibleSpace: SimpleAppBarUi(title: "Payment"),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                EnumLocal.txtSelectPaymentMethod.name.tr,
                style: AppFontStyle.styleW700(AppColor.black, 16),
              ),
              15.height,
              GetBuilder<PaymentController>(
                id: "onChangePaymentMethod",
                builder: (controller) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(visible: Utils.isShowInAppPurchasePaymentMethod, child: PaymentItemUi(0)),
                    Visibility(visible: Utils.isShowRazorPayPaymentMethod, child: PaymentItemUi(1)),
                    Visibility(visible: Utils.isShowStripePaymentMethod, child: PaymentItemUi(2)),
                    Visibility(visible: true, child: PaymentItemUi(3)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: GetBuilder<PaymentController>(
          builder: (controller) => AppButtonUi(
            height: 56,
            title: EnumLocal.txtPayNow.name.tr,
            gradient: AppColor.primaryLinearGradient,
            callback: controller.onClickPayNow,
          ),
        ),
      ),
    );
  }
}

class PaymentItemUi extends GetView<PaymentController> {
  const PaymentItemUi(this.index, {super.key});

  final int index;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.onChangePaymentMethod(index),
      child: Container(
        height: 70,
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
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.colorBorderGrey.withOpacity(0.4)),
              ),
              child: Center(
                child: Image.asset(
                  controller.paymentMethodList[index]["icon"]!,
                  width: double.parse(controller.paymentMethodList[index]["size"]!),
                ),
              ),
            ),
            10.width,
            Text(
              controller.paymentMethodList[index]["title"]!,
              style: AppFontStyle.styleW700(AppColor.black, 16),
            ),
            Spacer(),
            PaymentRadioButtonUi(isSelected: controller.selectedPaymentMethod == index),
            15.width,
          ],
        ),
      ),
    );
  }
}
