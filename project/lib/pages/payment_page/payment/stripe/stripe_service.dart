import 'dart:convert';
import 'dart:developer';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:http/http.dart' as http;
import 'package:shortie/pages/payment_page/payment/stripe/stripe_pay_model.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/utils.dart';
//
// class StripeService {
//   bool isTest = false;
//
//   init({
//     required bool isTest,
//   }) async {
//     Stripe.publishableKey = Utils.stripeTestPublicKey;
//     Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
//
//     await Stripe.instance.applySettings().catchError((e) {
//       Utils.showLog("Stripe Apply Settings => $e");
//       throw e.toString();
//     });
//
//     this.isTest = isTest;
//   }
//
//   Future<dynamic> stripePay({required int amount, required Callback callback}) async {
//     try {
//       Map<String, dynamic> body = {
//         'amount': amount.toString(),
//         'currency': Utils.stripeCurrencyCode,
//         'description':
//             'Name: ${Database.fetchLoginUserProfileModel?.user?.name ?? ""} - Email: ${Database.fetchLoginUserProfileModel?.user?.email ?? ""}',
//       };
//
//       Utils.showLog("Start Payment Intent Http Request.....");
//
//       var response = await http.post(Uri.parse(Utils.stripeUrl), body: body, headers: {
//         "Authorization": "Bearer ${Utils.stripeTestSecretKey}",
//         "Content-Type": 'application/x-www-form-urlencoded'
//       });
//
//       Utils.showLog("End Payment Intent Http Request.....");
//
//       Utils.showLog("Payment Intent Http Response => ${response.body}");
//
//       if (response.statusCode == 200) {
//         StripePayModel result = StripePayModel.fromJson(jsonDecode(response.body));
//
//         Utils.showLog("Stripe Payment Response => $result");
//
//         SetupPaymentSheetParameters setupPaymentSheetParameters = SetupPaymentSheetParameters(
//           paymentIntentClientSecret: result.clientSecret,
//           appearance: const PaymentSheetAppearance(colors: PaymentSheetAppearanceColors(primary: AppColor.primary)),
//           applePay: PaymentSheetApplePay(merchantCountryCode: Utils.stripeMerchantCountryCode),
//           googlePay: PaymentSheetGooglePay(merchantCountryCode: Utils.stripeMerchantCountryCode, testEnv: isTest),
//           merchantDisplayName: EnumLocal.txtAppName.name.tr,
//           customerId: Database.loginUserId,
//           customerEphemeralKeySecret: result.clientSecret,
//           setupIntentClientSecret: result.clientSecret,
//           billingDetails: BillingDetails(
//             name: Database.fetchLoginUserProfileModel?.user?.name ?? "",
//             email: Database.fetchLoginUserProfileModel?.user?.email ?? "",
//           ),
//         );
//
//         await Stripe.instance.initPaymentSheet(paymentSheetParameters: setupPaymentSheetParameters).then((value) async {
//           await Stripe.instance.presentPaymentSheet().then((value) async {
//             Utils.showLog("*** Stripe Payment Success ***");
//             callback.call();
//           }).catchError((e) {
//             Utils.showLog("Init Payment Sheet Error => $e");
//           });
//         }).catchError((e) {
//           Utils.showLog("Something Went Wrong => $e");
//         });
//       } else if (response.statusCode == 401) {
//         Utils.showLog("Error During Stripe Payment");
//       }
//       return jsonDecode(response.body);
//     } catch (e) {
//       Utils.showLog('Error Charging User => ${e.toString()}');
//     }
//   }
// }

class StripeService {
  bool isTest = false;

  init({
    required bool isTest,
  }) async {
    Stripe.publishableKey = Utils.stripeTestPublicKey;
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';

    await Stripe.instance.applySettings().catchError((e) {
      log("Stripe Apply Settings => $e");
      throw e.toString();
    });

    this.isTest = isTest;
  }

  Future<dynamic> stripePay({required int amount, required Callback callback}) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount.toString(),
        'currency': Utils.stripeCurrencyCode,
        'description': 'Name: "hello" - Email: "hello@gmail.com"',
      };

      log("Start Payment Intent Http Request.....");

      var response = await http
          .post(Uri.parse(Utils.stripeUrl), body: body, headers: {"Authorization": "Bearer ${Utils.stripeTestSecretKey}", "Content-Type": 'application/x-www-form-urlencoded'});

      log("End Payment Intent Http Request.....");

      log("Payment Intent Http Response => ${response.body}");

      if (response.statusCode == 200) {
        StripePayModel result = StripePayModel.fromJson(jsonDecode(response.body));

        log("Stripe Payment Response => $result");

        SetupPaymentSheetParameters setupPaymentSheetParameters = SetupPaymentSheetParameters(
          paymentIntentClientSecret: result.clientSecret,
          appearance: const PaymentSheetAppearance(colors: PaymentSheetAppearanceColors(primary: AppColor.primary)),
          applePay: PaymentSheetApplePay(merchantCountryCode: Utils.stripeMerchantCountryCode),
          googlePay: PaymentSheetGooglePay(merchantCountryCode: Utils.stripeMerchantCountryCode, testEnv: isTest),
          merchantDisplayName: "Hello",
          customerId: Database.loginUserId,
          billingDetails: const BillingDetails(name: "Hello", email: "hello@gmail.com"),
        );

        await Stripe.instance.initPaymentSheet(paymentSheetParameters: setupPaymentSheetParameters).then((value) async {
          await Stripe.instance.presentPaymentSheet().then((value) async {
            log("***** Payment Done *****");
            callback.call();
            Utils.showLog("Stripe Payment Success Method Called....");
            Utils.showLog("Stripe Payment Successfully");
          }).catchError((e) {
            log("Init Payment Sheet Error => $e");
          });
        }).catchError((e) {
          log("Something Went Wrong => $e");
        });
      } else if (response.statusCode == 401) {
        // appStore.setLoading(false);
        log("Error During Stripe Payment");
      }
      return jsonDecode(response.body);
    } catch (e) {
      log('Error Charging User: ${e.toString()}');
    }
  }
}
