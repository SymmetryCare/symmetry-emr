import 'package:flutter/material.dart';

import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/patient_tab_data/patient_protocol_model.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/base64/encode_decode_base64.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/emr_patient_repo/patient_protocol_repo.dart';

Future<List<PatientProtocolModule>> getProtocolDropDown({
  required BuildContext context,
}) async {
  List<PatientProtocolModule> itemsList = [];
  try {
    final response = await Api(context).get(path: PatientProtocolRepo.getProtocol);
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(PatientProtocolModule(
            protocolTypeId: item['protocolTypeId'] ?? 0,
            typeName: item['typeName'] ?? '',
            createdAt: item['createdAt'] ?? '',
            updatedAt: item['updatedAt'] ?? ''
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

Future<List<PatientProtocolListModule>> getProtocolListData({
  required BuildContext context,
  required int ptId,
}) async {
  List<PatientProtocolListModule> itemsList = [];
  try {
    final response = await Api(context).get(path: PatientProtocolRepo.getProtocolList(patientId: ptId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(PatientProtocolListModule(
            protocolId: item['protocolId'] ?? 0,
            patientId: item['patientId'] ?? 0,
            protocolTypeId: item['protocolTypeId'] ?? 0,
            pdfUrl: item['pdfUrl'] ?? "",
            fileName: item['fileName'] ?? "",
            uploadedAt: item['uploadedAt'] ?? "",
            createdAt: item['createdAt'] ?? "",
            updatedAt: item['updatedAt'] ?? "",
            protocolType: ProtocolData(
                protocolTypeId: item['protocolType']['protocolTypeId'] ?? 0,
                typeName: item['protocolType']['typeName'] ?? '',
                createdAt: item['protocolType']['createdAt'] ?? '',
                updatedAt: item['protocolType']['updatedAt'] ?? ''
            )
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

/// Post protocol

Future<ApiData> postPatientProtocol({
  required BuildContext context,
  required int ptId,
  required int protocolTypeId,

}) async {
  try {
    final response = await Api(context).post(
      path: PatientProtocolRepo.protocolAction,
      data: {
        "patientId": ptId,
        "protocolTypeId": protocolTypeId
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ Protocol created successfully");
      final data = response.data;
      final protocolId = data['protocolId'] ?? 0;
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
        protocolId: protocolId
      );
    } else {
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'],
      );
    }
  } catch (e) {
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}

Future<ApiData> uploadPatientProtocolDocument({
  required BuildContext context,
  required int protocolId,           // ← was patientId
  required dynamic base64,
  required String documentName,
}) async {
  try {
    var base64file = await AppFilePickerBase64.getEncodeBase64(bytes: base64);
    final response = await Api(context).post(
      path: PatientProtocolRepo.postUploadDoc(protocolId: protocolId),  // ← was patientId
      data: {
        "base64": base64file,
        "fileName": documentName,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ Document uploaded successfully");
      return ApiData(statusCode: response.statusCode!, success: true, message: response.statusMessage!);
    } else {
      print("Document upload error: ${response.statusCode}");
      return ApiData(statusCode: response.statusCode!, success: false, message: response.data['message']);
    }
  } catch (e) {
    print("uploadPatientProtocolDocument error: $e");
    return ApiData(statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}