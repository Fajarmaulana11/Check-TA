import 'package:get/get.dart';

import '../controllers/daftar_kartu_controller.dart';

class DaftarKartuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DaftarKartuController>(
      () => DaftarKartuController(),
    );
  }
}
