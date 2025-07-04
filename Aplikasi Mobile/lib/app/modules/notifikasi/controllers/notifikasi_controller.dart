import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class NotifikasiController extends GetxController {
  final notifikasiList = <Map<String, dynamic>>[].obs;
  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  void loadNotifications() {
    final data = storage.read<List>('notifikasi');
    if (data != null) {
      final sorted = List<Map<String, dynamic>>.from(data.reversed);
      notifikasiList.value = sorted;
    }
  }

  void hapusNotifikasi(String waktu) {
    final updatedList = List<Map<String, dynamic>>.from(notifikasiList);
    updatedList.removeWhere((item) => item['waktu'] == waktu);
    notifikasiList.value = updatedList.reversed.toList();
    storage.write('notifikasi', updatedList.reversed.toList());
  }
}
