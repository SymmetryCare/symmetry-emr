import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/patient_tab_data/emr_clinical_group_chatbot_data.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/emr_patient_repo/emr_clinical_group_chatbot_repo.dart';


// ── GET: Care Team Chat ───────────────────────────────────────────────────────
Future<PatientCareTeamChatData?> getCareTeamChat(
    BuildContext context,
    int ptId,
    ) async {
  try {
    final response = await Api(context).get(
      path: CliniciansChatRepository.getCareTeamChat(ptId: ptId),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final d = response.data;

      List<CareTeamMemberData> membersList = [];
      for (var member in d['members']) {
        membersList.add(
          CareTeamMemberData(
            employeeId:               member['employeeId'],
            userId:                   member['userId'],
            firstName:                member['firstName'],
            lastName:                 member['lastName'],
            fullName:                 member['fullName'],
            imgurl:                   member['imgurl'] ?? '',
            email:                    member['email'] ?? '',
            position:                 member['position'] ?? '',
            employeeTypeId:           member['employeeTypeId'],
            employeeTypeName:         member['employeeTypeName'] ?? '',
            employeeTypeAbbreviation: member['employeeTypeAbbreviation'] ?? '',
            employeeTypeColor:        member['employeeTypeColor'] ?? '',
          ),
        );
      }

      print("Response:::::${response}");
      return PatientCareTeamChatData(
        ptGroupId:        d['pt_group_id'],
        groupName:        d['group_name'] ?? '',
        groupDescription: d['group_description'] ?? '',
        groupProfileUrl:  d['group_profile_url'] ?? '',
        isActive:         d['is_active'] ?? false,
        isClinicianOnly:  d['is_clinician_only'] ?? false,
        createdAt:        d['created_at'] ?? '',
        members:          membersList,
      );
    } else {
      print('Api Error');
      return null;
    }
  } catch (e) {
    print("Error $e");
    return null;
  }
}

// ── GET: Chat Screen ──────────────────────────────────────────────────────────
Future<PatientGroupChatScreenData?> getGroupChatScreen(
    BuildContext context,
    int ptGroupId,
    int pageNbr,
    int nbrOfRows,
    ) async {
  try {
    final response = await Api(context).get(
      path: CliniciansChatRepository.getChatScreen(
        ptGroupId: ptGroupId,
        pageNbr:   pageNbr,
        nbrOfRows: nbrOfRows,
      ),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final d = response.data;

      // groupInfo
      final gi = d['groupInfo'];
      final groupInfo = GroupInfoData(
        ptGroupId:        gi['pt_group_id'],
        groupName:        gi['group_name'] ?? '',
        groupDescription: gi['group_description'] ?? '',
        groupProfileUrl:  gi['group_profile_url'] ?? '',
        isActive:         gi['is_active'] ?? false,
        createdAt:        gi['created_at'] ?? '',
      );

      // participants
      List<ChatParticipantData> participantsList = [];
      for (var p in d['participants']) {
        participantsList.add(
          ChatParticipantData(
            participantId:            p['participantId'],
            participantType:          p['participantType'] ?? '',
            firstName:                p['firstName'] ?? '',
            lastName:                 p['lastName'] ?? '',
            fullName:                 p['fullName'] ?? '',
            imgurl:                   p['imgurl'] ?? '',
            email:                    p['email'] ?? '',
            userId:                   p['userId'],
            isOnline:                 p['isOnline'] ?? false,
            lastOnline:               p['lastOnline'],
            willReceiveSms:           p['willReceiveSms'] ?? false,
            employeeTypeAbbreviation: p['employeeTypeAbbreviation'],
            employeeTypeColor:        p['employeeTypeColor'],
            employeeTypeId:           p['employeeTypeId'],
            employeeTypeName:         p['employeeTypeName'],
          ),
        );
      }

      // messages — real snake_case keys from API
      List<ChatMessageData> messagesList = [];
      for (var m in d['messages']) {
        // attached_multimedia_url is List or null
        List<String> attachedUrls = [];
        if (m['attached_multimedia_url'] != null) {
          for (var url in m['attached_multimedia_url']) {
            attachedUrls.add(url.toString());
          }
        }

        // sender nested object
        final s = m['sender'];
        final sender = ChatMessageSenderData(
          senderId:   s['senderId'],
          senderType: s['senderType'] ?? '',
          firstName:  s['firstName'] ?? '',
          lastName:   s['lastName'] ?? '',
          imgurl:     s['imgurl'] ?? '',
          userId:     s['userId'],
        );

        messagesList.add(
          ChatMessageData(
            ptChatId:              m['pt_chat_id'],
            ptUserId:              m['pt_user_id'],          // nullable
            ptUserEmpId:           m['pt_user_emp_id'],      // nullable
            textContent:           m['text_content'] ?? '',
            dateCreated:           m['date_created'] ?? '',
            dateModified:          m['date_modified'],
            unsend:                m['unsend'] ?? false,
            seenByPatient:         m['seen_by_patient'] ?? false,
            attachedMultimediaUrl: attachedUrls,
            voiceNoteUrl:          m['voice_note_url'],
            voiceNoteUrlDuration:  m['voice_note_url_duration'],
            sentAsSms:             m['sent_as_sms'] ?? false,
            sender:                sender,
          ),
        );
      }

      // pagination
      final pg = d['pagination'];
      final pagination = ChatPaginationData(
        currentPage:     pg['currentPage'],
        totalPages:      pg['totalPages'],
        totalMessages:   pg['totalMessages'],
        hasNextPage:     pg['hasNextPage'],
        hasPreviousPage: pg['hasPreviousPage'],
      );

      print("Response:::::${response}");
      return PatientGroupChatScreenData(
        groupInfo:    groupInfo,
        participants: participantsList,
        messages:     messagesList,
        pagination:   pagination,
      );
    } else {
      print('Api Error');
      return null;
    }
  } catch (e) {
    print("Error $e");
    return null;
  }
}

// ── POST: Send group chat message ─────────────────────────────────────────────
Future<ApiData> sendPatientGroupChat(
    BuildContext context,
    int ptGroupId,
    String textContent, {
      int? referredChatId,
      String? attachedMultimediaUrl,
      String? stickerMultimediaUrl,
      bool restrictPatientFromView = false,
      bool sentAsSms = false,
      String? voiceNoteUrl,
    }) async {
  try {
    var response = await Api(context).post(
      path: CliniciansChatRepository.sendChat(isGroup: true),
      data: {
        "pt_group_id":                ptGroupId,
        "referred_chat_id":           referredChatId,
        "text_content":               textContent,
        "attached_multimedia_url":    attachedMultimediaUrl,
        "sticker_multimedia_url":     stickerMultimediaUrl,
        "restrict_patient_from_view": restrictPatientFromView,
        "sent_as_sms":                sentAsSms,
        "voice_note_url":             voiceNoteUrl,
      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Message sent");
      final int? sentChatId = response.data is Map
          ? response.data['pt_chat_id'] as int?
          : null;

      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
        ptChatId: sentChatId,
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

// ── POST: Send attachment ─────────────────────────────────────────────────────
Future<ApiData> sendChatAttachment(
    BuildContext context,
    int chatId,
    String base64,
    String fileName,
    ) async {
  try {
    var response = await Api(context).post(
      path: CliniciansChatRepository.sendAttachment(isGroup: true, chatId: chatId),
      data: {
        "base64":   base64,
        "fileName": fileName,
      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Attachment sent");
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

// ── POST: Send voice note ─────────────────────────────────────────────────────
Future<ApiData> sendChatVoiceNote(
    BuildContext context,
    int chatId,
    String base64,
    String fileName,
    int duration,
    ) async {
  try {
    var response = await Api(context).post(
      path: CliniciansChatRepository.sendVoiceNote(isGroup: true, chatId: chatId),
      data: {
        "base64":    base64,
        "fileName":  fileName,
        "duration":  duration,
      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Voice note sent");
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