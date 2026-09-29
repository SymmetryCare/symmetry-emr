class PatientInsuranceRepo{
  static String patientInsuranceDocuments = '/patient-document/patient';
  static String patientInsuranceDocumentsAdd = '/patient-insurance-documents/add';
  static String patientInsuranceDocumentAttach = '/patient-insurance-documents/attachDocument';
  static String patientInsuranceDocumentsDelete = '/patient-insurance-documents';
  static String patientInsuranceDocWithPtId = '/patient-insurance-documents';
  static String patientSecondIsurnace = '/patient-insurance-documents/patient';

  // insurance
  static String patientInsuranceInfo = '/patient-insurance/patient';
  static String updatePatientInsuranceInfo = '/patient-insurance';

  //emergency contact
  static String getRefPatientInsurance = '/ai-referral-patient-insurances/patient';


  static  String getPatientInsuranceDocuments({required int ptId,required bool isPrimary}){
    return "$patientInsuranceDocuments/$ptId/$isPrimary";
  }

  static  String addPatientInsuranceDocuments(){
    return "$patientInsuranceDocumentsAdd";
  }

  static  String attachPatientInsuranceDocuments({required int documentid}){
    return "$patientInsuranceDocumentAttach/$documentid";
  }

  static  String deletePatientInsuranceDocuments({required int documentid}){
    return "$patientInsuranceDocumentsDelete/$documentid";
  }

  static  String getPatientInsuranceDocumentsWithPtId({required int ptId,required bool isPrimary}){
    return "$patientInsuranceDocWithPtId/$ptId/$isPrimary";
  }

  static  String getPatientInsuranceSeconfDocumentsWithPtId({required int ptId}){
    return "$patientSecondIsurnace/$ptId";
  }


  static  String getPatientInsuranceAll(){
    return updatePatientInsuranceInfo;
  }

  // insurance info

  static  String getPatientInsuranceInfo({required int ptId}){
    return "$patientInsuranceInfo/$ptId";
  }

  static String updatePatientInsurance({required int id}){
    return "$updatePatientInsuranceInfo/$id";
  }

  //emergency contact
  ///ai-referral-patient-insurances/patient/{ptId}
  static String getIntakeRefPatientInsurance({required int ptId}){
    return "$getRefPatientInsurance/$ptId";
  }
}