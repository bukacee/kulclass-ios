import 'package:get/get.dart';
import 'package:shortie/pages/stream_page/controller/stream_controller.dart';

class StreamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StreamController>(() => StreamController());
  }
}
