import 'package:get/get.dart';

import '../../exams/controllers/exam_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../../file_manager/controllers/file_manager_controller.dart';
import '../../../core/theme/theme_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ThemeController>(ThemeController(), permanent: true);
    Get.put<FileManagerController>(FileManagerController(), permanent: true);
    Get.put<ExamController>(ExamController(), permanent: true);
    Get.put<DashboardController>(DashboardController(), permanent: true);
  }
}
