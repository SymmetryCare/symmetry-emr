// ── Data Model ────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/services/api/api.dart';

class DistinctInsuranceProviderData {
  final String providerName;

  DistinctInsuranceProviderData({
    required this.providerName,
  });
}

// ── Repository ────────────────────────────────────────────────────────────────
class PatientInsuranceRepository {
  static String _patientInsurance = '/patient-insurance';
  static String _distinctProviders = '/distinct-providers';

  static String getDistinctProviders = '$_patientInsurance$_distinctProviders';
}

// ── Manager ───────────────────────────────────────────────────────────────────


Future<List<DistinctInsuranceProviderData>> getDistinctInsuranceProviders(
    BuildContext context,
    ) async {
  List<DistinctInsuranceProviderData> itemsList = <DistinctInsuranceProviderData>[];
  try {
    final response = await Api(context).get(
      path: PatientInsuranceRepository.getDistinctProviders,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        if (item == null) continue;
        itemsList.add(
          DistinctInsuranceProviderData(
            providerName: item.toString(),
          ),
        );
      }
      print("Response:::::: ${response.data}");
    } else {
      print('getDistinctInsuranceProviders API Error: ${response.statusCode}');
    }
    return itemsList;
  } catch (e) {
    print("getDistinctInsuranceProviders Error: $e");
    return itemsList;
  }
}