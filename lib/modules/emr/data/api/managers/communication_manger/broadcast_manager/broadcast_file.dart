import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/communication_data/broadcast_data/broadcast.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/communication_repo/communication_repo.dart';

// Future<List<Broadcast>> getAllBroadcast(BuildContext context) async {
//   List<Broadcast> broadcastList = [];
//
//   try {
//     final response = await Api(context).get(
//       path: CommunicationManagerRepository.getAllBroadcast(), // Replace with your actual API method
//     );
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       print("Broadcast API Response: ${response.data}");
//
//       for (var item in response.data["data"]) {
//         broadcastList.add(
//           Broadcast(
//             broadcastId: item["broadcast_id"] ?? 0,
//             patientId: item["patient_id"] ?? 0,
//             employeeId: List<int>.from(item["employee_id"] ?? []),
//             description: item["description"] ?? "",
//             createdAt: item["created_at"] ?? "--",
//             updatedAt: item["updated_at"] ?? "--",
//             success: true,
//             message: response.data["message"] ?? "",
//           ),
//         );
//       }
//     } else {
//       print("Broadcast API Error: ${response.statusMessage}");
//       return broadcastList;
//     }
//
//     return broadcastList;
//   } catch (e) {
//     print("Broadcast API Exception: $e");
//     return broadcastList;
//   }
// }

Future<BrodcastModelData> getAllBroadcast({required BuildContext context,
required int pageNo,required int rows, required String searchText}) async {
  String convertIsoToDayMonthYear(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      DateTime dateTime = DateTime.parse(isoDate);
      return DateFormat('dd.MM.yy').format(dateTime);
    } catch (_) {
      return '';
    }
  }
  String convertIsoToTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      DateTime dateTime = DateTime.parse(isoDate);
      return DateFormat('hh:mm a').format(dateTime).toLowerCase(); // Example: 10:32 PM
    } catch (_) {
      return '';
    }
  }
  var broadcastItemData;
  try {
    final response = await Api(context).get(
      path: CommunicationManagerRepository.getAllBroadcast(
          pageNo: pageNo,
          rows: rows,
          searchName: searchText), // your API path
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Broadcast API Response: ${response.data}");
        broadcastItemData =
          BrodcastModelData(
            message: response.data["message"] ?? "",
            data: ( response.data['data'] as List).map((a) {
            return AlertItem(
                alertId: a['alert_id'] ?? 0,
                alertHeading: a['alert_heading'] ?? '',
                alertBody: a['alert_body'] ?? '',
                alertResolve: a['alert_resolve'] ?? false,
                createdAt: a['created_at'] !=null ? convertIsoToDayMonthYear(a['created_at']) : '',
                time: a['created_at'] !=null ? convertIsoToTime(a['created_at']) : '',
                day: a['day'] ?? '',
                sender: a['sender'] != null ? Sender(
                    userId: a['sender']['user_id'] ?? 0,
                    name: a['sender']['name'] ?? '',
                    role: a['sender']['role'] ?? '') : Sender(
                    userId:  0,
                    name:  '',
                    role:  ''),
                clinician: a['clinician'] != null ? Clinician(
                    employeeId: a['clinician']['employeeId'] ?? 0,
                    fullName: a['clinician']['fullName'] ?? '',
                    imgurl: a['clinician']['imgurl'] ?? '',
                    abbreviation: a['clinician']['abbreviation'] ?? '',
                    color: a['clinician']['color'] ?? '#FFFFFF') : Clinician(
                    employeeId: 0,
                    fullName: '',
                    imgurl: '',
                    abbreviation: '',
                    color: '')

            );
          }).toList(),
          );

      return broadcastItemData;
    } else {
      print("Broadcast API Error: ${response.statusMessage}");
      return broadcastItemData;
    }
  } catch (e) {
    print("Broadcast API Exception: $e");
    return broadcastItemData;
  }
}

Future<ApiData> postBrodcaseData({
  required BuildContext context,
  required int userId, // Pass the order ID here
  required List<int> clinicialId,
  required String aleartHeading,
  required String aleartBody,
}) async {
  try {
    var response = await Api(context).post( // Use PATCH method
      path: CommunicationManagerRepository.addAleartBroadcast(), // Pass orderId into the endpoint
      data: {
        "user_id": userId,
        "clinician_id": clinicialId,
        "alert_heading": aleartHeading,
        "alert_body": aleartBody
      },
    );

    print("📥 Received response:");
    print("Status Code: ${response.statusCode}");
    print("Response Data: ${response.data}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Add aleart data successfully");
      var responseData = response.data;
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage ?? "Success",
        banckingId: responseData['orderId'], // adjust if needed
      );
    } else {
      print("Broadcast added: ${response.statusCode}");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'] ?? "Something went wrong",
      );
    }
  } catch (e) {
    print("Error updating order: $e");
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}

Future<BroadCastChipsData> getAllBroadcastChips({required BuildContext context,
required String searchText}) async {
  String convertIsoToDayMonthYear(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      DateTime dateTime = DateTime.parse(isoDate);
      return DateFormat('dd.MM.yy').format(dateTime);
    } catch (_) {
      return '';
    }
  }
  String convertIsoToTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      DateTime dateTime = DateTime.parse(isoDate);
      return DateFormat('hh:mm a').format(dateTime); // Example: 10:32 PM
    } catch (_) {
      return '';
    }
  }
  var broadcastItemData;
  try {
    final response = await Api(context).get(
      path: CommunicationManagerRepository.getAllBroadcastChipsData(
          searchName: searchText), // your API path
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      broadcastItemData =
          BroadCastChipsData(
            message: response.data["message"] ?? "",
            data: ( response.data['data'] as List).map((a) {
              return ChipsData(
                  employeeId: a['employeeId'] ?? 0,
                  employeeName:  a['employee_name'] ?? '',
                  code:  a['code'] ?? '',
                  imgUrl:  a['imgurl'] ?? ''
              );
            }).toList(),
          );

      return broadcastItemData;
    } else {
      print("Broadcast API Error: ${response.statusMessage}");
      return broadcastItemData;
    }
  } catch (e) {
    print("Broadcast API Exception: $e");
    return broadcastItemData;
  }
}

