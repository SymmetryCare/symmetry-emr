import 'package:flutter/material.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';

import 'package:symmetry_emr/modules/emr/data/models/qa_coordinator_data/qa_coader_patient_filter_data.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/qa_coordinator/qa_coader_patient_filter_repo.dart';

Future<List<SupplyOrderPatientDropdownData>> getSupplyOrderPatientDropdown(
    BuildContext context,
    String role,
    ) async {
  List<SupplyOrderPatientDropdownData> itemsList = [];
  try {
    final response = await Api(context).get(
      path: SupplyOrderRepository.getPatientDropdown(role: role),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
          SupplyOrderPatientDropdownData(
            patientId: item['patientId'],
            name:      item['name'],
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