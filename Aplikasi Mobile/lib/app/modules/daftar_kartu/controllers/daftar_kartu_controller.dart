import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DaftarKartuController extends GetxController {
  final namaController = TextEditingController();
  final teleponController = TextEditingController();
  final divisiController = TextEditingController();
  final platNomorController = TextEditingController();
  final emailController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    getUserData();
  }

  void getUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final snapshot = await _firestore.collection('users').doc(uid).get();
        if (snapshot.exists) {
          final data = snapshot.data();
          namaController.text = data?['name'] ?? '';
          teleponController.text = data?['noTelp'] ?? '';
          divisiController.text = data?['devisi'] ?? '';
          emailController.text = data?['email'] ?? '';
        } else {
          Get.snackbar("Error", "Data user tidak ditemukan di Firestore.");
        }
      } else {
        Get.snackbar("Error", "User belum login.");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil data user: $e");
    }
  }

  void simpanData() async {
    if (platNomorController.text.trim().isEmpty) {
      Get.snackbar("Validasi", "Plat Nomor tidak boleh kosong.");
      return;
    }
    try {
      await _firestore.collection('daftar_kartu_parkir').add({
        'nama': namaController.text,
        'noTelp': teleponController.text,
        'divisi': divisiController.text,
        'plat_nomor': platNomorController.text,
        'email': emailController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Get.snackbar("Berhasil", "Data berhasil disimpan.");
      clearForm();
    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan data: $e");
    }
  }

  void clearForm() {
    platNomorController.clear();
  }

  @override
  void onClose() {
    namaController.dispose();
    teleponController.dispose();
    divisiController.dispose();
    platNomorController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
