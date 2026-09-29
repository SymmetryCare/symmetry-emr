import 'package:flutter/material.dart';

class EmrPatientProvider extends ChangeNotifier {
  bool _isChatbotVisible = false;
  // Referal filter
  bool _isQaFilterOpen = false;
  bool _fromTypeVisible = false;
  bool _fromDateVisible = false;
  bool _patientNameVisible = false;
  bool _clinitianNameVisible = false;
  bool _primaryInsuranceVisible = false;
  bool _deadLineVisible = false;
  bool _codingStaffVisible = false;

  // ── Patient group ID for EMR chat ────────────────────────────────────
  int _selectedPtGroupId = 0;
  int get selectedPtGroupId => _selectedPtGroupId;

  void setSelectedPtGroupId(int id) {
    _selectedPtGroupId = id;
    notifyListeners();
  }
  // ─────────────────────────────────────────────────────────────────────

  bool get isChatVisible => _isChatbotVisible;
  bool get isFilterOpen => _isQaFilterOpen;
  bool get fromTypeVisible => _fromTypeVisible;
  bool get fromDateVisible => _fromDateVisible;
  bool get patientNameVisible => _patientNameVisible;
  bool get clinitianNameVisible => _clinitianNameVisible;
  bool get primaryInsuranceVisible => _primaryInsuranceVisible;
  bool get deadLineVisible => _deadLineVisible;
  bool get codingStaffVisible => _codingStaffVisible;

  void toggleQaChat() {
    _isChatbotVisible = !_isChatbotVisible;
    notifyListeners();
  }

  void clearChatVisible() {
    _isChatbotVisible = false;
    notifyListeners();
  }

  /// Filter open
  void toggleFilter() {
    _isQaFilterOpen = !_isQaFilterOpen;
    notifyListeners();
  }

  void toggleFromType() {
    _fromTypeVisible = !_fromTypeVisible;
    notifyListeners();
  }

  void toggleFromDate() {
    _fromDateVisible = !_fromDateVisible;
    notifyListeners();
  }

  void togglePatientName() {
    _patientNameVisible = !_patientNameVisible;
    notifyListeners();
  }

  void toggleClinicalName() {
    _clinitianNameVisible = !_clinitianNameVisible;
    notifyListeners();
  }

  void togglePrimaryInsurance() {
    _primaryInsuranceVisible = !_primaryInsuranceVisible;
    notifyListeners();
  }

  void toggleDeadLine() {
    _deadLineVisible = !_deadLineVisible;
    notifyListeners();
  }

  void toggleCodingStaff() {
    _codingStaffVisible = !_codingStaffVisible;
    notifyListeners();
  }
}