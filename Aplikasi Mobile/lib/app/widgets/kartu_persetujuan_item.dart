import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class KartuPersetujuanItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onHapus;
  final Function(String uid) onTerima;

  const KartuPersetujuanItem({
    super.key,
    required this.data,
    required this.onHapus,
    required this.onTerima,
  });

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.grey[700],
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Detail Pengajuan",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text("Nama: ${data['nama']}", style: GoogleFonts.poppins(color: Colors.white)),
              Text("Divisi: ${data['divisi']}", style: GoogleFonts.poppins(color: Colors.white)),
              Text("Email: ${data['email']}", style: GoogleFonts.poppins(color: Colors.white)),
              Text("Telepon: ${data['telepon']}", style: GoogleFonts.poppins(color: Colors.white)),
              Text("Plat Nomor: ${data['plat_nomor']}", style: GoogleFonts.poppins(color: Colors.white)),
              Text("Tanggal Pengajuan: ${formatTanggal(data['timestamp'])}", style: GoogleFonts.poppins(color: Colors.white)),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Tutup", style: GoogleFonts.poppins()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSetujuiModal(
    BuildContext context,
    Map<String, dynamic> data,
    Function(String uid) onTerima,
  ) {
    final uidController = TextEditingController();

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
                  "Setujui Pengajuan",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text("Nama: ${data['nama']}", style: GoogleFonts.poppins(color: Colors.white)),
                const SizedBox(height: 8),
                Text("Plat Nomor: ${data['plat_nomor']}", style: GoogleFonts.poppins(color: Colors.white)),
                const SizedBox(height: 16),
                _buildTextField("UID Kartu", uidController),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final uid = uidController.text.trim();
                      if (uid.isEmpty) {
                        Get.snackbar("Validasi", "UID tidak boleh kosong!");
                        return;
                      }
                      onTerima(uid);
                      Navigator.pop(context);
                    },
                    child: Text("Setujui", style: GoogleFonts.poppins()),
                  ),
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

  String formatTanggal(dynamic timestamp) {
    try {
      DateTime date = timestamp is DateTime ? timestamp : DateTime.parse(timestamp.toDate().toString());
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return '-';
    }
  }

  Widget iconCard(IconData icon, Color bgColor, VoidCallback onTap) {
    return Card(
      color: bgColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: bgColor, size: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String tanggalFormatted = formatTanggal(data['timestamp']);

    return Card(
      elevation: 6,
      color: Colors.grey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Info Kartu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['nama'] ?? '-',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data['plat_nomor'] ?? '-',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tanggalFormatted,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
            // Aksi
            Row(
              children: [
                iconCard(Icons.remove_red_eye_rounded, Colors.blue, () => _showDetail(context)),
                const SizedBox(width: 6),
                iconCard(Icons.delete, Colors.redAccent, onHapus),
                const SizedBox(width: 6),
                iconCard(Icons.check_circle, Colors.green, () => _showSetujuiModal(context, data, onTerima)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
