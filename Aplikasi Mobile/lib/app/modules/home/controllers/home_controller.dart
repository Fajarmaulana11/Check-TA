import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage storage = GetStorage();
  final FlutterLocalNotificationsPlugin _notifPlugin = FlutterLocalNotificationsPlugin();

  var username = "".obs;
  var slot = 0.obs;
  var keluar = 0.obs;
  var masuk = 0.obs;
  var jumlahMotor = 0.obs;

  var newsList = <Map<String, dynamic>>[].obs;
  var isLoadingNews = false.obs;

  static const int totalKapasitas = 10;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    fetchParkingInfo();
    fetchNews();
  }

  void fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      username.value = userDoc['name'] ?? 'User';
    }
  }

  void fetchParkingInfo() {
    _database.child("info_parkir").onValue.listen((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final sisaSlot = int.tryParse(data['slot'].toString()) ?? 0;
        slot.value = sisaSlot;

        jumlahMotor.value = totalKapasitas - sisaSlot;

        final previousSlot = storage.read('lastSlot') ?? -1;

        if (sisaSlot <= 3 && sisaSlot != previousSlot) {
          final now = DateTime.now();
          final formattedTime = DateFormat('d MMMM yyyy - HH:mm', 'id_ID').format(now);

          final notifData = {
            "judul": "Slot Hampir Penuh",
            "deskripsi": "Slot parkir motor tersisa $sisaSlot unit lagi.",
            "waktu": formattedTime,
          };

          final existing = storage.read<List>('notifikasi') ?? [];

          await _showNotification(notifData['judul']!, notifData['deskripsi']!);
          storage.write('notifikasi', [...existing, notifData]);
          storage.write('lastSlot', sisaSlot);
        }
      }
    });
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Siparkir Notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notifDetails = NotificationDetails(android: androidDetails);

    await _notifPlugin.show(
      0,
      title,
      body,
      notifDetails,
      payload: 'slot_notif',
    );
  }

  void navigateTo(String menu) {
    switch (menu) {
      case 'Daftar Kartu':
        Get.toNamed(Routes.DAFTAR_KARTU);
        break;
      case 'Cek Kartu':
        Get.toNamed(Routes.CEK_KARTU);
        break;
      case 'Notifikasi':
        Get.toNamed(Routes.NOTIFIKASI);
        break;
      default:
        Get.snackbar("Oops", "Menu tidak dikenali");
    }
  }

  void fetchNews() async {
    isLoadingNews.value = true;
    try {
      final response = await http.get(Uri.parse('https://api-berita-indonesia.vercel.app/antara/otomotif/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final posts = data['data']['posts'] as List;

        final formattedPosts = posts.map<Map<String, dynamic>>((e) {
          final pubDate = e['pubDate'] ?? '';
          String formattedDate = pubDate;

          try {
            final parsedDate = DateTime.parse(pubDate);
            formattedDate = DateFormat('d MMMM yyyy', 'id_ID').format(parsedDate);
          } catch (_) {
            // Gunakan format asli jika gagal parsing
          }

          return {
            ...Map<String, dynamic>.from(e),
            'pubDate': formattedDate,
          };
        }).toList();

        newsList.value = formattedPosts;
      } else {
        Get.snackbar("Error", "Gagal memuat berita");
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan saat memuat berita");
    } finally {
      isLoadingNews.value = false;
    }
  }

  void logout() async {
    await _auth.signOut();
    storage.remove("isLoggedIn");
    storage.remove("userEmail");
    Get.offAllNamed(Routes.LOGIN);
  }

  void showLogoutDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Konfirmasi Keluar",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),
              const Text("Apakah kamu yakin untuk keluar?"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: Get.back,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Batal", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Ya", style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
