import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/dashboard_emr_repo.dart';

class NotificationData {
  final int notificationId;
  final int userId;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final String color;
  final bool isRead;
  final int callId;
  final String createdAt;
  final String updatedAt;

  NotificationData({
    required this.color,
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    required this.callId,
    required this.createdAt,
    required this.updatedAt,
  });
}

Future<List<NotificationData>> getNotificationData(BuildContext context) async {
  List<NotificationData> itemsList = [];
  try {
    final userId = await TokenManager.getuserId();
    final response = await Api(context).get(
      path: EMRDashboardRepo.getNotification(userId: userId),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("calling Notificatiion api :::::");
      for (var item in response.data) {
        itemsList.add(
          NotificationData(
            notificationId: item['notificationId'] ?? 0,
            userId:         item['userId'] ?? 0,
            type:           item['type'] ?? '',
            title:          item['title'] ?? '',
            body:           item['body'] ?? '',
            data: item['data'] != null
                ? Map<String, dynamic>.from(item['data'])
                : null,
            isRead:         item['isRead'] ?? false,
            callId:         item['callId'] ?? 0,
            createdAt:      item['createdAt'] ?? '',
            updatedAt:      item['updatedAt'] ?? '',
            color:          item['color'] ?? '',
          ),
        );
      }
    } else {
      print('Api Error');
    }
    print("Response Notification****:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}