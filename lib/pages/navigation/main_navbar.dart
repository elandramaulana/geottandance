import 'package:flutter/material.dart';
import 'package:geottandance/controllers/navbar_controller.dart';
import 'package:geottandance/pages/history/history_page.dart';
import 'package:geottandance/pages/home/home_screen.dart';
import 'package:geottandance/pages/profile/profile.dart';
import 'package:geottandance/widgets/navbar_widget.dart';
import 'package:get/get.dart';

class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NavigationController controller = Get.find();

    final List<Widget> pages = [
      const HomeScreen(),
      const CheckOutPage(),
      const TotalHoursPage(),
    ];

    return Scaffold(
      extendBody: true,
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: pages,
        ),
      ),
      bottomNavigationBar: const FloatingBottomNav(),
    );
  }
}
