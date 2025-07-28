import 'package:flutter/material.dart';
import 'package:geottandance/controllers/navbar_controller.dart';
import 'package:geottandance/widgets/navbar_widget.dart';
import 'package:get/get.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

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
  const MainScreenAlternative({super.key});

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
