import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/new_visit_request_data.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/dashboard_emr_repo.dart';



Future<RequestVisitResponseData> getRequestVisitList(
    BuildContext context, {
      required int clinicianId,
      required String visitStatus,
      required String patientName,
    }) async {
  try {
    final response = await Api(context).get(
      path: RequestVisitRepository.getRequestVisitList(
        clinicianId: clinicianId,
        visitStatus: visitStatus,
        patientName: patientName,
      ),
    );
    print("Response::********:::: $response  *******");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final rawVisits = response.data['visits'] as List? ?? [];
      List<RequestVisitData> visitsList = [];

      for (var item in rawVisits) {
        final rawVisitList = item['visitList'] as List? ?? [];
        List<VisitListItemData> visitListItems = [];
        for (var v in rawVisitList) {
          visitListItems.add(VisitListItemData(
            visitId: v['visitId'] ?? 0,
            visitDateFrom: v['visitDateFrom'] ?? '',
            visitDateTo: v['visitDateTo'] ?? '',
            employeeTypeId: v['employeeTypeId'] ?? 0,
            employeeTypeAbbreviation: v['employeeTypeAbbreviation'] ?? '',
            employeeTypeColor: v['employeeTypeColor'] ?? '',
          ));
        }

        visitsList.add(RequestVisitData(
          visitId: item['visitId'] ?? 0,
          visitStatus: item['visitStatus'],
          visitDateTime: item['visitDateTime'],
          warning: item['warning'],
          ptId: item['pt_id'] ?? 0,
          mrn: item['mrn'] ?? 0,
          patientName: item['patientName'] ?? '',
          patientImage: item['patientImage'] ?? '',
          patientGenderId: item['patientGenderId'] ?? 0,
          genderName: item['genderName'] ?? '',
          patientAge: item['patientAge'] ?? 0,
          primaryDiagnosisId: item['primaryDiagnosisId'] ?? 0,
          primaryDiagnosisName: item['primaryDiagnosisName'] ?? '',
          visitType: item['visitType'] ?? '',
          visitTimeframeFrom: item['visitTimeframeFrom'] ?? '',
          visitTimeframeTo: item['visitTimeframeTo'] ?? '',
          requestType: item['requestType'],
          isZone: item['isZone'] ?? '',
          zoneId: item['zoneId'] ?? 0,
          zoneName: item['zoneName'] ?? '',
          patientAddress: item['patientAddress'] ?? '',
          distance: (item['distance'] ?? 0).toDouble(),
          visitNote: item['visit_note'] ?? '',
          visitCharge: (item['visit_charge'] ?? 0).toDouble(),
          visitList: visitListItems,
        ));
      }

      return RequestVisitResponseData(
        todaysDate: response.data['todaysDate'] ?? '',
        visits: visitsList,
      );
    } else {
      print('Api Error');
      return RequestVisitResponseData(todaysDate: '', visits: []);
    }
  } catch (e) {
    print("Error $e");
    return RequestVisitResponseData(todaysDate: '', visits: []);
  }
}

Future<ApiData> approveAllVisits(
    BuildContext context,
    List<int> visitIds,
    ) async {
  try {
    var response = await Api(context).post(
      path: RequestVisitRepository.approveAll,
      data: {"visitIds": visitIds},
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Visits approved");
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.data['message'] ?? response.statusMessage!,
      );
    } else {
      print("Error 1");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'],
      );
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}

// Future<ApiData> approveSingleVisit(
//     BuildContext context,
//     int visitId,
//     ) async {
//   try {
//     var response = await Api(context).patch(
//       path: RequestVisitRepository.approveSingle(visitId: visitId),
//       data: {"visitId": visitId},
//     );
//     print(response);
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       print("Visit approved");
//       return ApiData(
//         statusCode: response.statusCode!,
//         success: true,
//         message: response.data['message'] ?? response.statusMessage!,
//       );
//     } else {
//       print("Error 1");
//       return ApiData(
//         statusCode: response.statusCode!,
//         success: false,
//         message: response.data['message'],
//       );
//     }
//   } catch (e) {
//     print("Error $e");
//     return ApiData(
//       statusCode: 404,
//       success: false,
//       message: AppString.somethingWentWrong,
//     );
//   }
// }

// Future<ApiData> rejectVisit(
//     BuildContext context,
//     int visitId,
//     String reason,
//     ) async {
//   try {
//     var response = await Api(context).post(
//       path: EMRDashboardRepo.rejectApproveVisit,
//       data: {
//         "visitId": visitId,
//         "reason": reason,
//       },
//     );
//     print(response);
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       print("Visit rejected");
//       return ApiData(
//         statusCode: response.statusCode!,
//         success: true,
//         message: response.data['message'] ?? response.statusMessage!,
//       );
//     } else {
//       print("Error 1");
//       return ApiData(
//         statusCode: response.statusCode!,
//         success: false,
//         message: response.data['message'],
//       );
//     }
//   } catch (e) {
//     print("Error $e");
//     return ApiData(
//       statusCode: 404,
//       success: false,
//       message: AppString.somethingWentWrong,
//     );
//   }
// }




///post  reject
Future<ApiData> rejectVisit(
    BuildContext context,
    int visitId,
    String rejectedReason,
    String noteToScheduler,
    ) async {
  try {
    var response = await Api(context).post(
      path: EMRDashboardRepo.rejectApproveVisit,
      data: {
        "visitId": visitId,
        "rejectedReason": rejectedReason,
        "isVisitAccepted": false,
        "noteToScheduler": noteToScheduler,

      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Visit rejected");
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.data['message'] ?? response.statusMessage!,
      );
    } else {
      print("Error 1");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'],
      );
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}





///post on other day
///
Future<ApiData> approveVisitForDifferentDay(
    BuildContext context,
    int visitId,
    String newDate,
    String startTime,
    String endTime,
    ) async {
  try {
    var response = await Api(context).post(
      path: RequestVisitRepository.approveForDifferentDay,
      data: {
        "visitId": visitId,
        "newDate": newDate,
        "startTime": startTime,
        "endTime": endTime,
      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Visit approved for different day");
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
      );
    } else {
      print("Error 1");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'],
      );
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}



Future<ApiData> approveRejectedVisit(
    BuildContext context,
    int visitId,
    String startTime,
    String endTime,
    ) async {
  try {
    var response = await Api(context).post(
      path: RequestVisitRepository.approve,
      data: {
        "visitId": visitId,
        "startTime": startTime,
        "endTime": endTime,
      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Rejected visit approved");
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
      );
    } else {
      print("Error 1");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'],
      );
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}