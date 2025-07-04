import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/routes/app_pages.dart';

// Deklarasikan instance notifikasi global (bisa dipakai di controller juga)
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inisialisasi Firebase
  await initializeDateFormatting('id_ID', null); // Locale Indonesia
  await _initLocalNotification(); // Inisialisasi notifikasi lokal

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Siparkir",
      initialRoute: Routes.SPLASHSCREEN,
      getPages: AppPages.routes,
    ),
  );
}

Future<void> _initLocalNotification() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}
