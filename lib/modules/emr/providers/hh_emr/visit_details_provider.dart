import 'package:flutter/material.dart';

// ── Patient data holder ───────────────────────────────────────────────────────
class EMRSelectedPatient {
  final int patientId;
  final String name;
  final String initials;
  final int avatarBgValue;
  final int avatarTextValue;
  final String mrn;
  final String episode;
  final String physician;
  final String diagnosis;
  final String insurance;
  final String authorization;
  final String status;
  final int chartId;
  final int episodeId;

  const EMRSelectedPatient({
    required this.patientId,
    required this.name,
    required this.initials,
    required this.avatarBgValue,
    required this.avatarTextValue,
    required this.mrn,
    required this.episode,
    required this.physician,
    required this.diagnosis,
    required this.insurance,
    required this.authorization,
    required this.status,
    required this.chartId,
    required this.episodeId,
  });
}

class EMRNavigationController extends ChangeNotifier {
  bool _isViewingVisit = false;
  int _visitId = 0;
  int get visitId => _visitId;

  bool get isViewingVisit => _isViewingVisit;

  void openVisit() {
    _isViewingVisit = true;
    notifyListeners();
  }

  void passVisitId({required int id}) {
    _visitId = id;
    notifyListeners();
  }

  void closeVisit() {
    _isViewingVisit = false;
    notifyListeners();
  }

  // ── Dashboard today visit tab ─────────────────────────────────────────────
  bool _isScheduleVisit = false;
  bool get isScheduleVisit => _isScheduleVisit;

  void openScheduleVisit() {
    _isScheduleVisit = true;
    notifyListeners();
  }

  void closeScheduleVisit() {
    _isScheduleVisit = false;
    notifyListeners();
  }

  // ── Today's Visits Map ────────────────────────────────────────────────────
  bool _isViewingMap = false;
  bool get isViewingMap => _isViewingMap;

  void openMap() {
    _isViewingMap = true;
    notifyListeners();
  }

  void closeMap() {
    _isViewingMap = false;
    notifyListeners();
  }

  // ── Patient Detail ────────────────────────────────────────────────────────
  bool _isViewingPatientDetail = false;
  EMRSelectedPatient? _selectedPatient;

  bool get isViewingPatientDetail => _isViewingPatientDetail;
  EMRSelectedPatient? get selectedPatient => _selectedPatient;

  void openPatientDetail(EMRSelectedPatient patient) {
    _selectedPatient = patient;
    _isViewingPatientDetail = true;
    notifyListeners();
  }

  void closePatientDetail() {
    _isViewingPatientDetail = false;
    _selectedPatient = null;
    notifyListeners();
  }

  // ── Protocol Screen ───────────────────────────────────────────────────────
  bool _isViewingProtocol = false;
  bool get isViewingProtocol => _isViewingProtocol;

  void openProtocol() {
    _isViewingProtocol = true;
    notifyListeners();
  }

  void closeProtocol() {
    _isViewingProtocol = false;
    notifyListeners();
  }

  // ── Alerts Screen ─────────────────────────────────────────────────────────
  bool _isViewingAlerts = false;
  bool get isViewingAlerts => _isViewingAlerts;

  void openAlerts() {
    _isViewingAlerts = true;
    notifyListeners();
  }

  void closeAlerts() {
    _isViewingAlerts = false;
    notifyListeners();
  }

  // ── Plan of Care Screen ───────────────────────────────────────────────────
  bool _isViewingPlanOfCare = false;
  bool get isViewingPlanOfCare => _isViewingPlanOfCare;

  // Patient card data for Plan of Care screen
  String _pocPatientName = '';
  String _pocPatientStatus = '';
  String _pocImgUrl = '';
  List<String> _pocCareTeam = [];

  String get pocPatientName => _pocPatientName;
  String get pocPatientStatus => _pocPatientStatus;
  String get pocImgUrl => _pocImgUrl;
  List<String> get pocCareTeam => _pocCareTeam;

  void openPlanOfCare({
    String patientName = '',
    String patientStatus = '',
    String imgUrl = '',
    List<String> careTeam = const [],
  }) {
    _pocPatientName = patientName;
    _pocPatientStatus = patientStatus;
    _pocImgUrl = imgUrl;
    _pocCareTeam = List.from(careTeam);
    _isViewingPlanOfCare = true;
    notifyListeners();
  }

  void closePlanOfCare() {
    _isViewingPlanOfCare = false;
    notifyListeners();
  }

  // ── Frequency Detail Screen ───────────────────────────────────────────────
  bool _isViewingFrequencyDetail = false;
  bool get isViewingFrequencyDetail => _isViewingFrequencyDetail;

  void openFrequencyDetail() {
    _isViewingFrequencyDetail = true;
    notifyListeners();
  }

  void closeFrequencyDetail() {
    _isViewingFrequencyDetail = false;
    notifyListeners();
  }

  // ── Reset — call on new login to clear stale session state ───────────────
  void reset() {
    _isViewingVisit           = false;
    _isScheduleVisit          = false;
    _isViewingMap             = false;
    _isViewingPatientDetail   = false;
    _isViewingProtocol        = false;
    _isViewingAlerts          = false;
    _isViewingPlanOfCare      = false;
    _isViewingFrequencyDetail = false;
    _visitId                  = 0;
    _selectedPatient          = null;
    notifyListeners();
  }
}

// ── Filter drawer provider ────────────────────────────────────────────────────
class FilterDrawerProvider extends ChangeNotifier {
  bool _isFilterOpen = false;

  // ── selected (live UI state) ──────────────────────────────────────────────
  Set<String> _selectedFormNames  = {};
  Set<String> _selectedInsurances = {};

  // ── saved (committed on Save tap — drives actual filtering) ──────────────
  Set<String> _savedFormNames  = {};
  Set<String> _savedInsurances = {};

  bool get isFilterOpen => _isFilterOpen;

  Set<String> get selectedFormNames  => _selectedFormNames;
  Set<String> get selectedInsurances => _selectedInsurances;
  Set<String> get savedFormNames     => _savedFormNames;
  Set<String> get savedInsurances    => _savedInsurances;

  bool get hasActiveFilters =>
      _savedFormNames.isNotEmpty || _savedInsurances.isNotEmpty;

  void openFilter() {
    _isFilterOpen = true;
    notifyListeners();
  }

  void closeFilter() {
    _isFilterOpen = false;
    notifyListeners();
  }

  void toggleFilter() {
    _isFilterOpen = !_isFilterOpen;
    notifyListeners();
  }

  // ── called on every checkbox toggle (live UI only) ────────────────────────
  void applyFilters({
    required Set<String> formNames,
    required Set<String> insurances,
  }) {
    _selectedFormNames  = Set.from(formNames);
    _selectedInsurances = Set.from(insurances);
    notifyListeners();
  }

  // ── called on Save tap — commits selected → saved ─────────────────────────
  void saveFilters() {
    _savedFormNames  = Set.from(_selectedFormNames);
    _savedInsurances = Set.from(_selectedInsurances);
    notifyListeners();
  }

  // ── clears both selected and saved ───────────────────────────────────────
  void clearFilters() {
    _selectedFormNames.clear();
    _selectedInsurances.clear();
    _savedFormNames.clear();
    _savedInsurances.clear();
    notifyListeners();
  }
}