class PatientPhysicianRepo {
  static String getPatientPhysician = "/physician-master/byPatient";
  static String patientFormEMR = "/patient-form/emr";
  static String patientFormTowFormDoc = "/f2f/patient";
  static String signatureFormDoc = "/signature-form-documents/patient";
  static String patientFormDocuments = "/patient-document/patient";
  static String patientInsuranceDoc = "/patient-insurance-documents";

  static String getPatientPhysicianEndpoint({required int patientId}) {
    return "$getPatientPhysician/$patientId";
  }
  static String getPatientFormToFormDoc({required int patientId}) {
    return "$patientFormTowFormDoc/$patientId";
  }
  static String getSignatureFormDoc({required int patientId}) {
    return "$signatureFormDoc/$patientId";
  }
  static String getPatientFormDoc({required int patientId, required String documentType}) {
    return "$patientFormDocuments/$patientId/$documentType";
  }
  static String getPatientInsuranceDoc({required int patientId, required bool isPrimary}) {
    return "$patientInsuranceDoc/$patientId/$isPrimary";
  }
}






class PatientReferralRepository {
  static String patientReferral = '/patient-referral';
  static String header = '/header';

  static String getHeader({required int patientId}) {
    return '$patientReferral/$patientId$header';
  }
}