class SupplyOrderRepository {
  static String _supplyOrders = '/supply-orders';
  static String _patients = '/patients';
  static String _dropdown = '/dropdown';

  static String getPatientDropdown({required String role}) {
    return '$_supplyOrders$_patients$_dropdown/$role';
  }
}