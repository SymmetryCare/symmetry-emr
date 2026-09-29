import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/referringdiagnosis_data/sm_signature_data.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/refferals/sm_signature_repo.dart';

// ── GET list by patient ───────────────────────────────────────────────────────
Future<List<SignatureFormDocumentData>> getSignatureFormDocumentsByPatient(
    BuildContext context,
    int patientId,
    ) async {
  List<SignatureFormDocumentData> itemsList = [];
  try {
    final response = await Api(context).get(
      path: SignatureFormDocumentRepository.getByPatientId(patientId: patientId),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
          SignatureFormDocumentData(
            sigDocId:        item['sig_doc_id'],
            fkPtId:          item['fk_pt_id'],
            sigDocUrl:       item['sig_doc_url'] ?? '',
            sigDocName:      item['sig_doc_name'] ?? '',
            sigDocContent:   item['sig_doc_content'],
            sigDocCreatedAt: item['sig_doc_created_at'] ?? '',
            sigDocCreatedBy: item['sig_doc_created_by'] ?? '',
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

// ── POST create record ────────────────────────────────────────────────────────
Future<ApiData> createSignatureFormDocument(
    BuildContext context,
    int fkPtId,
    ) async {
  try {
    var response = await Api(context).post(
      path: SignatureFormDocumentRepository.add,
      data: {
        "fk_pt_id": fkPtId,
      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Signature form document created");
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

// ── POST attach PDF ───────────────────────────────────────────────────────────
Future<ApiData> attachSignatureFormDocument(
    BuildContext context,
    int sigDocId,
    String base64,
    String documentName,
    ) async {
  try {
    var response = await Api(context).post(
      path: SignatureFormDocumentRepository.attachDocument(sigDocId: sigDocId),
      data: {
        "base64": base64,
        "documentName": documentName,
      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Document attached successfully");
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

// ── CHAINED: create → attach ──────────────────────────────────────────────────
Future<ApiData> createAndAttachSignatureFormDocument(
    BuildContext context,
    int fkPtId,
    String base64,
    String documentName,
    ) async {
  try {
    // Step 1 — create record
    var createResponse = await Api(context).post(
      path: SignatureFormDocumentRepository.add,
      data: {
        "fk_pt_id": fkPtId,
      },
    );
    print("Create response:::::$createResponse");

    if (createResponse.statusCode != 200 && createResponse.statusCode != 201) {
      print("Error creating signature form document");
      return ApiData(
        statusCode: createResponse.statusCode!,
        success: false,
        message: createResponse.data['message'],
      );
    }

    // Step 2 — extract sigDocId
    final int sigDocId = createResponse.data['sig_doc_id'] ??
        createResponse.data['id'] ??
        createResponse.data['sigDocId'];
    print("sigDocId:::::$sigDocId");

    // Step 3 — attach PDF
    var attachResponse = await Api(context).post(
      path: SignatureFormDocumentRepository.attachDocument(sigDocId: sigDocId),
      data: {
        "base64": base64,
        "documentName": documentName,
      },
    );
    print("Attach response:::::$attachResponse");

    if (attachResponse.statusCode == 200 || attachResponse.statusCode == 201) {
      print("Document created and attached successfully");
      return ApiData(
        statusCode: attachResponse.statusCode!,
        success: true,
        message: attachResponse.statusMessage!,
      );
    } else {
      print("Error attaching document");
      return ApiData(
        statusCode: attachResponse.statusCode!,
        success: false,
        message: attachResponse.data['message'],
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



Future<ApiData> deleteSignatureFormDocument(
    BuildContext context,
    int sigDocId,
    ) async {
  try {
    var response = await Api(context).delete(
      path: SignatureFormDocumentRepository.delete(sigDocId: sigDocId),
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Signature form document deleted");
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




