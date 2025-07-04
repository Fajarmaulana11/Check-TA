import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';


class PersetujuanKartuController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final daftarKartu = <Map<String, dynamic>>[].obs;
  final daftarKartuFiltered = <Map<String, dynamic>>[].obs; // Daftar kartu yang difilter
  final isLoading = false.obs;
  final searchQuery = ''.obs; // Untuk menyimpan query pencarian
  final _database = FirebaseDatabase.instance.ref();


  @override
  void onInit() {
    super.onInit();
    ambilDaftarKartu();
  }

  // Ambil daftar kartu dari Firestore
  Future<void> ambilDaftarKartu() async {
    isLoading.value = true;
    try {
      final snapshot = await _firestore.collection('daftar_kartu_parkir').get();
      daftarKartu.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      daftarKartuFiltered.value = List.from(daftarKartu); // Menginisialisasi daftar kartu yang difilter
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi untuk menghapus kartu
  Future<void> hapusKartu(String id) async {
    try {
      await _firestore.collection('daftar_kartu_parkir').doc(id).delete();
      daftarKartu.removeWhere((item) => item['id'] == id);
      daftarKartuFiltered.removeWhere((item) => item['id'] == id); // Hapus dari daftar yang difilter
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus data: $e");
    }
  }

Future<void> terimaKartu(Map<String, dynamic> data, String uid) async {
  try {
    // Ambil semua RFID dari kartu_parkir
    final snapshot = await _firestore.collection('kartu_parkir').get();
    final existingRfids = snapshot.docs
        .map((doc) => doc['rfid'].toString())
        .where((rfid) => RegExp(r'^\d+$').hasMatch(rfid)) // pastikan hanya angka
        .map((rfid) => int.parse(rfid))
        .toList();

    // Cari nomor RFID terkecil yang belum terpakai
    int nextRfid = 1;
    while (existingRfids.contains(nextRfid)) {
      nextRfid++;
    }

    // Format jadi 3 digit (misal: 001, 002, dst)
    final rfidBaru = nextRfid.toString().padLeft(3, '0');

    final dataBaru = {
      "nama": data["nama"],
      "email": data["email"],
      "noTelp": data["noTelp"], 
      "plat_nomor": data["plat_nomor"],
      "divisi": data["divisi"],
      "rfid": rfidBaru,
      "status": "disetujui",
      "uid": uid,
    };

    // Simpan ke Firestore
    await _firestore.collection('kartu_parkir').add(dataBaru);

    // Hapus dari daftar pengajuan
    await hapusKartu(data['id']);

    // Simpan juga ke Realtime Database
    await _database.child("daftar_kartu/$uid").set({
      "status": false,
      "value": true,
    });

    Get.snackbar("Berhasil", "Kartu berhasil disetujui.");
  } catch (e) {
    Get.snackbar("Error", "Gagal menyetujui data: $e");
  }
}




  // Fungsi untuk melakukan pencarian
  void searchKartu(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      daftarKartuFiltered.value = List.from(daftarKartu); // Jika tidak ada pencarian, tampilkan semua
    } else {
      daftarKartuFiltered.value = daftarKartu
          .where((kartu) => kartu['nama'].toLowerCase().contains(query.toLowerCase()) ||
                           kartu['plat_nomor'].toLowerCase().contains(query.toLowerCase()))
          .toList(); // Filter berdasarkan nama atau plat nomor
    }
  }
}
