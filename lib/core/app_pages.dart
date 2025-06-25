import 'package:geottandance/bindings/forgot_password_binding.dart';
import 'package:geottandance/bindings/home_binding.dart';
import 'package:geottandance/bindings/login_binding.dart';
import 'package:geottandance/bindings/navbar_binding.dart';
import 'package:geottandance/bindings/register_binding.dart';
import 'package:geottandance/controllers/splash_controller.dart';
import 'package:geottandance/core/app_routes.dart';
import 'package:geottandance/pages/auth/forgot_password_screen.dart';
import 'package:geottandance/pages/auth/login_screen.dart';
import 'package:geottandance/pages/auth/register_screen.dart';
import 'package:geottandance/pages/home/home_screen.dart';
import 'package:geottandance/pages/navigation/main_navbar.dart';
import 'package:geottandance/pages/splash/splashscreen.dart';
import 'package:get/get.dart';

class AppPages {
  static const initial = AppRoutes.splash;
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.put(SplashScreenController());
      }),
    ),
    GetPage(
      name: AppRoutes.bottomNav,
      page: () => const MainNavigationPage(),
      binding: NavigationBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: LoginBinding(),
    ),

    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ),

    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
    ),
    // GetPage(
    //   name: AppRoutes.home,
    //   page: () => const HomeScreen(),
    //   binding: HomeBinding(),
    // ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    // GetPage(
    //   name: AppRoutes.history,
    //   page: () => const HistoryPage(),
    //   binding: HistoryBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.historyDetail,
    //   page: () => const HistoryDetailPage(),
    //   binding: HistoryBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.correction,
    //   page: () => const CorrectionPage(),
    //   binding: CorrectionBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.pengajuanCuti,
    //   page: () => const HistoryListCuti(),
    //   binding: PengajuanBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.pengajuanLembur,
    //   page: () => const HistoryListLembur(),
    //   binding: PengajuanBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.pengajuanSakit,
    //   page: () => const HistoryListSakit(),
    //   binding: PengajuanBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.correctionHistory,
    //   page: () => const HistoryListCorrection(),
    //   binding: CorrectionBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.pengajuanIzin,
    //   page: () => const HistoryListIzin(),
    //   binding: PengajuanBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.formCuti,
    //   page: () => const FormCutiPage(),
    //   binding: PengajuanBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.formLembur,
    //   page: () => const FormOvertimePage(),
    //   binding: PengajuanBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.formSakit,
    //   page: () => FormSakitPage(),
    //   binding: PengajuanBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.formIzin,
    //   page: () => const FormIzinPage(),
    //   binding: PengajuanBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.profile,
    //   page: () => const ProfilePage(),
    //   binding: ProfileBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.mapAttendance,
    //   page: () => const AttendanceMapPage(),
    //   binding: AttendanceBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.approval,
    //   page: () => const ApprovalPage(),
    //   binding: ApprovalBinding(),
    // ),
  ];
}
