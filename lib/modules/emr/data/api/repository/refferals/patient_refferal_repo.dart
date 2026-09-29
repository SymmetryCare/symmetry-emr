class PatientRefferalsRepo{
  static String patientRefferals ="/patient-referral";
  static String serviceRefferals = '/services-master';
  static String employeeClinical = '/employee-types/GetClinicianType';
  static String patientInsuarnce = '/insurances-master';
  static String marketerApi = '/employees/department';

  /// patient document
  static String patientDocument = '/patient-document/patient';
  static String patientDocumentAdd = '/patient-document/add';
  static String patientDocumentDelete = '/patient-document';
  static String patientDocumentAttach = '/patient-document/attach-document';

  /// filter master repo
  static String patientRefferalsMaster = '/referral-sources';
  static String patientPhysicianMaster = '/physician-master';
  static String patientDiagnosisiMaster = '/diagnosis-master';

  /// patient diagnosis
  static String patientDiagnosisGet = '/referral-patient-diagnosis/patient';
  static String patientDiagnosisAdd = '/referral-patient-diagnosis';

  ///f2f document
  static String f2fPatient = '/f2f/patient';
  static String f2fDocument = '/f2f/document';
  static String f2fAdd = '/f2f/add';
  static String f2fDocAdd = '/f2f/document/add';
  static String f2fDocAttach = '/f2f/document/attach/';


  ///order
  static String referalsources = '/referral-sources';
  static String spacialorder = '/orders/special';
  static String orderpatient = '/orders/patient';
  static String orderpatientprifill = '/orders/patient/by-patient';
  static String orderpatientpatch = '/orders/patient';

  ///scheduler
  static String tobescheduler = '/patient-referral/toBeScheduled';
  static String scheduler = '/patient-referral/scheduled';
  static String discipschedulerd = '/discipline/patient';
  static String disciplinebyid = '/discipline/clinician_asigned';
  static String schedulerNew = '/scheduler';
  static String employeesugg = '/employees/by-employeeType';

  ///patient-referral/non-admit/{pageNbr}/{NbrofRows}/{sort}/{searchName}/{marketerId}/{referralSourceId}/{pcpId}
  static String getNonAdmit =  '/non-admit';

  static  String getReferralNonAdmitData({ required int pgNbr, required int nbrOfRows, required String sort, required String searchName ,required String marketerId, required String referralSourceId,required String pcpId}){
    return "$patientRefferals$getNonAdmit/$pgNbr/$nbrOfRows/$sort/$searchName/$marketerId/$referralSourceId/$pcpId";
  }
  ///scheduler/{screen}/{pgNbr}/{nbrOfRows}/{sort}/{isScheduler}/{isNonAdmit}/{searchName}/{marketerId}/{referralSourceId}/{pcpId}
  static  String getSchedulerFlowPatientData({required String screen, required int pgNbr, required int nbrOfRows, required String sort, required String isScheduler,required String isNonAdmit, required String searchName ,required String marketerId, required String referralSourceId,required String pcpId,}){
    return "$schedulerNew/$screen/$pgNbr/$nbrOfRows/$sort/$isScheduler/$isNonAdmit/$searchName/$marketerId/$referralSourceId/$pcpId";
  }



  /// patient diagnosis
 // static String patientDiagnosisGet = '/referral-patient-diagnosis/patient';
 // static String patientDiagnosisAdd = '/referral-patient-diagnosis';

///patient-referral/{pageNbr}/{NbrofRows}/{isIntake}/{intakeSort}/{isArchived}/{archivedSort}/{isScheduled}/{scheduledSort}/{isNonAdmit}/{nonAdmitSort}/{searchName}/{marketerId}/{referralSourceId}/{pcpId}
  static  String getPatientRefferals({required int pageNo, required int nbrOfRows, required String isIntake, required String intakeSort, required String isArchived, required String archivedSort,required String isScheduled, required String scheduledSort, required String isNonAdmit, required String nonAdmitSort,required String searchName, required String marketerId,required String referralSourceId, required String pcpId}){
    return "$patientRefferals/$pageNo/$nbrOfRows/$isIntake/$intakeSort/$isArchived/$archivedSort/$isScheduled/$scheduledSort/$isNonAdmit/$nonAdmitSort/$searchName/$marketerId/$referralSourceId/$pcpId";
  }

  static  String getPatientRefferalsWithId({required int id}){
    return "$patientRefferals/$id";
  }

  ///patient-referral/{id}
  static  String updateSchedularWithId({required int id}){
    return "$patientRefferals/$id";
  }

  static  String getReffrealsServiceData(){
    return "$serviceRefferals";
  }

  static  String getReffrealsEmployeeClinicalType(){
    return "$employeeClinical";
  }

  static  String getReffrealsInsurance(){
    return "$patientInsuarnce";
  }

  static  String getReffrealsInsuranceWithId({required int id}){
    return "$patientInsuarnce/$id";
  }

  static  String getPatientDocument({required int patientId}){
    return "$patientDocument/$patientId";
  }

  static  String addPatientDocument(){
    return "$patientDocumentAdd";
  }

  static  String deletePatientDocument({required int id}){
    return "$patientDocumentDelete/$id";
  }
  ///patient-document/patient/{patientId}/{documentType}
  static  String getPatientDocumentByDocType({required int patientId, required int documentType}){
    return "$patientDocument/$patientId/$documentType";
  }

  ///f2f/patient/{patientId}
  static  String getPatientDocumentF2FIntake({required int patientId}){
    return "$f2fPatient/$patientId";
  }
  ///f2f/add
  static  String addF2F(){
    return "$f2fAdd";
  }
  ///f2f/document/add
  static  String addDocumentF2FAdd(){
    return "$f2fDocAdd";
  }
  ///f2f/document/attach/{f2f_doc_id}
  static  String addDocumentF2FAttach({required int f2f_doc_id}){
    return "$f2fDocAttach/$f2f_doc_id";
  }

  static  String deleteF2FDocument({required int id}){
    return "$f2fDocument/$id";
  }


  static  String attachPatientDocument({required int rptd_id}){
    return "$patientDocumentAttach/$rptd_id";
  }

  /// filter master

  static  String patientPhysicianmaster(){
    return "$patientPhysicianMaster";
  }

  static  String patientReffrealsSources(){
    return "$patientRefferalsMaster";
  }

  static  String patientReffrealsSearchSources({required String searchPatient}){
    return "$patientRefferalsMaster/name/$searchPatient";
  }

  /// marketer data
  static  String getMarketerIdWithData({required int deptId}){
    return "$marketerApi/$deptId";
  }

  static  String getDiagnosisMaster(){
    return "$patientDiagnosisiMaster";
  }

  static String getReferalpath(){
    return "$referalsources";
  }

  static String getspecialorderpath(){
    return "$spacialorder";
  }

  /// Patient diagnosis
  static  String getPatientDiagnosisWithPtId({required int ptId}){
    return "$patientDiagnosisGet/$ptId";
  }

  static  String addPatientDiagnosis(){
    return "$patientDiagnosisAdd";
  }

  static  String patchPatientDiagnosis({required int id}){
    return "$patientDiagnosisAdd/$id";
  }

  ///order screen post
  static  String addPatientorder(){
    return "$orderpatient";
  }
//prifill
  static  String getPatientorderbyid({required int pt_id}){
    return "$orderpatientprifill/$pt_id";
  }

  static  String updateorderId({required int id}){
    return "$orderpatientpatch/$id";
  }

  ///get
  static  String gettobescheduler({ required int pageNbr, required int NbrofRows, required String isNonAdmit , required String isScheduler,required String searchName, }){
    return "$tobescheduler/$pageNbr/$NbrofRows/$isNonAdmit/$isScheduler/$searchName";
  }

  ///patient-referral/scheduled/{pageNbr}/{NbrofRows}/{isNonAdmit}/{isScheduler}/{searchName}
  static  String getScheduler({required int pageNbr, required int NbrofRows, required String isNonAdmit, required String isScheduler, required String searchName}){
    return "$scheduler/$pageNbr/$NbrofRows/$isNonAdmit/$isScheduler/$searchName";
  }

  static  String getdisciplanebyid({required int pt_id}){
    return "$discipschedulerd/$pt_id";
  }

  static String patchDisciplineEndpoint({required int discipline_id , required String is_assign}) {
    return "$disciplinebyid/$discipline_id/$is_assign";
  }

  static String getEmpSuggestionEndpoint({required int employeeTypeId, required String searchClinician,
    required int patientId
  }) {
    return "$employeesugg/$employeeTypeId/$searchClinician/$patientId";
  }

}

