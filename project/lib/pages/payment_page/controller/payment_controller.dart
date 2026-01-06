import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shortie/pages/payment_page/payment/flutter_wave/flutter_wave_services.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/pages/payment_page/api/create_coin_plan_history_api.dart';
import 'package:shortie/pages/payment_page/payment/in_app_purchase/iap_callback.dart';
import 'package:shortie/pages/payment_page/payment/in_app_purchase/in_app_purchase_helper.dart';
import 'package:shortie/pages/payment_page/payment/razor_pay/razor_pay_view.dart';
import 'package:shortie/pages/payment_page/payment/stripe/stripe_service.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/utils.dart';

class PaymentController extends GetxController implements IAPCallback {
  String coinPlanId = "";
  int coinAmount = 0;
  String productKey = "";
  Map<String, PurchaseDetails>? purchases;

  @override
  void onInit() {
    Utils.showLog("Selected Plan => ${Get.arguments}");
    if (Get.arguments != null) {
      coinPlanId = Get.arguments["id"];
      coinAmount = Get.arguments["amount"];
      productKey = Get.arguments["productKey"];
    }

    InAppPurchaseHelper().getAlreadyPurchaseItems(this);
    purchases = InAppPurchaseHelper().getPurchases();
    InAppPurchaseHelper().clearTransactions();
    super.onInit();
  }

  final paymentMethodList = [
    {"icon": AppAsset.icGoogleLogo, "title": "Google Pay", "size": "27.0"},
    {"icon": AppAsset.icRazorPayLogo, "title": "Razor Pay", "size": "35.0"},
    {"icon": AppAsset.icStripeLogo, "title": "Stripe", "size": "35.0"},
    {"icon": AppAsset.icFlutterWaveLogo, "title": "Flutter Wave", "size": "30"},
  ];

  int selectedPaymentMethod = 0;

  void onChangePaymentMethod(int index) async {
    selectedPaymentMethod = index;
    update(["onChangePaymentMethod"]);
  }

  Future<void> onClickPayNow() async {
    // >>>>> >>>>> >>>>> In App Purchase Payment <<<<< <<<<< <<<<<

    if (selectedPaymentMethod == 0) {
      List<String> kProductIds = <String>[productKey];

      await InAppPurchaseHelper().init(
        paymentType: "In App Purchase",
        userId: Database.loginUserId,
        productKey: kProductIds,
        rupee: coinAmount.toDouble(),
        callBack: () async {
          Utils.showLog("In App Purchase Payment Successfully");

          Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
          final isSuccess = await CreateCoinPlanHistoryApi.callApi(loginUserId: Database.loginUserId, coinPlanId: coinPlanId, paymentType: "In App Purchase");
          Get.back(); // Stop Loading...
          if (isSuccess) {
            Utils.showToast(EnumLocal.txtCoinRechargeSuccess.name.tr);
            Get.close(2);
          } else {
            Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
          }
        },
      );

      InAppPurchaseHelper().initStoreInfo();

      await Future.delayed(const Duration(seconds: 1));

      ProductDetails? product = InAppPurchaseHelper().getProductDetail(productKey);

      if (product != null) {
        InAppPurchaseHelper().buySubscription(product, purchases!);
      }
    }

    // >>>>> >>>>> >>>>> RazorPay Payment <<<<< <<<<< <<<<<

    if (selectedPaymentMethod == 1) {
      Utils.showLog("Razorpay Payment Working....");

      try {
        Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
        RazorPayService().init(
          razorKey: Utils.razorpayTestKey,
          callback: () async {
            Utils.showLog("RazorPay Payment Successfully");

            Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
            final isSuccess = await CreateCoinPlanHistoryApi.callApi(loginUserId: Database.loginUserId, coinPlanId: coinPlanId, paymentType: "Razorpay");
            Get.back(); // Stop Loading...
            if (isSuccess) {
              Utils.showToast(EnumLocal.txtCoinRechargeSuccess.name.tr);
              Get.close(2);
            } else {
              Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
            }
          },
        );
        await 1.seconds.delay();
        RazorPayService().razorPayCheckout((coinAmount * 100).toInt());
        Get.back(); // Stop Loading...
      } catch (e) {
        Get.back(); // Stop Loading...
        Utils.showLog("RazorPay Payment Failed => $e");
      }
    }

    // >>>>> >>>>> >>>>> Stripe Payment <<<<< <<<<< <<<<<

    if (selectedPaymentMethod == 2) {
      try {
        Utils.showLog("Stripe Payment Working...");
        Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
        await StripeService().init(isTest: true);
        await 1.seconds.delay();
        StripeService()
            .stripePay(
          amount: (coinAmount * 100).toInt(),
          callback: () async {
            Utils.showLog("Stripe Payment Success Method Called....");
            Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
            final isSuccess = await CreateCoinPlanHistoryApi.callApi(loginUserId: Database.loginUserId, coinPlanId: coinPlanId, paymentType: "Stripe");
            Get.back(); // Stop Loading...
            if (isSuccess) {
              Utils.showToast(EnumLocal.txtCoinRechargeSuccess.name.tr);
              Get.close(2);
            } else {
              Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
            }
          },
        )
            .then((value) async {
          Utils.showLog("Stripe Payment Successfully");
        }).catchError((e) {
          Utils.showLog("Stripe Payment Error !!!");
        });
        Get.back(); // Stop Loading...
      } catch (e) {
        Get.back(); // Stop Loading...
        Utils.showLog("Stripe Payment Failed !! => $e");
      }
    }

    // >>>>> >>>>> >>>>> Flutter Wave Payment <<<<< <<<<< <<<<<

    if (selectedPaymentMethod == 3) {
      Utils.showLog("Flutter Wave Payment Working....");

      try {
        Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
        FlutterWaveService.init(
          amount: coinAmount.toString(),
          onPaymentComplete: () async {
            Utils.showLog("Flutter Wave Payment Successfully");

            Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

            final isSuccess = await CreateCoinPlanHistoryApi.callApi(loginUserId: Database.loginUserId, coinPlanId: coinPlanId, paymentType: "Flutter Wave");

            Get.back(); // Stop Loading...

            if (isSuccess) {
              Utils.showToast(EnumLocal.txtCoinRechargeSuccess.name.tr);
              Get.close(2);
            } else {
              Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
            }
          },
        );

        Get.back(); // Stop Loading...
      } catch (e) {
        Get.back(); // Stop Loading...
        Utils.showLog("Flutter Wave Payment Failed => $e");
      }
    }
  }

  @override
  void onBillingError(error) {}

  @override
  void onLoaded(bool initialized) {}

  @override
  void onPending(PurchaseDetails product) {}

  @override
  void onSuccessPurchase(PurchaseDetails product) {}
}
