import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geottandance/controllers/navbar_controller.dart';
import 'package:geottandance/widgets/navbar_widget.dart';
import 'package:get/get.dart';

<<<<<<< HEAD
class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({super.key});
=======
class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);
>>>>>>> ef18e0413942664de87036e7170aa17ae7220c0d

  @override
  Widget build(BuildContext context) {
    final NavigationController controller = Get.find();
    final FloatingBottomNav bottomNav = FloatingBottomNav();

    return Obx(
      () => Scaffold(
        // Menggunakan pages dari controller
        body: IndexedStack(
          index: controller.selectedIndex.value,
          children: controller.pages,
        ),
        bottomNavigationBar: bottomNav,
        floatingActionButton: bottomNav.buildCenterFAB(controller),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

// Alternatif: Jika tidak ingin menggunakan IndexedStack
class MainScreenAlternative extends StatelessWidget {
  const MainScreenAlternative({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NavigationController controller = Get.find();
    final FloatingBottomNav bottomNav = FloatingBottomNav();

    return Obx(
      () => Scaffold(
        // Langsung gunakan currentPage dari controller
        body: controller.currentPage,
        bottomNavigationBar: bottomNav,
        floatingActionButton: bottomNav.buildCenterFAB(controller),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
