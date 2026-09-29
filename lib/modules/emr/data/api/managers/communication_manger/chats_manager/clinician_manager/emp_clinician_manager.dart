import 'package:flutter/material.dart';

import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/communication_data/chats_data/clinitian_data/clinical_empChat_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/communication_data/chats_data/clinitian_data/clinitian_emp_data.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/base64/encode_decode_base64.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'dart:convert';
import 'package:symmetry_emr/modules/emr/data/api/repository/communication_repo/communication_repo.dart';

import 'package:dio/dio.dart';   // ← add this import at the top

Future<ApiData> sendClinicianMessage(
    BuildContext context, {
      required int empId,
      required String textContent,
      required bool isMedia,
      required bool isVoiceNote
    }) async {
  try {
    var response = await Api(context).post(
      path: CommunicationManagerRepository.postEmployeeChat(),
      data: isVoiceNote == false ? {
        "receiver_emp_id": empId,
        "text_content": textContent,
      } : {
        "receiver_emp_id": empId,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Message Sent Successfully");
      var uploadResponse = response.data;
      int employeeChatId = uploadResponse['emp_chat_id'];
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage ?? "Success",
          data: response.data,
          empChatId: employeeChatId
      );
    } else {
      print("Error 1");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'] ?? "Error occurred",
      );
    }
  } on DioException catch (e) {
    // ✅ surfaces the REAL backend reason instead of a generic message
    final serverMessage = e.response?.data is Map
        ? (e.response?.data['message'] ?? e.response?.data['error'])
        : null;

    print("sendClinicianMessage DioException [${e.response?.statusCode}]: ${e.response?.data}");

    return ApiData(
      statusCode: e.response?.statusCode ?? 400,
      success: false,
      message: serverMessage?.toString() ?? AppString.somethingWentWrong,
    );
  } catch (e) {
    print("Error $e");
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}

Future<List<EmpDepartmentChatdetails>> getAllChatsClinitianGroups(BuildContext context,
    final int pageNo,
    final int rowNo,
    final String searchName,
    final String selectDept) async
{
  try {
    final response = await Api(context).get(
      path: CommunicationManagerRepository.getEmployeeChat(pageNo: pageNo, rows: rowNo,
          searchName: searchName, selectDepartment: selectDept),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      //print("Clinitian Group Chats API Response: ${response.data}");

      List<EmpDepartmentChatdetails> groupList = [];

      // assuming the response.data is a List (as in your provided JSON)
      for (var item in response.data) {
        groupList.add(
          EmpDepartmentChatdetails(
              partnerEmpId: item['partner_emp_id'] ?? 0,
              firstName: item['firstName'] ?? '',
              lastName: item['lastName'] ?? '',
              imageUrl: item['imgurl'] ?? '',
              lastMessage: item['lastMessageText'] ?? '',
              lastMessageTime: item['lastMessageTimestamp'] ?? '',
              unseenCount: item['unseenMessageCount'] ?? 0,
              userId: item['userId'] ?? 0
          ),
        );
      }

      return groupList;
    } else {
      print("Clinitian Group API Error: ${response.statusMessage}");
      return [];
    }
  } catch (e) {
    print("Clinitian Group API Exception: $e");
    return [];
  }
}




List<String> parseAttachedMultimediaUrl(dynamic raw) {
  if (raw == null) return const [];

  // Case 1: already a list from backend
  if (raw is List) {
    return raw.map((e) => e.toString()).toList();
  }

  // Case 2: backend sends a JSON-encoded string: "[\"url1\",\"url2\"]"
  if (raw is String) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const [];

    try {
      final decoded = json.decode(trimmed);

      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }

      if (decoded is String) {
        // e.g. "\"https://...\"" – single string inside JSON
        return [decoded];
      }
    } catch (_) {
      // Fallback: maybe comma-separated single string "url1,url2"
      return trimmed
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
  }

  return const [];
}



///seles ,clinical ,admin
Future<ChatDepartmentGroupCommunicationData?> chatClinicalGroupCommunication(
    BuildContext context,
    final int otherEmpId,
    final int pageNo,
    final int rowNo
    ) async
{
  try {
    final response = await Api(context).get(
      path: CommunicationManagerRepository.getAllEmployeeChat(pageNo: pageNo,rows: rowNo,otherEmpid: otherEmpId),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      //print("Chat Clinical Group Communication API Response: ${response.data}");

      final data = response.data;
      final empInfo = data["employee_info"] ?? {};
      final empInfoData = EmployeeClinicalInfoData(
          employeeId: empInfo['employeeId'] ?? 0,
          userId: empInfo['user_id'] ?? 0,
          fullName: empInfo['fullName'] ?? '',
          imageUrl: empInfo['imgurl'] ?? '',
          isOnline: empInfo['isOnline'] ?? false);
      // ------------------ Participants ------------------
      List<ParticipantData> participants = [];
      if (data["participants"] != null) {
        for (var p in data["participants"]) {
          participants.add(
            ParticipantData(
              fullName: p["fullName"] ?? "",
              imgUrl: p["imgurl"] ?? "",
              email: p["email"] ?? "",
              isOnline: p["isOnline"] ?? false,
              willReceiveSms: p["willReceiveSms"] ?? false,
              departmentId: p['departmentId'] ?? 0,
              departmentName: p['departmentName'] ?? '',
              role: p['role'] ?? '',
              employeeId: p['employeeId'] ?? 0,
              userId: p['user_id'] ?? 0,
              position: p['position'] ?? '',
            ),
          );
        }
      }

      // ------------------ Messages ------------------
      // ------------------ Messages ------------------
      List<Message> messages = [];
      if (data["messages"] != null) {
        for (var m in data["messages"]) {
          final sender = m["sender"] ?? {};
          List<String> voiceNoteUrls = parseAttachedMultimediaUrl(m['voice_note_url']);
          messages.add(
            Message(
              voiceNoteUrl:voiceNoteUrls ,
              textContent: m["text_content"] ?? "",
              dateCreated: m["date_created"] ?? "",
              dateModified: m["date_modified"],
              unsend: m["unsend"] ?? false,
              seenByEmployees:
              List<int>.from(m["seen_by_employees"] ?? const <int>[]),

              // ✅ use parser, returns List<String>
              attachedMultimediaUrl:
              parseAttachedMultimediaUrl(m["attached_multimedia_url"]),

              stickerMultimediaUrl: m["sticker_multimedia_url"] ?? "",
              sender: Sender(
                senderId: sender["senderId"] ?? 0,
                senderType: sender["senderType"] ?? "",
                firstName: sender["firstName"] ?? "",
                lastName: sender["lastName"] ?? "",
                imgUrl: sender["imgurl"] ?? "",
              ),
              sendAsSms: m["sent_as_sms"] ?? false,
              isMine: m["isMine"] ?? false,
              empChatId: m["emp_chat_id"] ?? 0,
              senderEmpId: m["sender_emp_id"] ?? 0,
              receiverEmpId: m["receiver_emp_id"] ?? 0,
            ),
          );
        }
      }



      // ------------------ Pagination ------------------
      final paginationData = data["pagination"] ?? {};
      final pagination = Pagination(
        currentPage: paginationData["currentPage"] ?? 1,
        totalPages: paginationData["totalPages"] ?? 1,
        totalMessages: paginationData["totalMessages"] ?? 0,
        hasNextPage: paginationData["hasNextPage"] ?? false,
        hasPreviousPage: paginationData["hasPreviousPage"] ?? false,
      );

      // ------------------ Final Combined Model ------------------
      return ChatDepartmentGroupCommunicationData(
        participants: participants,
        messages: messages,
        pagination: pagination, empInfoData: empInfoData,
      );
    } else {
      print("Chat Clinical Group Communication API Error: ${response.statusMessage}");
      return null;
    }
  } catch (e) {
    print("Chat Clinical Group Communication API Exception: $e");
    return null;
  }
}

Future<ApiData> deleteEmployeeChat(
    BuildContext context, {
      required int otherEmpId,

    }) async {
  try {
    var response = await Api(context).delete(
      path: CommunicationManagerRepository.deleteEmpChat(otherEmpId: otherEmpId),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Emp Chat clear Successfully");
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage ?? "Success",
        data: response.data,
      );
    } else {
      print("Error 1");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'] ?? "Error occurred",
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

Future<ApiData> uploadMediaEmpChat({
  required BuildContext context,
  required int employeeChatId,
  required dynamic documentFiles,   // Uint8List / List<int>
  required String documentNames,    // list of names
}) async {
  try {
    /// Convert all selected files to base64
    // List<String> base64List = [];

    // for (var file in documentFiles) {
      // file is Uint8List / List<int>
      String encoded = await AppFilePickerBase64.getEncodeBase64(bytes: documentFiles);
      // base64List.add(encoded);
    // }

    print("Base64 List (emp): $encoded");

    final response = await Api(context).post(
      path: CommunicationManagerRepository.empAttachMedia(
        employeeId: employeeChatId,
      ),
      data: {
        "base64": encoded,       // list of base64 strings
        "fileNames": documentNames, // list of file names
      },
    );

    print("Emp Attach Response: ${response.data}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Documents uploaded to employee chat");

      final uploadResponse = response.data as Map<String, dynamic>? ?? {};

      // ✅ Use safe parser instead of List<String>.from(...)
      final List<String> mediaUrls =
      parseAttachedMultimediaUrl(uploadResponse['attached_multimedia_url']);

      return ApiData(
        statusCode: response.statusCode ?? 0,
        success: true,
        message: response.statusMessage ?? '',
        mediaUrlList: mediaUrls, // if ApiData has this field
      );
    } else {
      print("Emp attach error: ${response.statusMessage}");

      return ApiData(
        statusCode: response.statusCode ?? 0,
        success: false,
        message: (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Something went wrong',
      );
    }
  } catch (e, st) {
    print("Emp attach exception: $e");
    print(st);
    return ApiData(
      statusCode: 500, // better than fake 404
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}




Future<ApiData> uploadMediaEmpChatsm({
  required BuildContext context,
  required int employeeChatId,
  required dynamic documentFile,
  // required String documentName

}) async {
  try {
    String documents = await AppFilePickerBase64.getEncodeBase64(bytes: documentFile);
    print("File :::${documents}" );
    var response = await Api(context).post(
      path:CommunicationManagerRepository.empAttachMedia(employeeId: employeeChatId),
      data: {
        // 'base64':documents,
        "base64": documents,
        // "file_name":documentName

      },
    );
    print("Response ${response.toString()}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("......>>>>>>>Documents uploaded emp chat");
      // orgDocumentGet(context);
      var uploadResponse = response.data;
      String mediaUrlE = uploadResponse['attached_multimedia_url'];
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
      mediaUrl: mediaUrlE);
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

Future<EmpDetailsDataClass> getEmpDetailCommunication(BuildContext context,
    final int empId) async
{
  var empDetails;
  try {
    final response = await Api(context).get(
      path: CommunicationManagerRepository.getEmployeeDetailsCom(empId: empId),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Employee Details API Response: ${response.data}");


      List<String> mediaUrl = [];
      if (response.data["media"] != null) {
        for (var m in response.data["media"]) {
          mediaUrl.add(
              m
          );
        }
      }
      // assuming the response.data is a List (as in your provided JSON)
      empDetails =
          EmpDetailsDataClass(
              firstName: response.data['firstName'] ?? '',
              lastName: response.data['lastName'] ?? '',
            employeeId: response.data['employeeId'] ?? 0,
            userId: response.data['userId'] ?? 0,
            profileUrl: response.data['profileUrl'] ?? '',
            departmentId: response.data['departmentId'] ?? 0,
            employeeTypeId: response.data['employeeTypeId'] ?? 0,
            employeeTypeAbbreviation: response.data['employeeTypeAbbreviation'] ?? '',
            employeeTypeColor: response.data['employeeTypeColor'] ?? '',
            media: mediaUrl,
          );
      return empDetails;
    } else {
      print("Employee Group API Error: ${response.statusMessage}");
      return empDetails;
    }
  } catch (e) {
    print("Employee Group API Exception: $e");
    return empDetails;
  }
}

Future<ApiData> uploadVoiceEmpChat({
  required BuildContext context,
  required int otherEmpChatId,
  required dynamic documentFile,
  required String documentName,
  required int duration,

}) async {
  try {
    String documents = await AppFilePickerBase64.getEncodeBase64(bytes: documentFile);
    print("File :::${documents}" );
    var response = await Api(context).post(
      path:CommunicationManagerRepository.empAttachVoiceMedia(employeeId: otherEmpChatId),
      data: {
        "base64": documents,
        "fileName": documentName,
        "duration": duration
      },
    );
    print("Response ${response.toString()}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("......>>>>>>>Voice Note uploaded Emp chat");
      // orgDocumentGet(context);
      // var uploadResponse = response.data;
      // String mediaUrlP = uploadResponse['attached_multimedia_url'];
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
        // mediaUrl: mediaUrlP,
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
        statusCode: 404, success: false, message: "Something Went Wrong!");
  }
}

