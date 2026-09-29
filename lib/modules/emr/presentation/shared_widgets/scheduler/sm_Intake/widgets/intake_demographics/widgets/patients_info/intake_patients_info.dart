import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/dropdown_constant_sm.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/all_intake_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/demographich_ai_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_employee_documents/widgets/radio_button_tile_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';
// removed in extraction: import '../../../../../textfield_dropdown_constant/schedular_dropdown_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/schedular_textfield_const.dart';
// removed in extraction: import '../../../../../textfield_dropdown_constant/schedular_textfield_withbutton_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/address_map_screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_flow_contgainer_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_update_schedular/information_update.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_demographics/widgets/patients_info/intake_patients_info_controller.dart';

class IntakePatientsDatatInfo extends StatelessWidget {
  final Widget childState;
  final Widget childCountry;
  final VoidCallback isIButtonPressed;
  final VoidCallback onSkip;

  const IntakePatientsDatatInfo(
      {super.key,
      required this.childState,
      required this.childCountry,
        required this.isIButtonPressed, required this.onSkip,
      });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<IntakePatientsInfoController>(
      create: (ctx) => IntakePatientsInfoController()
        ..load(ctx, patientId: Provider.of<DiagnosisProvider>(ctx, listen: false).patientId),
      child: _IntakePatientsDatatInfoBody(
        childState: childState,
        childCountry: childCountry,
        isIButtonPressed: isIButtonPressed,
        onSkip: onSkip,
      ),
    );
  }
}

class _IntakePatientsDatatInfoBody extends StatefulWidget {
  final Widget childState;
  final Widget childCountry;
  final VoidCallback isIButtonPressed;
  final VoidCallback onSkip;

  const _IntakePatientsDatatInfoBody(
      {required this.childState,
      required this.childCountry,
        required this.isIButtonPressed, required this.onSkip,
      });

  @override
  State<_IntakePatientsDatatInfoBody> createState() => _IntakePatientsDatatInfoBodyState();
}

class _IntakePatientsDatatInfoBodyState extends State<_IntakePatientsDatatInfoBody> {
  TextEditingController ctlrfirstName = TextEditingController();
  TextEditingController ctlrMedicalRecord = TextEditingController();

  TextEditingController ctlrLastName = TextEditingController();
  TextEditingController ctlrSuffix = TextEditingController();
  TextEditingController ctlrDate = TextEditingController();
  TextEditingController ctlrStreet = TextEditingController();
  TextEditingController ctlrZipCode = TextEditingController();
  TextEditingController ctlrSuitApt = TextEditingController();
  TextEditingController ctlrCity = TextEditingController();
  TextEditingController ctlrState = TextEditingController();
  TextEditingController ctlrPrimaryContact = TextEditingController();
  TextEditingController ctlrSecondContact = TextEditingController();
  TextEditingController ctlrPrimeNo = TextEditingController();
  TextEditingController ctlrSecNo = TextEditingController();
  TextEditingController ctlrEmail = TextEditingController();
  TextEditingController ctlrSocialSec = TextEditingController();
  TextEditingController facilityNameController = TextEditingController();
  TextEditingController locationNotesController = TextEditingController();
  TextEditingController primaryContactNameController = TextEditingController();
  TextEditingController cahpsContactController = TextEditingController();
  TextEditingController secondaryPhoneController = TextEditingController();
  TextEditingController secEmailController = TextEditingController();
  TextEditingController primaryLanguageController = TextEditingController();
  TextEditingController residencyController = TextEditingController();
  TextEditingController maritalStatusController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController zoneController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController raceController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<IntakePatientsInfoController>();
    final providerPatientId = Provider.of<DiagnosisProvider>(context,listen: false);
    final providerUpdate = Provider.of<SmIntakeProviderManager>(context,listen: false);
    String? status = '';
    String? statustype;
    String selectedCountry = 'Select';
    String selectedRace = 'Select';
    String selectedResidency = 'Select';
    String? selectedState;
    String? selectedcity;
    String selectedLanguage = 'Select';
    String selectedGender = 'Select';
    String? selectedReligion;
    String selectedMaritalStatus = 'Select';
    String selectedZone = 'Select';
    int primaryLanguageid = 0;
    int countyId = 0;
    int zoneId = 0;
    int residentialId = 0;
    int maritalStatusId = 0;
    int genderId = 0;
    int raceId = 0;
    bool isLoading = false;




    Widget bodyContent;
    if (controller.isLoadingDemographic) {
      bodyContent = Center(
        child: CircularProgressIndicator(color: ColorManager.blueprime,),
      );
    } else if (controller.hasError) {
      bodyContent = const Center(
        child: Text('Something went wrong!'),
      );
    } else {
          print('Page error ${controller.error}');
          primaryLanguageid = controller.demographicPatient!.fkSpokenLanguage;
          countyId = controller.demographicPatient!.fkCountryId;
          zoneId = controller.demographicPatient!.fkZoneId;
          genderId = controller.demographicPatient!.fkGender;
          raceId = controller.demographicPatient!.fkRaceEthnicity;
          residentialId = controller.demographicPatient!.fkResidenceTypeId;
          selectedGender = controller.demographicPatient!.gender.gender.isEmpty ? 'Select' : controller.demographicPatient!.gender.gender;
          maritalStatusId = controller.demographicPatient!.fkMaritalStatus;
          selectedCountry = controller.demographicPatient!.country.name.isEmpty ? 'Select' : controller.demographicPatient!.country.name;
          selectedResidency = controller.demographicPatient!.residenceType.detail.isEmpty ? 'Select' : controller.demographicPatient!.residenceType.detail;
          selectedRace = controller.demographicPatient!.race.race.isEmpty ? 'Select' : controller.demographicPatient!.race.race;
          selectedLanguage = controller.demographicPatient!.spokenLanguage.languageSpoken.isEmpty ? 'Select' : controller.demographicPatient!.spokenLanguage.languageSpoken;
          selectedMaritalStatus = controller.demographicPatient!.maritalStatus.maritalStatus.isEmpty ? 'Select' :controller.demographicPatient!.maritalStatus.maritalStatus;
          selectedZone = controller.demographicPatient!.zone.zoneName.isEmpty ? 'Select' : controller.demographicPatient!.zone.zoneName;
          raceController = TextEditingController(text: raceController.text.isEmpty ? controller.demographicPatient!.race.race : raceController.text);
          genderController = TextEditingController(text: genderController.text.isEmpty ? controller.demographicPatient!.gender.gender : genderController.text);
          residencyController = TextEditingController(text: residencyController.text.isEmpty ? controller.demographicPatient!.residenceType.detail : residencyController.text);
           ctlrMedicalRecord = TextEditingController(text: ctlrMedicalRecord.text.isEmpty ? controller.demographicPatient!.middleInitial.demoMiddleInitial : ctlrMedicalRecord.text);
           ctlrfirstName = TextEditingController(text: ctlrfirstName.text.isEmpty ? controller.demographicPatient!.firstName.demoFirstName : ctlrfirstName.text);
           ctlrLastName = TextEditingController(text: ctlrLastName.text.isEmpty ? controller.demographicPatient!.lastName.demoLastName : ctlrLastName.text);
           ctlrSuffix = TextEditingController(text: ctlrSuffix.text.isEmpty ? controller.demographicPatient!.suffix.demoSuffix : ctlrSuffix.text);
           ctlrDate = TextEditingController(text: ctlrDate.text.isEmpty ? controller.demographicPatient!.demoDob : ctlrDate.text);
           ctlrStreet = TextEditingController(text: ctlrStreet.text.isEmpty ? controller.demographicPatient!.street.demoStreet : ctlrStreet.text);
           ctlrZipCode = TextEditingController(text: ctlrZipCode.text.isEmpty ? controller.demographicPatient!.zipcode.demoZipcode : ctlrZipCode.text);
           ctlrState = TextEditingController(text: ctlrState.text.isEmpty ? controller.demographicPatient!.state.demoState : ctlrState.text);
            ctlrSuitApt = TextEditingController(text: ctlrSuitApt.text.isEmpty ? controller.demographicPatient!.suite.demoSuite : ctlrSuitApt.text);
           ctlrCity = TextEditingController(text: ctlrCity.text.isEmpty ? controller.demographicPatient!.city.demoCity : ctlrCity.text);
           ctlrPrimaryContact = TextEditingController(text: ctlrPrimaryContact.text.isEmpty ? controller.demographicPatient!.primaryContact.demoPrimaryContact : ctlrPrimaryContact.text);
           ctlrSecondContact = TextEditingController(text: ctlrSecondContact.text.isEmpty ? controller.demographicPatient!.secondaryContact.demoSecondaryContact : ctlrSecondContact.text);
           ctlrPrimeNo = TextEditingController(text: ctlrPrimeNo.text.isEmpty ? controller.demographicPatient!.primaryPhone.demoPrimaryPhone : ctlrPrimeNo.text);
           ctlrSecNo = TextEditingController(text: ctlrSecNo.text.isEmpty ? controller.demographicPatient!.secondaryPhone.demoSecondaryPhone : ctlrSecNo.text);
           ctlrEmail = TextEditingController(text: ctlrEmail.text.isEmpty ? controller.demographicPatient!.primaryEmail.demoPrimaryEmail : ctlrEmail.text);
           ctlrSocialSec = TextEditingController(text: ctlrSocialSec.text.isEmpty ?controller.demographicPatient!.socialSecurity.demoSocialSecurity : ctlrSocialSec.text);
           facilityNameController = TextEditingController(text: facilityNameController.text.isEmpty ? controller.demographicPatient!.facilityName.demoFacilityName : facilityNameController.text);
           locationNotesController = TextEditingController(text: locationNotesController.text.isEmpty ? controller.demographicPatient!.locationNotes.demoLocationNotes : locationNotesController.text);
           primaryContactNameController = TextEditingController(text: primaryContactNameController.text.isEmpty ? controller.demographicPatient!.primaryContactName.demoPrimaryContactName : primaryContactNameController.text);
           cahpsContactController = TextEditingController(text: cahpsContactController.text.isEmpty ? controller.demographicPatient!.cahpsContact.demoCahpsContact : cahpsContactController.text);
           secondaryPhoneController = TextEditingController(text:secondaryPhoneController.text.isEmpty ? controller.demographicPatient!.secondaryContact.demoSecondaryContact : secondaryPhoneController.text);
           secEmailController = TextEditingController(text:secEmailController.text.isEmpty ? controller.demographicPatient!.secondaryEmail.demoSecondaryEmail :secEmailController.text);

      bodyContent = Consumer<SmIntakeProviderManager>(
            builder: (context,providerState,child) {
              return Center(
                child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10,right: 36,),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Review and confirm the data pulled is correct  ',
                                  style: SMItalicTextConst.customTextStyle(context))
                            ],
                          ),
                        ),

                        providerState.isLeftSidebarOpen ? Container(
                          child: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              onTap:(){
                                widget.isIButtonPressed();
                                providerState.setLinkAndPageClear();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 35,vertical: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_back,
                                      size: IconSize.I16,
                                      color: ColorManager.mediumgrey,

                                    ),
                                    const SizedBox(width: 5,),
                                    Text(
                                      'Go Back',
                                      style:TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: ColorManager.mediumgrey,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ) : const Offstage(),
                         Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: BlueBGHeadConst(HeadText: "Contact Information",
                            body: IntakeFlowContainerConst(
                              height:providerState.isContactTrue ? AppSize.s640:AppSize.s500,
                              child: Column(
                                children: [
                                  providerState.isContactTrue ?  Row(
                                    children: [
                                      Flexible(
                                          child: SchedularTextField(
                                            isIconVisible: controller.demographicPatient!.firstName.firstNameLink.isEmpty ? true : false,
                                            isIClicked: (){
                                              widget.isIButtonPressed();
                                              providerUpdate.setLinkAndPageNumber(
                                                  selectLink: Uri.parse(controller.demographicPatient!.firstName.firstNameLink).pathSegments.last,
                                                  pageNo: controller.demographicPatient!.firstName.firstNamePgNo,
                                                  isLinkeOpen: controller.demographicPatient!.firstName.firstNameLink);

                                            },
                                            controller: ctlrfirstName,
                                            labelText: 'First Name*',
                                          )),
                                      SizedBox(width:  providerState.isLeftSidebarOpen ?  AppSize.s70 : AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                              isIClicked: (){
                                                widget.isIButtonPressed();
                                                providerUpdate.setLinkAndPageNumber(
                                                    selectLink: Uri.parse(controller.demographicPatient!.middleInitial.middleInitialLink).pathSegments.last,
                                                    pageNo: controller.demographicPatient!.middleInitial.middleInitialPgNo,
                                                    isLinkeOpen: controller.demographicPatient!.middleInitial.middleInitialLink);
                                              },
                                              isIconVisible :controller.demographicPatient!.middleInitial.middleInitialLink.isEmpty ? true : false,
                                              controller: ctlrMedicalRecord,
                                              labelText: 'Middle Initial',
                                              initialValue: 'A')),
                                      SizedBox(width: providerState.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                              isIClicked: (){
                                                widget.isIButtonPressed();
                                                providerUpdate.setLinkAndPageNumber(
                                                    selectLink: Uri.parse(controller.demographicPatient!.lastName.lastNameLink).pathSegments.last,
                                                    pageNo: controller.demographicPatient!.lastName.lastNamePgNo,
                                                    isLinkeOpen: controller.demographicPatient!.lastName.lastNameLink);
                                              },
                                              isIconVisible :controller.demographicPatient!.lastName.lastNameLink.isEmpty ? true : false,
                                              controller: ctlrLastName,
                                              labelText: "Last Name*",
                                              initialValue: 'Erica')),
                                    ],
                                  ):
                                  Row(
                                    children: [
                                      Flexible(
                                          child: SchedularTextField(

                                            isIClicked: (){
                                              widget.isIButtonPressed();
                                              providerUpdate.setLinkAndPageNumber(
                                                  selectLink: Uri.parse(controller.demographicPatient!.firstName.firstNameLink).pathSegments.last,
                                                  pageNo: controller.demographicPatient!.firstName.firstNamePgNo,
                                                  isLinkeOpen: controller.demographicPatient!.firstName.firstNameLink);
                                            },
                                            isIconVisible: controller.demographicPatient!.firstName.firstNameLink.isEmpty ? true : false,
                                            controller: ctlrfirstName,
                                            labelText: 'First Name*',
                                          )),
                                      SizedBox(width:providerState.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                              isIClicked: (){
                                                widget.isIButtonPressed();
                                                providerUpdate.setLinkAndPageNumber(
                                                    selectLink: Uri.parse(controller.demographicPatient!.middleInitial.middleInitialLink).pathSegments.last,
                                                    pageNo: controller.demographicPatient!.middleInitial.middleInitialPgNo,
                                                    isLinkeOpen:controller.demographicPatient!.middleInitial.middleInitialLink );
                                              },
                                              isIconVisible :controller.demographicPatient!.middleInitial.middleInitialLink.isEmpty ? true : false,
                                              controller: ctlrMedicalRecord,
                                              labelText: 'Middle Initial',
                                              initialValue: 'A')),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                              isIClicked: (){
                                                widget.isIButtonPressed();
                                                providerUpdate.setLinkAndPageNumber(
                                                    selectLink: Uri.parse(controller.demographicPatient!.lastName.lastNameLink).pathSegments.last,
                                                    pageNo: controller.demographicPatient!.lastName.lastNamePgNo,
                                                    isLinkeOpen:controller.demographicPatient!.lastName.lastNameLink );
                                              },
                                              isIconVisible :controller.demographicPatient!.lastName.lastNameLink.isEmpty ? true : false,
                                              controller: ctlrLastName,
                                              labelText: "Last Name*",
                                              initialValue: 'Erica')),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                              isIClicked: (){
                                                widget.isIButtonPressed();
                                                providerUpdate.setLinkAndPageNumber(
                                                    selectLink: Uri.parse(controller.demographicPatient!.suffix.suffixLink).pathSegments.last,
                                                    pageNo: controller.demographicPatient!.suffix.suffixPgNo,
                                                    isLinkeOpen:controller.demographicPatient!.suffix.suffixLink );
                                              },
                                              isIconVisible :controller.demographicPatient!.suffix.suffixLink.isEmpty ? true : false,
                                              controller:ctlrSuffix,
                                              labelText: "Suffix",
                                              initialValue: 'Erica')),
                                      const SizedBox(width: AppSize.s35),
                                      const Flexible(
                                          child: SizedBox(width:0)),

                                    ],
                                  ),
                                  const SizedBox(height: AppSize.s16),
                                  providerState.isContactTrue ?  Row(
                                    children: [
                                      Flexible(
                                          child: SchedularTextField(
                                              isIClicked: (){
                                                widget.isIButtonPressed();
                                                providerUpdate.setLinkAndPageNumber(
                                                    selectLink: Uri.parse(controller.demographicPatient!.suffix.suffixLink).pathSegments.last,
                                                    pageNo: controller.demographicPatient!.suffix.suffixPgNo,
                                                    isLinkeOpen: controller.demographicPatient!.suffix.suffixLink);
                                              },
                                              isIconVisible :controller.demographicPatient!.suffix.suffixLink.isEmpty ? true : false,
                                              controller:ctlrSuffix,
                                              labelText: "Suffix",
                                              initialValue: 'Erica')),
                                      SizedBox(width:providerState.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                              isIconClicked: true,
                                              iconClickedPress:(){
                                                providerState.openMapScreen(context:context);
                                              },
                                              isIClicked: (){
                                                widget.isIButtonPressed();
                                                providerUpdate.setLinkAndPageNumber(
                                                    selectLink: Uri.parse(controller.demographicPatient!.street.streetLink).pathSegments.last,
                                                    pageNo: controller.demographicPatient!.street.streetPgNo,
                                                    isLinkeOpen: controller.demographicPatient!.street.streetLink);
                                              },
                                              isIconVisible :controller.demographicPatient!.street.streetLink.isEmpty ? true : false,
                                              controller: providerState.ctlrStreetProvider.text.isEmpty ? ctlrStreet : providerState.ctlrStreetProvider,
                                              icon: Icon(Icons.location_on_outlined, color: ColorManager.blueprime,size: IconSize.I18,),
                                              labelText: 'Street*',
                                              initialValue: 'A')),
                                      SizedBox(width:providerState.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                              isIClicked: (){
                                                widget.isIButtonPressed();
                                                providerUpdate.setLinkAndPageNumber(
                                                    selectLink: Uri.parse(controller.demographicPatient!.suite.suiteLink).pathSegments.last,
                                                    pageNo: controller.demographicPatient!.suite.suitePgNo,
                                                    isLinkeOpen:controller.demographicPatient!.suite.suiteLink );
                                              },
                                              isIconVisible :controller.demographicPatient!.suite.suiteLink.isEmpty ? true : false,
                                              controller: ctlrSuitApt,
                                              labelText: "Suit/Apt#")),
                                    ],
                                  ):
                                  Row(
                                    children: [
                                      Flexible(
                                          child: SchedularTextField(
                                              isIconClicked: true,
                                              iconClickedPress: (){
                                                providerState.openMapScreen(context:context);
                                              },
                                              isIClicked: (){
                                                widget.isIButtonPressed();
                                                providerUpdate.setLinkAndPageNumber(
                                                    selectLink: Uri.parse(controller.demographicPatient!.street.streetLink).pathSegments.last,
                                                    pageNo: controller.demographicPatient!.street.streetPgNo,
                                                    isLinkeOpen:controller.demographicPatient!.street.streetLink );
                                              },
                                              isIconVisible :controller.demographicPatient!.street.streetLink.isEmpty ? true : false,
                                              controller: providerState.ctlrStreetProvider.text.isEmpty ? ctlrStreet : providerState.ctlrStreetProvider,
                                              icon: Icon(Icons.location_on_outlined, color: ColorManager.blueprime,size: IconSize.I18,),
                                              labelText: 'Street*',
                                              initialValue: 'A')),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                              isIClicked: (){
                                                widget.isIButtonPressed();
                                                providerUpdate.setLinkAndPageNumber(
                                                    selectLink: Uri.parse(controller.demographicPatient!.suite.suiteLink).pathSegments.last,
                                                    pageNo: controller.demographicPatient!.suite.suitePgNo,
                                                    isLinkeOpen: controller.demographicPatient!.suite.suiteLink);
                                              },
                                              isIconVisible :controller.demographicPatient!.suite.suiteLink.isEmpty ? true : false,
                                              controller: ctlrSuitApt,
                                              labelText: "Suit/Apt#")),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child:  SchedularTextField(
                                          isIClicked: (){
                                            widget.isIButtonPressed();
                                            providerUpdate.setLinkAndPageNumber(
                                                selectLink: Uri.parse(controller.demographicPatient!.city.cityLink).pathSegments.last,
                                                pageNo: controller.demographicPatient!.city.cityPgNo,
                                                isLinkeOpen: controller.demographicPatient!.city.cityLink);
                                          },
                                          isIconVisible :controller.demographicPatient!.city.cityLink.isEmpty ? true : false,
                                          controller: providerState.ctlrCityProvider.text.isEmpty ? ctlrCity : providerState.ctlrCityProvider,
                                          labelText: 'City*',
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          isIClicked: (){
                                            widget.isIButtonPressed();
                                            providerUpdate.setLinkAndPageNumber(
                                                selectLink: Uri.parse(controller.demographicPatient!.state.stateLink).pathSegments.last,
                                                pageNo: controller.demographicPatient!.state.statePgNo,
                                                isLinkeOpen: controller.demographicPatient!.state.stateLink);
                                          },
                                          isIconVisible :controller.demographicPatient!.state.stateLink.isEmpty ? true : false,
                                          controller: providerState.ctlrStateProvider.text.isEmpty ? ctlrState : providerState.ctlrStateProvider,
                                          labelText: 'State*',
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                              isIClicked: (){
                                                widget.isIButtonPressed();
                                                providerUpdate.setLinkAndPageNumber(
                                                    selectLink: Uri.parse(controller.demographicPatient!.zipcode.zipcodeLink).pathSegments.last,
                                                    pageNo: controller.demographicPatient!.zipcode.zipcodePgNo,
                                                    isLinkeOpen: controller.demographicPatient!.zipcode.zipcodeLink);
                                              },
                                              isIconVisible :controller.demographicPatient!.zipcode.zipcodeLink.isEmpty ? true : false,
                                              controller: ctlrZipCode,
                                              allowSSNBR: true,
                                              labelText: AppString.zip_code)
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: AppSize.s16),
                                  providerState.isContactTrue ?  Row(
                                    children: [
                                      Flexible(
                                        child: SchedularTextField(
                                          isIClicked: (){
                                            widget.isIButtonPressed();
                                            providerUpdate.setLinkAndPageNumber(
                                                selectLink: Uri.parse(controller.demographicPatient!.city.cityLink).pathSegments.last,
                                                pageNo: controller.demographicPatient!.city.cityPgNo,
                                                isLinkeOpen: controller.demographicPatient!.city.cityLink);
                                          },
                                          isIconVisible :controller.demographicPatient!.city.cityLink.isEmpty ? true : false,
                                          controller: providerState.ctlrCityProvider.text.isEmpty ? ctlrCity : providerState.ctlrCityProvider,
                                          labelText: 'City*',
                                        ),
                                      ),
                                      SizedBox(width: providerState.isLeftSidebarOpen ?  AppSize.s70 : AppSize.s35),
                                      Flexible( child:  SchedularTextField(
                                        isIClicked: (){
                                          widget.isIButtonPressed();
                                          providerUpdate.setLinkAndPageNumber(
                                              selectLink: Uri.parse(controller.demographicPatient!.state.stateLink).pathSegments.last,
                                              pageNo: controller.demographicPatient!.state.statePgNo,
                                              isLinkeOpen: controller.demographicPatient!.state.stateLink);
                                        },
                                        isIconVisible :controller.demographicPatient!.state.stateLink.isEmpty ? true : false,
                                        controller: providerState.ctlrStateProvider.text.isEmpty ? ctlrState : providerState.ctlrStateProvider,
                                        labelText: 'State*',
                                      ),
                                      ),
                                      SizedBox(width: providerState.isLeftSidebarOpen ?  AppSize.s70 : AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                              isIClicked: (){
                                                widget.isIButtonPressed();
                                                providerUpdate.setLinkAndPageNumber(
                                                    selectLink: Uri.parse(controller.demographicPatient!.zipcode.zipcodeLink).pathSegments.last,
                                                    pageNo: controller.demographicPatient!.zipcode.zipcodePgNo,
                                                    isLinkeOpen:controller.demographicPatient!.zipcode.zipcodeLink );
                                              },
                                              allowSSNBR: true,
                                              isIconVisible :controller.demographicPatient!.zipcode.zipcodeLink.isEmpty ? true : false,
                                              controller: ctlrZipCode,
                                              labelText: AppString.zip_code)
                                      )
                                    ],
                                  ):
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Builder(
                                          builder: (context) {
                                            if (controller.countries == null) {
                                              return SchedularTextField(
                                                  controller: countryController, labelText: 'Country*');
                                            }
                                              List<DropdownMenuItem<String>> dropDownList = [];
                                              for (var i in controller.countries!) {
                                                dropDownList.add(DropdownMenuItem<String>(
                                                  child: Text(i.name!),
                                                  value: i.name,
                                                ));
                                              }

                                              return CustomDropdownTextFieldsm(
                                                  initialValue: selectedCountry,
                                                  headText: 'Country*',
                                                  dropDownMenuList: dropDownList,
                                                  onChanged: (newValue) {
                                                    for (var a in controller.countries!) {
                                                      if (a.name == newValue) {
                                                        selectedCountry = a.name!;
                                                        countyId = a.countryId;
                                                      }
                                                    }
                                                  });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: Builder(
                                          builder: (context) {
                                            if (controller.residenceTypes == null) {
                                              return SchedularTextField(
                                                  controller:residencyController , labelText: 'Residence Type');
                                            }
                                              List<DropdownMenuItem<String>> dropDownList = [];
                                              for (var i in controller.residenceTypes!) {
                                                dropDownList.add(DropdownMenuItem<String>(
                                                  child: Text(i.description),
                                                  value: i.description,
                                                ));
                                              }

                                              return CustomDropdownTextFieldsm(
                                                  initialValue: selectedResidency,
                                                  headText: 'Residence Type',
                                                  dropDownMenuList: dropDownList,
                                                  onChanged: (newValue) {
                                                    for (var a in controller.residenceTypes!) {
                                                      if (a.description == newValue) {
                                                        selectedResidency = a.description;
                                                        residentialId = a.id;
                                                      }
                                                    }
                                                  });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                            isIClicked: (){
                                              widget.isIButtonPressed();
                                              providerUpdate.setLinkAndPageNumber(
                                                  selectLink: Uri.parse(controller.demographicPatient!.facilityName.facilityNameLink).pathSegments.last,
                                                  pageNo: controller.demographicPatient!.facilityName.facilityNamePgNo,
                                                  isLinkeOpen:controller.demographicPatient!.facilityName.facilityNameLink );
                                            },
                                            isIconVisible :controller.demographicPatient!.facilityName.facilityNameLink.isEmpty ? true : false,
                                            controller: facilityNameController,
                                            labelText: 'Facility Name',
                                          )),
                                      const SizedBox(width: AppSize.s35),

                                      Flexible(
                                        child: Builder(
                                          builder: (context) {
                                            if (controller.zones == null) {
                                              return SchedularTextField(
                                                  controller: zoneController, labelText: 'Zone*');
                                            }
                                              List<DropdownMenuItem<String>> dropDownList = [];
                                              for (var i in controller.zones!) {
                                                dropDownList.add(DropdownMenuItem<String>(
                                                  child: Text(i.zoneName!),
                                                  value: i.zoneName,
                                                ));

                                              }

                                              return CustomDropdownTextFieldsm(
                                                  initialValue: selectedZone,
                                                  headText: 'Zone*',
                                                  dropDownMenuList: dropDownList,
                                                  onChanged: (newValue) {
                                                    for (var a in controller.zones!) {
                                                      if (a.zoneName == newValue) {
                                                        zoneId = a.zoneID!;
                                                        selectedZone = a.zoneName!;
                                                      }
                                                    }
                                                  });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                            isIClicked: (){
                                              widget.isIButtonPressed();
                                              providerUpdate.setLinkAndPageNumber(
                                                  selectLink: Uri.parse(controller.demographicPatient!.locationNotes.locationNotesLink).pathSegments.last,
                                                  pageNo: controller.demographicPatient!.locationNotes.locationNotesPgNo,
                                                  isLinkeOpen:controller.demographicPatient!.locationNotes.locationNotesLink );
                                            },
                                            isIconVisible :controller.demographicPatient!.locationNotes.locationNotesLink.isEmpty ? true : false,
                                            controller: locationNotesController,
                                            labelText: 'Location Notes',
                                          )),

                                      /// Remove code

                                    ],
                                  ),
                                  const SizedBox(height: AppSize.s16),
                                  providerState.isContactTrue ?  Row(
                                    children: [
                                      Flexible(
                                        child: Builder(
                                          builder: (context) {
                                            if (controller.countries == null) {
                                              return SchedularTextField(
                                                  controller: countryController, labelText: 'Country*');
                                            }
                                              List<DropdownMenuItem<String>> dropDownList = [];
                                              for (var i in controller.countries!) {
                                                dropDownList.add(DropdownMenuItem<String>(
                                                  child: Text(i.name!),
                                                  value: i.name,
                                                ));

                                              }

                                              return CustomDropdownTextFieldsm(
                                                  initialValue: selectedCountry,
                                                  headText: 'Country*',
                                                  dropDownMenuList: dropDownList,
                                                  onChanged: (newValue) {
                                                    for (var a in controller.countries!) {
                                                      if (a.name == newValue) {
                                                        selectedCountry = a.name!;
                                                        countyId = a.countryId;
                                                      }
                                                    }
                                                  });
                                          },
                                        ),
                                      ),
                                      SizedBox(width:providerState.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
                                      Flexible(
                                        child: Builder(
                                          builder: (context) {
                                            if (controller.residenceTypes == null) {
                                              return SchedularTextField(
                                                  controller:residencyController , labelText: 'Residence Type');
                                            }
                                              List<DropdownMenuItem<String>> dropDownList = [];
                                              for (var i in controller.residenceTypes!) {
                                                dropDownList.add(DropdownMenuItem<String>(
                                                  child: Text(i.description),
                                                  value: i.description,
                                                ));
                                              }

                                              return CustomDropdownTextFieldsm(
                                                  initialValue: selectedResidency,
                                                  headText: 'Residence Type',
                                                  dropDownMenuList: dropDownList,
                                                  onChanged: (newValue) {
                                                    for (var a in controller.residenceTypes!) {
                                                      if (a.description == newValue) {
                                                        selectedResidency = a.description;
                                                        residentialId = a.id;
                                                      }
                                                    }
                                                  });
                                          },
                                        ),
                                      ),
                                      SizedBox(width:providerState.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                            isIClicked: (){
                                              widget.isIButtonPressed();
                                              providerUpdate.setLinkAndPageNumber(
                                                  selectLink: Uri.parse(controller.demographicPatient!.facilityName.facilityNameLink).pathSegments.last,
                                                  pageNo: controller.demographicPatient!.facilityName.facilityNamePgNo,
                                                  isLinkeOpen:controller.demographicPatient!.facilityName.facilityNameLink );
                                            },
                                            isIconVisible :controller.demographicPatient!.facilityName.facilityNameLink.isEmpty ? true : false,
                                            controller: facilityNameController,
                                            labelText: 'Facility Name',
                                          )),
                                    ],
                                  ):
                                  Row(
                                    children: [
                                      Flexible(
                                        child: SchedularTextField(
                                          isIClicked: (){
                                            widget.isIButtonPressed();
                                            providerUpdate.setLinkAndPageNumber(
                                                selectLink: Uri.parse(controller.demographicPatient!.primaryContact.primaryContactLink).pathSegments.last,
                                                pageNo: controller.demographicPatient!.primaryContact.primaryContactPgNo,
                                                isLinkeOpen:controller.demographicPatient!.primaryContact.primaryContactLink );
                                          },
                                          isIconVisible :controller.demographicPatient!.primaryContact.primaryContactLink.isEmpty ? true : false,
                                          controller: ctlrPrimaryContact,
                                          labelText: 'Primary Contact*',
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                            isIClicked: (){
                                              widget.isIButtonPressed();
                                              providerUpdate.setLinkAndPageNumber(
                                                  selectLink: Uri.parse(controller.demographicPatient!.primaryContactName.primaryContactNameLink).pathSegments.last,
                                                  pageNo: controller.demographicPatient!.primaryContactName.primaryContactNamePgNo,
                                                  isLinkeOpen: controller.demographicPatient!.primaryContactName.primaryContactNameLink);
                                            },
                                            isIconVisible :controller.demographicPatient!.primaryContactName.primaryContactNameLink.isEmpty ? true : false,
                                            controller: primaryContactNameController,
                                            labelText: providerState.isContactTrue?'Primary Contact\nName*' :"Primary Contact Name*",
                                          )),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                              isIClicked: (){
                                                widget.isIButtonPressed();
                                                providerUpdate.setLinkAndPageNumber(
                                                    selectLink: Uri.parse(controller.demographicPatient!.primaryPhone.primaryPhoneLink).pathSegments.last,
                                                    pageNo: controller.demographicPatient!.primaryPhone.primaryPhonePgNo,
                                                    isLinkeOpen:controller.demographicPatient!.primaryPhone.primaryPhoneLink);
                                              },
                                              isIconVisible :controller.demographicPatient!.primaryPhone.primaryPhoneLink.isEmpty ? true : false,
                                              controller: ctlrPrimeNo,
                                              labelText: "Primary Phone #*",
                                              phoneField:true)),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                              isIClicked: (){
                                                widget.isIButtonPressed();
                                                providerUpdate.setLinkAndPageNumber(
                                                    selectLink: Uri.parse(controller.demographicPatient!.primaryEmail.primaryEmailLink).pathSegments.last,
                                                    pageNo: controller.demographicPatient!.primaryEmail.primaryEmailPgNo,
                                                    isLinkeOpen:controller.demographicPatient!.primaryEmail.primaryEmailLink);
                                              },
                                              isIconVisible :controller.demographicPatient!.primaryEmail.primaryEmailLink.isEmpty ? true : false,
                                              controller: ctlrEmail,
                                              labelText: "Primary Email")),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                              isIClicked: (){
                                                widget.isIButtonPressed();
                                                providerUpdate.setLinkAndPageNumber(
                                                    selectLink: Uri.parse(controller.demographicPatient!.cahpsContact.cahpsContactLink).pathSegments.last,
                                                    pageNo: controller.demographicPatient!.cahpsContact.cahpsContactPgNo,
                                                    isLinkeOpen:controller.demographicPatient!.cahpsContact.cahpsContactLink );
                                              },
                                              isIconVisible :controller.demographicPatient!.cahpsContact.cahpsContactLink.isEmpty ? true : false,
                                              controller: cahpsContactController,
                                              labelText: "CAHPS Contact")),


                                    ],
                                  ),
                                  const SizedBox(height: AppSize.s16),
                                  providerState.isContactTrue ?  Row(
                                    children: [
                                      Flexible(
                                        child: Builder(
                                          builder: (context) {
                                            if (controller.zones == null) {
                                              return SchedularTextField(
                                                  controller: zoneController, labelText: 'Zone*');
                                            }
                                              List<DropdownMenuItem<String>> dropDownList = [];
                                              for (var i in controller.zones!) {
                                                dropDownList.add(DropdownMenuItem<String>(
                                                  child: Text(i.zoneName!),
                                                  value: i.zoneName,
                                                ));

                                              }

                                              return CustomDropdownTextFieldsm(
                                                  initialValue: selectedZone,
                                                  headText: 'Zone*',
                                                  dropDownMenuList: dropDownList,
                                                  onChanged: (newValue) {
                                                    for (var a in controller.zones!) {
                                                      if (a.zoneName == newValue) {
                                                        zoneId = a.zoneID!;
                                                        selectedZone = a.zoneName!;
                                                      }
                                                    }
                                                  });
                                          },
                                        ),
                                      ),
                                      SizedBox(width: providerState.isLeftSidebarOpen ?  AppSize.s70 : AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                            isIClicked: (){
                                              widget.isIButtonPressed();
                                              providerUpdate.setLinkAndPageNumber(
                                                  selectLink: Uri.parse(controller.demographicPatient!.locationNotes.locationNotesLink).pathSegments.last,
                                                  pageNo: controller.demographicPatient!.locationNotes.locationNotesPgNo,
                                                  isLinkeOpen: controller.demographicPatient!.locationNotes.locationNotesLink);
                                            },
                                            isIconVisible :controller.demographicPatient!.locationNotes.locationNotesLink.isEmpty ? true : false,
                                            controller: locationNotesController,
                                            labelText: 'Location Notes',
                                          )),
                                      SizedBox(width: providerState.isLeftSidebarOpen ?  AppSize.s70 : AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          isIClicked: (){
                                            widget.isIButtonPressed();
                                            providerUpdate.setLinkAndPageNumber(
                                                selectLink: Uri.parse(controller.demographicPatient!.primaryContact.primaryContactLink).pathSegments.last,
                                                pageNo: controller.demographicPatient!.primaryContact.primaryContactPgNo,
                                                isLinkeOpen: controller.demographicPatient!.primaryContact.primaryContactLink);
                                          },
                                          isIconVisible :controller.demographicPatient!.primaryContact.primaryContactLink.isEmpty ? true : false,
                                          controller: ctlrPrimaryContact,
                                          labelText: 'Primary Contact*',
                                        ),
                                      ),
                                    ],
                                  ):
                                  Row(
                                    children: [
                                      Flexible(
                                        child: SchedularTextField(
                                          isIClicked: (){
                                            widget.isIButtonPressed();
                                            providerUpdate.setLinkAndPageNumber(
                                                selectLink: Uri.parse(controller.demographicPatient!.secondaryContact.secondaryContactLink).pathSegments.last,
                                                pageNo: controller.demographicPatient!.secondaryContact.secondaryContactPgNo,
                                                isLinkeOpen: controller.demographicPatient!.secondaryContact.secondaryContactLink);
                                          },
                                          isIconVisible :controller.demographicPatient!.secondaryContact.secondaryContactLink.isEmpty ? true : false,
                                          controller: ctlrSecondContact,
                                          labelText: 'Secondary Contact*',
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                            isIClicked: (){
                                              widget.isIButtonPressed();
                                              providerUpdate.setLinkAndPageNumber(
                                                  selectLink: Uri.parse(controller.demographicPatient!.secondaryContactName.secondaryContactNameLink).pathSegments.last,
                                                  pageNo: controller.demographicPatient!.secondaryContactName.secondaryContactNamePgNo,
                                                  isLinkeOpen: controller.demographicPatient!.secondaryContactName.secondaryContactNameLink);
                                            },
                                            isIconVisible :controller.demographicPatient!.secondaryContactName.secondaryContactNameLink.isEmpty ? true : false,
                                            controller: secondaryPhoneController,
                                            labelText: "Secondary Contact Name",
                                          )),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                            isIClicked: (){
                                              widget.isIButtonPressed();
                                              providerUpdate.setLinkAndPageNumber(
                                                  selectLink: Uri.parse(controller.demographicPatient!.secondaryPhone.secondaryPhoneLink).pathSegments.last,
                                                  pageNo: controller.demographicPatient!.secondaryPhone.secondaryPhonePgNo,
                                                  isLinkeOpen: controller.demographicPatient!.secondaryPhone.secondaryPhoneLink);
                                            },
                                            isIconVisible :controller.demographicPatient!.secondaryPhone.secondaryPhoneLink.isEmpty ? true : false,
                                            controller: ctlrSecNo,
                                            phoneField: true,
                                            labelText: "Secondary Phone #*",
                                          )),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                            isIClicked: (){
                                              widget.isIButtonPressed();
                                              providerUpdate.setLinkAndPageNumber(
                                                  selectLink: Uri.parse(controller.demographicPatient!.secondaryEmail.secondaryEmailLink).pathSegments.last,
                                                  pageNo: controller.demographicPatient!.secondaryEmail.secondaryEmailPgNo,
                                                  isLinkeOpen: controller.demographicPatient!.secondaryEmail.secondaryEmailLink);
                                            },
                                            isIconVisible :controller.demographicPatient!.secondaryEmail.secondaryEmailLink.isEmpty ? true : false,
                                            controller: secEmailController,
                                            labelText: "Secondary Email",
                                          )),
                                      const SizedBox(width: AppSize.s35),
                                      const Flexible(
                                          child: SizedBox(width:0)),

                                    ],
                                  ),
                                  const SizedBox(height: AppSize.s16),
                                  providerState.isContactTrue ? Row(
                                    children: [
                                      Flexible(
                                          child: SchedularTextField(
                                            isIClicked: (){
                                              widget.isIButtonPressed();
                                              providerUpdate.setLinkAndPageNumber(
                                                  selectLink: Uri.parse(controller.demographicPatient!.primaryContactName.primaryContactNameLink).pathSegments.last,
                                                  pageNo: controller.demographicPatient!.primaryContactName.primaryContactNamePgNo,
                                                  isLinkeOpen:controller.demographicPatient!.primaryContactName.primaryContactNameLink );
                                            },
                                            isIconVisible :controller.demographicPatient!.primaryContactName.primaryContactNameLink.isEmpty ? true : false,
                                            controller: primaryContactNameController,
                                            labelText: "Primary Contact Name*",
                                          )),
                                      SizedBox(width: providerState.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                              isIClicked: (){
                                                widget.isIButtonPressed();
                                                providerUpdate.setLinkAndPageNumber(
                                                    selectLink: Uri.parse(controller.demographicPatient!.primaryPhone.primaryPhoneLink).pathSegments.last,
                                                    pageNo: controller.demographicPatient!.primaryPhone.primaryPhonePgNo,
                                                    isLinkeOpen: controller.demographicPatient!.primaryPhone.primaryPhoneLink);
                                              },
                                              isIconVisible :controller.demographicPatient!.primaryPhone.primaryPhoneLink.isEmpty ? true : false,
                                              controller: ctlrPrimeNo,
                                              labelText: "Primary Phone #*",
                                              phoneField:true)),
                                      SizedBox(width:providerState.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                              isIClicked: (){
                                                widget.isIButtonPressed();
                                                providerUpdate.setLinkAndPageNumber(
                                                    selectLink: Uri.parse(controller.demographicPatient!.primaryEmail.primaryEmailLink).pathSegments.last,
                                                    pageNo: controller.demographicPatient!.primaryEmail.primaryEmailPgNo,
                                                    isLinkeOpen: controller.demographicPatient!.primaryEmail.primaryEmailLink);
                                              },
                                              isIconVisible :controller.demographicPatient!.primaryEmail.primaryEmailLink.isEmpty ? true : false,
                                              controller: ctlrEmail,
                                              labelText: "Primary Email")),
                                    ],
                                  ):const Offstage(),
                                  const SizedBox(height: AppSize.s16),
                                  providerState.isContactTrue ? Row(
                                    children: [
                                      Flexible(
                                          child: SchedularTextField(
                                              isIClicked: (){
                                                widget.isIButtonPressed();
                                                providerUpdate.setLinkAndPageNumber(
                                                    selectLink: Uri.parse(controller.demographicPatient!.cahpsContact.cahpsContactLink).pathSegments.last,
                                                    pageNo: controller.demographicPatient!.cahpsContact.cahpsContactPgNo,
                                                    isLinkeOpen: controller.demographicPatient!.cahpsContact.cahpsContactLink);
                                              },
                                              isIconVisible :controller.demographicPatient!.cahpsContact.cahpsContactLink.isEmpty ? true : false,
                                              controller: cahpsContactController,
                                              labelText: "CAHPS Contact")),
                                      SizedBox(width: providerState.isLeftSidebarOpen ?  AppSize.s70 : AppSize.s35),
                                      Flexible(
                                        child:  SchedularTextField(
                                          isIClicked: (){
                                            widget.isIButtonPressed();
                                            providerUpdate.setLinkAndPageNumber(
                                                selectLink: Uri.parse(controller.demographicPatient!.secondaryContact.secondaryContactLink).pathSegments.last,
                                                pageNo: controller.demographicPatient!.secondaryContact.secondaryContactPgNo,
                                                isLinkeOpen: controller.demographicPatient!.secondaryContact.secondaryContactLink);
                                          },
                                          isIconVisible :controller.demographicPatient!.secondaryContact.secondaryContactLink.isEmpty ? true : false,
                                          controller: ctlrSecondContact,
                                          labelText: 'Secondary Contact*',
                                        ),
                                      ),
                                      SizedBox(width:providerState.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                            isIClicked: (){
                                              widget.isIButtonPressed();
                                              providerUpdate.setLinkAndPageNumber(
                                                  selectLink: Uri.parse(controller.demographicPatient!.secondaryContactName.secondaryContactNameLink).pathSegments.last,
                                                  pageNo: controller.demographicPatient!.secondaryContactName.secondaryContactNamePgNo,
                                              isLinkeOpen:controller.demographicPatient!.secondaryContactName.secondaryContactNameLink );
                                            },
                                            isIconVisible :controller.demographicPatient!.secondaryContactName.secondaryContactNameLink.isEmpty ? true : false,
                                            controller: secondaryPhoneController,
                                            labelText: "Secondary Contact Name",
                                          )),
                                    ],
                                  ):const Offstage(),
                                  const SizedBox(height: AppSize.s16),
                                  providerState.isContactTrue ? Row(
                                    children: [
                                      Flexible(
                                          child: SchedularTextField(
                                            isIClicked: (){
                                              widget.isIButtonPressed();
                                              providerUpdate.setLinkAndPageNumber(
                                                  selectLink: Uri.parse(controller.demographicPatient!.secondaryPhone.secondaryPhoneLink).pathSegments.last,
                                                  pageNo: controller.demographicPatient!.secondaryPhone.secondaryPhonePgNo,
                                              isLinkeOpen: controller.demographicPatient!.secondaryPhone.secondaryPhoneLink);
                                            },
                                            isIconVisible :controller.demographicPatient!.secondaryPhone.secondaryPhoneLink.isEmpty ? true : false,
                                            controller: ctlrSecNo,
                                            phoneField: true,
                                            labelText: "Secondary Phone #*",
                                          )),
                                      SizedBox(width:providerState.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
                                      Flexible(
                                          child: SchedularTextField(
                                            isIClicked: (){
                                              widget.isIButtonPressed();
                                              providerUpdate.setLinkAndPageNumber(
                                                  selectLink: Uri.parse(controller.demographicPatient!.secondaryEmail.secondaryEmailLink).pathSegments.last,
                                                  pageNo: controller.demographicPatient!.secondaryEmail.secondaryEmailPgNo,
                                                  isLinkeOpen: controller.demographicPatient!.secondaryEmail.secondaryEmailLink);
                                            },
                                            isIconVisible :controller.demographicPatient!.secondaryEmail.secondaryEmailLink.isEmpty ? true : false,
                                            controller: secEmailController,
                                            labelText: "Secondary Email",
                                          )),
                                      SizedBox(width: providerState.isLeftSidebarOpen ?  AppSize.s70 : AppSize.s35),
                                      const Flexible(
                                          child: SizedBox(width:0)),
                                    ],
                                  ):const Offstage(),
                                ],
                              ),
                            ),),
                        ),



                        const SizedBox(height: AppSize.s40),
                         Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: BlueBGHeadConst(HeadText: "Additional Information",
                          body: IntakeFlowContainerConst(
                              height: AppSize.s180,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                            child: SchedularTextField(
                                              dateFormateMMDDYYYY: true,
                                                controller: ctlrDate,
                                                labelText: 'Date of Birth*',
                                                showDatePicker:true,
                                              isDOB: true,
                                            )),
                                        SizedBox(width: providerState.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
                                        Flexible(
                                          child: Builder(
                                            builder: (context) {
                                              if (controller.genders == null) {
                                                return SchedularTextField(
                                                  controller: genderController,
                                                  labelText: 'Gender*',
                                                );
                                              }
                                                List<DropdownMenuItem<String>> dropDownList = [];
                                                for (var i in controller.genders!) {
                                                  dropDownList.add(DropdownMenuItem<String>(
                                                    child: Text(i.gender!),
                                                    value: i.gender,
                                                  ));
                                                }
                                                return CustomDropdownSmallBoxSm(
                                                    initialValue: selectedGender,
                                                    headText: 'Gender*',
                                                    dropDownMenuList: dropDownList,
                                                    onChanged: (newValue) {
                                                      for (var a in controller.genders!) {
                                                        if (a.gender == newValue) {
                                                          selectedGender = a.gender!;
                                                          genderId = a.genderId;
                                                        }
                                                      }
                                                    });
                                            },
                                          ),),
                                        SizedBox(width:providerState.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
                                        Flexible(
                                          child: Builder(
                                            builder: (context) {
                                              if (controller.languagesSpoken == null) {
                                                return SchedularTextField(
                                                  controller: primaryLanguageController,
                                                  labelText: 'Primary Language',
                                                );
                                              }
                                                List<DropdownMenuItem<String>> dropDownList = [];
                                                for (var i in controller.languagesSpoken!) {
                                                  dropDownList.add(DropdownMenuItem<String>(
                                                    child: Text(i.languageSpoken!),
                                                    value: i.languageSpoken,
                                                  ));
                                                }

                                                return CustomDropdownSmallBoxSm(
                                                    initialValue: selectedLanguage,
                                                    headText: 'Primary Language',
                                                    dropDownMenuList: dropDownList,
                                                    onChanged: (newValue) {
                                                      for (var a in controller.languagesSpoken!) {
                                                        if (a.languageSpoken == newValue) {
                                                          selectedLanguage = a.languageSpoken!;
                                                          primaryLanguageid = a.languageSpokenId;
                                                        }
                                                      }
                                                    });
                                            },
                                          ),),
                                        providerState.isContactTrue ? const Offstage():  const SizedBox(width: AppSize.s35),
                                        providerState.isContactTrue ? const Offstage() :const Flexible(
                                            child: SizedBox(width:0)),
                                        providerState.isContactTrue ? const Offstage() : const SizedBox(width: AppSize.s35),
                                        providerState.isContactTrue ? const Offstage() :const Flexible(
                                            child: SizedBox(width:0)),
                                      ],
                                    ),
                                    const SizedBox(height: AppSize.s16),
                                    Row(
                                      children: [
                                        Flexible(
                                            child: SchedularTextField(
                                              allowSSNBR: true,
                                              isIClicked: (){
                                                widget.isIButtonPressed();
                                                providerUpdate.setLinkAndPageNumber(
                                                    selectLink: Uri.parse(controller.demographicPatient!.socialSecurity.socialSecurityLink).pathSegments.last,
                                                    pageNo: controller.demographicPatient!.socialSecurity.socialSecurityPgNo,
                                                isLinkeOpen:controller.demographicPatient!.socialSecurity.socialSecurityLink );
                                              },
                                              isIconVisible :controller.demographicPatient!.socialSecurity.socialSecurityLink.isEmpty ? true : false,
                                              controller: ctlrSocialSec,
                                              labelText: 'Social Security',
                                              isPasswordField: true,
                                            )),
                                        SizedBox(width:providerState.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
                                        Flexible(
                                          child: Builder(
                                            builder: (context) {
                                              if (controller.races == null) {
                                                return SchedularTextField(
                                                  controller: raceController,
                                                  labelText: 'Race/Ethnicity',
                                                );
                                              }
                                                List<DropdownMenuItem<String>> dropDownList = [];
                                                for (var i in controller.races!) {
                                                  dropDownList.add(DropdownMenuItem<String>(
                                                    child: Text(i.raceName),
                                                    value: i.raceName,
                                                  ));
                                                }
                                                return CustomDropdownSmallBoxSm(
                                                    initialValue: selectedRace,
                                                    headText: 'Race/Ethnicity',
                                                    dropDownMenuList: dropDownList,
                                                    onChanged: (newValue) {
                                                      for (var a in controller.races!) {
                                                        if (a.raceName == newValue) {
                                                          selectedRace = a.raceName!;
                                                          raceId = a.raceId;
                                                        }
                                                      }
                                                    });
                                            },
                                          ),),
                                        SizedBox(width: providerState.isLeftSidebarOpen ?  AppSize.s70 : AppSize.s35),
                                        Flexible(
                                          child: Builder(
                                            builder: (context) {
                                              if (controller.maritalStatuses == null) {
                                                return SchedularTextField(
                                                  controller: maritalStatusController,
                                                  labelText: 'Marital Status',
                                                );
                                              }
                                                List<DropdownMenuItem<String>> dropDownList = [];
                                                for (var i in controller.maritalStatuses!) {
                                                  dropDownList.add(DropdownMenuItem<String>(
                                                    child: Text(i.maritalStatus),
                                                    value: i.maritalStatus,
                                                  ));
                                                }
                                                return CustomDropdownSmallBoxSm(
                                                    initialValue: selectedMaritalStatus,
                                                    headText: 'Marital Status',
                                                    dropDownMenuList: dropDownList,
                                                    onChanged: (newValue) {
                                                      for (var a in controller.maritalStatuses!) {
                                                        if (a.maritalStatus == newValue) {
                                                          selectedMaritalStatus = a.maritalStatus!;
                                                          maritalStatusId = a.maritalStatusId;
                                                        }
                                                      }
                                                    });
                                            },
                                          ),),
                                        providerState.isContactTrue ? const Offstage():  const SizedBox(width: AppSize.s35),
                                        providerState.isContactTrue ? const Offstage() :const Flexible(
                                            child: SizedBox(width:0)),
                                        providerState.isContactTrue ? const Offstage() : const SizedBox(width: AppSize.s35),
                                        providerState.isContactTrue ? const Offstage() :const Flexible(
                                            child: SizedBox(width:0)),
                                      ],
                                    ),
                                  ],
                                ),
                              ) ),),
                        ),

                        const SizedBox(height: AppSize.s10),
                        StatefulBuilder(
                            builder: (BuildContext context, void Function(void Function()) setState) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 10,
                            children: [
                              SkipButtonTransparent(
                                width: AppSize.s110,
                                text: "Skip",
                                onPressed: () {
                                  print("🔹 Skip button tapped - going to documentation screen");
                                  widget.onSkip();
                                },
                              ),
                              CustomElevatedButton(
                                width: AppSize.s110,
                                text: AppString.save,
                                isLoading: isLoading,
                                onPressed: ()async{
                                  print('Demo id ${controller.demographicPatient!.demoId}');
                                  // assuming ctlrDate.text = "09/16/2025" (MM/DD/YYYY)
                                  final parts = ctlrDate.text.split('/'); // [MM, DD, YYYY]
                                  final formattedDate = "${parts[2]}-${parts[0].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}T00:00:00.000Z";

                                  print('Street ::;${providerState.ctlrStreetProvider.text}');
                                  print('City :::;${providerState.ctlrCityProvider.text}');
                                  print('state ::::${providerState.ctlrStateProvider.text}');
                                  print('''
Patient Demo Data:
demoId: ${controller.demographicPatient!.demoId}
fk_pt_id: ${controller.demographicPatient!.fkPtId}
demoFirstName: ${ctlrfirstName.text}
demoMiddleInitial: ${ctlrMedicalRecord.text}
demoLastName: ${ctlrLastName.text}
demoSuffix: ${ctlrSuffix.text}
demoStreet: ${providerState.ctlrStreetProvider.text.isEmpty ? ctlrStreet.text : providerState.ctlrStreetProvider.text}
demoSuite: ${ctlrSuitApt.text}
demoCity: ${providerState.ctlrCityProvider.text.isEmpty ? ctlrCity.text : providerState.ctlrCityProvider.text}
demoState: ${providerState.ctlrStateProvider.text.isEmpty ? ctlrState.text : providerState.ctlrStateProvider.text}
demoZipcode: ${ctlrZipCode.text}
fkCountryId: $countyId
fkResidenceTypeId: $residentialId
demoFacilityName: ${facilityNameController.text}
fkZoneId: $zoneId
demoLocationNotes: ${locationNotesController.text}
demoPrimaryContact: ${ctlrPrimaryContact.text}
demoPrimaryContactName: ${primaryContactNameController.text}
demoPrimaryPhone: ${ctlrPrimeNo.text}
demoPrimaryEmail: ${ctlrEmail.text}
demoCahpsContact: ${cahpsContactController.text}
demoSecondaryContact: ${ctlrSecondContact.text}
demoSecondaryContactName: ${secondaryPhoneController.text}
demoSecondaryPhone: ${ctlrSecNo.text}
demoSecondaryEmail: ${secEmailController.text}
demoDob: $formattedDate
fkGender: $genderId
fkSpokenLanguage: $primaryLanguageid
demoSocialSecurity: ${ctlrSocialSec.text}
fkRaceEthnicity: $raceId
fkMaritalStatus: $maritalStatusId
''');


                                  try{
                                    setState(() {
                                      isLoading = true;
                                    });
                                    var responseUpdate = await patchPatientIntakeDemographich(
                                      context: context,
                                      demoId: controller.demographicPatient!.demoId,
                                      fk_pt_id: controller.demographicPatient!.fkPtId,
                                      demoFirstName: ctlrfirstName.text,
                                      demoMiddleInitial: ctlrMedicalRecord.text,
                                      demoLastName: ctlrLastName.text,
                                      demoSuffix: ctlrSuffix.text,
                                      demoStreet: providerState.ctlrStreetProvider.text.isEmpty ? ctlrStreet.text : providerState.ctlrStreetProvider.text,
                                      demoSuite: ctlrSuitApt.text,
                                      demoCity: providerState.ctlrCityProvider.text.isEmpty ? ctlrCity.text : providerState.ctlrCityProvider.text,
                                      demoState: providerState.ctlrStateProvider.text.isEmpty ? ctlrState.text : providerState.ctlrStateProvider.text,
                                      demoZipcode: ctlrZipCode.text,
                                      fkCountryId: countyId,
                                      fkResidenceTypeId: residentialId,
                                      demoFacilityName: facilityNameController.text,
                                      fkZoneId: zoneId,
                                      demoLocationNotes: locationNotesController.text,
                                      demoPrimaryContact: ctlrPrimaryContact.text,
                                      demoPrimaryContactName: primaryContactNameController.text,
                                      demoPrimaryPhone: ctlrPrimeNo.text,
                                      demoPrimaryEmail: ctlrEmail.text,
                                      demoCahpsContact: cahpsContactController.text,
                                      demoSecondaryContact: ctlrSecondContact.text,
                                      demoSecondaryContactName: secondaryPhoneController.text,
                                      demoSecondaryPhone: ctlrSecNo.text,
                                      demoSecondaryEmail: secEmailController.text,
                                      demoDob: formattedDate,
                                      fkGender: genderId,// pass dynamic id
                                      fkSpokenLanguage: primaryLanguageid,
                                      demoSocialSecurity: ctlrSocialSec.text,
                                      fkRaceEthnicity: raceId, // pass dynamic id
                                      fkMaritalStatus: maritalStatusId,
                                    );
                                    if(responseUpdate.statusCode == 200 || responseUpdate.statusCode == 201){
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return const AddSuccessPopup(
                                            message: 'Patient Info Updated Successfully',
                                          );
                                        },
                                      );
                                    }else{
                                      showDialog(
                                        context: context,
                                        builder: (_) => const AddErrorPopup(
                                          message: 'Please Check Your Input And Try Again',
                                        ),
                                      );
                                      print('API status code: ${responseUpdate.statusCode}');
                                      print('API error: ${responseUpdate.message}');
                                      print('Please check your input and try again');

                                    }
                                  }finally{
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                              ),
                            ],
                          );}
                        ),
                        const SizedBox(height: AppSize.s30),
                      ],
                    ),
                  ),

              );
            }
          );
        }

    return Scaffold(
      backgroundColor: ColorManager.white,
      body: bodyContent,
    );
  }
}
