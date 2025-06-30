import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  // Observable untuk waktu clock in dan clock out
  var clockInTime = ''.obs;
  var clockOutTime = ''.obs;

  // Method untuk clock in
  void clockIn() {
    clockInTime.value = DateFormat('HH:mm').format(DateTime.now());
  }

  // Method untuk clock out
  void clockOut() {
    clockOutTime.value = DateFormat('HH:mm').format(DateTime.now());
  }

  // Method untuk reset waktu
  void resetTimes() {
    clockInTime.value = '';
    clockOutTime.value = '';
  }
}
