import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/cek_kartu_controller.dart';
import '../../../widgets/kartu_karyawan.dart'; // pastikan path widget sesuai

class CekKartuView extends GetView<CekKartuController> {
  const CekKartuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 253, 253),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                          'Kartu Tap Parkir Karyawan',
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
              const SizedBox(height: 30),
              Obx(() {
                if (controller.isLoading.value) {
                  return const CircularProgressIndicator();
                }

                if (controller.kartuList.isEmpty) {
                  return Text(
                    "Belum ada kartu yang terdaftar.",
                    style: GoogleFonts.poppins(fontSize: 14),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: controller.kartuList.length,
                    itemBuilder: (context, index) {
                      final data = controller.kartuList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: KartuKaryawanWidget(
                          nama: data['nama'] ?? '-',
                          divisi: data['divisi'] ?? '-',
                          platNomor: data['plat_nomor'] ?? '-',
                          rfid: data['rfid'] ?? '-',
                        ),
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
}

