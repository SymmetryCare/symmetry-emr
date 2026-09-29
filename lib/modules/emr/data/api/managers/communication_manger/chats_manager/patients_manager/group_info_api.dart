
import 'package:flutter/material.dart';

import 'package:symmetry_emr/modules/emr/data/models/communication_data/chats_data/patients_data/patients_group_info.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/communication_repo/communication_repo.dart';

///patients group info
Future<PatientsGroupInfoData?> getAllPatientsGroupInfo(BuildContext context,
    final int id) async {
  try {
    final response = await Api(context).get(
      path: CommunicationManagerRepository.getGroupInfoPatientsChats(id: id),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patients Group Info API Response: ${response.data}");

      final data = response.data;

      List<Participant> participants = [];
      if (data["allParticipants"] != null) {
        for (var p in data["allParticipants"]) {
          participants.add(
            Participant(
              participantId: p["participantId"] ?? 0,
              participantType: p["participantType"] ?? "",
              firstName: p["firstName"] ?? "",
              lastName: p["lastName"] ?? "",
              fullName: p["fullName"] ?? "",
              imgUrl: p["imgurl"] ?? "",
              email: p["email"] ?? "",
              address: p["address"],
              treatment: p["treatment"],
              lastOnline: p["lastOnline"],
            ),
          );
        }
      }

      final patientInfo = PatientInfo(
        ptUserId: data["patientInfo"]["pt_user_id"] ?? 0,
        ptUserName: data["patientInfo"]["pt_user_name"] ?? "",
        ptUserEmail: data["patientInfo"]["pt_user_email"] ?? "",
        ptUserProfileUrl: data["patientInfo"]["pt_user_profile_url"] ?? "",
        ptUserAddress: data["patientInfo"]["pt_user_address"] ?? "",
        ptUserTreatment: data["patientInfo"]["pt_user_treatment"] ?? "",
        ptUserLastOnline: data["patientInfo"]["pt_user_last_online"] ?? "",
      );
      List<MediaLinksData> mediaData = [];
      if (data["mediaLinksAndDocs"] != null) {
        for (var p in data["mediaLinksAndDocs"]) {
          mediaData.add(
            MediaLinksData(
                mediaID: p['mediaId'] ?? '',
                mediaType: p['mediaType'] ?? '',
                mediaUrl: p['mediaUrl'] ?? '',
                description: p['description'] ?? '',
                datecreated: p['dateCreated'] ?? ''

            ),
          );
        }
      }

      final groupInfo = PatientsGroupInfoData(
        ptGroupId: data["pt_group_id"] ?? 0,
        groupName: data["group_name"] ?? "",
        groupDescription: data["group_description"] ?? "",
        groupProfileUrl: data["group_profile_url"] ?? "",
        isActive: data["is_active"] ?? false,
        createdAt: data["created_at"] ?? "",
        totalMessages: data["totalMessages"] ?? 0,
        unseenMessageCount: data["unseenMessageCount"] ?? 0,
        allParticipants: participants,
        mediaLinksAndDocs: mediaData,
        patientInfo: patientInfo,
      );
      return groupInfo;
    } else {
      print("Patients Group Info API Error: ${response.statusMessage}");
      return null;
    }
  } catch (e) {
    print("Patients Group Info API Exception: $e");
    return null;
  }
}
