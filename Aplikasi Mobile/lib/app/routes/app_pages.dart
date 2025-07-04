import 'package:get/get.dart';

import '../modules/cek_kartu/bindings/cek_kartu_binding.dart';
import '../modules/cek_kartu/views/cek_kartu_view.dart';
import '../modules/daftar_kartu/bindings/daftar_kartu_binding.dart';
import '../modules/daftar_kartu/views/daftar_kartu_view.dart';
import '../modules/history_parkir/bindings/history_parkir_binding.dart';
import '../modules/history_parkir/views/history_parkir_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home_admin/bindings/home_admin_binding.dart';
import '../modules/home_admin/views/home_admin_view.dart';
import '../modules/kartu_terdaftar/bindings/kartu_terdaftar_binding.dart';
import '../modules/kartu_terdaftar/views/kartu_terdaftar_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/login_admin/bindings/login_admin_binding.dart';
import '../modules/login_admin/views/login_admin_view.dart';
import '../modules/notifikasi/bindings/notifikasi_binding.dart';
import '../modules/notifikasi/views/notifikasi_view.dart';
import '../modules/persetujuan_kartu/bindings/persetujuan_kartu_binding.dart';
import '../modules/persetujuan_kartu/views/persetujuan_kartu_view.dart';
import '../modules/signup/bindings/signup_binding.dart';
import '../modules/signup/views/signup_view.dart';
import '../modules/splashscreen/bindings/splashscreen_binding.dart';
import '../modules/splashscreen/views/splashscreen_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASHSCREEN,
      page: () => const SplashscreenView(),
      binding: SplashscreenBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => const SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFIKASI,
      page: () => const NotifikasiView(),
      binding: NotifikasiBinding(),
    ),
    GetPage(
      name: _Paths.CEK_KARTU,
      page: () => const CekKartuView(),
      binding: CekKartuBinding(),
    ),
    GetPage(
      name: _Paths.DAFTAR_KARTU,
      page: () => const DaftarKartuView(),
      binding: DaftarKartuBinding(),
    ),
    GetPage(
      name: _Paths.HOME_ADMIN,
      page: () => const HomeAdminView(),
      binding: HomeAdminBinding(),
    ),
    GetPage(
      name: _Paths.PERSETUJUAN_KARTU,
      page: () => const PersetujuanKartuView(),
      binding: PersetujuanKartuBinding(),
    ),
    GetPage(
      name: _Paths.KARTU_TERDAFTAR,
      page: () => const KartuTerdaftarView(),
      binding: KartuTerdaftarBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN_ADMIN,
      page: () => const LoginAdminView(),
      binding: LoginAdminBinding(),
    ),
    GetPage(
      name: _Paths.HISTORY_PARKIR,
      page: () => const HistoryParkirView(),
      binding: HistoryParkirBinding(),
    ),
  ];
}
