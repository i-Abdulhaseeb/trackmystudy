import 'dart:async';

import 'package:get/get.dart';

import '../models/gpa_scenario.dart';
import '../services/gpa_calculator.dart';
import '../services/gpa_store.dart';

class GpaController extends GetxController {
  GpaController({GpaStore? store}) : _store = store ?? GpaStore();

  final GpaStore _store;
  final scenarios = <GpaScenario>[].obs;
  final activeId = ''.obs;
  final loading = true.obs;
  final saving = false.obs;
  final restoreFailed = false.obs;
  final storageError = ''.obs;
  final finalizing = false.obs;
  late final Future<void> ready;
  Future<void> _writes = Future.value();
  int _pendingWrites = 0;
  int _sequence = 0;
  int _baselineRevision = 0;
  String _confirmedCgpa = '';
  String _confirmedCredits = '';
  String _confirmedDegreeCredits = '';

  GpaScenario? get active =>
      scenarios.firstWhereOrNull((item) => item.id == activeId.value);
  bool get editable =>
      !loading.value &&
      !restoreFailed.value &&
      !finalizing.value &&
      active?.finalized == false;
  GpaResult? get result =>
      active == null ? null : GpaCalculator.calculate(active!);
  bool get canFinalize =>
      editable &&
      active!.baselineRevision == _baselineRevision &&
      result?.predictedCgpa != null;
  bool get staleBaseline =>
      active != null && active!.baselineRevision != _baselineRevision;

  @override
  void onInit() {
    super.onInit();
    ready = restore();
  }

  String _id() => '${DateTime.now().microsecondsSinceEpoch}_${_sequence++}';

  GpaScenario _newScenario() => GpaScenario(
    id: _id(),
    cgpa: _confirmedCgpa,
    priorCredits: _confirmedCredits,
    degreeCredits: _confirmedDegreeCredits,
    baselineRevision: _baselineRevision,
  );

  Future<void> restore() async {
    loading.value = true;
    try {
      final data = await _store.read();
      if (data != null) {
        if (data['version'] != 1) {
          throw const FormatException('Unsupported calculator data.');
        }
        final restored = (data['scenarios'] as List)
            .map(
              (item) =>
                  GpaScenario.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList();
        if (restored.map((item) => item.id).toSet().length != restored.length ||
            restored.any(
              (item) =>
                  item.courses.length > 30 ||
                  item.courses.map((course) => course.id).toSet().length !=
                      item.courses.length,
            )) {
          throw const FormatException('Invalid saved scenarios.');
        }
        _baselineRevision = data['baselineRevision'] as int;
        _confirmedCgpa = data['confirmedCgpa'] as String;
        _confirmedCredits = data['confirmedCredits'] as String;
        _confirmedDegreeCredits = data['confirmedDegreeCredits'] as String;
        scenarios.assignAll(restored);
        activeId.value = data['activeId'] as String;
      }
      if (scenarios.isEmpty) scenarios.add(_newScenario());
      if (active == null) activeId.value = scenarios.first.id;
      restoreFailed.value = false;
      storageError.value = '';
    } catch (_) {
      restoreFailed.value = true;
      storageError.value = 'Saved calculator data could not be opened. It has not been overwritten. Retry after checking storage.';
    } finally {
      loading.value = false;
    }
  }

  Map<String, dynamic> _snapshot() => {
    'version': 1,
    'baselineRevision': _baselineRevision,
    'confirmedCgpa': _confirmedCgpa,
    'confirmedCredits': _confirmedCredits,
    'confirmedDegreeCredits': _confirmedDegreeCredits,
    'activeId': activeId.value,
    'scenarios': scenarios.map((item) => item.toJson()).toList(),
  };

  Future<void> save() {
    if (restoreFailed.value || loading.value) return Future.value();
    final snapshot = _snapshot();
    _pendingWrites++;
    saving.value = true;
    _writes = _writes.then((_) async {
      try {
        await _store.write(snapshot);
        storageError.value = '';
      } catch (_) {
        storageError.value = 'Changes are available in this session but could not be saved. Retry before closing the app.';
      } finally {
        _pendingWrites--;
        saving.value = _pendingWrites > 0;
      }
    });
    return _writes;
  }

  void updateScenario(GpaScenario scenario) {
    if (!editable || scenario.id != activeId.value) return;
    final index = scenarios.indexWhere((item) => item.id == scenario.id);
    if (index < 0) return;
    scenarios[index] = scenario;
    unawaited(save());
  }

  void updateCourse(GpaCourse course) {
    final scenario = active;
    if (scenario == null) return;
    updateScenario(
      scenario.copyWith(
        courses: [
          for (final item in scenario.courses)
            if (item.id == course.id) course else item,
        ],
      ),
    );
  }

  void addCourse() {
    final scenario = active;
    if (!editable || scenario == null || scenario.courses.length >= 30) return;
    updateScenario(
      scenario.copyWith(
        courses: [
          ...scenario.courses,
          GpaCourse(id: _id()),
        ],
      ),
    );
  }

  void removeCourse(String id) {
    final scenario = active;
    if (scenario == null) return;
    updateScenario(
      scenario.copyWith(
        courses: scenario.courses.where((item) => item.id != id).toList(),
      ),
    );
  }

  void selectScenario(String id) {
    if (loading.value ||
        finalizing.value ||
        !scenarios.any((item) => item.id == id)) {
      return;
    }
    activeId.value = id;
    unawaited(save());
  }

  void newScenario() {
    if (loading.value || restoreFailed.value || finalizing.value) return;
    final scenario = _newScenario();
    scenarios.add(scenario);
    activeId.value = scenario.id;
    unawaited(save());
  }

  void duplicateScenario() {
    final scenario = active;
    if (scenario == null ||
        loading.value ||
        restoreFailed.value ||
        finalizing.value) {
      return;
    }
    final duplicate = scenario.copyWith(
      id: _id(),
      name: '${scenario.name} (copy)',
    );
    scenarios.add(duplicate);
    activeId.value = duplicate.id;
    unawaited(save());
  }

  void deleteScenario() {
    if (loading.value || restoreFailed.value || finalizing.value) return;
    scenarios.removeWhere((item) => item.id == activeId.value);
    if (scenarios.isEmpty) scenarios.add(_newScenario());
    activeId.value = scenarios.last.id;
    unawaited(save());
  }

  void useConfirmedBaseline() {
    final scenario = active;
    if (!editable || scenario == null || _confirmedCredits.isEmpty) return;
    updateScenario(
      scenario.copyWith(
        cgpa: _confirmedCgpa,
        priorCredits: _confirmedCredits,
        degreeCredits: _confirmedDegreeCredits,
        baselineRevision: _baselineRevision,
      ),
    );
  }

  Future<bool> finalizeResults() async {
    if (!canFinalize) return false;
    finalizing.value = true;
    await _writes;
    final scenario = active!;
    final calculation = GpaCalculator.calculate(scenario);
    final nextRevision = _baselineRevision + 1;
    final nextCgpa = calculation.predictedCgpa!.toString();
    final nextCredits =
        (int.parse(scenario.priorCredits.trim()) + calculation.credits)
            .toString();
    final passedCredits = scenario.courses
        .where((course) => course.included && course.grade!.points > 0)
        .fold(0, (sum, course) => sum + course.credits);
    final nextDegree = scenario.degreeCredits.trim().isEmpty
        ? ''
        : (int.parse(scenario.degreeCredits.trim()) + passedCredits).toString();
    final next = GpaScenario(
      id: _id(),
      cgpa: nextCgpa,
      priorCredits: nextCredits,
      degreeCredits: nextDegree,
      baselineRevision: nextRevision,
    );
    final updated = [
      for (final item in scenarios)
        if (item.id == scenario.id) item.copyWith(finalized: true) else item,
      next,
    ];
    try {
      await _store.write({
        'version': 1,
        'baselineRevision': nextRevision,
        'confirmedCgpa': nextCgpa,
        'confirmedCredits': nextCredits,
        'confirmedDegreeCredits': nextDegree,
        'activeId': next.id,
        'scenarios': updated.map((item) => item.toJson()).toList(),
      });
      _baselineRevision = nextRevision;
      _confirmedCgpa = nextCgpa;
      _confirmedCredits = nextCredits;
      _confirmedDegreeCredits = nextDegree;
      scenarios.assignAll(updated);
      activeId.value = next.id;
      storageError.value = '';
      return true;
    } catch (_) {
      storageError.value = 'Final results could not be saved. Your academic baseline has not changed.';
      return false;
    } finally {
      finalizing.value = false;
    }
  }
}
