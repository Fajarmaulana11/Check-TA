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

class HomeAdminController extends GetxController {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage storage = GetStorage();
  final FlutterLocalNotificationsPlugin _notifPlugin = FlutterLocalNotificationsPlugin();

  var username = "".obs;
  var slot = 0.obs;
  var keluar = 0.obs;
  var masuk = 0.obs;

  var newsList = <Map<String, dynamic>>[].obs;
  var isLoadingNews = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeNotification();
    fetchParkingInfo();
    fetchNews();
  }

  void _initializeNotification() {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    _notifPlugin.initialize(initSettings);
  }

  void fetchParkingInfo() {
    _database.child("info_parkir").onValue.listen((event) async {
      try {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          final sisaSlot = int.tryParse(data['slot'].toString()) ?? 0;
          slot.value = sisaSlot;
          keluar.value = int.tryParse(data['keluar'].toString()) ?? 0;
          masuk.value = int.tryParse(data['masuk'].toString()) ?? 0;

          final previousSlot = storage.read('lastSlot') ?? -1;

          if (sisaSlot <= 3 && sisaSlot != previousSlot) {
            final now = DateTime.now();
            final formattedTime = DateFormat('d MMMM yyyy - HH:mm', 'id_ID').format(now);

            final notifData = {
              "judul": "Slot Hampir Penuh",
              "deskripsi": "Slot parkir motor tersisa $sisaSlot unit lagi.",
              "waktu": formattedTime,
            };

            List<dynamic> existing = storage.read('notifikasi') ?? [];
            existing.add(notifData);

            await _showNotification(notifData['judul']!, notifData['deskripsi']!);
            storage.write('notifikasi', existing);
            storage.write('lastSlot', sisaSlot);
          }
        }
      } catch (e) {
        Get.snackbar("Error", "Gagal mengambil data parkir.");
      }
    });
  }

  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Siparkir Notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const platformDetails = NotificationDetails(android: androidDetails);

    await _notifPlugin.show(0, title, body, platformDetails, payload: 'slot_notif');
  }

  void navigateTo(String menu) {
    switch (menu) {
      case 'Persetujuan Kartu':
        Get.toNamed(Routes.PERSETUJUAN_KARTU);
        break;
      case 'Kartu Terdaftar':
        Get.toNamed(Routes.KARTU_TERDAFTAR);
        break;
      case 'Riwayat Parkir':
        Get.toNamed(Routes.HISTORY_PARKIR);
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
          } catch (_) {}

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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 15),
              const Text("Apakah kamu yakin untuk keluar?"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Get.back(),
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
