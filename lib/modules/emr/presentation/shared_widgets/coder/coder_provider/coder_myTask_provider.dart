import 'package:flutter/material.dart';

class CoderMyTaskProvider extends ChangeNotifier {
  // ── Filter panel visibility ──────────────────────────────────────────────
  bool _isFilterOpen = false;
  bool get isFilterOpen => _isFilterOpen;
  void toggleFilter() {
    _isFilterOpen = !_isFilterOpen;
    notifyListeners();
  }

  // ── Section expand/collapse ──────────────────────────────────────────────
  bool fromTypeVisible         = false;
  bool fromDateVisible         = false;
  bool patientNameVisible      = false;
  bool clinitianNameVisible    = false;
  bool primaryInsuranceVisible = false;
  bool deadLineVisible         = false;
  bool codingStaffVisible      = false;

  void toggleFromType()         { fromTypeVisible = !fromTypeVisible;                 notifyListeners(); }
  void toggleFromDate()         { fromDateVisible = !fromDateVisible;                 notifyListeners(); }
  void togglePatientName()      { patientNameVisible = !patientNameVisible;           notifyListeners(); }
  void toggleClinicalName()     { clinitianNameVisible = !clinitianNameVisible;       notifyListeners(); }
  void togglePrimaryInsurance() { primaryInsuranceVisible = !primaryInsuranceVisible; notifyListeners(); }
  void toggleDeadLine()         { deadLineVisible = !deadLineVisible;                 notifyListeners(); }
  void toggleCodingStaff()      { codingStaffVisible = !codingStaffVisible;           notifyListeners(); }

  // ── Form ─────────────────────────────────────────────────────────────────
  List<int>    selectedFormIds   = [];
  List<String> selectedFormNames = [];

  void setSelectedForms(List<int> ids, List<String> names) {
    selectedFormIds   = ids;
    selectedFormNames = names;
    notifyListeners();
  }

  DateTime? fromDate;
  void setFromDate(DateTime? date) {
    fromDate = date;
    notifyListeners();
  }

  // ── Patient ───────────────────────────────────────────────────────────────
  List<int>    selectedPatientIds   = [];
  List<String> selectedPatientNames = [];

  void setSelectedPatients(List<int> ids, List<String> names) {
    selectedPatientIds   = ids;
    selectedPatientNames = names;
    notifyListeners();
  }

  // ── Clinician ─────────────────────────────────────────────────────────────
  List<int>    selectedClinicianIds   = [];
  List<String> selectedClinicianNames = [];

  void setSelectedClinicians(List<int> ids, List<String> names) {
    selectedClinicianIds   = ids;
    selectedClinicianNames = names;
    notifyListeners();
  }

  // ── Primary Insurance ─────────────────────────────────────────────────────
  List<String> selectedInsuranceNames = [];

  void setSelectedInsurances(List<String> names) {
    selectedInsuranceNames = names;
    notifyListeners();
  }

  // ── Timely Filing Deadline ───────────────────────────────────────────────
  DateTime? deadlineDate;
  void setDeadlineDate(DateTime? date) {
    deadlineDate = date;
    notifyListeners();
  }

  // ── Coding Staff ─────────────────────────────────────────────────────────
  List<int>    selectedCoderIds   = [];
  List<String> selectedCoderNames = [];

  void setSelectedCoders(List<int> ids, List<String> names) {
    selectedCoderIds   = ids;
    selectedCoderNames = names;
    notifyListeners();
  }

  // ── Saved snapshot (consumed by list screens) ────────────────────────────
  List<int>    savedFormIds            = [];
  List<String> savedFormNames          = [];
  DateTime?    savedFromDate;
  List<int>    savedPatientIds         = [];
  List<String> savedPatientNames       = [];
  List<int>    savedClinicianIds       = [];
  List<String> savedClinicianNames     = [];
  List<String> savedInsuranceNames     = [];
  DateTime?    savedDeadlineDate;
  List<int>    savedCoderIds           = [];
  List<String> savedCoderNames         = [];

  void onFilterSaved() {
    savedFormIds           = List.from(selectedFormIds);
    savedFormNames         = List.from(selectedFormNames);
    savedFromDate          = fromDate;
    savedPatientIds        = List.from(selectedPatientIds);
    savedPatientNames      = List.from(selectedPatientNames);
    savedClinicianIds      = List.from(selectedClinicianIds);
    savedClinicianNames    = List.from(selectedClinicianNames);
    savedInsuranceNames    = List.from(selectedInsuranceNames);
    savedDeadlineDate      = deadlineDate;
    savedCoderIds          = List.from(selectedCoderIds);
    savedCoderNames        = List.from(selectedCoderNames);
    notifyListeners();
  }

  // ── Completed tab reload signal ───────────────────────────────────────────
  bool _completedReloadRequested = false;
  bool get completedReloadRequested => _completedReloadRequested;

  void requestCompletedReload() {
    _completedReloadRequested = true;
    notifyListeners();
  }

  void consumeCompletedReload() {
    _completedReloadRequested = false;
  }

  // ── Clear all ────────────────────────────────────────────────────────────
  void clearAll() {
    selectedFormIds           = [];
    selectedFormNames         = [];
    fromDate                  = null;
    selectedPatientIds        = [];
    selectedPatientNames      = [];
    selectedClinicianIds      = [];
    selectedClinicianNames    = [];
    selectedInsuranceNames    = [];
    deadlineDate              = null;
    selectedCoderIds          = [];
    selectedCoderNames        = [];
    savedFormIds              = [];
    savedFormNames            = [];
    savedFromDate             = null;
    savedPatientIds           = [];
    savedPatientNames         = [];
    savedClinicianIds         = [];
    savedClinicianNames       = [];
    savedInsuranceNames       = [];
    savedDeadlineDate         = null;
    savedCoderIds             = [];
    savedCoderNames           = [];
    fromTypeVisible           = false;
    fromDateVisible           = false;
    patientNameVisible        = false;
    clinitianNameVisible      = false;
    primaryInsuranceVisible   = false;
    deadLineVisible           = false;
    codingStaffVisible        = false;
    _isFilterOpen             = false;
    _completedReloadRequested = false;
    notifyListeners();
  }
}