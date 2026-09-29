class PatientIntakeRepo{
  static String demographich = '/demographics';
  static String aiDemographic = '/ai-demographics/patient';
  static String aiEmergencyContact = '/ai-emergency-contact/patient';
  static String aiRepresentative = "/ai-patient-representative/patient";
  static String discipline = '/discipline';

  static  String addPatientDemographich(){
    return "$demographich";
  }

  static  String getPatientDemographichWithPtId({required int ptId}){
    return "$demographich/patient/$ptId";
  }

  static String updatePatientDemographich({required int id}){
    return "$demographich/$id";
  }

  static String getAIDemographich({required int ptId}){
    return "$aiDemographic/$ptId";
  }

  static  String addDiscipline(){
    return "$discipline";
  }

  static String getAIEmergencyContact({required int ptId}){
    return "$aiEmergencyContact/$ptId";
  }

  static String getAIPatientRepresentative({required int ptId}){
    return "$aiRepresentative/$ptId";
  }

}