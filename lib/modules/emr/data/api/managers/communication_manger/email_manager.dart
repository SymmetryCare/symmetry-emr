// lib/models/employee_signature.dart

// lib/models/employee_signature_model.dart

import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/services/api/api.dart';

class EmployeeSignatureModel {
  final int employeeId;
  final int userId;
  final String firstName;
  final String lastName;
  final int departmentId;
  final int companyId;
  final String signatureUrl;

  EmployeeSignatureModel({
    required this.employeeId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.departmentId,
    required this.companyId,
    required this.signatureUrl,
  });

  String get fullName => '$firstName $lastName';
}


class SignatureManagerRepository {
  // If Api(context) already adds base URL, keep only the path:
  static String getEmployeeSignaturePath() {
    return '/employee-signature';
  }
}


Future<EmployeeSignatureModel?> getEmployeeSignature({
  required BuildContext context,
}) async {
  EmployeeSignatureModel? signatureData;

  try {
    final response = await Api(context).get(
      path: SignatureManagerRepository.getEmployeeSignaturePath(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Employee Signature API Response: ${response.data}");

      final data = response.data; // your JSON object

      signatureData = EmployeeSignatureModel(
        employeeId: data['employeeId'] ?? 0,
        userId: data['userId'] ?? 0,
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        departmentId: data['departmentId'] ?? 0,
        companyId: data['companyId'] ?? 0,
        signatureUrl: data['signatureURL'] ?? '',
      );

      return signatureData;
    } else {
      print("Employee Signature API Error: ${response.statusMessage}");
      return signatureData; // will be null if not set
    }
  } catch (e) {
    print("Employee Signature API Exception: $e");
    return signatureData; // null
  }
}
