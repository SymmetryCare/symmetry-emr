import 'package:flutter/material.dart';

import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/pending_visit_notes_model.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/dashboard_emr_repo.dart';

Future<PendingVisitNotesModel?> getPendingVisitNotes({
  required BuildContext context,
  required int employeeId,
  required String date,
}) async {
  PendingVisitNotesModel? itemsList;
  String _toInitials(String text) {
    if (text.trim().isEmpty) return '';
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase())
        .join();
  }
  try {
    final response = await Api(context).get(
      path: EMRDashboardRepo.getPendingVisitNotes(
        employeeId: employeeId,
        date: date,
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dynamic data = response.data;

      if (data != null && data is Map<String, dynamic>) {
        final int resEmployeeId = data['employeeId'] ?? 0;
        final String resDate = data['date'] ?? '';
        final List<dynamic> rawItems =
        data['items'] is List ? data['items'] as List<dynamic> : [];

        final List<PendingVisitItem> items = rawItems.map((rawItem) {
          final Map<String, dynamic> itemMap =
          rawItem as Map<String, dynamic>;

          final Map<String, dynamic>? diagnosisMap =
          itemMap['primaryDiagnosis'] as Map<String, dynamic>?;
          final Diagnosis diagnosis = Diagnosis(
            id: diagnosisMap?['id'] ?? 0,
            name: diagnosisMap?['name'] ?? '',
            code: diagnosisMap?['code'] ?? '',
          );

          final Map<String, dynamic>? visitTypeMap =
          itemMap['visitType'] as Map<String, dynamic>?;
          final String rawVisitTypeName = visitTypeMap?['name'] ?? '';
          final VisitType visitType = VisitType(
            id: visitTypeMap?['id'] ?? 0,
            name: _toInitials(rawVisitTypeName),
          );

          return PendingVisitItem(
            visitId: itemMap['visitId'] ?? 0,
            employeeId: itemMap['employeeId'] ?? 0,
            employeeTypeId: itemMap['employeeTypeId'] ?? 0,
            ptId: itemMap['pt_id'] ?? 0,
            patientName: itemMap['patientName'] ?? '',
            imageUrl: itemMap['imageUrl'] ?? '',
            primaryDiagnosis: diagnosis,
            visitType: visitType,
            visiteDateTimeFrom:
           itemMap['visiteDateTimeFrom'] ??
                "",
            visitDateTimeTo:
         itemMap['visitDateTimeTo'] ??
                "",
            isVisitCompleted: itemMap['isVisitCompleted'] ?? false,
            isVisitMissed: itemMap['isVisitMissed'] ?? false,
            isVisitAccepted: itemMap['isVisitAccepted'] ?? false,
            visitCharge: itemMap['visit_charge'] ?? 0,
          );
        }).toList();

        itemsList = PendingVisitNotesModel(
          employeeId: resEmployeeId,
          date: resDate,
          items: items,
        );
      }
    } else {
      debugPrint('Api Error: ${response.statusCode}');
    }

    debugPrint('Response::::: $response');
    return itemsList;
  } catch (e) {
    debugPrint('Error $e');
    return itemsList;
  }
}