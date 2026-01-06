import 'package:flutterwave_standard/flutterwave.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:auralive/utils/utils.dart';

class FlutterWaveService {
  static Future<void> init({required String amount, required Callback onPaymentComplete}) async {
    final Customer customer = Customer(name: "Flutter wave Developer", email: "customer@customer.com", phoneNumber: '');

    Utils.showLog("Flutter Wave Id => ${Utils.flutterWaveId}");
    final Flutterwave flutterWave = Flutterwave(
      context: Get.context!,
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

    final ChargeResponse response = await flutterWave.charge();

    Utils.showLog("Flutter Wave Payment Status => ${response.status.toString()}");

    if (response.success == true) {
      onPaymentComplete.call();
    }
    Utils.showLog("Flutter Wave Response => ${response.toString()}");
  }
}
