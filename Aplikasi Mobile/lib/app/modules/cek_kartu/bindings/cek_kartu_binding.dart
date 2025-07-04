import 'package:get/get.dart';

import '../controllers/cek_kartu_controller.dart';

class CekKartuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CekKartuController>(
      () => CekKartuController(),
    );
  }
}
