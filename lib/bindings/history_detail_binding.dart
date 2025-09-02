import 'package:get/get.dart';
import 'package:geottandance/controllers/history_detail_controller.dart';

class HistoryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceDetailController>(() => AttendanceDetailController());
  }
}
