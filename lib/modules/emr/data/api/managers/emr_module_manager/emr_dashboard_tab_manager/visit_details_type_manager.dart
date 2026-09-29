import 'package:flutter/material.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/visist_type_data.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/dashboard_emr_repo.dart';

Future<List<VisitListData>> getVisitList(BuildContext context) async {
  List<VisitListData> itemsList = [];
  try {
    final response = await Api(context).get(
      path: VisitsRepository.getVisitList,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        List<EligibleClinicianData> clinicians = [];
        for (var c in (item['eligibleClinician'] ?? [])) {
          clinicians.add(
            EligibleClinicianData(
              employeeTypeId: c['employeeTypeId'],
              eligibleClinician: c['eligibleClinician'],
              color: c['color'],
            ),
          );
        }
        itemsList.add(
          VisitListData(
            visitId: item['visitId'],
            typeOfVisit: item['typeOfVisit'],
            serviceId: item['serviceId'],
            eligibleClinician: clinicians,
          ),
        );
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}


Future<ApiData> updatePatientVisit(
    BuildContext context,
    String id,
    int ptId,
    int visitType,
    ) async {
  try {
    var response = await Api(context).patch(
      path: PatientVisitsRepository.update(id: id),
      data: {
        "pt_id": ptId,
        "visitType": visitType,
      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient visit updated");
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




Future<ApiData> updatePatientVisitcalender(
    BuildContext context,
    String id,
    int ptId,
    int visitType, {
      String visiteDateTimeFrom = '',
      String visitDateTimeTo = '',
    }) async {
  try {
    var response = await Api(context).patch(
      path: PatientVisitsRepository.update(id: id),
      data: {
        "pt_id": ptId,
        "visitType": visitType,
        if (visiteDateTimeFrom.isNotEmpty)
          "visiteDateTimeFrom": visiteDateTimeFrom,
        if (visitDateTimeTo.isNotEmpty)
          "visitDateTimeTo": visitDateTimeTo,
      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient visit updated");
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