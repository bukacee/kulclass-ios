import 'package:get/get.dart';
import 'package:shortie/pages/fill_profile_page/controller/fill_profile_controller.dart';

class FillProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FillProfileController>(() => FillProfileController());
  }
}
