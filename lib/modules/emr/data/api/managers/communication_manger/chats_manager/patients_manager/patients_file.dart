import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/communication_data/chats_data/patients_data/patients.dart';
import 'package:symmetry_emr/modules/emr/data/models/communication_data/chats_data/patients_data/patients_chat.dart';
import 'package:symmetry_emr/modules/emr/data/models/communication_data/chats_data/patients_data/patients_group_info.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/base64/encode_decode_base64.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/communication_repo/communication_repo.dart';

Future<List<PatientGroup>> getAllChatsPatientGroups(BuildContext context,
    final int pageNo,
    final int rowNo,
    final String searchName) async
{
  try {
    final response = await Api(context).get(
      path: CommunicationManagerRepository.getAllPatientsChats(pageNo: pageNo, rowNo: rowNo, searchName: searchName),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<PatientGroup> groupList = [];
      print('Group data ${response.data}');

      // assuming the response.data is a List (as in your provided JSON)
      for (var item in response.data) {
        // Parse nested group members
        List<GroupMember> members = [];
        if (item["groupMembers"] != null) {
          for (var member in item["groupMembers"]) {
            members.add(
              GroupMember(
                memberId: member["memberId"] ?? 0,
                firstName: member["firstName"] ?? "",
                lastName: member["lastName"] ?? "",
                imgUrl: member["imgurl"] ?? "",
              ),
            );
          }
        }

        groupList.add(
          PatientGroup(
            ptGroupId: item["pt_group_id"] ?? 0,
            groupName: item["group_name"] ?? "",
            groupDescription: item["group_description"] ?? "",
            groupProfileUrl: item["group_profile_url"] ?? "",
            isActive: item["is_active"] ?? false,
            groupMembers: members,
            unseenMessageCount: item["unseenMessageCount"] ?? 0,
            lastMessageTimestamp: item["lastMessageTimestamp"] ?? "--",
            lastMessageText: item['lastMessageText'] ?? 0,
          ),
        );
      }

      return groupList;
    } else {
      print("Patient Group API Error: ${response.statusMessage}");
      return [];
    }
  } catch (e) {
    print("Patient Group API Exception: $e");
    return [];
  }
}



List<String> parseAttachments(dynamic value) {
  if (value == null) return [];

  // Case: already a List
  if (value is List) {
    return value.map((e) => e.toString().trim()).toList();
  }

  // Case: Stringified JSON List
  if (value is String && value.trim().startsWith('[')) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded.map((e) => e.toString().trim()).toList();
      }
    } catch (e) {
      print("JSON decode error in attachments: $e");
    }
  }

  // Case: single URL string
  if (value is String) {
    if (value.trim().isEmpty) return [];
    return [value.trim()];
  }

  return [];
}

///patients chat panel
Future<ChatPatientsGroupCommunicationData?> chatPatientsGroupCommunication(
    BuildContext context,
    int groupId,
    int pageNo,
    int rowNo,
    ) async {
  try {
    final response = await Api(context).get(
      path: CommunicationManagerRepository.getChatPatientsGroupCommunication(
        grpId: groupId,
        pageNo: pageNo,
        rowNo: rowNo,
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      print("API Error: ${response.statusMessage}");
      return null;
    }

    final data = response.data;

    // ------------------ Group Info ------------------
    final groupInfoData = data["groupInfo"] ?? {};
    final groupInfo = GroupInfo(
      ptGroupId: groupInfoData["pt_group_id"] ?? 0,
      groupName: groupInfoData["group_name"] ?? "",
      groupDescription: groupInfoData["group_description"] ?? "",
      groupProfileUrl: groupInfoData["group_profile_url"] ?? "",
      isActive: groupInfoData["is_active"] ?? false,
      createdAt: groupInfoData["created_at"] ?? "",
    );

    // ------------------ Participants ------------------
    List<ParticipantData> participants = [];
    if (data["participants"] != null) {
      for (var p in data["participants"]) {
        participants.add(
          ParticipantData(
            userId: p["userId"] ?? 0,
            participantId: p["participantId"] ?? 0,
            participantType: p["participantType"] ?? "",
            firstName: p["firstName"] ?? "",
            lastName: p["lastName"] ?? "",
            fullName: p["fullName"] ?? "",
            imgUrl: p["imgurl"] ?? "",
            email: p["email"] ?? "",
            isOnline: p["isOnline"] ?? false,
            lastOnline: p["lastOnline"],
            willReceiveSms: p["willReceiveSms"] ?? false,
          ),
        );
      }
    }

    // ------------------ Messages ------------------
    List<Message> messages = [];
    if (data["messages"] != null) {
      for (var m in data["messages"]) {
        final sender = m["sender"] ?? {};

        List<String> attachments = parseAttachments(m["attached_multimedia_url"]);
        List<String> voiceNote = parseAttachments(m['voice_note_url']);

        messages.add(
          Message(
            ptUserId: m["pt_user_id"] ?? 0,
            ptEmpUserId: m["pt_user_emp_id"] ?? 0,
            ptChatId: m["pt_chat_id"] ?? 0,
            textContent: m["text_content"] ?? "",
            dateCreated: m["date_created"] ?? "",
            dateModified: m["date_modified"],
            unsend: m["unsend"] ?? false,
            seenByPatient: m["seen_by_patient"] ?? false,
            seenByClinicians: List<int>.from(m["seen_by_clinicians"] ?? []),
            attachedMultimediaUrls: attachments,
            stickerMultimediaUrl: m["sticker_multimedia_url"] ?? "",
            voiceNoteUrl: voiceNote,
            sentAsSms: m["sent_as_sms"] ?? false,
            sender: Sender(
              userId: sender["userId"] ?? 0,
              senderId: sender["senderId"] ?? 0,
              senderType: sender["senderType"] ?? "",
              firstName: sender["firstName"] ?? "",
              lastName: sender["lastName"] ?? "",
              imgUrl: sender["imgurl"] ?? "",
            ),
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

    return ChatPatientsGroupCommunicationData(
      groupInfo: groupInfo,
      participants: participants,
      messages: messages,
      pagination: pagination,
    );
  } catch (e) {
    print("Chat Patients Group Communication API Exception: $e");
    return null;
  }
}



///post
Future<ApiData> sendGroupMessage(
    BuildContext context, {
      required int ptGroupId,
      required String textContent,
      required bool restrictPatientFromView,
      required bool sentAsSms,
      required bool isMedia,
      required bool isVoiceNote
    }) async {
  try {
    var response = await Api(context).post(
      path: CommunicationManagerRepository.postPatientGroupChat(),
      data:isVoiceNote == false ? {
        "pt_group_id": ptGroupId,
        "text_content": textContent,
        "restrict_patient_from_view": restrictPatientFromView,
        "sent_as_sms": sentAsSms,
      } :{
        "pt_group_id": ptGroupId,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Message Sent Successfully");
      var uploadResponse = response.data;
      int patientChatId = uploadResponse['pt_chat_id'];
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage ?? "Success",
        data: response.data,
        ptChatId: patientChatId
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

Future<ApiData> patchexitPatientGrop(
    BuildContext context, {
      required int patientId,

    }) async {
  try {
    var response = await Api(context).delete(
      path: CommunicationManagerRepository.patchExitPatientGrp(id: patientId),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Group Exit Successfully");
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage ?? "Success",
        //data: response.data,
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

Future<ApiData> clearPatientGropChatPatch(
    BuildContext context, {
      required int id,
    }) async {
  try {
    var response = await Api(context).delete(
      path: CommunicationManagerRepository.patchClearPatientGroupChat(id: id),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Group Chat clear Successfully");
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


//
Future<ApiData> uploadMediaPatientChat({
  required BuildContext context,
  required int patientChatId,
  required dynamic documentFiles,      // <--- updated
  required String documentNames,       // <--- updated
}) async {
  try {
    /// Convert all selected files to base64
    // List<String> base64List = [];

    // for (var file in documentFiles) {
      String base64List = await AppFilePickerBase64.getEncodeBase64(bytes: documentFiles);
      // base64List.add(encoded);
    // }

    print("Base64 List: $base64List");

    var response = await Api(context).post(
      path: CommunicationManagerRepository.patientAttachMedia(id: patientChatId),
      data: {
        "base64": base64List,       // <-- list instead of single item
        "fileNames": documentNames, // <-- list instead of single name
      },
    );

    print("Response ${response.toString()}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Documents uploaded to patient chat");

      var uploadResponse = response.data;

      List<String> mediaUrls = List<String>.from(
        uploadResponse['attached_multimedia_url'] ?? [],
      );

      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
        mediaUrlList: mediaUrls,
      );
    } else {
      print("Error");

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

Future<ApiData> uploadVoicePatientChat({
  required BuildContext context,
  required int patientChatId,
  required dynamic documentFile,
  required String documentName,
  required int duration,

}) async {
  try {
    String documents = await AppFilePickerBase64.getEncodeBase64(bytes: documentFile);
    print("File :::${documents}" );
    var response = await Api(context).post(
      path:CommunicationManagerRepository.patientAttachVoiceNoteMedia(id: patientChatId),
      data: {
        "base64": documents,
        "fileName": documentName,
        "duration": duration
      },
    );
    print("Response ${response.toString()}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("......>>>>>>>Voice Note uploaded patient chat");
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











// Future<ApiData> uploadMediaPatientChat({
//   required BuildContext context,
//   required int patientChatId,
//   required dynamic documentFile,
//   required String documentName
//
// }) async {
//   try {
//     String documents = await AppFilePickerBase64.getEncodeBase64(bytes: documentFile);
//     print("File :::${documents}" );
//     var response = await Api(context).post(
//       path:CommunicationManagerRepository.patientAttachMedia(id: patientChatId),
//       data: {
//         "base64": documents,
//         "fileName": documentName
//
//       },
//     );
//     print("Response ${response.toString()}");
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       print("......>>>>>>>Documents uploaded patient chat");
//       // orgDocumentGet(context);
//       var uploadResponse = response.data;
//       String mediaUrlP = uploadResponse['attached_multimedia_url'];
//       return ApiData(
//         statusCode: response.statusCode!,
//         success: true,
//         message: response.statusMessage!,
//         mediaUrl: mediaUrlP,
//         );
//     } else {
//       print("Error 1");
//       return ApiData(
//           statusCode: response.statusCode!,
//           success: false,
//           message: response.data['message']);
//     }
//   } catch (e) {
//     print("Error $e");
//     return ApiData(
//         statusCode: 404, success: false, message: AppString.somethingWentWrong);
//   }
// }
