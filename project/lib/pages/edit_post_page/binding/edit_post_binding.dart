import 'package:get/get.dart';
import 'package:shortie/pages/edit_post_page/controller/edit_post_controller.dart';

class EditPostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditPostController>(() => EditPostController());
  }
}
