import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../controllers/history_parkir_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryParkirView extends GetView<HistoryParkirController> {
  const HistoryParkirView({super.key});

  Future<void> _downloadPdf() async {
    final pdf = pw.Document();
    final controller = Get.find<HistoryParkirController>();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Riwayat Parkir', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              pw.Table.fromTextArray(
                headers: ['UID', 'Nama', 'Plat', 'Aktivitas', 'Waktu'],
                data: controller.riwayatFiltered.map((item) {
                  final time = item['time'] is Timestamp
                      ? DateFormat('dd/MM/yyyy HH:mm').format((item['time'] as Timestamp).toDate())
                      : item['time']?.toString() ?? '-';

                  return [
                    item['uid'] ?? '-',
                    item['nama'] ?? '-',
                    item['plat'] ?? '-',
                    item['activity'] ?? '-',
                    time,
                  ];
                }).toList(),
                cellStyle: const pw.TextStyle(fontSize: 10),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 253, 253),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "hapusSemua",
            onPressed: controller.hapusSemuaRiwayat,
            backgroundColor: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "downloadPdf",
            onPressed: _downloadPdf,
            backgroundColor: Colors.black,
            child: const Icon(Icons.picture_as_pdf, color: Colors.white),
          ),
        ],
      ),
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
                          'Riwayat Parkir',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

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

                if (controller.riwayatFiltered.isEmpty) {
                  return Text(
                    "Belum ada riwayat parkir.",
                    style: GoogleFonts.poppins(fontSize: 14),
                  );
                }

                return Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20,
                      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.black87),
                      headingTextStyle: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      dataTextStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      columns: const [
                        DataColumn(label: Text("UID")),
                        DataColumn(label: Text("Nama")),
                        DataColumn(label: Text("Plat")),
                        DataColumn(label: Text("Aktivitas")),
                        DataColumn(label: Text("Waktu")),
                      ],
                      rows: List<DataRow>.generate(
                        controller.riwayatFiltered.length,
                        (index) {
                          final item = controller.riwayatFiltered[index];
                          final formattedTime = item['time'] is Timestamp
                              ? DateFormat('dd/MM/yyyy . HH:mm').format(
                                  (item['time'] as Timestamp).toDate(),
                                )
                              : item['time']?.toString() ?? '-';

                          final isEven = index % 2 == 0;

                          return DataRow(
                            color: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                                return isEven
                                    ? const Color(0xFFF7F7F7)
                                    : const Color(0xFFEFEFEF);
                              },
                            ),
                            cells: [
                              DataCell(Text(item['uid'] ?? '-')),
                              DataCell(Text(item['nama'] ?? '-')),
                              DataCell(Text(item['plat'] ?? '-')),
                              DataCell(Text(item['activity'] ?? '-')),
                              DataCell(Text(formattedTime)),
                            ],
                          );
                        },
                      ),
                    ),
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
