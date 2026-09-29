import 'package:flutter/material.dart';

import 'package:symmetry_emr/modules/emr/data/models/qa_coordinator_data/dashboard/dashboard_graph_model.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/qa_coordinator/dashboard_repo.dart';

Future<QaDashboardGraphModel> getDashboardGraphData({
  required BuildContext context,
}) async {
  var itemsData;
  try {
    final response = await Api(context).get(
      path: QaDashboardRepo.getDashboardGraphData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("getDashboardGraphData response: ${response.data}");
      final data = response.data;

       List<ProductivityWeekly> productivityWeekly = [];

      for (var item in data['productivity_weekly'] ) {
        productivityWeekly.add(ProductivityWeekly(
          day: item['day'] ?? '',
          count: item['count'] ?? 0,
        ));
      }

       List<ProductivityMonthly> productivityMonthly = [];
      for (var item in data['productivity_monthly'] ) {
        productivityMonthly.add(ProductivityMonthly(
          month: item['month'] ?? '',
          count: item['count'] ?? 23,
        ));
      }

      itemsData = QaDashboardGraphModel(
        summary: Summary(
          pendingTasks: data['summary']['pending_tasks'] ?? 0,
          correctedTasks: data['summary']['corrected_tasks'] ?? 0,
          sentForCorrection: data['summary']['sent_for_correction'] ?? 0,
          todayCompletions: data['summary']['today_completions'] ?? 0,
        ),
        productivityWeekly: productivityWeekly,
        productivityMonthly: productivityMonthly,
      );
    } else {
      debugPrint("getDashboardGraphData error: ${response.statusCode}");
    }

    return itemsData ?? QaDashboardGraphModel(
      summary: Summary(
        pendingTasks: 0,
        correctedTasks: 0,
        sentForCorrection: 0,
        todayCompletions: 0,
      ),
      productivityWeekly: [],
      productivityMonthly: [],
    );
  } catch (e) {
    debugPrint("getDashboardGraphData error: $e");
    return QaDashboardGraphModel(
      summary: Summary(
        pendingTasks: 0,
        correctedTasks: 0,
        sentForCorrection: 0,
        todayCompletions: 0,
      ),
      productivityWeekly: [],
      productivityMonthly: [],
    );
  }
}