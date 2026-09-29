// lib/data/repository/my_task_order/my_task_order_repository.dart

// class MyTaskOrderRepository {
//   static String _myTasks = '/patient-form/my-tasks';
//
//   static String getMyTasks({
//     int? patientId,
//     int? chartId,
//     int? episodeId,
//     int? formId,
//     int? visitTypeId,
//     int? schedulerId,
//     String? tab,
//     String? search,
//     int page = 1,
//     int limit = 20,
//   }) {
//     final params = <String, String>{};
//     if (patientId != null) params['patientId'] = patientId.toString();
//     if (chartId != null) params['chartId'] = chartId.toString();
//     if (episodeId != null) params['episodeId'] = episodeId.toString();
//     if (formId != null) params['formId'] = formId.toString();
//     if (visitTypeId != null) params['visitTypeId'] = visitTypeId.toString();
//     if (schedulerId != null) params['schedulerId'] = schedulerId.toString();
//     if (tab != null) params['tab'] = tab;
//     if (search != null) params['search'] = search;
//     params['page'] = page.toString();
//     params['limit'] = limit.toString();
//
//     final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
//     return '$_myTasks?$query';
//   }
// }



// lib/data/repository/patient_referral/patient_referral_repository.dart

class PatientReferralRepository {
  static String _patientReferral = '/patient-referral';

  static String getById({required int id}) {
    return '$_patientReferral/$id';
  }
}


// lib/data/repository/employee/employee_by_id_repository.dart

class EmployeeByIdRepository {
  static String _employees = '/employees';

  static String getById({required int employeeId}) {
    return '$_employees/$employeeId';
  }
}