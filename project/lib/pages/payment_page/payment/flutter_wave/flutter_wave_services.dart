import 'package:flutter/material.dart'; // 1. IMPORT THIS
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:auralive/utils/utils.dart';

class FlutterWaveService {
  // 2. Add 'required BuildContext context' here
  static Future<void> init({
    required BuildContext context, 
    required String amount, 
    required Callback onPaymentComplete
  }) async {
    final Customer customer = Customer(
      name: "Flutter wave Developer", 
      email: "customer@customer.com", 
      phoneNumber: ''
    );

    Utils.showLog("Flutter Wave Id => ${Utils.flutterWaveId}");
    
    // Note: Depending on your package version, you might also need 
    // to pass 'context: context' inside this constructor. 
    // If the compiler complains here, add 'context: context,' below.
    final Flutterwave flutterWave = Flutterwave( 
      publicKey: Utils.flutterWaveId,
      currency: Utils.flutterWaveCurrencyCode,
      redirectUrl: "https://www.google.com/",
      txRef: DateTime.now().microsecond.toString(),
      amount: amount,
      customer: customer,
      paymentOptions: "ussd, card, barter, pay attitude",
      customization: Customization(title: "Heart Haven"),
      isTestMode: true,
    );

    Utils.showLog("Flutter Wave Payment Finish");

    // 3. PASS CONTEXT HERE to fix the "1 argument required" error
    final ChargeResponse response = await flutterWave.charge(context);

    Utils.showLog("Flutter Wave Payment Status => ${response.status.toString()}");

    if (response.success == true) {
      onPaymentComplete.call();
    }
    Utils.showLog("Flutter Wave Response => ${response.toString()}");
  }
}