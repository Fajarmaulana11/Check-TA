import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KartuKaryawanWidget extends StatelessWidget {
  final String nama;
  final String divisi;
  final String platNomor;
  final String rfid; // Tambahan

  const KartuKaryawanWidget({
    super.key,
    required this.nama,
    required this.divisi,
    required this.platNomor,
    required this.rfid, // Tambahan
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      color: Colors.grey[700],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
