import 'package:get/get.dart';

import '../controllers/kartu_terdaftar_controller.dart';

class KartuTerdaftarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KartuTerdaftarController>(
      () => KartuTerdaftarController(),
    );
  }
}
