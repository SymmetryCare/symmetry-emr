import 'package:flutter/material.dart';

class QaMyTaskProvider extends ChangeNotifier {
  bool _isChatbotVisible  = false;
  bool _isQaFilterOpen    = false;
  bool _isCoderFilterOpen = false;

  bool _fromTypeVisible         = false;
  bool _fromDateVisible         = false;
  bool _patientNameVisible      = false;
  bool _clinitianNameVisible    = false;
  bool _primaryInsuranceVisible = false;
  bool _deadLineVisible         = false;
  bool _codingStaffVisible      = false;

  bool get isChatVisible           => _isChatbotVisible;
  bool get isCoderFilterOpen       => _isCoderFilterOpen;
  bool get isFilterOpen            => _isQaFilterOpen;
  bool get fromTypeVisible         => _fromTypeVisible;
  bool get fromDateVisible         => _fromDateVisible;
  bool get patientNameVisible      => _patientNameVisible;
  bool get clinitianNameVisible    => _clinitianNameVisible;
  bool get primaryInsuranceVisible => _primaryInsuranceVisible;
  bool get deadLineVisible         => _deadLineVisible;
  bool get codingStaffVisible      => _codingStaffVisible;

  // ── Chat receiver state ───────────────────────────────────────────────────
  int    _chatReceiverEmpId  = 0;
  String _chatReceiverName   = '';
  String _chatReceiverImage  = '';
  String _chatReceiverAbbrev = '';
  String _chatReceiverColor  = '#FFA500';
  int    _chatKey            = 0;

  int    get chatReceiverEmpId  => _chatReceiverEmpId;
  String get chatReceiverName   => _chatReceiverName;
  String get chatReceiverImage  => _chatReceiverImage;
  String get chatReceiverAbbrev => _chatReceiverAbbrev;
  String get chatReceiverColor  => _chatReceiverColor;
  int    get chatKey            => _chatKey;

  void toggleQaChat({
    int    empId  = 0,
    String name   = '',
    String image  = '',
    String abbrev = '',
    String color  = '#FFA500',
  }) {
    if (_isChatbotVisible && _chatReceiverEmpId == empId) {
      _isChatbotVisible = false;
    } else {
      _chatReceiverEmpId  = empId;
      _chatReceiverName   = name;
      _chatReceiverImage  = image;
      _chatReceiverAbbrev = abbrev;
      _chatReceiverColor  = color;
      _isChatbotVisible   = true;
      _chatKey++;
    }
    notifyListeners();
  }

  void clearChatVisible() { _isChatbotVisible = false; notifyListeners(); }

  // ── SELECTED (live, panel UI only) ───────────────────────────────────────
  List<int>    selectedFormIds        = [];
  List<String> selectedFormNames      = [];
  DateTime?    fromDate;
  List<int>    selectedPatientIds     = [];
  List<String> selectedPatientNames   = [];
  List<int>    selectedClinicianIds   = [];
  List<String> selectedClinicianNames = [];
  List<String> selectedInsuranceNames = [];
  DateTime?    deadlineDate;
  List<int>    selectedCoderIds       = [];
  List<String> selectedCoderNames     = [];

  // ── SAVED (committed on Save tap — used by list screens) ─────────────────
  List<int>    savedFormIds           = [];
  List<String> savedFormNames         = [];
  DateTime?    savedFromDate;
  List<int>    savedPatientIds        = [];
  List<String> savedPatientNames      = [];
  List<int>    savedClinicianIds      = [];
  List<String> savedClinicianNames    = [];
  List<String> savedInsuranceNames    = [];
  DateTime?    savedDeadlineDate;
  List<int>    savedCoderIds          = [];
  List<String> savedCoderNames        = [];

  // ── Setters ───────────────────────────────────────────────────────────────
  void setSelectedForms(List<int> ids, List<String> names) {
    selectedFormIds   = ids;
    selectedFormNames = names;
    notifyListeners();
  }

  void setFromDate(DateTime? date) {
    fromDate = date;
    notifyListeners();
  }

  void setSelectedPatients(List<int> ids, List<String> names) {
    selectedPatientIds   = ids;
    selectedPatientNames = names;
    notifyListeners();
  }

  void setSelectedClinicians(List<int> ids, List<String> names) {
    selectedClinicianIds   = ids;
    selectedClinicianNames = names;
    notifyListeners();
  }

  void setSelectedInsurances(List<String> names) {
    selectedInsuranceNames = names;
    notifyListeners();
  }

  void setDeadlineDate(DateTime? date) {
    deadlineDate = date;
    notifyListeners();
  }

  void setSelectedCoders(List<int> ids, List<String> names) {
    selectedCoderIds   = ids;
    selectedCoderNames = names;
    notifyListeners();
  }

  // ── Save ─────────────────────────────────────────────────────────────────
  void onFilterSaved() {
    savedFormIds        = List.from(selectedFormIds);
    savedFormNames      = List.from(selectedFormNames);
    savedFromDate       = fromDate;
    savedPatientIds     = List.from(selectedPatientIds);
    savedPatientNames   = List.from(selectedPatientNames);
    savedClinicianIds   = List.from(selectedClinicianIds);
    savedClinicianNames = List.from(selectedClinicianNames);
    savedInsuranceNames = List.from(selectedInsuranceNames);
    savedDeadlineDate   = deadlineDate;
    savedCoderIds       = List.from(selectedCoderIds);
    savedCoderNames     = List.from(selectedCoderNames);
    notifyListeners();
  }

  // ── Clear All ─────────────────────────────────────────────────────────────
  void clearAll() {
    selectedFormIds        = [];
    selectedFormNames      = [];
    fromDate               = null;
    selectedPatientIds     = [];
    selectedPatientNames   = [];
    selectedClinicianIds   = [];
    selectedClinicianNames = [];
    selectedInsuranceNames = [];
    deadlineDate           = null;
    selectedCoderIds       = [];
    selectedCoderNames     = [];
    savedFormIds           = [];
    savedFormNames         = [];
    savedFromDate          = null;
    savedPatientIds        = [];
    savedPatientNames      = [];
    savedClinicianIds      = [];
    savedClinicianNames    = [];
    savedInsuranceNames    = [];
    savedDeadlineDate      = null;
    savedCoderIds          = [];
    savedCoderNames        = [];
    _fromTypeVisible         = false;
    _fromDateVisible         = false;
    _patientNameVisible      = false;
    _clinitianNameVisible    = false;
    _primaryInsuranceVisible = false;
    _deadLineVisible         = false;
    _codingStaffVisible      = false;
    _isQaFilterOpen          = false;
    notifyListeners();
  }

  // ── Toggles ───────────────────────────────────────────────────────────────
  void toggleFilter()           { _isQaFilterOpen    = !_isQaFilterOpen;    notifyListeners(); }
  void toggleCoderFilter()      { _isCoderFilterOpen = !_isCoderFilterOpen; notifyListeners(); }
  void toggleFromType()         { _fromTypeVisible         = !_fromTypeVisible;         notifyListeners(); }
  void toggleFromDate()         { _fromDateVisible         = !_fromDateVisible;         notifyListeners(); }
  void togglePatientName()      { _patientNameVisible      = !_patientNameVisible;      notifyListeners(); }
  void toggleClinicalName()     { _clinitianNameVisible    = !_clinitianNameVisible;    notifyListeners(); }
  void togglePrimaryInsurance() { _primaryInsuranceVisible = !_primaryInsuranceVisible; notifyListeners(); }
  void toggleDeadLine()         { _deadLineVisible         = !_deadLineVisible;         notifyListeners(); }
  void toggleCodingStaff()      { _codingStaffVisible      = !_codingStaffVisible;      notifyListeners(); }
}