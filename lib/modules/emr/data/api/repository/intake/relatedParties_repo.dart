class RelatedPartiesRepo{
  static String emergencyContact = '/emergency-contact';
  static String rolePath = '/related-parties/role';
  static String typePath = '/related-parties/type';
  static String relatedParties = '/related-parties/patient-representative/patient/';
  static String representativeAdd = '/related-parties/patient-representative';
  static String emergencyandrepresent = "/related-parties/combined-contact-representative";


  static String getEmergencyContact({required int ptId}){
    return "$emergencyContact/patient/$ptId";
  }

  static String getRelatedRepresentive({required int ptId}){
    return "$relatedParties/$ptId";
  }

  static String addRelatedRepresentive(){
    return "$representativeAdd";
  }

  static String deleteRelatedRepresentive({required int id}){
    return "$representativeAdd/$id";
  }

  static String addEmergencyContact(){
    return "$emergencyandrepresent";
  }

  static String deleteEmergencyContact({required int id}){
    return "$emergencyContact/$id";
  }

  static String getRelatedPartiesRole(){
    return "$rolePath";
  }

  static String getRelatedPartiesType(){
    return "$typePath";
  }
}