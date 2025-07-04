import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CekKartuController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final kartuList = RxList<Map<String, dynamic>>([]);
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    ambilDanCekKartu();
  }

  Future<void> ambilDanCekKartu() async {
    isLoading.value = true;

    try {
      final uid = _auth.currentUser?.uid;

      if (uid == null) {
        Get.snackbar("Error", "User belum login.");
        return;
      }

      final userSnapshot = await _firestore.collection('users').doc(uid).get();
      final email = userSnapshot.data()?['email'];

      if (email == null) {
        Get.snackbar("Error", "Email user tidak ditemukan.");
        return;
      }

      final kartuQuery = await _firestore
          .collection('kartu_parkir')
          .where('email', isEqualTo: email)
          .get();

      if (kartuQuery.docs.isNotEmpty) {
        kartuList.assignAll(
          kartuQuery.docs.map((doc) => doc.data()).toList(),
        );
      } else {
        kartuList.clear();
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
