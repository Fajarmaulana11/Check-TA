import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siparkir/app/routes/app_pages.dart';

class LoginController extends GetxController {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var emailResetController = TextEditingController();  // Menambahkan deklarasi emailResetController
  var isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GetStorage storage = GetStorage();

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showSnackbar("Error", "Email dan password tidak boleh kosong", Colors.redAccent);
      return;
    }

    try {
      isLoading.value = true;

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      isLoading.value = false;
      showSnackbar("Success", "Login berhasil", Colors.black);

      storage.write("isLoggedIn", true);
      storage.write("userEmail", userCredential.user?.email);

      Get.offAllNamed(Routes.HOME);
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = "Format email tidak valid.";
          break;
        case 'user-not-found':
          errorMessage = "Akun tidak ditemukan. Periksa kembali email Anda.";
          break;
        case 'wrong-password':
          errorMessage = "Password salah. Coba lagi.";
          break;
        case 'too-many-requests':
          errorMessage = "Terlalu banyak percobaan. Coba lagi nanti.";
          break;
        default:
          errorMessage = "Terjadi kesalahan. Coba lagi nanti.";
      }

      showSnackbar("Login Gagal", errorMessage, Colors.redAccent);
    } catch (e) {
      isLoading.value = false;
      showSnackbar("Error", "Terjadi kesalahan: ${e.toString()}", Colors.redAccent);
    }
  }

  void resetPassword(String email) async {
    if (email.isEmpty) {
      showSnackbar("Error", "Email tidak boleh kosong", Colors.redAccent);
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      showSnackbar("Berhasil", "Tautan reset kata sandi telah dikirim ke email Anda.", Colors.black);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = "Format email tidak valid.";
          break;
        case 'user-not-found':
          errorMessage = "Pengguna dengan email ini tidak ditemukan.";
          break;
        default:
          errorMessage = "Terjadi kesalahan. Coba lagi nanti.";
      }
      showSnackbar("Gagal", errorMessage, Colors.redAccent);
    } catch (e) {
      showSnackbar("Error", "Terjadi kesalahan: ${e.toString()}", Colors.redAccent);
    }
  }

  void showForgotPasswordDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Reset Kata Sandi",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Masukkan email yang terdaftar untuk menerima tautan reset.",
                style: GoogleFonts.poppins(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailResetController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: Get.back,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Batal",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final String email = emailResetController.text.trim();
                      Navigator.of(Get.context!).pop();
                      resetPassword(email);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Kirim",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
    emailResetController.dispose();  // Menambahkan dispose untuk emailResetController
    super.onClose();
  }
}
