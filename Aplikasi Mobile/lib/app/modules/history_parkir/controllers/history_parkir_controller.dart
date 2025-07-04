import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class HistoryParkirController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final riwayat = <Map<String, dynamic>>[].obs;
  final riwayatFiltered = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ambilRiwayat();
  }

  Future<void> ambilRiwayat() async {
    isLoading.value = true;
    try {
      final snapshot = await _firestore
          .collection('history_parkir')
          .orderBy('time', descending: true)
          .get();

      List<Map<String, dynamic>> hasil = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final uid = data['uid'];

        // Ambil info dari kartu_parkir berdasarkan UID
        final kartuSnapshot = await _firestore
            .collection('kartu_parkir')
            .where('uid', isEqualTo: uid)
            .limit(1)
            .get();

        String nama = '-';
        String plat = '-';

        if (kartuSnapshot.docs.isNotEmpty) {
          final kartuData = kartuSnapshot.docs.first.data();
          nama = kartuData['nama']?.toString() ?? '-';
          plat = kartuData['plat_nomor']?.toString() ?? '-';
        }

        hasil.add({
          'uid': uid?.toString() ?? '-',
          'nama': nama,
          'plat': plat,
          'activity': data['activity']?.toString() ?? '-',
          'time': data['time'],
        });
      }

      riwayat.value = hasil;
      riwayatFiltered.value = List.from(hasil);
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat riwayat: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void searchKartu(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      riwayatFiltered.value = List.from(riwayat);
    } else {
      riwayatFiltered.value = riwayat.where((item) {
        final nama = item['nama'].toLowerCase();
        final plat = item['plat'].toLowerCase();
        return nama.contains(query.toLowerCase()) || plat.contains(query.toLowerCase());
      }).toList();
    }
  }
Future<void> hapusSemuaRiwayat() async {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Konfirmasi Hapus",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Apakah kamu yakin ingin menghapus semua riwayat parkir?",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Batal", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Get.back(); // tutup dialog
                    isLoading.value = true;
                    try {
                      final snapshot = await _firestore.collection('history_parkir').get();
                      for (var doc in snapshot.docs) {
                        await doc.reference.delete();
                      }
                      riwayat.clear();
                      riwayatFiltered.clear();
                      Get.snackbar("Berhasil", "Semua data riwayat telah dihapus.");
                    } catch (e) {
                      Get.snackbar("Error", "Gagal menghapus data: $e");
                    } finally {
                      isLoading.value = false;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Hapus", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}



}
