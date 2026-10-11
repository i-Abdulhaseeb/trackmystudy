import 'package:get/get.dart';

class DashboardController extends GetxController {
  final RxString activeTopTab = 'Dashboard'.obs;
  final RxString activeWorkspaceView = 'Dashboard'.obs;
  final RxString activeSidebarItem = 'Dashboard'.obs;
  final RxString selectedFilter = 'ALL_TYPES'.obs;
  void setActiveTopTab(String tab) {
    activeTopTab.value = tab;
  }

  void setActiveWorkspaceView(String view) {
    activeWorkspaceView.value = view;
  }

  void setActiveSidebarItem(String item) {
    activeSidebarItem.value = item;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void noOp() {}
}
