import 'package:flutter/material.dart';

import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/setting_profile_data/document_uploaded_data.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/setting_profile_emr_repo/profile_secton_repo.dart';


Future<EmployeeDocumentData> getEmployeeDocuments({
  required BuildContext context,
  required int employeeId,
  required String searchFilter,
}) async {
  try {
    final response = await Api(context).get(
      path: ProfileSectonRepo.getEmployeeDocumentsById(
          employeeId: employeeId,
          approve: 'no',
          searchText: searchFilter),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data =
          (response.data as Map<String, dynamic>?) ?? {};

      final String todayDate = data['todayDate'] ?? '';
      final List<dynamic> documentList =
          (data['document'] as List<dynamic>?) ?? [];

      final List<DocumentGroup> documentGroups = [];

      for (var groupItem in documentList) {
        if (groupItem is! Map<String, dynamic>) continue;
        final Map<String, dynamic> groupJson = groupItem;

        final List<dynamic> docListJson =
            (groupJson['docList'] as List<dynamic>?) ?? [];

        final List<DocItem> docItems = [];
        for (var docItem in docListJson) {
          if (docItem is! Map<String, dynamic>) continue;
          final Map<String, dynamic> docJson = docItem;

          docItems.add(DocItem(
            employeeDocumentId:
            docJson['employeeDocumentId']  ?? 0,
            employeeId: docJson['employeeId']  ?? 0,
            documentUrl: docJson['DocumentUrl']  ?? '',
            employeeDocumentTypeMetaDataId:
            docJson['EmployeeDocumentTypeMetaDataId']  ?? 0,
            employeeDocumentTypeSetupId:
            docJson['EmployeeDocumentTypeSetupId']  ?? 0,
            uploadDate: docJson['UploadDate']  ?? '',
            approved: docJson['approved'] ?? false,
            documentName: docJson['documentName']  ?? '',
            expiryDate: docJson['expiry_date'] ?? '--',
            docStatus: docJson['docStatus']  ?? '',
            status: docJson['status']  ?? '',
          ));
        }

        documentGroups.add(DocumentGroup(
          docName: groupJson['docName'] ?? '',
          metaId: groupJson['metaId'] ?? 0,
          docList: docItems,
        ));
      }

      return EmployeeDocumentData(
        todayDate: todayDate,
        document: documentGroups,
      );
    } else {
      debugPrint("Employee documents error: ${response.statusCode}");
      return EmployeeDocumentData(todayDate: '', document: []);
    }
  } catch (e) {
    debugPrint("getEmployeeDocuments error: $e");
    return EmployeeDocumentData(todayDate: '', document: []);
  }
}





///post api
Future<ApiData> uploadEmployeeDocument({
  required BuildContext context,
  required int employeeDocumentTypeMetaDataId,
  required int employeeDocumentTypeSetupId,
  required int employeeId,
  required String base64,
  required String documentName,
}) async {
  try {
    final response = await Api(context).post(
      path: ProfileSectonRepo.uploadEmployeeDocument(
        employeeDocumentTypeMetaDataId: employeeDocumentTypeMetaDataId,
        employeeDocumentTypeSetupId: employeeDocumentTypeSetupId,
        employeeId: employeeId,
      ),
      data: {
        "base64": base64,
        "documentName": documentName,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ Document uploaded successfully");
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
    debugPrint("uploadEmployeeDocument error: $e");
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}







///dropdpwn api
///
Future<List<EmployeeDocumentTypeSetupData>> getEmployeeDocumentTypeSetup({
  required BuildContext context,
  required int employeeDocumentTypeMetaDataId,
}) async {
  try {
    final response = await Api(context).get(
      path:  ProfileSectonRepo.getEmployeeDocumentTypeSetupByMetaDataId(
        employeeDocumentTypeMetaDataId: employeeDocumentTypeMetaDataId,
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> jsonList = response.data as List<dynamic>;
      return jsonList.map((e) => EmployeeDocumentTypeSetupData(
        employeeDocumentTypeSetupId: e['EmployeeDocumentTypeSetupId'],
        documentName: e['DocumentName'],
        expiry: e['Expiry'],
        reminderThreshold: e['ReminderThreshold'],
        employeeDocumentTypeMetaDataId: e['EmployeeDocumentTypeMetaDataId'],
        idOfDocument: e['idOfDocument'],
        companyId: e['companyId'],
        expiryType: e['expiry_type'],
        threshold: e['threshold'],
      )).toList();
    } else {
      debugPrint("getEmployeeDocumentTypeSetup error: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    debugPrint("getEmployeeDocumentTypeSetup error: $e");
    return [];
  }
}





///
///
Future<List<EssentialDocData>> getEssentialDocs({
  required BuildContext context,
}) async {
  try {
    final response = await Api(context).get(
      path: ProfileSectonRepo.getEssentialDocs(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> jsonList = response.data as List<dynamic>;
      return jsonList.map((e) => EssentialDocData(
        documentName: e['DocumentName'],
        employeeDocumentTypeMetaDataId: e['EmployeeDocumentTypeMetaDataId'],
      )).toList();
    } else {
      debugPrint("getEssentialDocs error: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    debugPrint("getEssentialDocs error: $e");
    return [];
  }
}