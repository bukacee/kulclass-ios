import 'package:get/get.dart';
import 'package:shortie/pages/verification_request_page/controller/verification_request_controller.dart';

class VerificationRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VerificationRequestController>(() => VerificationRequestController());
  }
}
