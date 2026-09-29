class QaDashboardGraphModel {
  final Summary summary;
  final List<ProductivityWeekly> productivityWeekly;
  final List<ProductivityMonthly> productivityMonthly;

  QaDashboardGraphModel({
    required this.summary,
    required this.productivityWeekly,
    required this.productivityMonthly,
  });
}

class Summary {
  final int pendingTasks;
  final int correctedTasks;
  final int sentForCorrection;
  final int todayCompletions;

  Summary({
    required this.pendingTasks,
    required this.correctedTasks,
    required this.sentForCorrection,
    required this.todayCompletions,
  });
}

class ProductivityWeekly {
  final String day;
  final int count;

  ProductivityWeekly({
    required this.day,
    required this.count,
  });
}

class ProductivityMonthly {
  final String month;
  final int count;

  ProductivityMonthly({
    required this.month,
    required this.count,
  });
}