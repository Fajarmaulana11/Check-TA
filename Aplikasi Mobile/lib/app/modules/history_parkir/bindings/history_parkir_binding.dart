import 'package:get/get.dart';

import '../controllers/history_parkir_controller.dart';

class HistoryParkirBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryParkirController>(
      () => HistoryParkirController(),
    );
  }
}
