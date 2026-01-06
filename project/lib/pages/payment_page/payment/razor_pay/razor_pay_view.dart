import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/utils.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';

class RazorPayService {
  static late Razorpay razorPay;
  static late String razorKeys;
  Callback onComplete = () {};

  void init({
    required String razorKey,
    required Callback callback,
  }) {
    razorPay = Razorpay();
    razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
    razorKeys = razorKey;
    onComplete = () => callback.call();
  }

  void razorPayCheckout(int amount) async {
    debugPrint("Payment Amount => $amount");
    var options = {
      'key': Utils.razorpayTestKey,
      'amount': amount,
      'name': EnumLocal.txtAppName.name.tr,
      'theme.color': AppColor.primary.value.toRadixString(16),
      'description': EnumLocal.txtAppName.name,
      'currency': Utils.razorpayCurrencyCode,
      'prefill': {'contact': "", 'email': Database.fetchLoginUserProfileModel?.user?.email ?? ""},
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      razorPay.open(options);
    } catch (e) {
      debugPrint("Razor Payment Error => ${e.toString()}");
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) async => onComplete.call();

  void handlePaymentError(PaymentFailureResponse response) {
    Utils.showLog("RazorPay Payment Failed !! => ${response.message}");
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    Utils.showLog("RazorPay Payment External Wallet !! => ${response.walletName}");
  }
}
