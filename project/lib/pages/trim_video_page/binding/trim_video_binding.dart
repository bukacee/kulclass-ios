import 'package:get/get.dart';
import 'package:shortie/pages/trim_video_page/controller/trim_video_controller.dart';

class TrimVideoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrimVideoController>(() => TrimVideoController());
  }
}
