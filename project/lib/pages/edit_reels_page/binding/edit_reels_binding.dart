import 'package:get/get.dart';
import 'package:shortie/pages/edit_reels_page/controller/edit_reels_controller.dart';

class EditReelsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditReelsController>(() => EditReelsController());
  }
}
