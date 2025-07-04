import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/kartu_karyawan_widget.dart';
import '../controllers/kartu_terdaftar_controller.dart';

class KartuTerdaftarView extends GetView<KartuTerdaftarController> {
  const KartuTerdaftarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 253, 253),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Daftar Kartu Terdaftar',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
    

// 👉 Jumlah kartu
Obx(() => Align(
  alignment: Alignment.centerLeft,
  child: Text(
    'Jumlah Kartu Terdaftar: ${controller.daftarKartu.length}',
    style: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),
)),
const SizedBox(height: 8),

              // 🔍 Search Field
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  onChanged: controller.searchKartu,
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau plat nomor...',
                    filled: true,
                    fillColor: Colors.black12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),

              Obx(() {
                if (controller.isLoading.value) {
                  return const CircularProgressIndicator();
                }

                if (controller.daftarKartuFiltered.isEmpty) {
                  return Text(
                    "Belum ada kartu yang terdaftar.",
                    style: GoogleFonts.poppins(fontSize: 14),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: controller.daftarKartuFiltered.length,
                    itemBuilder: (context, index) {
                      final data = controller.daftarKartuFiltered[index];
                      return KartuKaryawanWidget(
                        nama: data['nama'] ?? '-',
                        divisi: data['divisi'] ?? '-',
                        platNomor: data['plat_nomor'] ?? '-',
                        rfid: data['rfid'] ?? '-',
                        uid: data['uid'] ?? '-', // ✅ Tambahkan UID
                        onEdit: () => _showEditModal(context, controller, data),
                        onHapus: () => controller.hapusKartu(data['id']),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

 void _showEditModal(BuildContext context, KartuTerdaftarController controller, Map<String, dynamic> data) {
  final namaC = TextEditingController(text: data['nama']);
  final emailC = TextEditingController(text: data['email']);
  final noHpC = TextEditingController(text: data['noTelp']);
  final divisiC = TextEditingController(text: data['divisi']);
  final platNomorC = TextEditingController(text: data['plat_nomor']);
  final uidC = TextEditingController(text: data['uid']);

  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.grey[700],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Edit Data Karyawan",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField("Nama", namaC),
              const SizedBox(height: 10),
              _buildTextField("Email", emailC),
              const SizedBox(height: 10),
              _buildTextField("No HP", noHpC),
              const SizedBox(height: 10),
              _buildTextField("Divisi", divisiC),
              const SizedBox(height: 10),
              _buildTextField("Plat Nomor", platNomorC),
              const SizedBox(height: 10),
              _buildTextField("UID", uidC),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: Text("Batal", style: GoogleFonts.poppins()),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (namaC.text.isEmpty ||
                          emailC.text.isEmpty ||
                          noHpC.text.isEmpty ||
                          divisiC.text.isEmpty ||
                          platNomorC.text.isEmpty ||
                          uidC.text.isEmpty) {
                        Get.snackbar("Validasi", "Semua field harus diisi!");
                        return;
                      }

                      controller.updateKartu(data['id'], {
                        'nama': namaC.text,
                        'email': emailC.text,
                        'noTelp': noHpC.text,
                        'divisi': divisiC.text,
                        'plat_nomor': platNomorC.text,
                        'uid': uidC.text,
                      });

                      Navigator.pop(context);
                    },
                    child: Text("Simpan", style: GoogleFonts.poppins()),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    ),
  );
}


  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white38),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
