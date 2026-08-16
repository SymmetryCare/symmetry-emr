import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../../app/resources/color.dart';
import '../../../../../../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../../../../../../app/resources/value_manager.dart';
import '../../../../../../../../../app/services/api/managers/hr_module_manager/add_employee/clinical_manager.dart';
import '../../../../../../../../../app/services/api/managers/sm_module_manager/intake/all_intake_manager.dart';
import '../../../../../../../../../app/services/api/managers/sm_module_manager/sm_intake_manager/intake_demographics/intake_demographic_dropdown_manager.dart';
import '../../../../../../../../../app/services/api/repository/hr_module_repository/manage_emp/gender_api.dart';
import '../../../../../../../../../data/api_data/hr_module_data/add_employee/clinical.dart';
import '../../../../../../../../../data/api_data/hr_module_data/manage/gender_data.dart';
import '../../../../../../../../../data/api_data/sm_data/scheduler_create_data/create_data.dart';
import '../../../../../../../../../data/api_data/sm_data/sm_intake_data/intake_demographics/demographic_patient_data.dart';
import '../../../../../../../../../data/api_data/sm_data/sm_intake_data/intake_demographics/demographics_dropdown_data.dart';
import '../../../../../../../scheduler_model/sm_Intake/widgets/intake_flow_contgainer_const.dart';
import '../../../../../../../scheduler_model/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import '../../../../../../../scheduler_model/textfield_dropdown_constant/schedular_textfield_const.dart';
import '../../../../../../../scheduler_model/widgets/constant_widgets/dropdown_constant_sm.dart';


class EmrPatientInfo extends StatefulWidget {
  final int patientId;
  final Widget childState;
  final Widget childCountry;

  const EmrPatientInfo({
    super.key,
    required this.patientId,
    required this.childState,
    required this.childCountry,
  });

  @override
  State<EmrPatientInfo> createState() => _EmrPatientInfoState();
}

class _EmrPatientInfoState extends State<EmrPatientInfo> {
  // ── Controllers ───────────────────────────────────────────────────────────
  final TextEditingController ctlrFirstName            = TextEditingController();
  final TextEditingController ctlrMiddleInitial        = TextEditingController();
  final TextEditingController ctlrLastName             = TextEditingController();
  final TextEditingController ctlrSuffix               = TextEditingController();
  final TextEditingController ctlrDob                  = TextEditingController();
  final TextEditingController ctlrStreet               = TextEditingController();
  final TextEditingController ctlrSuitApt              = TextEditingController();
  final TextEditingController ctlrCity                 = TextEditingController();
  final TextEditingController ctlrState                = TextEditingController();
  final TextEditingController ctlrZipCode              = TextEditingController();
  final TextEditingController ctlrPrimaryContact       = TextEditingController();
  final TextEditingController ctlrPrimaryContactName   = TextEditingController();
  final TextEditingController ctlrPrimaryPhone         = TextEditingController();
  final TextEditingController ctlrPrimaryEmail         = TextEditingController();
  final TextEditingController ctlrCahpsContact         = TextEditingController();
  final TextEditingController ctlrSecondaryContact     = TextEditingController();
  final TextEditingController ctlrSecondaryContactName = TextEditingController();
  final TextEditingController ctlrSecondaryPhone       = TextEditingController();
  final TextEditingController ctlrSecondaryEmail       = TextEditingController();
  final TextEditingController ctlrSocialSecurity       = TextEditingController();
  final TextEditingController ctlrFacilityName         = TextEditingController();
  final TextEditingController ctlrLocationNotes        = TextEditingController();
  final TextEditingController ctlrGender               = TextEditingController();
  final TextEditingController ctlrLanguage             = TextEditingController();
  final TextEditingController ctlrRace                 = TextEditingController();
  final TextEditingController ctlrMaritalStatus        = TextEditingController();
  final TextEditingController ctlrResidency            = TextEditingController();
  final TextEditingController ctlrCountry              = TextEditingController();
  final TextEditingController ctlrZone                 = TextEditingController();

  // ── Dropdown selected values ──────────────────────────────────────────────
  String selectedGender        = 'Select';
  String selectedLanguage      = 'Select';
  String selectedRace          = 'Select';
  String selectedMaritalStatus = 'Select';
  String selectedResidency     = 'Select';
  String selectedZone          = 'Select';

  @override
  void dispose() {
    ctlrFirstName.dispose();
    ctlrMiddleInitial.dispose();
    ctlrLastName.dispose();
    ctlrSuffix.dispose();
    ctlrDob.dispose();
    ctlrStreet.dispose();
    ctlrSuitApt.dispose();
    ctlrCity.dispose();
    ctlrState.dispose();
    ctlrZipCode.dispose();
    ctlrPrimaryContact.dispose();
    ctlrPrimaryContactName.dispose();
    ctlrPrimaryPhone.dispose();
    ctlrPrimaryEmail.dispose();
    ctlrCahpsContact.dispose();
    ctlrSecondaryContact.dispose();
    ctlrSecondaryContactName.dispose();
    ctlrSecondaryPhone.dispose();
    ctlrSecondaryEmail.dispose();
    ctlrSocialSecurity.dispose();
    ctlrFacilityName.dispose();
    ctlrLocationNotes.dispose();
    ctlrGender.dispose();
    ctlrLanguage.dispose();
    ctlrRace.dispose();
    ctlrMaritalStatus.dispose();
    ctlrResidency.dispose();
    ctlrCountry.dispose();
    ctlrZone.dispose();
    super.dispose();
  }

  void _prefill(DemographicPatientDataModel data) {
    selectedGender        = data.gender.gender.isEmpty               ? 'Select' : data.gender.gender;
    selectedLanguage      = data.spokenLanguage.languageSpoken.isEmpty ? 'Select' : data.spokenLanguage.languageSpoken;
    selectedRace          = data.race.race.isEmpty                   ? 'Select' : data.race.race;
    selectedMaritalStatus = data.maritalStatus.maritalStatus.isEmpty ? 'Select' : data.maritalStatus.maritalStatus;
    selectedResidency     = data.residenceType.detail.isEmpty        ? 'Select' : data.residenceType.detail;
    selectedZone          = data.zone.zoneName.isEmpty               ? 'Select' : data.zone.zoneName;

    if (ctlrFirstName.text.isEmpty)            ctlrFirstName.text            = data.firstName.demoFirstName;
    if (ctlrMiddleInitial.text.isEmpty)        ctlrMiddleInitial.text        = data.middleInitial.demoMiddleInitial;
    if (ctlrLastName.text.isEmpty)             ctlrLastName.text             = data.lastName.demoLastName;
    if (ctlrSuffix.text.isEmpty)               ctlrSuffix.text               = data.suffix.demoSuffix;
    if (ctlrDob.text.isEmpty)                  ctlrDob.text                  = data.demoDob;
    if (ctlrStreet.text.isEmpty)               ctlrStreet.text               = data.street.demoStreet;
    if (ctlrSuitApt.text.isEmpty)              ctlrSuitApt.text              = data.suite.demoSuite;
    if (ctlrCity.text.isEmpty)                 ctlrCity.text                 = data.city.demoCity;
    if (ctlrState.text.isEmpty)                ctlrState.text                = data.state.demoState;
    if (ctlrZipCode.text.isEmpty)              ctlrZipCode.text              = data.zipcode.demoZipcode;
    if (ctlrPrimaryContact.text.isEmpty)       ctlrPrimaryContact.text       = data.primaryContact.demoPrimaryContact;
    if (ctlrPrimaryContactName.text.isEmpty)   ctlrPrimaryContactName.text   = data.primaryContactName.demoPrimaryContactName;
    if (ctlrPrimaryPhone.text.isEmpty)         ctlrPrimaryPhone.text         = data.primaryPhone.demoPrimaryPhone;
    if (ctlrPrimaryEmail.text.isEmpty)         ctlrPrimaryEmail.text         = data.primaryEmail.demoPrimaryEmail;
    if (ctlrCahpsContact.text.isEmpty)         ctlrCahpsContact.text         = data.cahpsContact.demoCahpsContact;
    if (ctlrSecondaryContact.text.isEmpty)     ctlrSecondaryContact.text     = data.secondaryContact.demoSecondaryContact;
    if (ctlrSecondaryContactName.text.isEmpty) ctlrSecondaryContactName.text = data.secondaryContactName.demoSecondaryContactName;
    if (ctlrSecondaryPhone.text.isEmpty)       ctlrSecondaryPhone.text       = data.secondaryPhone.demoSecondaryPhone;
    if (ctlrSecondaryEmail.text.isEmpty)       ctlrSecondaryEmail.text       = data.secondaryEmail.demoSecondaryEmail;
    if (ctlrSocialSecurity.text.isEmpty)       ctlrSocialSecurity.text       = data.socialSecurity.demoSocialSecurity;
    if (ctlrFacilityName.text.isEmpty)         ctlrFacilityName.text         = data.facilityName.demoFacilityName;
    if (ctlrLocationNotes.text.isEmpty)        ctlrLocationNotes.text        = data.locationNotes.demoLocationNotes;
    if (ctlrGender.text.isEmpty)               ctlrGender.text               = data.gender.gender;
    if (ctlrRace.text.isEmpty)                 ctlrRace.text                 = data.race.race;
    if (ctlrResidency.text.isEmpty)            ctlrResidency.text            = data.residenceType.detail;
  }

  // ── Shared gap between fields ─────────────────────────────────────────────
  static const _gap = SizedBox(width: AppSize.s35);
  static const _rowGap = SizedBox(height: AppSize.s16);

  /// Builds a 4-field row with consistent start alignment
  Widget _row(List<Widget> children) {
    assert(children.length == 4);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(child: children[0]),
        _gap,
        Flexible(child: children[1]),
        _gap,
        Flexible(child: children[2]),
        _gap,
        Flexible(child: children[3]),
      ],
    );
  }

  /// Builds a 3-field row with consistent start alignment
  Widget _row3(List<Widget> children) {
    assert(children.length == 3);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(child: children[0]),
        _gap,
        Flexible(child: children[1]),
        _gap,
        Flexible(child: children[2]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: FutureBuilder<DemographicPatientDataModel>(
        future: getDemographichPatientDetail(
          context: context,
          patientId: widget.patientId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: ColorManager.blueprime));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Something went wrong!'));
          }

          _prefill(snapshot.data!);

          return SingleChildScrollView(
            child: Column(
              children: [

                // ══════════════════════════════════════════════════════════
                // CONTACT INFORMATION
                // ══════════════════════════════════════════════════════════
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                  child: BlueBGHeadConst(
                    HeadText: "Contact Information",
                    body: IntakeFlowContainerConst(
                      height: AppSize.s600,
                      child: Column(
                        children: [

                          // Row 1 — First Name | Middle Initial | Last Name | Suffix
                          _row([
                            SchedularTextField(isIconVisible: false, controller: ctlrFirstName, labelText: 'First Name*'),
                            SchedularTextField(isIconVisible: false, controller: ctlrMiddleInitial, labelText: 'Middle Initial'),
                            SchedularTextField(isIconVisible: false, controller: ctlrLastName, labelText: 'Last Name*'),
                            SchedularTextField(isIconVisible: false, controller: ctlrSuffix, labelText: 'Suffix'),
                          ]),
                          _rowGap,

                          // Row 2 — Street | Suite/Apt | City | State
                          _row([
                            SchedularTextField(isIconVisible: false,
                              controller: ctlrStreet,
                              icon: Icon(Icons.location_on_outlined,
                                  color: ColorManager.blueprime, size: IconSize.I18),
                              labelText: 'Street*',
                            ),
                            SchedularTextField(isIconVisible: false, controller: ctlrSuitApt, labelText: 'Suit/Apt#'),
                            SchedularTextField(isIconVisible: false, controller: ctlrCity, labelText: 'City*'),
                            widget.childState,
                          ]),
                          _rowGap,

                          // Row 3 — Zip Code | Country | Residence Type | Facility Name
                          _row([
                            SchedularTextField(isIconVisible: false, controller: ctlrZipCode, allowSSNBR: true, labelText: 'Zip Code'),
                            widget.childCountry,
                            FutureBuilder<List<ResidenceTypeData>>(
                              future: getResidenceDropdown(context),
                              builder: (context, snap) {
                                if (snap.connectionState == ConnectionState.waiting) {
                                  return SchedularTextField(isIconVisible: false, controller: ctlrResidency, labelText: 'Residence Type');
                                }
                                if (snap.hasData) {
                                  return CustomDropdownTextFieldsm(
                                    initialValue: selectedResidency,
                                    headText: 'Residence Type',
                                    dropDownMenuList: snap.data!
                                        .map((e) => DropdownMenuItem<String>(
                                        value: e.description, child: Text(e.description)))
                                        .toList(),
                                    onChanged: (v) {
                                      for (var a in snap.data!) {
                                        if (a.description == v) selectedResidency = a.description;
                                      }
                                    },
                                  );
                                }
                                return const Offstage();
                              },
                            ),
                            SchedularTextField(isIconVisible: false, controller: ctlrFacilityName, labelText: 'Facility Name'),
                          ]),
                          _rowGap,

                          // Row 4 — Zone | Location Notes | Primary Contact | Primary Contact Name
                          _row([
                            FutureBuilder<List<AEClinicalZone>>(
                              future: HrAddEmplyClinicalZoneApi(context),
                              builder: (context, snap) {
                                if (snap.connectionState == ConnectionState.waiting) {
                                  return SchedularTextField(isIconVisible: false, controller: ctlrZone, labelText: 'Zone*');
                                }
                                if (snap.hasData) {
                                  return CustomDropdownTextFieldsm(
                                    initialValue: selectedZone,
                                    headText: 'Zone*',
                                    dropDownMenuList: snap.data!
                                        .map((e) => DropdownMenuItem<String>(
                                        value: e.zoneName, child: Text(e.zoneName!)))
                                        .toList(),
                                    onChanged: (v) {
                                      for (var a in snap.data!) {
                                        if (a.zoneName == v) selectedZone = a.zoneName!;
                                      }
                                    },
                                  );
                                }
                                return const Offstage();
                              },
                            ),
                            SchedularTextField(isIconVisible: false, controller: ctlrLocationNotes, labelText: 'Location Notes'),
                            SchedularTextField(isIconVisible: false, controller: ctlrPrimaryContact, labelText: 'Primary Contact*'),
                            SchedularTextField(isIconVisible: false, controller: ctlrPrimaryContactName, labelText: 'Primary Contact Name*'),
                          ]),
                          _rowGap,

                          // Row 5 — Primary Phone | Primary Email | CAHPS Contact | Secondary Contact
                          _row([
                            SchedularTextField(isIconVisible: false, controller: ctlrPrimaryPhone, labelText: 'Primary Phone #*', phoneField: true),
                            SchedularTextField(isIconVisible: false, controller: ctlrPrimaryEmail, labelText: 'Primary Email'),
                            SchedularTextField(isIconVisible: false, controller: ctlrCahpsContact, labelText: 'CAHPS Contact'),
                            SchedularTextField(isIconVisible: false, controller: ctlrSecondaryContact, labelText: 'Secondary Contact*'),
                          ]),
                          _rowGap,

                          // Row 6 — Secondary Contact Name | Secondary Phone | Secondary Email | (empty)
                          _row([
                            SchedularTextField(isIconVisible: false, controller: ctlrSecondaryContactName, labelText: 'Secondary Contact Name'),
                            SchedularTextField(isIconVisible: false, controller: ctlrSecondaryPhone, labelText: 'Secondary Phone #*', phoneField: true),
                            SchedularTextField(isIconVisible: false, controller: ctlrSecondaryEmail, labelText: 'Secondary Email'),
                            const SizedBox(),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSize.s40),

                // ══════════════════════════════════════════════════════════
                // ADDITIONAL INFORMATION
                // ══════════════════════════════════════════════════════════
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: BlueBGHeadConst(
                    HeadText: "Additional Information",
                    body: IntakeFlowContainerConst(
                      height: AppSize.s180,
                      child: Column(
                        children: [

                          // Row 1 — DOB | Gender | Language | (spacer)
                          _row([
                            SchedularTextField(isIconVisible: false,
                              controller: ctlrDob,
                              labelText: 'Date of Birth*',
                              showDatePicker: true,
                              dateFormateMMDDYYYY: true,
                            ),
                            FutureBuilder<List<GenderData>>(
                              future: getGenderDropdown(context),
                              builder: (context, snap) {
                                if (snap.connectionState == ConnectionState.waiting) {
                                  return SchedularTextField(isIconVisible: false, controller: ctlrGender, labelText: 'Gender*');
                                }
                                if (snap.hasData) {
                                  return CustomDropdownSmallBoxSm(
                                    initialValue: selectedGender,
                                    headText: 'Gender*',
                                    dropDownMenuList: snap.data!
                                        .map((e) => DropdownMenuItem<String>(
                                        value: e.gender, child: Text(e.gender!)))
                                        .toList(),
                                    onChanged: (v) {
                                      for (var a in snap.data!) {
                                        if (a.gender == v) selectedGender = a.gender!;
                                      }
                                    },
                                  );
                                }
                                return const Offstage();
                              },
                            ),
                            FutureBuilder<List<LanguageSpokenData>>(
                              future: getlanguageSpokenDropDown(context),
                              builder: (context, snap) {
                                if (snap.connectionState == ConnectionState.waiting) {
                                  return SchedularTextField(isIconVisible: false, controller: ctlrLanguage, labelText: 'Primary Language');
                                }
                                if (snap.hasData) {
                                  return CustomDropdownSmallBoxSm(
                                    initialValue: selectedLanguage,
                                    headText: 'Primary Language',
                                    dropDownMenuList: snap.data!
                                        .map((e) => DropdownMenuItem<String>(
                                        value: e.languageSpoken, child: Text(e.languageSpoken!)))
                                        .toList(),
                                    onChanged: (v) {
                                      for (var a in snap.data!) {
                                        if (a.languageSpoken == v) selectedLanguage = a.languageSpoken!;
                                      }
                                    },
                                  );
                                }
                                return const Offstage();
                              },
                            ),
                            const SizedBox(),
                          ]),
                          _rowGap,

                          // Row 2 — SSN | Race | Marital Status | (spacer)
                          _row([
                            SchedularTextField(isIconVisible: false,
                              controller: ctlrSocialSecurity,
                              labelText: 'Social Security',
                              isPasswordField: true,
                              allowSSNBR: true,
                            ),
                            FutureBuilder<List<RaceModelData>>(
                              future: getRaceDropdown(context),
                              builder: (context, snap) {
                                if (snap.connectionState == ConnectionState.waiting) {
                                  return SchedularTextField(isIconVisible: false, controller: ctlrRace, labelText: 'Race/Ethnicity');
                                }
                                if (snap.hasData) {
                                  return CustomDropdownSmallBoxSm(
                                    initialValue: selectedRace,
                                    headText: 'Race/Ethnicity',
                                    dropDownMenuList: snap.data!
                                        .map((e) => DropdownMenuItem<String>(
                                        value: e.raceName, child: Text(e.raceName)))
                                        .toList(),
                                    onChanged: (v) {
                                      for (var a in snap.data!) {
                                        if (a.raceName == v) selectedRace = a.raceName;
                                      }
                                    },
                                  );
                                }
                                return const Offstage();
                              },
                            ),
                            FutureBuilder<List<MetrialStatusData>>(
                              future: getMaritalStatusDropDown(context),
                              builder: (context, snap) {
                                if (snap.connectionState == ConnectionState.waiting) {
                                  return SchedularTextField(isIconVisible: false, controller: ctlrMaritalStatus, labelText: 'Marital Status');
                                }
                                if (snap.hasData) {
                                  return CustomDropdownSmallBoxSm(
                                    initialValue: selectedMaritalStatus,
                                    headText: 'Marital Status',
                                    dropDownMenuList: snap.data!
                                        .map((e) => DropdownMenuItem<String>(
                                        value: e?.maritalStatus, child: Text(e.maritalStatus)))
                                        .toList(),
                                    onChanged: (v) {
                                      for (var a in snap.data!) {
                                        if (a.maritalStatus == v) selectedMaritalStatus = a.maritalStatus;
                                      }
                                    },
                                  );
                                }
                                return const Offstage();
                              },
                            ),
                            const SizedBox(),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSize.s30),
              ],
            ),
          );
        },
      ),
    );
  }
}