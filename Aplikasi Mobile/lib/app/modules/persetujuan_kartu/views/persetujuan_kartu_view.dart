import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/persetujuan_kartu_controller.dart';
import '../../../widgets/kartu_persetujuan_item.dart';

class PersetujuanKartuView extends GetView<PersetujuanKartuController> {
  const PersetujuanKartuView({super.key});

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
                          'Persetujuan Kartu Parkir',
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
              // Kolom pencarian
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
                    "Tidak ada permintaan kartu parkir.",
                    style: GoogleFonts.poppins(fontSize: 14),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: controller.daftarKartuFiltered.length,
                    itemBuilder: (context, index) {
                      final data = controller.daftarKartuFiltered[index];
                      return KartuPersetujuanItem(
                        data: data,
                        onHapus: () => controller.hapusKartu(data['id']),
                        onTerima: (uid) => controller.terimaKartu(data, uid),
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
