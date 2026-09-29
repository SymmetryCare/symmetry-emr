

import 'package:flutter/material.dart';

import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
class MoveToSchedulerrepo{
  static String postmovetoscdeduler ='/discipline';



  static  String getVisits({
    required int companyId,
    required int pageNbr,
    required int nbrOfRows,}){
    return "/visits/$companyId/$pageNbr/$nbrOfRows";
  }
}


Future<ApiData> scheduleVisits({
  required BuildContext context,
  required int patientId,
  required List<Map<String, dynamic>> employeeVisits,
  required bool sentAsRequest,
}) async {
  try {
    var response = await Api(context).post(
      path: MoveToSchedulerrepo.postmovetoscdeduler,
      data: {
        "fk_pt_Id": patientId,
        "data": employeeVisits,
        // "sentAsRequest": sentAsRequest,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ Visits scheduled successfully");
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage ?? 'Success',
      );
    } else {
      print("❌ Error scheduling visits");
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'] ?? 'Failed to schedule visits',
      );
    }
  } catch (e) {
    print("⚠️ Exception while scheduling visits: $e");
    return ApiData(
      statusCode: 500,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}





Future<List<VisitTypeMasterModel>?> getVisitsForDropdown({
  required BuildContext context,
  required int companyId,
  required int pageNbr,
  required int nbrOfRows,
}) async {
  List<VisitTypeMasterModel>? itemsList;

  try {
    final response = await Api(context).get(
      path: MoveToSchedulerrepo.getVisits(
        companyId: companyId,
        pageNbr: pageNbr,
        nbrOfRows: nbrOfRows,
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> dataList = response.data as List? ?? [];

      itemsList = dataList.map((item) {
        final Map<String, dynamic> map = item as Map<String, dynamic>;

        final List<EligibleClinicianModel> clinicians =
        (map['eligibleClinician'] as List? ?? [])
            .map((e) {
          final Map<String, dynamic> c = e as Map<String, dynamic>;
          return EligibleClinicianModel(
            employeeTypeId: c['employeeTypeId'],
            eligibleClinician: c['eligibleClinician'],
            color: c['color'],
          );
        })
            .toList();

        return VisitTypeMasterModel(
          visitId: map['visitId'],
          typeOfVisit: map['typeOfVisit'],
          serviceId: map['serviceId'],
          eligibleClinician: clinicians,
        );
      }).toList();

      print('✅ Visits Dropdown Data: ${response.data}');
    } else {
      print('❌ Api Error');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
    }

    return itemsList;
  } catch (e) {
    print("⚠️ Error $e");
    return itemsList;
  }
}













///data file
class VisitTypeMasterModel {
  final int? visitId;
  final String? typeOfVisit;
  final String? serviceId;
  final List<EligibleClinicianModel>? eligibleClinician;

  VisitTypeMasterModel({
    this.visitId,
    this.typeOfVisit,
    this.serviceId,
    this.eligibleClinician,
  });
}

class EligibleClinicianModel {
  final int? employeeTypeId;
  final String? eligibleClinician;
  final String? color;

  EligibleClinicianModel({
    this.employeeTypeId,
    this.eligibleClinician,
    this.color,
  });
}

