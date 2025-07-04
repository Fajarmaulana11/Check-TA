import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:siparkir/app/routes/app_pages.dart';

class LoginAdminController extends GetxController {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var secretCodeController = TextEditingController();
  var isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GetStorage storage = GetStorage();

  final String secretCode = "ICON33";
  final String allowedAdminEmail = "admin@gmail.com"; // <- tambahkan di sini

  void loginAdmin() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String code = secretCodeController.text.trim();

    if (email.isEmpty || password.isEmpty || code.isEmpty) {
      showSnackbar("Error", "Semua kolom harus diisi", Colors.redAccent);
      return;
    }

    if (email != allowedAdminEmail) {
      showSnackbar("Email Tidak Diizinkan", "Hanya email admin yang boleh login", Colors.redAccent);
      return;
    }

    if (code != secretCode) {
      showSnackbar("Kode Rahasia Salah", "Kode tidak sesuai", Colors.redAccent);
      return;
    }

    try {
      isLoading.value = true;

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      isLoading.value = false;
      showSnackbar("Success", "Login admin berhasil", Colors.black);

      storage.write("isLoggedIn", true);
      storage.write("userEmail", userCredential.user?.email);
      storage.write("isAdmin", true);

      Get.offAllNamed(Routes.HOME_ADMIN); // arahkan ke home admin
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      showSnackbar("Login Gagal", e.message ?? "Terjadi kesalahan", Colors.redAccent);
    }
  }

  void showSnackbar(String title, String message, Color backgroundColor) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    secretCodeController.dispose();
    super.onClose();
  }
}
