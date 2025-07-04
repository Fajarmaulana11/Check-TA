import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';

class KartuTerdaftarController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  final daftarKartu = <Map<String, dynamic>>[].obs;
  final daftarKartuFiltered = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ambilSemuaKartu();
  }

  Future<void> ambilSemuaKartu() async {
    isLoading.value = true;
    try {
      final snapshot = await _firestore.collection('kartu_parkir').get();
      daftarKartu.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      daftarKartuFiltered.value = List.from(daftarKartu);
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void searchKartu(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      daftarKartuFiltered.value = List.from(daftarKartu);
    } else {
      daftarKartuFiltered.value = daftarKartu.where((kartu) =>
        kartu['nama'].toLowerCase().contains(query.toLowerCase()) ||
        kartu['plat_nomor'].toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
  }

  Future<void> hapusKartu(String id) async {
  try {
    final doc = await _firestore.collection('kartu_parkir').doc(id).get();
    final uid = doc.data()?['uid'];

    await _firestore.collection('kartu_parkir').doc(id).delete();

    if (uid != null && uid.toString().isNotEmpty) {
      await _database.ref('daftar_kartu/$uid').remove();
    }

    daftarKartu.removeWhere((item) => item['id'] == id);
    daftarKartuFiltered.removeWhere((item) => item['id'] == id);
    Get.snackbar("Berhasil", "Data berhasil dihapus");
  } catch (e) {
    Get.snackbar("Error", "Gagal menghapus data: $e");
  }
}


  Future<void> updateKartu(String id, Map<String, dynamic> dataBaru) async {
  try {
    final doc = await _firestore.collection('kartu_parkir').doc(id).get();
    final uidLama = doc.data()?['uid'];

    // Update di Firestore
    await _firestore.collection('kartu_parkir').doc(id).update(dataBaru);

    final uidBaru = dataBaru['uid'];

    // Hapus UID lama di Realtime Database (kalau berbeda)
    if (uidLama != null && uidLama != uidBaru) {
      await _database.ref('daftar_kartu/$uidLama').remove();
    }

    // Tambahkan UID baru
    if (uidBaru != null) {
      await _database.ref('daftar_kartu/$uidBaru').set({
        "status": false,
        "value": true,
      });
    }

    ambilSemuaKartu();
    Get.snackbar("Berhasil", "Data berhasil diperbarui");
  } catch (e) {
    Get.snackbar("Error", "Gagal memperbarui data: $e");
  }
}


}
