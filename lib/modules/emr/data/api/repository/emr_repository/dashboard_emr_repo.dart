class EMRDashboardRepo{
  static String addReminder = "/reminder";
  static String remiderList = "/reminder/list";
  static String patientVisitList = "/patient-visits/clinician/today/list";
  static String rejectApproveVisit = "/rejected-visits";
  static String bulkApproveVisit = "/rejected-visits/approve-all";
  static String startVisit = "/patient-visits/clinician_assign";
  static String visitDetailsById = "/patient-visits";
  static String pendingVisitsNotes = "/patient-visits/clinician";
  static String pendingReviewForm = "/patient-form/assistant-pending-reviews";


  // supply order
  static String addSupplyOrder = "/supply-orders";
  static String supplyOrderCategory = "/supply-orders/categories";
  static String attachSupplyOrderImage = "/supply-orders/items/attach-image";
  static String skuInventory = "/inventory/search";
  static String supplyPatientOrderDetails = "/supply-orders/patient-info/search";
  static String supplyPatientDeepDetails = "/supply-orders/patient-info";
  static String supplyClinicalDetails = "/supply-orders/clinician-info";

  //notification
  static String notification = '/notifications';


  static String getPendingVisitNotes({required int employeeId,required String date}){
    return "$pendingVisitsNotes/$employeeId/$date/pending";
  }

  static String getNotification({required int userId}){
    return "$notification/$userId";
  }
  static String getPatientFormReview({required int patientId}){
    return "$pendingReviewForm/$patientId";
  }
  static String searchRemiderList({
    required String priority, required String date}){
    return "$remiderList/$priority/$date";
  }
  static String pauseTreatmentVisit({required int visitId}){
    return "$visitDetailsById/$visitId/treatment-pause";
  }
  static String recertDecisionVisit({required int visitId}){
    return "$visitDetailsById/$visitId/recert-window-decision";
  }
  static String reminderWithId({required int id}){
    return "$addReminder/$id";
  }

  static String patientVisitWithFilter({required String filter}){
    return "$patientVisitList/$filter";
  }

  static String patientMissedVisit({required int visitId}){
    return "$visitDetailsById/$visitId/mark-missed";
  }

  static String startVisitFromToday({required int visitId, required String isAssign}){
    return "$startVisit/$visitId/$isAssign";
  }

  static String patientVisitById({required int visitId}){
    return "$visitDetailsById/$visitId";
  }

  static String patientVisitEpisodEnd({required int visitId}){
    return "$visitDetailsById/$visitId/episode-end";
  }

  static String patientVisitEpisodEndSelf({required int visitId}){
    return "$visitDetailsById/$visitId/episode-end-self";
  }

  /// supply order
  static String uploadSupplyImage({required int supplyOrderItemId}){
    return "$attachSupplyOrderImage/$supplyOrderItemId";
  }

  static String inventorySearchByItem({required String searchTerm}){
    return "$skuInventory/$searchTerm";
  }

  static String inventorySearchPatient({required String patientName}){
    return "$supplyPatientOrderDetails/$patientName";
  }

  static String inventoryPatientDetails({required int patientId}){
    return "$supplyPatientDeepDetails/$patientId";
  }

  static String inventoryClinicalDetails({required String searchQuery}){
    return "$supplyClinicalDetails/$searchQuery";
  }

}



class ClinicianAlertRepository {
  static String _alert = '/alert';
  static String _byClinician = '/ByClinician';

  static String getByClinician({required int clinicianId}) {
    return '$_alert$_byClinician/$clinicianId';
  }
}




class ClinicianVisitsMapRepository {
  static String _patientVisits = '/patient-visits';
  static String _map = '/map';
  static String _today = '/today';

  static String getTodayMapData({required int clinicianId}) {
    return '$_patientVisits$_map$_today/$clinicianId';
  }
}

class RequestVisitRepository {
  static String _base = '/patient-visits';
  static String _requestVisit = '/request_visit';
  static String approveForDifferentDay = '/rejected-visits/approve-different-day';
  static String approve = '/rejected-visits/approve';

  static String getRequestVisitList({
    required int clinicianId,
    required String visitStatus,
    required String patientName,
  }) {
    return '$_base$_requestVisit/$clinicianId/$visitStatus/$patientName';
  }

  static String approveAll = '/rejected-visits/approve-all';

  static String approveSingle({required int visitId}) {
    return '/rejected-visits/$visitId/approve';
  }
}

class VisitsRepository {
  static String _visits = '/visits';
  static String _visitList = '/visitList';

  static String getVisitList = '$_visits$_visitList';
}

class PatientVisitsRepository {
  static String _patientVisits = '/patient-visits';

  static String update({required String id}) {
    return '$_patientVisits/$id';
  }
}