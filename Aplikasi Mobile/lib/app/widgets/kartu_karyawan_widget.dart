import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KartuKaryawanWidget extends StatelessWidget {
  final String nama;
  final String divisi;
  final String platNomor;
  final String rfid;
  final String uid; // ✅ Tambahan
  final VoidCallback onHapus;
  final VoidCallback onEdit;

  const KartuKaryawanWidget({
    super.key,
    required this.nama,
    required this.divisi,
    required this.platNomor,
    required this.rfid,
    required this.uid, // ✅ Tambahan
    required this.onHapus,
    required this.onEdit,
  });

  Widget iconCard(IconData icon, String label, Color bgColor, VoidCallback onTap) {
    return Card(
      color: bgColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: bgColor, size: 20),
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.poppins(color: bgColor)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      color: Colors.grey[700],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.credit_card, size: 40, color: Colors.black87),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "$divisi / $platNomor",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "NO KARTU: $rfid",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.amberAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "UID: $uid", // ✅ Tampilkan UID
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.lightGreenAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                iconCard(Icons.edit, "Edit", Colors.blue, onEdit),
                const SizedBox(width: 8),
                iconCard(Icons.delete, "Hapus", Colors.redAccent, onHapus),
              ],
            )
          ],
        ),
      ),
    );
  }
}
