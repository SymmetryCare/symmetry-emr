class PhysicianOrderRepository {
  static String _myTasks = '/patient-form/my-tasks';

  static String getMyTasks = _myTasks;

  static String bulkStatus = '/patient-form/physician-order/bulk-status';

  static String supplyOrderBulkStatus = '/patient-form/supply-order/bulk-status';

  static String supplyOrderStatus(int supplyOrderId) =>
      '/patient-form/supply-order/$supplyOrderId/status';
}



