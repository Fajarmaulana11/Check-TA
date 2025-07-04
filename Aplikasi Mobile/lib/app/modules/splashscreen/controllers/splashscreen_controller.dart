import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:siparkir/app/routes/app_pages.dart';

class SplashscreenController extends GetxController {
  final GetStorage storage = GetStorage();

  @override
  void onInit() {
    super.onInit();

    Future.delayed(const Duration(seconds: 3), () {
      bool isLoggedIn = storage.read("isLoggedIn") ?? false;
      String? email = storage.read("userEmail");

      if (isLoggedIn) {
        if (email == "admin@gmail.com") {
          Get.offAllNamed(Routes.HOME_ADMIN);
        } else {
          Get.offAllNamed(Routes.HOME);
        }
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    });
  }
}
