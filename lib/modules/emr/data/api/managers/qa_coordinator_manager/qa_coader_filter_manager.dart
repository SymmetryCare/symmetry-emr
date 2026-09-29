import 'package:flutter/material.dart';

import 'package:symmetry_emr/modules/emr/data/models/qa_coordinator_data/qa_coader_filter_data.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/qa_coordinator/qa_coader_filter_repo.dart';

Future<List<FormData>> getFormList(BuildContext context) async {
  List<FormData> itemsList = [];
  try {
    final response = await Api(context).get(
      path: FormRepository.getAll,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
          FormData(
            formId:         item['formId'],
            formName:       item['formName'],
            formCode:       item['formCode'],
            visitTypeId:    item['visit_type_id'],
            employeeTypeId: item['employee_type_id'],
            visitType:      item['visit_type'],
            employeeType:   item['employee_type'],
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




///
///

Future<PatientFormStaffResponseData> getPatientFormStaff(
    BuildContext context, {
      String? type,
      String? search,
      int? page,
      int? limit,
      String? employment,
      String? zoneIds,
      String? ptoFrom,
      String? ptoTo,
      int? productivityMin,
      int? productivityMax,
    }) async {
  List<PatientFormStaffData> itemsList = [];
  try {
    final response = await Api(context).get(
      path: PatientFormStaffRepository.getStaff(
        type:            type,
        search:          search,
        page:            page,
        limit:           limit,
        employment:      employment,
        zoneIds:         zoneIds,
        ptoFrom:         ptoFrom,
        ptoTo:           ptoTo,
        productivityMin: productivityMin,
        productivityMax: productivityMax,
      ),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data['data']) {
        itemsList.add(
          PatientFormStaffData(
            employeeId:     item['employeeId'],
            name:           item['name'],
            imgurl:         item['imgurl'] ?? '',
            employeeType: PatientFormStaffEmployeeTypeData(
              employeeTypeId: item['employee_type']['employeeTypeId'],
              employeeType:   item['employee_type']['employeeType'],
              abbreviation:   item['employee_type']['abbreviation'],
              color:          item['employee_type']['color'],
            ),
            totalTaskCount: item['totalTaskCount'],
          ),
        );
      }
      return PatientFormStaffResponseData(
        data:       itemsList,
        total:      response.data['total'],
        page:       response.data['page'],
        limit:      response.data['limit'],
        totalPages: response.data['totalPages'],
      );
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return PatientFormStaffResponseData(data: itemsList);
  } catch (e) {
    print("Error $e");
    return PatientFormStaffResponseData(data: itemsList);
  }
}