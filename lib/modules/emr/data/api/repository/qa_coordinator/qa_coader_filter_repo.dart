class FormRepository {
  static String _form = '/form';

  static String getAll = '$_form';
}


class PatientFormStaffRepository {
  static String _patientForm = '/patient-form';
  static String _staff = '/staff';

  static String getStaff({
    String? type,
    String? search,
    int? page,
    int? limit,
    String? employment,
    String? zoneIds,
    String? ptoFrom,
    String? ptoTo,
    int? productivityMin,
    int? productivityMax,
  }) {
    final params = <String, String>{};
    if (type != null) params['type'] = type;
    if (search != null) params['search'] = search;
    if (page != null) params['page'] = page.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (employment != null) params['employment'] = employment;
    if (zoneIds != null) params['zoneIds'] = zoneIds;
    if (ptoFrom != null) params['ptoFrom'] = ptoFrom;
    if (ptoTo != null) params['ptoTo'] = ptoTo;
    if (productivityMin != null) params['productivityMin'] = productivityMin.toString();
    if (productivityMax != null) params['productivityMax'] = productivityMax.toString();

    if (params.isEmpty) return '$_patientForm$_staff';
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$_patientForm$_staff?$query';
  }
}