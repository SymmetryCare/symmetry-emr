import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/setting_profile_data/emr_profile_data.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/setting_profile_emr_repo/profile_secton_repo.dart';

Future<ClinicianProfileData?> getClinicianProfile({
  required BuildContext context,
}) async {
  try {
    final response = await Api(context).get(
      path: ProfileSectonRepo.getClinicianProfile(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ClinicianProfileData(
        clinicianFullName: response.data['clinicianFullName'] ?? '',
        imageUrl: response.data['imageUrl'] ?? '',
        employeeTypeId: response.data['employeeTypeId'] ?? 0,
        abbreviation: response.data['abbreviation'] ?? '',
        color: response.data['color'] ?? '',
        employeeType: response.data['employeeType'] ?? '',
        gender: response.data['gender'] ?? '',
        age: response.data['age'] ?? 0,
        email: response.data['email'] ?? '',
        mnumber: response.data['mnumber'] ?? '',
      );
    } else {
      debugPrint("Clinician profile error: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    debugPrint("getClinicianProfile error: $e");
    return null;
  }
}







Future<ApiData> updateEmployee({
  required BuildContext context,
  required int employeeId,
  required int userId,
  required String firstName,
  required String lastName,
  required String primaryPhoneNbr,
  required String personalEmail,
}) async {
  String extractBackendMessage(dynamic data, String? fallback) {
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'].toString();
    } else if (data is String && data.isNotEmpty) {
      return data;
    }
    return fallback ?? AppString.somethingWentWrong;
  }
  try {
    final companyId = await TokenManager.getCompanyId();

    print("PATCH updateEmployee path: ${ProfileSectonRepo.updateEmployee(employeeId: employeeId)}");
    print("PATCH updateEmployee body: employeeId=$employeeId, userId=$userId, firstName=$firstName, lastName=$lastName, primaryPhoneNbr=$primaryPhoneNbr, personalEmail=$personalEmail, companyId=$companyId");

    final response = await Api(context).patch(
      path: ProfileSectonRepo.updateEmployee(employeeId: employeeId),
      data: {
        "employeeId": employeeId,
        "userId": userId,
        "firstName": firstName,
        "lastName": lastName,
        "primaryPhoneNbr": primaryPhoneNbr,
        "personalEmail": personalEmail,
        "companyId": companyId,
      },
    );

    print("PATCH updateEmployee response statusCode: ${response.statusCode}");
    print("PATCH updateEmployee response data: ${response.data}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ Employee updated successfully");
      final backendMessage =
      extractBackendMessage(response.data, response.statusMessage);
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: backendMessage,
      );
    } else {
      debugPrint("Update employee error: ${response.statusCode}");
      final backendMessage =
      extractBackendMessage(response.data, response.statusMessage);
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: backendMessage,
      );
    }
  } on DioException catch (e) {
    print("updateEmployee DioException statusCode: ${e.response?.statusCode}");
    print("updateEmployee DioException data: ${e.response?.data}");
    final backendMessage = extractBackendMessage(e.response?.data, null);
    return ApiData(
      statusCode: e.response?.statusCode ?? 404,
      success: false,
      message: backendMessage,
    );
  } catch (e) {
    print("updateEmployee error: $e");
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}