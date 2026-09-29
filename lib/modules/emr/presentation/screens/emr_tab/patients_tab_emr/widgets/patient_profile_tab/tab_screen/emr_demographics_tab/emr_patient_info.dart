import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/hr_module_manager/add_employee/clinical_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/all_intake_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/sm_intake_manager/intake_demographics/intake_demographic_dropdown_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/hr_module_repository/manage_emp/gender_api.dart';
import 'package:symmetry_emr/modules/emr/data/models/hr_module_data/add_employee/clinical.dart';
import 'package:symmetry_emr/modules/emr/data/models/hr_module_data/manage/gender_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/scheduler_create_data/create_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/demographic_patient_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/demographics_dropdown_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_flow_contgainer_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/schedular_textfield_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_profile_tab/const_textfiled_emr.dart';


class EmrPatientInfo extends StatefulWidget {
  final int patientId;
  final Widget childState;
  final Widget childCountry;
  final VoidCallback isIButtonPressed; // ✅ opens/closes the referred-from sidebar

  const EmrPatientInfo({
    super.key,
    required this.patientId,
    required this.childState,
    required this.childCountry,
    required this.isIButtonPressed,
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

  // ── Cached futures — prevent refetch/rebuild loop on every build ──
  late Future<DemographicPatientDataModel> _demographicDetailFuture;
  late Future<List<ResidenceTypeData>> _residenceDropdownFuture;
  late Future<List<AEClinicalZone>> _zoneFuture;
  late Future<List<GenderData>> _genderDropdownFuture;
  late Future<List<LanguageSpokenData>> _languageSpokenDropdownFuture;
  late Future<List<RaceModelData>> _raceDropdownFuture;
  late Future<List<MetrialStatusData>> _maritalStatusDropdownFuture;

  @override
  void initState() {
    super.initState();
    _demographicDetailFuture = getDemographichPatientDetail(
      context: context,
      patientId: widget.patientId,
    );
    _residenceDropdownFuture = getResidenceDropdown(context);
    _zoneFuture = HrAddEmplyClinicalZoneApi(context);
    _genderDropdownFuture = getGenderDropdown(context);
    _languageSpokenDropdownFuture = getlanguageSpokenDropDown(context);
    _raceDropdownFuture = getRaceDropdown(context);
    _maritalStatusDropdownFuture = getMaritalStatusDropDown(context);
  }

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

  @override
  Widget build(BuildContext context) {
    final providerUpdate =
    Provider.of<SmIntakeProviderManager>(context, listen: false);

    return Container(
      color: Colors.transparent,
      child: FutureBuilder<DemographicPatientDataModel>(
        future: _demographicDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 100),
              child: CircularProgressIndicator(color: ColorManager.blueprime),
            ));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 100),
              child: Text('No data found!'),
            ));
          }

          final data = snapshot.data!;
          _prefill(data);

          // ✅ Sidebar-open drives BOTH gap width and how many fields sit per row
          //    (same structure as IntakePatientsDatatInfo's isContactTrue branching):
          //    closed → 4 fields/row @ AppSize.s35 gap
          //    open   → 3 fields/row @ AppSize.s70 gap
          final bool sidebarOpen = providerUpdate.isLeftSidebarOpen;
          final gap = SizedBox(width: sidebarOpen ? AppSize.s70 : AppSize.s35);
          const rowGap = SizedBox(height: AppSize.s16);

          // ── Field widgets (built once, reused across both row layouts) ───
          final firstName = SchedularTextField(
            isIconVisible: data.firstName.firstNameLink.isEmpty,
            isIClicked: () {
              widget.isIButtonPressed();
              providerUpdate.setLinkAndPageNumber(
                  selectLink: Uri.parse(data.firstName.firstNameLink).pathSegments.last,
                  pageNo: data.firstName.firstNamePgNo,
                  isLinkeOpen: data.firstName.firstNameLink);
            },
            controller: ctlrFirstName,
            labelText: 'First Name*',
          );
          final middleInitial = SchedularTextField(
            isIconVisible: data.middleInitial.middleInitialLink.isEmpty,
            isIClicked: () {
              widget.isIButtonPressed();
              providerUpdate.setLinkAndPageNumber(
                  selectLink: Uri.parse(data.middleInitial.middleInitialLink).pathSegments.last,
                  pageNo: data.middleInitial.middleInitialPgNo,
                  isLinkeOpen: data.middleInitial.middleInitialLink);
            },
            controller: ctlrMiddleInitial,
            labelText: 'Middle Initial',
          );
          final lastName = SchedularTextField(
            isIconVisible: data.lastName.lastNameLink.isEmpty,
            isIClicked: () {
              widget.isIButtonPressed();
              providerUpdate.setLinkAndPageNumber(
                  selectLink: Uri.parse(data.lastName.lastNameLink).pathSegments.last,
                  pageNo: data.lastName.lastNamePgNo,
                  isLinkeOpen: data.lastName.lastNameLink);
            },
            controller: ctlrLastName,
            labelText: 'Last Name*',
          );
          final suffix = SchedularTextField(
            isIconVisible: data.suffix.suffixLink.isEmpty,
            isIClicked: () {
              widget.isIButtonPressed();
              providerUpdate.setLinkAndPageNumber(
                  selectLink: Uri.parse(data.suffix.suffixLink).pathSegments.last,
                  pageNo: data.suffix.suffixPgNo,
                  isLinkeOpen: data.suffix.suffixLink);
            },
            controller: ctlrSuffix,
            labelText: 'Suffix',
          );
          final street = SchedularTextField(
            isIconVisible: data.street.streetLink.isEmpty,
            isIClicked: () {
              widget.isIButtonPressed();
              providerUpdate.setLinkAndPageNumber(
                  selectLink: Uri.parse(data.street.streetLink).pathSegments.last,
                  pageNo: data.street.streetPgNo,
                  isLinkeOpen: data.street.streetLink);
            },
            controller: ctlrStreet,
            icon: Icon(Icons.location_on_outlined, color: ColorManager.blueprime, size: IconSize.I18),
            labelText: 'Street*',
          );
          final suitApt = SchedularTextField(
            isIconVisible: data.suite.suiteLink.isEmpty,
            isIClicked: () {
              widget.isIButtonPressed();
              providerUpdate.setLinkAndPageNumber(
                  selectLink: Uri.parse(data.suite.suiteLink).pathSegments.last,
                  pageNo: data.suite.suitePgNo,
                  isLinkeOpen: data.suite.suiteLink);
            },
            controller: ctlrSuitApt,
            labelText: 'Suit/Apt#',
          );
          final city = SchedularTextField(
            isIconVisible: data.city.cityLink.isEmpty,
            isIClicked: () {
              widget.isIButtonPressed();
              providerUpdate.setLinkAndPageNumber(
                  selectLink: Uri.parse(data.city.cityLink).pathSegments.last,
                  pageNo: data.city.cityPgNo,
                  isLinkeOpen: data.city.cityLink);
            },
            controller: ctlrCity,
            labelText: 'City*',
          );
          final zipCode = SchedularTextField(
            isIconVisible: data.zipcode.zipcodeLink.isEmpty,
            isIClicked: () {
              widget.isIButtonPressed();
              providerUpdate.setLinkAndPageNumber(
                  selectLink: Uri.parse(data.zipcode.zipcodeLink).pathSegments.last,
                  pageNo: data.zipcode.zipcodePgNo,
                  isLinkeOpen: data.zipcode.zipcodeLink);
            },
            controller: ctlrZipCode,
            allowSSNBR: true,
            labelText: 'Zip Code',
          );
          // ✅ SWAPPED — CustomDropdownTextFieldsm → EmrDropdownTextFieldConst (alignment fix)
          final residenceType = FutureBuilder<List<ResidenceTypeData>>(
            future: _residenceDropdownFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return SchedularTextField(isIconVisible: false, controller: ctlrResidency, labelText: 'Residence Type');
              }
              if (snap.hasData) {
                return EmrDropdownTextFieldConst(
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
          );
          final facilityName = SchedularTextField(
            isIconVisible: data.facilityName.facilityNameLink.isEmpty,
            isIClicked: () {
              widget.isIButtonPressed();
              providerUpdate.setLinkAndPageNumber(
                  selectLink: Uri.parse(data.facilityName.facilityNameLink).pathSegments.last,
                  pageNo: data.facilityName.facilityNamePgNo,
                  isLinkeOpen: data.facilityName.facilityNameLink);
            },
            controller: ctlrFacilityName,
            labelText: 'Facility Name',
          );
          // ✅ SWAPPED — CustomDropdownTextFieldsm → EmrDropdownTextFieldConst (alignment fix)
          final zone = FutureBuilder<List<AEClinicalZone>>(
            future: _zoneFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return SchedularTextField(isIconVisible: false, controller: ctlrZone, labelText: 'Zone*');
              }
              if (snap.hasData) {
                return EmrDropdownTextFieldConst(
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
          );
          final locationNotes = SchedularTextField(
            isIconVisible: data.locationNotes.locationNotesLink.isEmpty,
            isIClicked: () {
              widget.isIButtonPressed();
              providerUpdate.setLinkAndPageNumber(
                  selectLink: Uri.parse(data.locationNotes.locationNotesLink).pathSegments.last,
                  pageNo: data.locationNotes.locationNotesPgNo,
                  isLinkeOpen: data.locationNotes.locationNotesLink);
            },
            controller: ctlrLocationNotes,
            labelText: 'Location Notes',
          );
          final primaryContact = SchedularTextField(
            isIconVisible: data.primaryContact.primaryContactLink.isEmpty,
            isIClicked: () {
              widget.isIButtonPressed();
              providerUpdate.setLinkAndPageNumber(
                  selectLink: Uri.parse(data.primaryContact.primaryContactLink).pathSegments.last,
                  pageNo: data.primaryContact.primaryContactPgNo,
                  isLinkeOpen: data.primaryContact.primaryContactLink);
            },
            controller: ctlrPrimaryContact,
            labelText: 'Primary Contact*',
          );
          final primaryContactName = SchedularTextField(
            isIconVisible: data.primaryContactName.primaryContactNameLink.isEmpty,
            isIClicked: () {
              widget.isIButtonPressed();
              providerUpdate.setLinkAndPageNumber(
                  selectLink: Uri.parse(data.primaryContactName.primaryContactNameLink).pathSegments.last,
                  pageNo: data.primaryContactName.primaryContactNamePgNo,
                  isLinkeOpen: data.primaryContactName.primaryContactNameLink);
            },
            controller: ctlrPrimaryContactName,
            labelText: 'Primary Contact Name*',
          );
          final primaryPhone = SchedularTextField(
            isIconVisible: data.primaryPhone.primaryPhoneLink.isEmpty,
            isIClicked: () {
              widget.isIButtonPressed();
              providerUpdate.setLinkAndPageNumber(
                  selectLink: Uri.parse(data.primaryPhone.primaryPhoneLink).pathSegments.last,
                  pageNo: data.primaryPhone.primaryPhonePgNo,
                  isLinkeOpen: data.primaryPhone.primaryPhoneLink);
            },
            controller: ctlrPrimaryPhone,
            labelText: 'Primary Phone #*',
            phoneField: true,
          );
          final primaryEmail = SchedularTextField(
            isIconVisible: data.primaryEmail.primaryEmailLink.isEmpty,
            isIClicked: () {
              widget.isIButtonPressed();
              providerUpdate.setLinkAndPageNumber(
                  selectLink: Uri.parse(data.primaryEmail.primaryEmailLink).pathSegments.last,
                  pageNo: data.primaryEmail.primaryEmailPgNo,
                  isLinkeOpen: data.primaryEmail.primaryEmailLink);
            },
            controller: ctlrPrimaryEmail,
            labelText: 'Primary Email',
          );
          final cahpsContact = SchedularTextField(
            isIconVisible: data.cahpsContact.cahpsContactLink.isEmpty,
            isIClicked: () {
              widget.isIButtonPressed();
              providerUpdate.setLinkAndPageNumber(
                  selectLink: Uri.parse(data.cahpsContact.cahpsContactLink).pathSegments.last,
                  pageNo: data.cahpsContact.cahpsContactPgNo,
                  isLinkeOpen: data.cahpsContact.cahpsContactLink);
            },
            controller: ctlrCahpsContact,
            labelText: 'CAHPS Contact',
          );
          final secondaryContact = SchedularTextField(
            isIconVisible: data.secondaryContact.secondaryContactLink.isEmpty,
            isIClicked: () {
              widget.isIButtonPressed();
              providerUpdate.setLinkAndPageNumber(
                  selectLink: Uri.parse(data.secondaryContact.secondaryContactLink).pathSegments.last,
                  pageNo: data.secondaryContact.secondaryContactPgNo,
                  isLinkeOpen: data.secondaryContact.secondaryContactLink);
            },
            controller: ctlrSecondaryContact,
            labelText: 'Secondary Contact*',
          );
          final secondaryContactName = SchedularTextField(
            isIconVisible: data.secondaryContactName.secondaryContactNameLink.isEmpty,
            isIClicked: () {
              widget.isIButtonPressed();
              providerUpdate.setLinkAndPageNumber(
                  selectLink: Uri.parse(data.secondaryContactName.secondaryContactNameLink).pathSegments.last,
                  pageNo: data.secondaryContactName.secondaryContactNamePgNo,
                  isLinkeOpen: data.secondaryContactName.secondaryContactNameLink);
            },
            controller: ctlrSecondaryContactName,
            labelText: 'Secondary Contact Name',
          );
          final secondaryPhone = SchedularTextField(
            isIconVisible: data.secondaryPhone.secondaryPhoneLink.isEmpty,
            isIClicked: () {
              widget.isIButtonPressed();
              providerUpdate.setLinkAndPageNumber(
                  selectLink: Uri.parse(data.secondaryPhone.secondaryPhoneLink).pathSegments.last,
                  pageNo: data.secondaryPhone.secondaryPhonePgNo,
                  isLinkeOpen: data.secondaryPhone.secondaryPhoneLink);
            },
            controller: ctlrSecondaryPhone,
            labelText: 'Secondary Phone #*',
            phoneField: true,
          );
          final secondaryEmail = SchedularTextField(
            isIconVisible: data.secondaryEmail.secondaryEmailLink.isEmpty,
            isIClicked: () {
              widget.isIButtonPressed();
              providerUpdate.setLinkAndPageNumber(
                  selectLink: Uri.parse(data.secondaryEmail.secondaryEmailLink).pathSegments.last,
                  pageNo: data.secondaryEmail.secondaryEmailPgNo,
                  isLinkeOpen: data.secondaryEmail.secondaryEmailLink);
            },
            controller: ctlrSecondaryEmail,
            labelText: 'Secondary Email',
          );

          return Column(
              children: [

                // ✅ Go Back — only shown while sidebar is open (same as intake)
                sidebarOpen
                    ? Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: () {
                        widget.isIButtonPressed();
                        providerUpdate.setLinkAndPageClear();
                      },
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back, size: IconSize.I16, color: ColorManager.mediumgrey),
                          const SizedBox(width: 5),
                          Text(
                            'Go Back',
                            style: TextStyle(fontWeight: FontWeight.w700, color: ColorManager.mediumgrey),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    : const Offstage(),

                // ══════════════════════════════════════════════════════════
                // CONTACT INFORMATION
                // ══════════════════════════════════════════════════════════
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: BlueBGHeadConst(
                    HeadText: "Contact Information",
                    body: IntakeFlowContainerConst(
                      // ✅ 8 rows needed at 3/row (sidebar open) vs 6 rows at 4/row (closed)
                      height: sidebarOpen ? AppSize.s700 : AppSize.s600,
                      child: sidebarOpen
                          ? Column(
                        children: [
                          // Row 1 — First Name | Middle Initial | Last Name
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(child: firstName),
                              gap,
                              Flexible(child: middleInitial),
                              gap,
                              Flexible(child: lastName),
                            ],
                          ),
                          rowGap,
                          // Row 2 — Suffix | Street | Suite/Apt
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(child: suffix),
                              gap,
                              Flexible(child: street),
                              gap,
                              Flexible(child: suitApt),
                            ],
                          ),
                          rowGap,
                          // Row 3 — City | State | Zip Code
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(child: city),
                              gap,
                              Flexible(child: widget.childState),
                              gap,
                              Flexible(child: zipCode),
                            ],
                          ),
                          rowGap,
                          // Row 4 — Country | Residence Type | Facility Name
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(child: widget.childCountry),
                              gap,
                              Flexible(child: residenceType),
                              gap,
                              Flexible(child: facilityName),
                            ],
                          ),
                          rowGap,
                          // Row 5 — Zone | Location Notes | Primary Contact
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(child: zone),
                              gap,
                              Flexible(child: locationNotes),
                              gap,
                              Flexible(child: primaryContact),
                            ],
                          ),
                          rowGap,
                          // Row 6 — Primary Contact Name | Primary Phone | Primary Email
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(child: primaryContactName),
                              gap,
                              Flexible(child: primaryPhone),
                              gap,
                              Flexible(child: primaryEmail),
                            ],
                          ),
                          rowGap,
                          // Row 7 — CAHPS Contact | Secondary Contact | Secondary Contact Name
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(child: cahpsContact),
                              gap,
                              Flexible(child: secondaryContact),
                              gap,
                              Flexible(child: secondaryContactName),
                            ],
                          ),
                          rowGap,
                          // Row 8 — Secondary Phone | Secondary Email | (empty)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(child: secondaryPhone),
                              gap,
                              Flexible(child: secondaryEmail),
                              gap,
                              const Flexible(child: SizedBox()),
                            ],
                          ),
                        ],
                      )
                          : Column(
                        children: [
                          // Row 1 — First Name | Middle Initial | Last Name | Suffix
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(child: firstName),
                              gap,
                              Flexible(child: middleInitial),
                              gap,
                              Flexible(child: lastName),
                              gap,
                              Flexible(child: suffix),
                            ],
                          ),
                          rowGap,
                          // Row 2 — Street | Suite/Apt | City | State
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(child: street),
                              gap,
                              Flexible(child: suitApt),
                              gap,
                              Flexible(child: city),
                              gap,
                              Flexible(child: widget.childState),
                            ],
                          ),
                          rowGap,
                          // Row 3 — Zip Code | Country | Residence Type | Facility Name
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(child: zipCode),
                              gap,
                              Flexible(child: widget.childCountry),
                              gap,
                              Flexible(child: residenceType),
                              gap,
                              Flexible(child: facilityName),
                            ],
                          ),
                          rowGap,
                          // Row 4 — Zone | Location Notes | Primary Contact | Primary Contact Name
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(child: zone),
                              gap,
                              Flexible(child: locationNotes),
                              gap,
                              Flexible(child: primaryContact),
                              gap,
                              Flexible(child: primaryContactName),
                            ],
                          ),
                          rowGap,
                          // Row 5 — Primary Phone | Primary Email | CAHPS Contact | Secondary Contact
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(child: primaryPhone),
                              gap,
                              Flexible(child: primaryEmail),
                              gap,
                              Flexible(child: cahpsContact),
                              gap,
                              Flexible(child: secondaryContact),
                            ],
                          ),
                          rowGap,
                          // Row 6 — Secondary Contact Name | Secondary Phone | Secondary Email | (empty)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(child: secondaryContactName),
                              gap,
                              Flexible(child: secondaryPhone),
                              gap,
                              Flexible(child: secondaryEmail),
                              gap,
                              const Flexible(child: SizedBox()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSize.s40),

                // ══════════════════════════════════════════════════════════
                // ADDITIONAL INFORMATION — stays fixed at 3/row (matches Intake's
                // Additional Information section, which never changes column count)
                // ══════════════════════════════════════════════════════════
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: BlueBGHeadConst(
                    HeadText: "Additional Information",
                    body: IntakeFlowContainerConst(
                      height: AppSize.s180,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: SchedularTextField(
                                  isIconVisible: true, // ✅ no source link for DOB — hide "i" button
                                  controller: ctlrDob,
                                  labelText: 'Date of Birth*',
                                  showDatePicker: true,
                                  dateFormateMMDDYYYY: true,
                                ),
                              ),
                              gap,
                              Flexible(
                                child: FutureBuilder<List<GenderData>>(
                                  future: _genderDropdownFuture,
                                  builder: (context, snap) {
                                    if (snap.connectionState == ConnectionState.waiting) {
                                      return SchedularTextField(isIconVisible: true, controller: ctlrGender, labelText: 'Gender*');
                                    }
                                    if (snap.hasData) {
                                      return EmrDropdownTextFieldConst(
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
                              ),
                              gap,
                              Flexible(
                                child: FutureBuilder<List<LanguageSpokenData>>(
                                  future: _languageSpokenDropdownFuture,
                                  builder: (context, snap) {
                                    if (snap.connectionState == ConnectionState.waiting) {
                                      return SchedularTextField(isIconVisible: true, controller: ctlrLanguage, labelText: 'Primary Language');
                                    }
                                    if (snap.hasData) {
                                      return EmrDropdownTextFieldConst(
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
                              ),
                              sidebarOpen ? const Offstage() : const Flexible(child: SizedBox()),
                            ],
                          ),
                          rowGap,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: SchedularTextField(
                                  isIconVisible: true, // ✅ no source link for Social Security — hide "i" button
                                  controller: ctlrSocialSecurity,
                                  labelText: 'Social Security',
                                  isPasswordField: true,
                                  allowSSNBR: true,
                                ),
                              ),
                              gap,
                              Flexible(
                                child: FutureBuilder<List<RaceModelData>>(
                                  future: _raceDropdownFuture,
                                  builder: (context, snap) {
                                    if (snap.connectionState == ConnectionState.waiting) {
                                      return SchedularTextField(isIconVisible: true, controller: ctlrRace, labelText: 'Race/Ethnicity');
                                    }
                                    if (snap.hasData) {
                                      return EmrDropdownTextFieldConst(
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
                              ),
                              gap,
                              Flexible(
                                child: FutureBuilder<List<MetrialStatusData>>(
                                  future: _maritalStatusDropdownFuture,
                                  builder: (context, snap) {
                                    if (snap.connectionState == ConnectionState.waiting) {
                                      return SchedularTextField(isIconVisible: true, controller: ctlrMaritalStatus, labelText: 'Marital Status');
                                    }
                                    if (snap.hasData) {
                                      return EmrDropdownTextFieldConst(
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
                              ),
                              sidebarOpen ? const Offstage() : const Flexible(child: SizedBox()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSize.s30),
              ],
            );
        },
      ),
    );
  }
}