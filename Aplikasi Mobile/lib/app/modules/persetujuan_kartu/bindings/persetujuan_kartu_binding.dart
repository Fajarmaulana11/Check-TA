import 'package:get/get.dart';

import '../controllers/persetujuan_kartu_controller.dart';

class PersetujuanKartuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PersetujuanKartuController>(
      () => PersetujuanKartuController(),
    );
  }
}
