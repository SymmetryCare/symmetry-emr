
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/reminder_model.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/dashboard_emr_repo.dart';


Future<ApiData> addToDoReminder({
required BuildContext context,
  required String title,
  required String date,
  required String startTime,
  required String endTime,
  required String priority,
  required bool isCompleted
}) async {
  try {
    var response = await Api(context).post(
      path: EMRDashboardRepo.addReminder,
      data:{
        "title": title,
        "date": date,
        "start_time": startTime,
        "end_time": endTime,
        "priority": priority,
        "is_completed": isCompleted
      }
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Reminder added");

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
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

/// Patch reminder
Future<ApiData> patchToDoReminder({
  required BuildContext context,
  required int reminderId,
  required String title,
  required String date,
  required String startTime,
  required String endTime,
  required String priority,
  required bool isCompleted
}) async {
  try {
    var response = await Api(context).patch(
        path: EMRDashboardRepo.reminderWithId(id: reminderId),
        data:{
          "title": title,
          "date": date,
          "start_time": startTime,
          "end_time": endTime,
          "priority": priority,
          "is_completed": isCompleted
        }
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Reminder updated");

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
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);}
}

/// delete reminder
Future<ApiData> deleteToDoReminder({
  required BuildContext context,
  required int reminderId,
}) async {
  try {
    var response = await Api(context).delete(
        path: EMRDashboardRepo.reminderWithId(id: reminderId),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Reminder deleted");

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
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);}
}

/// get reminder list
Future<ReminderData> getReminderToDoList({
  required BuildContext context,
  required String priority,
  required String date,
}) async {
  String convertIsoToDayMonthYear(String isoDate) {
    DateTime dateTime = DateTime.parse(isoDate);
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    return dateFormat.format(dateTime);
  }

  ReminderData? itemsData;
  try {
    final response = await Api(context).get(
        path: EMRDashboardRepo.searchRemiderList(priority: priority, date: date));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<RemiderListData> listData = [];

      // API response: { "message": "...", "data": [ { "reminder_id": 4, ... } ] }
      // response.data is the full map, so extract the 'data' list from it
      final List<dynamic> dataList = response.data['data'] ?? [];
      for (var item in dataList) {
        listData.add(RemiderListData(
          reminderId:    item['reminder_id']  ?? 0,
          title:         item['title']        ?? '',
          clinicianName: item['clinician_name'] ?? '',
          date:          item['date'] != null
              ? convertIsoToDayMonthYear(item['date'])
              : '',
          startTime:     item['start_time']   ?? '',
          endTime:       item['end_time']     ?? '',
          priority:      item['priority']     ?? '',
          isCompleted:   item['is_completed'] ?? false,
          createdAt:     item['created_at'] != null
              ? convertIsoToDayMonthYear(item['created_at'])
              : '',
        ));
      }

      itemsData = ReminderData(data: listData);
    } else {
      debugPrint("Reminder list error: ${response.statusCode}");
    }

    return itemsData ?? ReminderData(data: []);
  } catch (e) {
    debugPrint("getReminderToDoList error: $e");
    return ReminderData(data: []);
  }
}

/// get reminder  with id
Future<ReminderDataPrefill> getReminderToDoPreFill(
    {
      required BuildContext context,
      required int reminderId,
    }
    ) async {
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);
    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);
    return formattedDate;
  }

  var itemsData;
  try {
    final response = await Api(context).get(
        path: EMRDashboardRepo.reminderWithId(id: reminderId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final item = response.data;
        itemsData = ReminderDataPrefill(
            data:ReminderPreFillData(
          reminderId: item['data']['reminder_id']?? 0,
          title: item['data']['title']?? '',
          date: item['data']['date'] != null ? convertIsoToDayMonthYear(item['data']['date']):'',
          startTime: item['data']['start_time']??'',
          endTime: item['data']['end_time']?? '',
          priority: item['data']['priority']?? '',
          isCompleted: item['data']['is_completed']?? false,
          createdAt: item['data']['created_at'] != null ? convertIsoToDayMonthYear(item['data']['created_at']) :'',
          employeeId: item['data']['employee_id']?? 0,
          modifiedAt: item['data']['modified_at'] != null ? convertIsoToDayMonthYear(item['data']['modified_at']) :'',
        ));
        // itemsData.sort((a, b) => a.educationId.compareTo(b.educationId));

    } else {
      print("Reminder list error");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}


/// supply order

Future<ApiData> addOrderSupply({
  required BuildContext context,
  required String orderType,
  required int patientId,
  required int employeeId,
  required int categoryId,
  required List<Map<String, dynamic>> items,
  required String supplyMethod,
  required String address,
  required String deliveryMethod,
}) async {
  try {
    var response = await Api(context).post(
        path: EMRDashboardRepo.addSupplyOrder,
        data: {
          "orderType": orderType,
          "patientId": patientId,
          "employeeId": employeeId,
          "categoryId": categoryId,
          "items": items,
          "supplyMethod": supplyMethod,
          "address": address,
          "deliveryMethod": deliveryMethod
        });

    if (response.statusCode == 200 || response.statusCode == 201) {
      var data = response.data;

      List<int> orderItemIds = [];
      for (var item in data['items']) {
        orderItemIds.add(item['supplyOrderItemId'] ?? 0);
      }
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
          supplyOrderItemId: orderItemIds);
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message'] ?? AppString.somethingWentWrong);
    }
  } on DioException catch (e) {
    // Backend returned an error response (4xx/5xx)
    String backendMessage = AppString.somethingWentWrong;

    if (e.response != null && e.response?.data != null) {
      final resData = e.response!.data;
      if (resData is Map && resData['message'] != null) {
        backendMessage = resData['message'].toString();
      } else if (resData is String && resData.isNotEmpty) {
        backendMessage = resData;
      }
    }

    print("DioException: $backendMessage");
    return ApiData(
        statusCode: e.response?.statusCode ?? 404,
        success: false,
        message: backendMessage);
  } catch (e) {
    // Any other unexpected error (parsing, null, etc.)
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

Future<List<SupplyOrderCategoryData>> getSupplyOrderCategory(
    {
      required BuildContext context,
    }
    ) async {
  List<SupplyOrderCategoryData> itemsData = [];
  try {
    final response = await Api(context).get(
        path: EMRDashboardRepo.supplyOrderCategory);
    if (response.statusCode == 200 || response.statusCode == 201) {
      for(var item in response.data){
        itemsData.add(SupplyOrderCategoryData(
          categoryId: item['categoryId']?? 0,
          categoryName: item['categoryName']?? '',
        ));
      }
    } else {
      print("supply order list error");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

Future<ApiData> uploadOrderSupplyDoc({
  required BuildContext context,
  required int supplyOrderItemId,
  required String base64,
  required String documentName,
}) async {
  try {
    final response = await Api(context).post(
      path: EMRDashboardRepo.uploadSupplyImage(supplyOrderItemId: supplyOrderItemId),
      data: {
        "base64":base64
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ Supply order Document uploaded successfully");
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
      );
    } else {
      debugPrint("Document upload error: ${response.statusCode}");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'],
      );
    }
  } catch (e) {
    debugPrint("supply order upload doc error: $e");
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}


Future<List<InventorySupplyData>> getInventorySupplyData(
    {
      required BuildContext context,
      required String searchQuery
    }
    ) async {
  List<InventorySupplyData> itemsData = [];
  try {
    final response = await Api(context).get(
        path: EMRDashboardRepo.inventorySearchByItem(searchTerm: searchQuery));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for(var item in response.data){
        itemsData.add(InventorySupplyData(
            inventoryId: item['inventoryId']?? 0,
            name: item['name']?? '',
            qty: item['qty']?? 0,
            description: item['description']?? '',
            companyId: item['companyId']?? 0,
            sku: item['sku']?? '',
            price: item['price']?? 0,
            expiryDate: item['expiryDate']?? '',
            fkCategoryId: item['fkCategoryId']?? 0,));
      }
    } else {
      print("inventory order list error");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}



Future<List<PatientNameDetails>> getSupplyPatientByName(
    {
      required BuildContext context,
      required String patientName
    }
    ) async {
  List<PatientNameDetails> itemsData = [];
  try {
    final response = await Api(context).get(
        path: EMRDashboardRepo.inventorySearchPatient(patientName: patientName));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for(var item in response.data){
        itemsData.add(PatientNameDetails(
          patientId: item['patientId'] ?? 0,
          name: item['name'] ?? '',
        ));
      }
    } else {
      print("supply order list error");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}


Future<SupplyOrderPatientDetails> getSupplyPatientDeatils(
    {
      required BuildContext context,
      required int patientId
    }
    ) async {
  var itemsData ;
  try {
    final response = await Api(context).get(
        path: EMRDashboardRepo.inventoryPatientDetails(patientId: patientId));
    if (response.statusCode == 200 || response.statusCode == 201) {
        itemsData = SupplyOrderPatientDetails(
           age: response.data['age'] ?? 0,
          lastSupplyOrderDate: response.data['lastSupplyOrderDate'] ?? '',
          patientId: response.data['patientId'] ?? 0,
          name: response.data['name'] ?? 0,
          address: response.data['address'] ?? '',
        );

    } else {
      print("supply patient details list error");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

Future<List<SupplyOrderClinicalDetails>> getSupplyClinicalByName(
    {
      required BuildContext context,
      required String searchName
    }
    ) async {
  List<SupplyOrderClinicalDetails> itemsData = [];
  try {
    final response = await Api(context).get(
        path: EMRDashboardRepo.inventoryClinicalDetails(searchQuery: searchName));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for(var item in response.data){
        itemsData.add(SupplyOrderClinicalDetails(
          name: item['name'] ?? '',
          clinicianId: item['clinicianId'] ?? 0,
          gender: item['gender'] ?? '',
          address: item['address'] ?? '',
          photo: item['photo'] ?? '',
          employeeType: item['employeeType'] ?? '',
          abbreviation: item['abbreviation'] ?? '',
          colorCode: item['colorCode'] ?? '',
          lastSupplyOrderDate: item['name'] ?? '',
        ));
      }
    } else {
      print("supply order list error");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}



Future<ApiData> patchEpisodeEnd({
  required BuildContext context,
  required int visitId,
  required String episodeEndType
}) async {
  try {
    var response = await Api(context).patch(
        path: EMRDashboardRepo.patientVisitEpisodEnd(visitId: visitId),
        data:{
          "episodeEndType": episodeEndType,
        }
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Episode changed");

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
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

Future<ApiData> patchEpisodeEndSelf({
  required BuildContext context,
  required int visitId,
  required String episodeEndType
}) async {
  try {
    var response = await Api(context).patch(
        path: EMRDashboardRepo.patientVisitEpisodEndSelf(visitId: visitId),
        data:{
          "episodeEndType": episodeEndType,
        }
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Episode self changed");

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
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}