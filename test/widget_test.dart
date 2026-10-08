import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:trackmystudy/features/dashboard/controllers/dashboard_controller.dart';
import 'package:trackmystudy/features/file_manager/controllers/file_manager_controller.dart';
import 'package:trackmystudy/main.dart';

void main() {
  testWidgets('App load test and file manager navigation test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const UniversityMaterialManagerApp());
    await tester.pump();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('University Material Manager'), findsOneWidget);
    expect(find.text('Calculus'), findsWidgets);
    expect(find.text('Database Systems'), findsWidgets);

    final allFilesFinder = find.text('All Files');
    expect(allFilesFinder, findsWidgets);

    await tester.tap(allFilesFinder.first);
    await tester.pumpAndSettle();

    expect(find.text('Local document repository, imported syllabi, lecture slides, and notes.'), findsOneWidget);
    expect(find.text("Lecture 05 - Rolle's Theorem.pdf"), findsOneWidget);

    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().onClose();
    }
    if (Get.isRegistered<FileManagerController>()) {
      Get.find<FileManagerController>().onClose();
    }
    Get.reset();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
