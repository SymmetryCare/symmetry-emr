import 'package:flutter/material.dart';

import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/setting_profile_data/time_off_data.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/setting_profile_emr_repo/profile_secton_repo.dart';

Future<ApiData> addTimeOff({
  required BuildContext context,
  required int employeeId,
  required int timeOffTypeId,
  required int leaveTypeId,
  required String startDate,
  required String endDate,
  required String reason,
  required bool firstHalf,
}) async {
  try {
    print("---- addTimeOff REQUEST ----");
    print("employeeId   : $employeeId");
    print("timeOffTypeId: $timeOffTypeId");
    print("leaveTypeId  : $leaveTypeId");
    print("startDate    : $startDate");
    print("endDate      : $endDate");
    print("reason       : $reason");
    print("firstHalf    : $firstHalf");
    print("----------------------------");

    var response = await Api(context).post(
      path: ProfileSectonRepo.addTimeOff(),
      data: {
        "employeeId": employeeId,
        "timeOffTypeId": timeOffTypeId,
        "leaveTypeId": leaveTypeId,
        "startDate": startDate,
        "endDate": endDate,
        "reason": reason,
        "firstHalf": firstHalf,
      },
    );

    print("---- addTimeOff RESPONSE ----");
    print("statusCode   : ${response.statusCode}");
    print("statusMessage: ${response.statusMessage}");
    print("data         : ${response.data}");
    print("-----------------------------");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Time off added successfully");
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
      );
    } else {
      print("Error 1 — unexpected status: ${response.statusCode}");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'],
      );
    }
  } catch (e) {
    print("---- addTimeOff EXCEPTION ----");
    print("Error: $e");
    print("------------------------------");
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}



///leaves dropdown api
Future<List<TimeOffTypeData>> getTimeOffTypes({
  required BuildContext context,
}) async {
  List<TimeOffTypeData> itemsList = [];
  try {
    final response = await Api(context).get(
      path: ProfileSectonRepo.getTimeOffTypes(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> dataList = response.data;
      for (var item in dataList) {
        itemsList.add(TimeOffTypeData(
          id: item['id'] ?? 0,
          name: item['name'] ?? '',
        ));
      }
    } else {
      debugPrint("Time off types error: ${response.statusCode}");
    }

    return itemsList;
  } catch (e) {
    debugPrint("getTimeOffTypes error: $e");
    return itemsList;
  }
}






///leave type

Future<List<LeaveTypeData>> getLeaveTypes({
  required BuildContext context,
}) async {
  List<LeaveTypeData> itemsList = [];
  try {
    final response = await Api(context).get(
      path: ProfileSectonRepo.getLeaveTypes(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> dataList = response.data;
      for (var item in dataList) {
        itemsList.add(LeaveTypeData(
          id: item['id'] ?? 0,
          name: item['name'] ?? '',
        ));
      }
    } else {
      debugPrint("Leave types error: ${response.statusCode}");
    }

    return itemsList;
  } catch (e) {
    debugPrint("getLeaveTypes error: $e");
    return itemsList;
  }
}




///view history
///
Future<List<TimeOffHistoryData>> getTimeOffHistory({
  required BuildContext context,
  required int employeeId,
}) async {
  List<TimeOffHistoryData> itemsList = [];
  try {
    final response = await Api(context).get(
      path: ProfileSectonRepo.getTimeOffHistory(employeeId: employeeId),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> dataList = response.data['history'] ?? [];
      for (var item in dataList) {
        itemsList.add(TimeOffHistoryData(
          timeOffRequestId: item['timeOffRequestId'] ?? 0,
          employeeId:       item['employeeId']       ?? 0,
          employeeName:     item['employeeName']     ?? '',
          timeOffTypeId:    item['timeOffTypeId']    ?? 0,
          timeOffTypeName:  item['timeOffTypeName']  ?? '',
          startDate:        item['startDate']        ?? '',
          endDate:          item['endDate']          ?? '',
          reason:           item['reason']           ?? '',
          status:           item['status']           ?? '',
          createdAt:        item['createdAt']        ?? '',
        ));
      }
    } else {
      debugPrint("Time off history error: ${response.statusCode}");
    }

    return itemsList;
  } catch (e) {
    debugPrint("getTimeOffHistory error: $e");
    return itemsList;
  }
}