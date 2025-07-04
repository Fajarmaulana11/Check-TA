import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:siparkir/app/routes/app_pages.dart'; // UBAH DI SINI

class SignupController extends GetxController {
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var devisiController = TextEditingController();
  var noTelpController = TextEditingController();
  var isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void signup() async {
  String name = nameController.text.trim();
  String email = emailController.text.trim();
  String password = passwordController.text.trim();
  String devisi = devisiController.text.trim();
  String noTelp = noTelpController.text.trim();

  if (name.isEmpty || email.isEmpty || password.isEmpty || devisi.isEmpty || noTelp.isEmpty) {
    showSnackbar("Error", "Semua kolom harus diisi!", Colors.redAccent);
    return;
  }

  isLoading.value = true;

  try {
    Get.focusScope?.unfocus();

    // 🔍 Cek apakah noTelp sudah digunakan
    final existingPhone = await _firestore
        .collection("users")
        .where("noTelp", isEqualTo: noTelp)
        .limit(1)
        .get();

    if (existingPhone.docs.isNotEmpty) {
      showSnackbar("Signup Gagal", "Nomor telepon sudah digunakan.", Colors.redAccent);
      isLoading.value = false;
      return;
    }

    // ✅ Buat akun baru
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection("users").doc(userCredential.user!.uid).set({
      "name": name,
      "email": email,
      "devisi": devisi,
      "noTelp": noTelp,
      "createdAt": FieldValue.serverTimestamp(),
    });

    showSnackbar("Success", "Registrasi berhasil!", Colors.black);
    Get.offAllNamed(Routes.LOGIN);
  } on FirebaseAuthException catch (e) {
    String errorMessage = "Terjadi kesalahan.";
    if (e.code == 'email-already-in-use') {
      errorMessage = "Email sudah digunakan.";
    } else if (e.code == 'weak-password') {
      errorMessage = "Gunakan password yang lebih kuat.";
    }
    showSnackbar("Signup Gagal", errorMessage, Colors.redAccent);
  } catch (e) {
    showSnackbar("Error", "Gagal mendaftar: ${e.toString()}", Colors.redAccent);
  } finally {
    isLoading.value = false;
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    devisiController.dispose();
    noTelpController.dispose();
    super.onClose();
  }
}
