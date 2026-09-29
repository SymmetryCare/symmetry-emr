import 'package:flutter/widgets.dart';

import 'package:symmetry_emr/modules/emr/data/api/managers/hr_module_manager/add_employee/clinical_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/all_intake_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/sm_intake_manager/intake_demographics/intake_demographic_dropdown_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/hr_module_repository/manage_emp/gender_api.dart';
import 'package:symmetry_emr/modules/emr/data/models/hr_module_data/add_employee/clinical.dart';
import 'package:symmetry_emr/modules/emr/data/models/hr_module_data/manage/gender_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/scheduler_create_data/create_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/demographic_patient_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/demographics_dropdown_data.dart';

/// Combines the several independent API calls that [IntakePatientsDatatInfo]
/// needs on load (the patient's demographic detail plus each dropdown's
/// option list) into one widget-scoped `ChangeNotifierProvider`, so the
/// screen can be a StatelessWidget instead of holding each result in its own
/// `late Future` field.
///
/// Each field starts out `null` (mirroring the "still loading" state of its
/// own former nested `FutureBuilder`) and is notified as soon as its own
/// fetch resolves, independently of the others.
class IntakePatientsInfoController extends ChangeNotifier {
  DemographicPatientDataModel? demographicPatient;
  Object? error;
  bool isLoadingDemographic = true;

  List<CountryData>? countries;
  List<ResidenceTypeData>? residenceTypes;
  List<AEClinicalZone>? zones;
  List<GenderData>? genders;
  List<LanguageSpokenData>? languagesSpoken;
  List<RaceModelData>? races;
  List<MetrialStatusData>? maritalStatuses;

  bool _disposed = false;

  bool get hasError => error != null;

  Future<void> load(BuildContext context, {required int patientId}) async {
    try {
      demographicPatient = await getDemographichPatientDetail(context: context, patientId: patientId);
    } catch (e) {
      error = e;
    }
    isLoadingDemographic = false;
    if (_disposed) return;
    notifyListeners();

    countries = await getCountryDropDown(context);
    if (_disposed) return;
    notifyListeners();

    residenceTypes = await getResidenceDropdown(context);
    if (_disposed) return;
    notifyListeners();

    zones = await HrAddEmplyClinicalZoneApi(context);
    if (_disposed) return;
    notifyListeners();

    genders = await getGenderDropdown(context);
    if (_disposed) return;
    notifyListeners();

    languagesSpoken = await getlanguageSpokenDropDown(context);
    if (_disposed) return;
    notifyListeners();

    races = await getRaceDropdown(context);
    if (_disposed) return;
    notifyListeners();

    maritalStatuses = await getMaritalStatusDropDown(context);
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
