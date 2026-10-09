import 'package:get/get.dart';

import '../models/course_item.dart';
import '../models/recent_document.dart';
import '../models/pinned_document.dart';

class DashboardController extends GetxController {
  final RxString activeTopTab = 'Dashboard'.obs;
  final RxString activeWorkspaceView = 'Dashboard'.obs;
  final RxString activeSidebarItem = 'Dashboard'.obs;
  final RxString selectedFilter = 'ALL_TYPES'.obs;
  final RxBool isSemester4Expanded = true.obs;
  final RxBool isSemester3Expanded = false.obs;

  final RxList<CourseItem> courses = <CourseItem>[
    const CourseItem(
      title: 'Calculus',
      code: 'MATH-204',
      documentCount: 24,
      statusTag: '[EXAM PREP]',
    ),
    const CourseItem(
      title: 'Database Systems',
      code: 'CS-302',
      documentCount: 18,
      statusTag: '[SYNCED]',
    ),
    const CourseItem(
      title: 'Theory of Automata',
      code: 'CS-305',
      documentCount: 16,
      statusTag: '[ASSIGNMENT]',
    ),
    const CourseItem(
      title: 'Operating Systems',
      code: 'CS-307',
      documentCount: 21,
      statusTag: '[LAB CODE]',
    ),
  ].obs;

  final RxList<RecentDocument> recentDocuments = <RecentDocument>[
    const RecentDocument(
      name: "Lecture 05 - Rolle's Theorem.pdf",
      course: 'Calculus',
      type: 'PDF',
      lastOpened: 'Today',
    ),
    const RecentDocument(
      name: 'Database Normalization.pptx',
      course: 'Database Systems',
      type: 'PPTX',
      lastOpened: 'Yesterday',
    ),
    const RecentDocument(
      name: 'Automata Assignment 02.docx',
      course: 'Theory of Automata',
      type: 'DOCX',
      lastOpened: '2 days ago',
    ),
    const RecentDocument(
      name: 'Virtual Memory & Paging.pdf',
      course: 'Operating Systems',
      type: 'PDF',
      lastOpened: '3 days ago',
    ),
  ].obs;

  final RxList<PinnedDocument> pinnedDocuments = <PinnedDocument>[
    const PinnedDocument(
      name: 'Calculus_Formula_Sheet_v3.pdf',
      code: 'MATH-204',
    ),
    const PinnedDocument(
      name: 'Relational_Algebra_Cheatsheet.md',
      code: 'CS-302',
    ),
    const PinnedDocument(
      name: 'Chomsky_Hierarchy_Diagrams.pdf',
      code: 'CS-305',
    ),
    const PinnedDocument(
      name: 'POSIX_Threads_Syscalls_Guide.pdf',
      code: 'CS-307',
    ),
  ].obs;

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

  void toggleSemester4() {
    isSemester4Expanded.value = !isSemester4Expanded.value;
  }

  void toggleSemester3() {
    isSemester3Expanded.value = !isSemester3Expanded.value;
  }

  void noOp() {}
}
