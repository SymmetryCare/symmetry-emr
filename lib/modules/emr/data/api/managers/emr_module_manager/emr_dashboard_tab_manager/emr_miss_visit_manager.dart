import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/app/services/api/api.dart';

// ── Repository ────────────────────────────────────────────────────────────────
class MarkMissedRepository {
  static String markMissed({required int visitId}) {
    return '/patient-visits/$visitId/mark-missed';
  }
}

class PatientVisitRepository {
  static String _patientVisits = '/patient-visits';

  static String reschedule({required int visitId}) {
    return '$_patientVisits/$visitId';
  }
  static String uploadVisitPhoto({required int visitId}) {
    return '$_patientVisits/upload-visit-photo/$visitId';
  }
}



// ── Manager ───────────────────────────────────────────────────────────────────
Future<ApiData> markVisitMissed(
    BuildContext context,
    int visitId, {
      required String reason,
      required bool isAttemptedVisit,
      String? photoUrl,
      required List<String> actionsTaken,
      required String notificationDate,
      required String notificationTime,
      required List<String> individualsNotified,
      required List<String> notificationMethods,
    }) async {
  try {
    var response = await Api(context).patch(
      path: MarkMissedRepository.markMissed(visitId: visitId),
      data: {
        "reason":              reason,
        "isAttemptedVisit":    isAttemptedVisit,
        "photoUrl":            photoUrl,
        "actionsTaken":        actionsTaken,
        "notificationDate":    notificationDate,
        "notificationTime":    notificationTime,
        "individualsNotified": individualsNotified,
        "notificationMethods": notificationMethods,
      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Visit marked as missed");
      var data = response.data;
      final missVisitPatientForm = data['patient_form_id'] ?? 0;
      final requiredEpisodEnd = data['requiresEpisodeEndDecision'] ?? false;
      final lastVisitId = data['lastVisitId'] ?? 0;
      final dischardeFormPatientId = data['dischargeFormPatientFormId'] ?? 0;
      final patientDischarged = data['patientDischarged'] ?? false;
      return ApiData(
        statusCode: response.statusCode!,
        success:    true,
        message:    response.statusMessage!,
        missVisitFormID: missVisitPatientForm,
        requiredEpisodEnd: requiredEpisodEnd,
        lastVisitId: lastVisitId,
        dischardeFormPatientId: dischardeFormPatientId,
        patientDischarged: patientDischarged,
      );
    } else {
      print("Error 1");
      return ApiData(
        statusCode: response.statusCode!,
        success:    false,
        message:    response.data['message'],
      );
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
      statusCode: 404,
      success:    false,
      message:    AppString.somethingWentWrong,
    );
  }
}



/////

Future<ApiData> rescheduleVisit(
    BuildContext context,
    int visitId,
    String visiteDateTimeFrom,
    String visitDateTimeTo,
    int rescheduleReasonId,
    bool isAttemptedVisit,
    ) async {
  try {
    final body = {
      "visiteDateTimeFrom": visiteDateTimeFrom,
      "visitDateTimeTo":    visitDateTimeTo,
      "rescheduleReasonId": rescheduleReasonId,
      "isAttemptedVisit":   isAttemptedVisit,
    };
    print("Reschedule body: $body");

    var response = await Api(context).patch(
      path: PatientVisitRepository.reschedule(visitId: visitId),
      data: body,
    );
    print("Reschedule response: ${response.statusCode} — ${response.data}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Visit rescheduled");
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
      );
    } else {
      print("Error 1 — ${response.data}");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'],
      );
    }
  } catch (e) {
    print("Error $e");
    // ── print raw response if DioException ──
    if (e is DioException) {
      print("Dio error response data: ${e.response?.data}");
      print("Dio error status: ${e.response?.statusCode}");
      return ApiData(
        statusCode: e.response?.statusCode ?? 500,
        success: false,
        message: e.response?.data?['message'] ?? AppString.somethingWentWrong,
      );
    }
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}




///
///
Future<ApiData> uploadVisitPhoto(
    BuildContext context,
    int visitId,
    String base64,
    ) async {
  try {
    var response = await Api(context).post(
      path: PatientVisitRepository.uploadVisitPhoto(visitId: visitId),
      data: {
        "base64": base64,
      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Visit photo uploaded");
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



class RescheduleReasonData {
  final int    rescheduleReasonId;
  final String reason;
  final String createdAt;
  final String updatedAt;

  RescheduleReasonData({
    required this.rescheduleReasonId,
    required this.reason,
    required this.createdAt,
    required this.updatedAt,
  });
}


class RescheduleReasonRepository {
  static String _rescheduleReason = '/reschedule-reason';

  static String getAll = '$_rescheduleReason';
}



Future<List<RescheduleReasonData>> getRescheduleReasonList(BuildContext context) async {
  List<RescheduleReasonData> itemsList = [];
  try {
    final response = await Api(context).get(
      path: RescheduleReasonRepository.getAll,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
          RescheduleReasonData(
            rescheduleReasonId: item['rescheduleReasonId'],
            reason:             item['reason'],
            createdAt:          item['createdAt'],
            updatedAt:          item['updatedAt'],
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