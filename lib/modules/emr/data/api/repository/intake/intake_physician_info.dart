class IntakePhysicianInfo{
  ///intake physician info
  static String physicianMaster = '/physician-master';
  static String physicianMasterAdd = '/physician-master/add';
  static String physicianDropDown = '/physician-master/physician_names';

  static String addPhysicianMaster() {
    return "$physicianMaster/";
  }

  static String getDropDownPhysician() {
    return "$physicianDropDown";
  }

  ///physician-master/{id}
  static String patchPhysicianMaster({required int id}) {
    return "$physicianMaster/$id";
  }

  ///physician-master/patient/{patientId}
  static String getByIdPhysicianMaster({required int patientId, required int physicianId}) {
    return "$physicianMaster/patient/$patientId/$physicianId";
  }
}