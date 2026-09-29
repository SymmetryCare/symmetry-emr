class ProfileSectonRepo {
  static String timeOff            = "/time-off";
  static String employeeDocuments  = "/employee-documents/getBy";
  static String uploadDocument     = "/employee-documents/uploadDocumentbase64";
  static String timeOffTypes       = "/time-off-types";
  static String leaveTypes         = "/leave-types";
  static String patientVisits      = "/patient-visits";
  static String employees          = "/employees";
  static String clinicianEarning   = "/patient-visits/earning";
  static String employeeUpdateList = "/employee-documents/ByemployeeIdGrouped";
  static String employeeDocumentTypeSetup = "/employee-document-type-setup";

  static String assignedPatients = "/patient-referral/clinician/assigned-patients";


  static String getEmployeeDocumentsById({required int employeeId, required String approve, required String searchText}) {
    return "$employeeUpdateList/$employeeId/$approve/$searchText";
  }

  static String uploadEmployeeDocument({
    required int employeeDocumentTypeMetaDataId,
    required int employeeDocumentTypeSetupId,
    required int employeeId,
  }) {
    return "$uploadDocument/$employeeDocumentTypeMetaDataId/$employeeDocumentTypeSetupId/$employeeId";
  }

  static String getTimeOffTypes() {
    return timeOffTypes;
  }

  static String addTimeOff() {
    return "/$timeOff";
  }

  static String getLeaveTypes() {
    return leaveTypes;
  }

  static String getTimeOffHistory({required int employeeId}) {
    return "$timeOff/$employeeId/history";
  }

  static String getCompletedVisitsStats() {
    return "$patientVisits/clinician/completed-visits-stats";
  }

  static String getClinicianProfile() {
    return "$employees/me/clinician";
  }

  static String updateEmployee({required int employeeId}) {
    return "$employees/$employeeId";
  }

  static String getClinicianEarning({required int clinicianId}) {
    return "$clinicianEarning/$clinicianId";
  }

  static String getTodayCompletedVisits() {
    return "$patientVisits/clinician/today/completed";
  }

  static String getEmployeeDocumentTypeSetupByMetaDataId({
    required int employeeDocumentTypeMetaDataId,
  }) {
    return "$employeeDocumentTypeSetup/ByDocumentTypeMetaDataId/$employeeDocumentTypeMetaDataId";
  }

  static String getEssentialDocs() {
    return "$employeeDocumentTypeSetup/essential-docs";
  }

  // ── new
  static String getClinicianCalendar({
    required String dateFrom,
    required String dateTo,
  }) {
    return "$patientVisits/clinician/calendar/$dateFrom/$dateTo";
  }



  static String getAssignedPatients({
    String search = 'all',
    String statusFilter = 'all',
  }) {
    return "$assignedPatients/$search/$statusFilter";
  }

//---------alert--------------------------

  static String getAlertByPatient({
    required int patientId,
    required String alertType,
  }) {
    return '/alert/ByPatient/$patientId/$alertType';
  }

  static String updateAlert({required int alertId}) {
    return '/alert/$alertId';
  }

  static String deleteAlert({required int alertId}) {
    return '/alert/$alertId';
  }

}


