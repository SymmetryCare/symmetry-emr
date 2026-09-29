import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/provider/async_data_controller.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/patient_insurance_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/sm_intake_manager/intake_demographics/intake_demographic_dropdown_manager.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/scheduler_create_data/create_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/patient_insurance_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/patient_insurances_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_employee_documents/widgets/radio_button_tile_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/onboarding/download_doc_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/schedular_textfield_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/dropdown_constant_sm.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_flow_contgainer_const.dart';

class IntakeSecondaryScreen extends StatelessWidget {
  final int patientId;
  final VoidCallback onSave;
  final VoidCallback isIButtonPressed;
  final VoidCallback onSkip;
  const IntakeSecondaryScreen({super.key,
    required this.patientId, required this.onSave,
    required this.isIButtonPressed, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
    return ChangeNotifierProvider<AsyncDataController<List<PatientInsuranceInfoData>>>(
      create: (ctx) => AsyncDataController<List<PatientInsuranceInfoData>>()
        ..load(() => getPatientInsuranceinfo(context: ctx, ptId: diagnosisProvider.patientId)),
      child: _IntakeSecondaryScreenBody(
        patientId: patientId,
        onSave: onSave,
        isIButtonPressed: isIButtonPressed,
        onSkip: onSkip,
      ),
    );
  }
}

class _IntakeSecondaryScreenBody extends StatefulWidget {
  final int patientId;
  final VoidCallback onSave;
  final VoidCallback isIButtonPressed;
  final VoidCallback onSkip;
  const _IntakeSecondaryScreenBody({
    required this.patientId, required this.onSave,
    required this.isIButtonPressed, required this.onSkip,
  });

  @override
  State<_IntakeSecondaryScreenBody> createState() => _IntakeSecondaryScreenBodyState();
}

class _IntakeSecondaryScreenBodyState extends State<_IntakeSecondaryScreenBody> {
  // FIX: hoisted out of build() — a build()-local bool gets a brand new
  // instance (reset to false) on every rebuild. Any rebuild triggered while
  // an async save/delete was in flight (e.g. by an unrelated Consumer
  // notifying) orphaned the in-flight closure's copy from what was actually
  // on screen, which is how the Save/Delete button's spinner could get
  // stuck showing a state nothing was updating anymore.
  // FIX: split into two flags — this one used to be shared by both the
  // Delete popup and the Save button, so deleting a document also lit up
  // Save's spinner (they're independent actions and shouldn't visually
  // block each other).
  bool _isDeletingDoc = false;
  bool _isLoading = false;
  // FIX: guards the one-time re-fetch in build() — see its comment.
  bool _hasReloadedInsuranceDoc = false;
  // AIRefPatientInsurance? fetchedData;
  // var data;
  // Future<void> fetchAIRefInsurance() async{
  //   final providerPatientId = Provider.of<DiagnosisProvider>(context,listen: false);
  //   data = await getSingleAIRefPatientInsurance(context: context, ptId: providerPatientId.patientId);
  //   // notifyListeners();
  //   setState(() {
  //     fetchedData = data;
  //   });
  //   // fetchedData = data;
  // }
  TextEditingController pharmaSelectDB = TextEditingController();
  TextEditingController pharmaName = TextEditingController();
  TextEditingController pharmaphone = TextEditingController();
  TextEditingController pharmaType = TextEditingController();
  TextEditingController pharmaCategory = TextEditingController();
  TextEditingController pharmaSuitApt = TextEditingController();
  TextEditingController pharmacyaddress = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController pharmacyzipcode = TextEditingController();
  TextEditingController pharmaPolicyHicNo = TextEditingController();
  TextEditingController pharmaGrpName = TextEditingController();
  TextEditingController pharmaGrpNo = TextEditingController();
  TextEditingController pharmaEmail = TextEditingController();
  TextEditingController pharmaAuth = TextEditingController();
  TextEditingController pharmaEftDateForm = TextEditingController();
  TextEditingController pharmaEftDateFormTo = TextEditingController();
  TextEditingController pharmacycontactsecond = TextEditingController();
  TextEditingController dummyCtrl = TextEditingController();
  TextEditingController effectivefromController = TextEditingController();
  TextEditingController effectivetoController = TextEditingController();
  TextEditingController authorizze1 = TextEditingController();
  TextEditingController authorize2 = TextEditingController();

  // FIX: Hoisted to a field (was being recreated on every build()) and
  // populated once so the StreamBuilder below isn't re-fetching on every rebuild.
  final StreamController<List<PatientInsuranceDocumentData>> _streamControllerDoc = StreamController<List<PatientInsuranceDocumentData>>.broadcast();

  // FIX: rptiEffectiveFrom/rptiEffectiveTo were being sent to
  // updatePatientInsuranceInfo as raw date-picker display text, which
  // caused the backend to reject the PATCH with a 400. Convert to UTC
  // ISO-8601 before sending, matching this project's date-handling
  // convention. Handles both "MM/DD/YYYY" and ISO "YYYY-MM-DD" input so
  // it's safe regardless of what format the picker or preloaded API data
  // (rptiEffectiveFrom/rptiEffectiveTo) hands back.
  DateTime _parseFlexibleDate(String dateStr) {
    final trimmed = dateStr.trim();
    if (trimmed.contains('/')) {
      final parts = trimmed.split('/'); // [MM, DD, YYYY]
      if (parts.length != 3) {
        throw FormatException('Invalid date format: $dateStr');
      }
      return DateTime(int.parse(parts[2]), int.parse(parts[0]), int.parse(parts[1]));
    } else if (trimmed.contains('-')) {
      final parts = trimmed.split('-'); // [YYYY, MM, DD]
      if (parts.length != 3) {
        throw FormatException('Invalid date format: $dateStr');
      }
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    }
    throw FormatException('Invalid date format: $dateStr');
  }

  String _toIsoDateOrEmpty(String dateStr) {
    if (dateStr.trim().isEmpty) return '';
    return _parseFlexibleDate(dateStr).toUtc().toIso8601String();
  }

  void _loadInsuranceDoc() {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
    getPatientEmergencyContact(context: context,
        ptId: diagnosisProvider.patientId,
        isPrimary: false).then((data) {
      _streamControllerDoc.add(data);
    }).catchError((error) {
      // Handle error
    });
  }

  @override
  void initState() {
    super.initState();
    _loadInsuranceDoc();
  }

  @override
  void dispose() {
    _streamControllerDoc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);

    String? statustype;
    String? dmeSupplies;
    String? pharmacydd;
    String? pharmacystate;
    String? pharmacycity;
    return Consumer<AsyncDataController<List<PatientInsuranceInfoData>>>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return Center(
                child: CircularProgressIndicator(color: ColorManager.blueprime,)
            );
          }
          // FIX: the Attachments section's StreamBuilder (further down this
          // same builder) only exists once we get past the controller.isLoading
          // check above. _loadInsuranceDoc() was fired from initState() in
          // parallel with this controller's own fetch — if it (the doc fetch)
          // won that race and resolved first, it added its one-and-only event
          // to a broadcast stream that had no listener yet (this whole
          // subtree, including the StreamBuilder, hadn't been built), and that
          // event was silently dropped. Re-fetching once we know the
          // StreamBuilder is about to actually mount guarantees it's listening
          // in time.
          if (!_hasReloadedInsuranceDoc) {
            _hasReloadedInsuranceDoc = true;
            _loadInsuranceDoc();
          }
          return Consumer<SmIntakeProviderManager>(
              builder: (context,providerState,child) {
                return Center(
                  child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Padding(
                          //   padding: const EdgeInsets.only(right: 35.0,bottom: 10),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.end,
                          //     children: [
                          //       CustomIconButtonConst(
                          //           width: AppSize.s190,
                          //           text: 'Add Tertiary Insurance',
                          //           icon: Icons.add,
                          //           onPressed: () {
                          //
                          //           }),
                          //     ],
                          //   ),
                          // ),
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
                                          // fontSize: FontSize.s14,
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
                            child: BlueBGHeadConst(HeadText: "Policy Details",
                              body:  Container(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: controller.data!.isEmpty ? 1:controller.data!.length - 1,
                                    itemBuilder: (context,index) {
                                      // final item = controller.data![index + 1];
                                      // print('rptiId ${controller.data![index].rptiId.toInt()}');
                                      pharmaSelectDB = TextEditingController(text: pharmaSelectDB.text.isEmpty ? controller.data!.isEmpty?'':controller.data![index + 1].policy.rptiPolicy : pharmaSelectDB.text);
                                      pharmaName = TextEditingController(text:pharmaName.text.isEmpty ? controller.data!.isEmpty?'':controller.data![index + 1].insuranceProvider.rptiInsuranceProvider : pharmaName.text);
                                      pharmaType = TextEditingController(text: pharmaType.text.isEmpty ? controller.data!.isEmpty?'': controller.data![index + 1].insurancePlan.rptiInsurancePlan : pharmaType.text);
                                      pharmaCategory = TextEditingController(text:pharmaCategory.text.isEmpty ? controller.data!.isEmpty?'': controller.data![index + 1].category.rptiCategory : pharmaCategory.text);
                                      pharmacyaddress = TextEditingController(text: providerState.ctlrStreetInsuranceSecondProvider.text.isEmpty ?controller.data!.isEmpty?'':  controller.data![index + 1].street.rptiStreet : providerState.ctlrStreetInsuranceSecondProvider.text);
                                      pharmaSuitApt = TextEditingController(text:pharmaSuitApt.text.isEmpty ? controller.data!.isEmpty?'':  controller.data![index + 1].suite.rptiSuite : pharmaSuitApt.text);
                                      city = TextEditingController(text:providerState.ctlrCityInsuranceSecondProvider.text.isEmpty ?controller.data!.isEmpty?'': controller.data![index + 1].city.rptiCity : providerState.ctlrCityInsuranceSecondProvider.text);
                                      state = TextEditingController(text:providerState.ctlrStateInsuranceSecondProvider.text.isEmpty ?controller.data!.isEmpty?'':  controller.data![index + 1].state.rptiState : providerState.ctlrStateInsuranceSecondProvider.text);
                                      pharmacyzipcode = TextEditingController(text:pharmacyzipcode.text.isEmpty ? controller.data!.isEmpty?'': controller.data![index + 1].zipcode.rptiZipcode : pharmacyzipcode.text);
                                      pharmaphone =  TextEditingController(text:pharmaphone.text.isEmpty ? controller.data!.isEmpty?'':controller.data![index + 1].contact.rptiContact : pharmaphone.text);
                                      pharmaAuth = TextEditingController(text:controller.data!.isEmpty?'':  controller.data![index + 1].rptiAuthorization ? 'NOT REQUIRED' : 'REQUIRED');
                                      pharmaEftDateForm = TextEditingController(text: pharmaEftDateForm.text.isEmpty ? controller.data!.isEmpty?'': controller.data![index + 1].rptiEffectiveFrom : pharmaEftDateForm.text);
                                      pharmaEftDateFormTo = TextEditingController(text: pharmaEftDateFormTo.text.isEmpty ? controller.data!.isEmpty?'':controller.data![index + 1].rptiEffectiveTo : pharmaEftDateFormTo.text);
                                      pharmaPolicyHicNo = TextEditingController(text: pharmaPolicyHicNo.text.isEmpty ? controller.data!.isEmpty?'': controller.data![index + 1].policy.rptiPolicy : pharmaPolicyHicNo.text);
                                      pharmaGrpNo = TextEditingController(text: pharmaGrpNo.text.isEmpty ? controller.data!.isEmpty?'': controller.data![index + 1].groupNumber.rptiGroupNumber.toString() : pharmaGrpNo.text);
                                      pharmaGrpName = TextEditingController(text:pharmaGrpName.text.isEmpty ? controller.data!.isEmpty?'':  controller.data![index + 1].groupName.rptiGroupName : pharmaGrpName.text);
                                      pharmaEmail = TextEditingController(text: pharmaEmail.text.isEmpty ? controller.data!.isEmpty?'': controller.data![index + 1].email.rptiEmail : pharmaEmail.text);
                                      statustype = controller.data!.isEmpty?'': controller.data![index + 1].rptiVerified ? 'Yes' : 'No';
                                      return IntakeFlowContainerConst(
                                        height: providerState.isContactTrue ?AppSize.s550 :AppSize.s400,
                                        containerPadding: providerState.isContactTrue ? const EdgeInsets.only(left: AppPadding.p20, top: AppPadding.p30,bottom: AppPadding.p30) : null,
                                        //child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            providerState.isContactTrue ?   Row(
                                              children: [
                                                Flexible(
                                                  child: SchedularTextField(labelText: 'Policy Number',
                                                    isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].policy.rptiPolicyLink.isEmpty ? true : false,
                                                    isIClicked: (){
                                                      widget.isIButtonPressed();
                                                      providerState.setLinkAndPageNumber(
                                                          selectLink: Uri.parse(controller.data![index + 1].policy.rptiPolicyLink).pathSegments.last,
                                                          pageNo:controller.data![index + 1].policy.rptiPolicyPgNo,
                                                          isLinkeOpen: controller.data![index + 1].policy.rptiPolicyLink);
                                                    },
                                                    controller: pharmaSelectDB,
                                                    enable: true,
                                                  ),),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                        isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].insuranceProvider.rptiInsuranceProviderLink.isEmpty ? true : false,
                                                        isIClicked: (){
                                                          widget.isIButtonPressed();
                                                          providerState.setLinkAndPageNumber(
                                                              selectLink: Uri.parse(controller.data![index + 1].insuranceProvider.rptiInsuranceProviderLink).pathSegments.last,
                                                              pageNo:controller.data![index + 1].insuranceProvider.rptiInsuranceProviderPgNo,
                                                              isLinkeOpen: controller.data![index + 1].insuranceProvider.rptiInsuranceProviderLink);
                                                        },
                                                        controller: pharmaName, labelText: 'Name*')),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                      isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].insurancePlan.rptiInsurancePlanLink.isEmpty ? true : false,
                                                      isIClicked: (){
                                                        widget.isIButtonPressed();
                                                        providerState.setLinkAndPageNumber(
                                                            selectLink: Uri.parse(controller.data![index + 1].insurancePlan.rptiInsurancePlanLink).pathSegments.last,
                                                            pageNo:controller.data![index + 1].insurancePlan.rptiInsurancePlanPgNo,
                                                            isLinkeOpen: controller.data![index + 1].insurancePlan.rptiInsurancePlanLink);
                                                      },
                                                      controller: pharmaType,
                                                      labelText: 'Type*',
                                                    )),
                                              ],
                                            ) :
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: SchedularTextField(labelText: 'Policy Number',
                                                    isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].policy.rptiPolicyLink.isEmpty ? true : false,
                                                    isIClicked: (){
                                                      widget.isIButtonPressed();
                                                      providerState.setLinkAndPageNumber(
                                                          selectLink: Uri.parse(controller.data![index + 1].policy.rptiPolicyLink).pathSegments.last,
                                                          pageNo:controller.data![index + 1].policy.rptiPolicyPgNo,
                                                          isLinkeOpen: controller.data![index + 1].policy.rptiPolicyLink);
                                                    },
                                                    controller: pharmaSelectDB,
                                                    enable: true,
                                                  ),),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                        isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].insuranceProvider.rptiInsuranceProviderLink.isEmpty ? true : false,
                                                        isIClicked: (){
                                                          widget.isIButtonPressed();
                                                          providerState.setLinkAndPageNumber(
                                                              selectLink: Uri.parse(controller.data![index + 1].insuranceProvider.rptiInsuranceProviderLink).pathSegments.last,
                                                              pageNo:controller.data![index + 1].insuranceProvider.rptiInsuranceProviderPgNo,
                                                              isLinkeOpen: controller.data![index + 1].insuranceProvider.rptiInsuranceProviderLink);
                                                        },
                                                        controller: pharmaName, labelText: 'Name*')),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                      isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].insurancePlan.rptiInsurancePlanLink.isEmpty ? true : false,
                                                      isIClicked: (){
                                                        widget.isIButtonPressed();
                                                        providerState.setLinkAndPageNumber(
                                                            selectLink: Uri.parse(controller.data![index + 1].insurancePlan.rptiInsurancePlanLink).pathSegments.last,
                                                            pageNo:controller.data![index + 1].insurancePlan.rptiInsurancePlanPgNo,
                                                            isLinkeOpen: controller.data![index + 1].insurancePlan.rptiInsurancePlanLink);
                                                      },
                                                      controller: pharmaType,
                                                      labelText: 'Type*',
                                                    )),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                        isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].category.rptiCategoryLink.isEmpty ? true : false,
                                                        isIClicked: (){
                                                          widget.isIButtonPressed();
                                                          providerState.setLinkAndPageNumber(
                                                              selectLink: Uri.parse(controller
                                                                  .data![index + 1]
                                                                  .category
                                                                  .rptiCategoryLink).pathSegments.last,
                                                              pageNo:controller
                                                                  .data![index + 1]
                                                                  .category
                                                                  .rptiCategoryPgNo,
                                                              isLinkeOpen: controller
                                                                  .data![index + 1]
                                                                  .category
                                                                  .rptiCategoryLink);
                                                        },
                                                        controller: pharmaCategory, labelText: 'Category')),
                                                const SizedBox(width: AppSize.s35),
                                                const Flexible(
                                                    child: SizedBox()),
                                              ],
                                            ),
                                            const SizedBox(height: AppSize.s16),
                                            providerState.isContactTrue ?  Row(
                                              children: [
                                                Flexible(
                                                    child: SchedularTextField(
                                                        isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].category.rptiCategoryLink.isEmpty ? true : false,
                                                        isIClicked: (){
                                                          widget.isIButtonPressed();
                                                          providerState.setLinkAndPageNumber(
                                                              selectLink: Uri.parse(controller
                                                                  .data![index + 1]
                                                                  .category
                                                                  .rptiCategoryLink).pathSegments.last,
                                                              pageNo:controller
                                                                  .data![index + 1]
                                                                  .category
                                                                  .rptiCategoryPgNo,
                                                              isLinkeOpen: controller
                                                                  .data![index + 1]
                                                                  .category
                                                                  .rptiCategoryLink);
                                                        },
                                                        controller: pharmaCategory, labelText: 'Category')),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                        isIconClicked: true,
                                                        iconClickedPress:(){
                                                          providerState.openMapInsuranceSecondScreen(context: context);
                                                        },
                                                        isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].street.rptiStreetLink.isEmpty ? true : false,
                                                        isIClicked: (){
                                                          widget.isIButtonPressed();
                                                          providerState.setLinkAndPageNumber(
                                                              selectLink: Uri.parse(controller
                                                                  .data![index + 1]
                                                                  .street
                                                                  .rptiStreetLink).pathSegments.last,
                                                              pageNo:controller
                                                                  .data![index + 1]
                                                                  .street
                                                                  .rptiStreetPgNo,
                                                              isLinkeOpen:controller
                                                                  .data![index + 1]
                                                                  .street
                                                                  .rptiStreetLink );
                                                        },
                                                        controller: providerState.ctlrStreetInsuranceSecondProvider.text.isEmpty ? pharmacyaddress : providerState.ctlrStreetInsuranceSecondProvider,
                                                        icon: Icon(Icons.location_on_outlined, color: ColorManager.blueprime,size: IconSize.I18,),
                                                        labelText: 'Street*')),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                        isIconVisible: controller.data![index + 1] == null ? true :controller.data![index + 1].suite.rptiSuiteLink.isEmpty ? true : false,
                                                        isIClicked: (){
                                                          widget.isIButtonPressed();
                                                          providerState.setLinkAndPageNumber(
                                                              selectLink: Uri.parse(controller
                                                                  .data![index + 1]
                                                                  .suite
                                                                  .rptiSuiteLink).pathSegments.last,
                                                              pageNo:controller
                                                                  .data![index + 1]
                                                                  .suite
                                                                  .rptiSuitePgNo,
                                                              isLinkeOpen:controller
                                                                  .data![index + 1]
                                                                  .suite
                                                                  .rptiSuiteLink );
                                                        },
                                                        controller: pharmaSuitApt,
                                                        labelText: 'Suite/Apt#')),
                                              ],
                                            ):
                                            Row(
                                              children: [
                                                Flexible(
                                                    child: SchedularTextField(
                                                        isIconClicked: true,
                                                        iconClickedPress:(){
                                                          providerState.openMapInsuranceSecondScreen(context: context);
                                                        },
                                                        isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].street.rptiStreetLink.isEmpty ? true : false,
                                                        isIClicked: (){
                                                          widget.isIButtonPressed();
                                                          providerState.setLinkAndPageNumber(
                                                              selectLink: Uri.parse(controller
                                                                  .data![index + 1]
                                                                  .street
                                                                  .rptiStreetLink).pathSegments.last,
                                                              pageNo:controller
                                                                  .data![index + 1]
                                                                  .street
                                                                  .rptiStreetPgNo,
                                                              isLinkeOpen:controller
                                                                  .data![index + 1]
                                                                  .street
                                                                  .rptiStreetLink );
                                                        },
                                                        controller: providerState.ctlrStreetInsuranceSecondProvider.text.isEmpty ? pharmacyaddress : providerState.ctlrStreetInsuranceSecondProvider,
                                                        icon: Icon(Icons.location_on_outlined, color: ColorManager.blueprime,size: IconSize.I18,),
                                                        labelText: 'Street*')),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                        isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].suite.rptiSuiteLink.isEmpty ? true : false,
                                                        isIClicked: (){
                                                          widget.isIButtonPressed();
                                                          providerState.setLinkAndPageNumber(
                                                              selectLink: Uri.parse(controller
                                                                  .data![index + 1]
                                                                  .suite
                                                                  .rptiSuiteLink).pathSegments.last,
                                                              pageNo:controller
                                                                  .data![index + 1]
                                                                  .suite
                                                                  .rptiSuitePgNo,
                                                              isLinkeOpen:controller
                                                                  .data![index + 1]
                                                                  .suite
                                                                  .rptiSuiteLink );
                                                        },
                                                        controller: pharmaSuitApt,
                                                        labelText: 'Suite/Apt#')),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                  child: SchedularTextField(
                                                      isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].city.rptiCityLink.isEmpty ? true : false,
                                                      isIClicked: (){
                                                        widget.isIButtonPressed();
                                                        providerState.setLinkAndPageNumber(
                                                            selectLink: Uri.parse(controller.data![index + 1].city.rptiCityLink).pathSegments.last,
                                                            pageNo:controller.data![index + 1].city.rptiCityPgNo,
                                                            isLinkeOpen: controller.data![index + 1].city.rptiCityLink);
                                                      },
                                                      controller:providerState.ctlrCityInsuranceSecondProvider.text.isEmpty ? city : providerState.ctlrCityInsuranceSecondProvider, labelText: 'City*'),
                                                ),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child:  SchedularTextField(
                                                      isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].state.rptiStateLink.isEmpty ? true : false,
                                                      isIClicked: (){
                                                        widget.isIButtonPressed();
                                                        providerState.setLinkAndPageNumber(
                                                            selectLink: Uri.parse(controller.data![index + 1].state.rptiStateLink).pathSegments.last,
                                                            pageNo:controller.data![index + 1].state.rptiStatePgNo,
                                                            isLinkeOpen:controller.data![index + 1].state.rptiStateLink );
                                                      },
                                                      labelText: "State*",
                                                      controller: providerState.ctlrStateInsuranceSecondProvider.text.isEmpty ? state : providerState.ctlrStateInsuranceSecondProvider,
                                                    )
                                                ),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                        isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].zipcode.rptiZipcodeLink.isEmpty ? true : false,
                                                        isIClicked: (){
                                                          widget.isIButtonPressed();
                                                          providerState.setLinkAndPageNumber(
                                                              selectLink: Uri.parse(controller.data![index + 1].zipcode.rptiZipcodeLink).pathSegments.last,
                                                              pageNo:controller.data![index + 1].zipcode.rptiZipcodePgNo,
                                                              isLinkeOpen:controller.data![index + 1].zipcode.rptiZipcodeLink );
                                                        },
                                                        controller: pharmacyzipcode,
                                                        allowSSNBR: true,
                                                        // onlyAllowNumbers: true,
                                                        labelText: 'Zip Code*')),


                                              ],
                                            ),
                                            const SizedBox(height: AppSize.s16),
                                            providerState.isContactTrue ?    Row(
                                              children: [
                                                Flexible(
                                                  child: SchedularTextField(
                                                      isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].city.rptiCityLink.isEmpty ? true : false,
                                                      isIClicked: (){
                                                        widget.isIButtonPressed();
                                                        providerState.setLinkAndPageNumber(
                                                            selectLink: Uri.parse(controller.data![index + 1].city.rptiCityLink).pathSegments.last,
                                                            pageNo:controller.data![index + 1].city.rptiCityPgNo,
                                                            isLinkeOpen:controller.data![index + 1].city.rptiCityLink );
                                                      },
                                                      controller: providerState.ctlrCityInsuranceSecondProvider.text.isEmpty ? city : providerState.ctlrCityInsuranceSecondProvider, labelText: 'City*'),
                                                ),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child:  SchedularTextField(
                                                      isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].state.rptiStateLink.isEmpty ? true : false,
                                                      isIClicked: (){
                                                        widget.isIButtonPressed();
                                                        providerState.setLinkAndPageNumber(
                                                            selectLink: Uri.parse(controller.data![index + 1].state.rptiStateLink).pathSegments.last,
                                                            pageNo:controller.data![index + 1].state.rptiStatePgNo,
                                                            isLinkeOpen:controller.data![index + 1].state.rptiStateLink );
                                                      },
                                                      labelText: "State*",
                                                      controller: providerState.ctlrStateInsuranceSecondProvider.text.isEmpty ? state : providerState.ctlrStateInsuranceSecondProvider,
                                                    )
                                                ),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                        isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].zipcode.rptiZipcodeLink.isEmpty ? true : false,
                                                        isIClicked: (){
                                                          widget.isIButtonPressed();
                                                          providerState.setLinkAndPageNumber(
                                                              selectLink: Uri.parse(controller.data![index + 1].zipcode.rptiZipcodeLink).pathSegments.last,
                                                              pageNo:controller.data![index + 1].zipcode.rptiZipcodePgNo,
                                                              isLinkeOpen:controller.data![index + 1].zipcode.rptiZipcodeLink );
                                                        },
                                                        controller: pharmacyzipcode,
                                                        //  onlyAllowNumbers: true,
                                                        allowSSNBR: true,
                                                        labelText: 'Zip Code*')),
                                              ],
                                            ):
                                            Row(
                                              children: [
                                                Flexible(
                                                    child: SchedularTextField(
                                                        isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].contact.rptiContactLink.isEmpty ? true : false,
                                                        isIClicked: (){
                                                          widget.isIButtonPressed();
                                                          providerState.setLinkAndPageNumber(
                                                              selectLink: Uri.parse(controller.data![index + 1].contact.rptiContactLink).pathSegments.last,
                                                              pageNo:controller.data![index + 1].contact.rptiContactPgNo,
                                                              isLinkeOpen: controller.data![index + 1].contact.rptiContactLink);
                                                        },
                                                        controller: pharmaphone,
                                                        phoneField:true,
                                                        labelText: 'Phone Number*')),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                      textColor: const Color(0xff04BF00),
                                                      controller: pharmaAuth,
                                                      labelText: 'Auth Status',
                                                    )),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                      controller: pharmaEftDateForm, labelText: 'Effective From',
                                                      showDatePicker: true,)),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                      controller: pharmaEftDateFormTo, labelText: 'Effective to',
                                                      showDatePicker: true,)),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                  child: SchedularTextField(labelText: 'Eligibility Status',
                                                    controller: TextEditingController(text: statustype),
                                                    enable: true,
                                                  ),
                                                  // CustomDropdownTextFieldsm(headText: 'Eligibility Status',items: ['Santa Clara','A'],
                                                  //     onChanged: (newValue) {
                                                  //     })
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: AppSize.s16),
                                            providerState.isContactTrue ?   Row(
                                              children: [
                                                Flexible(
                                                    child: SchedularTextField(
                                                        isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].contact.rptiContactLink.isEmpty ? true : false,
                                                        isIClicked: (){
                                                          widget.isIButtonPressed();
                                                          providerState.setLinkAndPageNumber(
                                                              selectLink: Uri.parse(controller.data![index + 1].contact.rptiContactLink).pathSegments.last,
                                                              pageNo:controller.data![index + 1].contact.rptiContactPgNo,
                                                              isLinkeOpen:controller.data![index + 1].contact.rptiContactLink );
                                                        },
                                                        controller: pharmaphone,
                                                        phoneField:true,
                                                        labelText: 'Phone Number*')),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                      textColor: const Color(0xff04BF00),
                                                      controller: pharmaAuth,
                                                      labelText: 'Auth Status',
                                                    )),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                      controller: pharmaEftDateForm, labelText: 'Effective From',
                                                      showDatePicker: true,)),
                                              ],
                                            ):
                                            Row(
                                              children: [
                                                Flexible(
                                                    child: SchedularTextField(
                                                        isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].policy.rptiPolicyLink.isEmpty ? true : false,
                                                        isIClicked: (){
                                                          widget.isIButtonPressed();
                                                          providerState.setLinkAndPageNumber(
                                                              selectLink: Uri.parse(controller
                                                                  .data![index + 1]
                                                                  .policy
                                                                  .rptiPolicyLink).pathSegments.last,
                                                              pageNo:controller
                                                                  .data![index + 1]
                                                                  .policy
                                                                  .rptiPolicyPgNo,
                                                              isLinkeOpen: controller
                                                                  .data![index + 1]
                                                                  .policy
                                                                  .rptiPolicyLink);
                                                        },
                                                        controller: pharmaPolicyHicNo,
                                                        enable: true,
                                                        labelText: 'Policy/HIC Number')),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                      hintText: "###-###-####",
                                                      isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].groupNumber.rptiGroupNumberLink.isEmpty ? true : false,
                                                      isIClicked: (){
                                                        widget.isIButtonPressed();
                                                        providerState.setLinkAndPageNumber(
                                                            selectLink: Uri.parse(controller
                                                                .data![index + 1]
                                                                .groupNumber
                                                                .rptiGroupNumberLink).pathSegments.last,
                                                            pageNo:controller
                                                                .data![index + 1]
                                                                .groupNumber
                                                                .rptiGroupNumberPgNo,
                                                            isLinkeOpen: controller
                                                                .data![index + 1]
                                                                .groupNumber
                                                                .rptiGroupNumberLink);
                                                      },
                                                      controller: pharmaGrpNo,
                                                      onlyAllowNumbers: true,
                                                      labelText: 'Group Number',
                                                    )),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                      isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].groupName.rptiGroupNameLink.isEmpty ? true : false,
                                                      isIClicked: (){
                                                        widget.isIButtonPressed();
                                                        providerState.setLinkAndPageNumber(
                                                            selectLink: Uri.parse(controller
                                                                .data![index + 1]
                                                                .groupName
                                                                .rptiGroupNameLink).pathSegments.last,
                                                            pageNo:controller
                                                                .data![index + 1]
                                                                .groupName
                                                                .rptiGroupNamePgNo,
                                                            isLinkeOpen:controller
                                                                .data![index + 1]
                                                                .groupName
                                                                .rptiGroupNameLink );
                                                      },
                                                      controller: pharmaGrpName, labelText: 'Group Name',
                                                    )),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                      isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].comments.rptiCommentsLink.isEmpty ? true : false,
                                                      isIClicked: (){
                                                        widget.isIButtonPressed();
                                                        providerState.setLinkAndPageNumber(
                                                            selectLink: Uri.parse(controller.data![index + 1].comments.rptiCommentsLink).pathSegments.last,
                                                            pageNo:controller.data![index + 1].comments.rptiCommentsPgNo,
                                                            isLinkeOpen:controller.data![index + 1].comments.rptiCommentsLink );
                                                      },
                                                      controller: pharmaEmail, labelText: 'Comments',
                                                    )),
                                                const SizedBox(width: AppSize.s35),
                                                StatefulBuilder(
                                                    builder: (BuildContext context, void Function(void Function())setState) {
                                                      return Flexible(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text('Insurance Verified',
                                                                style:providerState.isContactTrue ?SMTextfieldResponsiveHeadings.customTextStyle(context)  :SMTextfieldHeadings.customTextStyle(context)
                                                              //AllPopupHeadings.customTextStyle(context)
                                                            ),
                                                            const SizedBox(height: 10),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: CustomRadioListTileSMp(
                                                                    title: 'Yes',
                                                                    value: 'Yes',
                                                                    groupValue: statustype,
                                                                    onChanged: (value) {
                                                                      setState(() {
                                                                        statustype = value;
                                                                      });
                                                                    },
                                                                  ),
                                                                ),

                                                                Expanded(
                                                                  child: CustomRadioListTileSMp(
                                                                    title: 'No',
                                                                    value: 'No',
                                                                    groupValue: statustype,
                                                                    onChanged: (value) {
                                                                      setState(() {
                                                                        statustype = value;
                                                                      });
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      );}
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: AppSize.s16),
                                            providerState.isContactTrue ?  Row(
                                              children: [
                                                Flexible(
                                                    child: SchedularTextField(
                                                      controller: pharmaEftDateFormTo, labelText: 'Effective to',
                                                      showDatePicker: true,)),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                  child: SchedularTextField(labelText: 'Eligibility Status',
                                                    controller: TextEditingController(text: statustype),
                                                    enable: true,
                                                  ),),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                        isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].policy.rptiPolicyLink.isEmpty ? true : false,
                                                        isIClicked: (){
                                                          widget.isIButtonPressed();
                                                          providerState.setLinkAndPageNumber(
                                                              selectLink: Uri.parse(controller
                                                                  .data![index + 1]
                                                                  .policy
                                                                  .rptiPolicyLink).pathSegments.last,
                                                              pageNo:controller
                                                                  .data![index + 1]
                                                                  .policy
                                                                  .rptiPolicyPgNo,
                                                              isLinkeOpen:controller
                                                                  .data![index + 1]
                                                                  .policy
                                                                  .rptiPolicyLink );
                                                        },
                                                        controller: pharmaPolicyHicNo,
                                                        enable: true,
                                                        labelText: 'Policy/HIC Number')),
                                              ],
                                            ) : const Offstage(),
                                            const SizedBox(height: AppSize.s16),
                                            providerState.isContactTrue ? Row(
                                              children: [
                                                Flexible(
                                                    child: SchedularTextField(
                                                      hintText: "###-###-####",
                                                      isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].groupNumber.rptiGroupNumberLink.isEmpty ? true : false,
                                                      isIClicked: (){
                                                        widget.isIButtonPressed();
                                                        providerState.setLinkAndPageNumber(
                                                            selectLink: Uri.parse(controller
                                                                .data![index + 1]
                                                                .groupNumber
                                                                .rptiGroupNumberLink).pathSegments.last,
                                                            pageNo:controller
                                                                .data![index + 1]
                                                                .groupNumber
                                                                .rptiGroupNumberPgNo,
                                                            isLinkeOpen:controller
                                                                .data![index + 1]
                                                                .groupNumber
                                                                .rptiGroupNumberLink );
                                                      },
                                                      controller: pharmaGrpNo,
                                                      onlyAllowNumbers: true,
                                                      labelText: 'Group Number',
                                                    )),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                      isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].policy.rptiPolicyLink.isEmpty ? true : false,
                                                      isIClicked: (){
                                                        widget.isIButtonPressed();
                                                        providerState.setLinkAndPageNumber(
                                                            selectLink: Uri.parse(controller
                                                                .data![index + 1]
                                                                .groupName
                                                                .rptiGroupNameLink).pathSegments.last,
                                                            pageNo:controller
                                                                .data![index + 1]
                                                                .groupName
                                                                .rptiGroupNamePgNo,
                                                            isLinkeOpen: controller
                                                                .data![index + 1]
                                                                .groupName
                                                                .rptiGroupNameLink);
                                                      },
                                                      controller: pharmaGrpName, labelText: 'Group Name',
                                                    )),
                                                const SizedBox(width: AppSize.s35),
                                                Flexible(
                                                    child: SchedularTextField(
                                                      isIconVisible: controller.data![index + 1] == null ? true : controller.data![index + 1].comments.rptiCommentsLink.isEmpty ? true : false,
                                                      isIClicked: (){
                                                        widget.isIButtonPressed();
                                                        providerState.setLinkAndPageNumber(
                                                            selectLink: Uri.parse(controller.data![index + 1].comments.rptiCommentsLink).pathSegments.last,
                                                            pageNo:controller.data![index + 1].comments.rptiCommentsPgNo,
                                                            isLinkeOpen:controller.data![index + 1].comments.rptiCommentsLink );
                                                      },
                                                      controller: pharmaEmail, labelText: 'Comments',
                                                    )),
                                              ],
                                            ) : const Offstage(),
                                            // const SizedBox(height: AppSize.s16),
                                            providerState.isContactTrue ?Padding(
                                              padding: const EdgeInsets.only(top: 16),
                                              child: SizedBox(
                                                width: 200,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    StatefulBuilder(
                                                        builder: (BuildContext context, void Function(void Function())setState) {
                                                          return Flexible(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text('Insurance Verified',
                                                                    style:providerState.isContactTrue ?SMTextfieldResponsiveHeadings.customTextStyle(context)  :SMTextfieldHeadings.customTextStyle(context)
                                                                  //AllPopupHeadings.customTextStyle(context)
                                                                ),
                                                                const SizedBox(height: 10),
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: CustomRadioListTileSMp(
                                                                        title: 'Yes',
                                                                        value: 'Yes',
                                                                        groupValue: statustype,
                                                                        onChanged: (value) {
                                                                          setState(() {
                                                                            statustype = value;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),

                                                                    Expanded(
                                                                      child: CustomRadioListTileSMp(
                                                                        title: 'No',
                                                                        value: 'No',
                                                                        groupValue: statustype,
                                                                        onChanged: (value) {
                                                                          setState(() {
                                                                            statustype = value;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          );}
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ):const Offstage(),
                                            const Divider()
                                          ],
                                        ),
                                        // ),
                                      );
                                    }
                                ),
                              ),),
                          ),

                          const SizedBox(height: AppSize.s5),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 35),
                            child: BlueBGHeadConst(HeadText: "Attachments",
                              body:  Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppPadding.p40,vertical: AppPadding.p15 ),
                                  //child: SingleChildScrollView(
                                  child: Column(
                                      children: [
                                        StreamBuilder<List<PatientInsuranceDocumentData>>(
                                            stream: _streamControllerDoc.stream,
                                            builder: (context, snapshotDoc){
                                              if(snapshotDoc.connectionState == ConnectionState.waiting){
                                                return Center(
                                                  child: CircularProgressIndicator(color: ColorManager.blueprime,),
                                                );
                                              }
                                              if(snapshotDoc.data!.isEmpty){
                                                return Center(
                                                    child: Padding(
                                                      padding:const EdgeInsets.symmetric(vertical: 76),
                                                      child: Text(
                                                        AppStringSMModule.patientInsuranceDocNoData,
                                                        style: AllNoDataAvailable.customTextStyle(context),
                                                      ),
                                                    ));
                                              }
                                              if(snapshotDoc.hasData){
                                                return  Container(
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: snapshotDoc.data!.length,
                                                      itemBuilder: (context,index) {
                                                        var fileUrl = snapshotDoc.data![index].docUrl;
                                                        var formatedData = DateFormat('yyyy/MM/dd').format(snapshotDoc.data![index].createdAt);
                                                        return snapshotDoc.data![index].isPrimary == true? const Offstage():Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 40.0,vertical: 10),
                                                          child: Container(
                                                            height: AppSize.s65,
                                                            decoration: BoxDecoration(
                                                              color: ColorManager.white,
                                                              border: Border(
                                                                bottom: BorderSide(width: 0.5,color: ColorManager.lightGrey),
                                                              ),
                                                            ),child:Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  const VerticalDivider(
                                                                    color: Color(0xFF50B5E5),
                                                                    thickness: 4.5,
                                                                  ),
                                                                  const SizedBox(width: AppSize.s20,),
                                                                  Column(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment.center,
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text('${snapshotDoc.data![index].docName}',
                                                                          style: DocDefineTableData.customTextStyle(context)),
                                                                      const SizedBox(height: AppSize.s8,),
                                                                      Text("Uploaded $formatedData, ${DateFormat.jm().format(snapshotDoc.data![index].createdAt)} PST by ${snapshotDoc.data![index].updatedBy}",
                                                                          style:  TextStyle(
                                                                            fontWeight: FontWeight.w500,
                                                                            fontSize: FontSize.s12,
                                                                            fontStyle: FontStyle.italic,
                                                                            color: ColorManager.mediumgrey,
                                                                            decoration: TextDecoration.none,
                                                                          )),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment.center,
                                                                children: [
                                                                  IconButton(
                                                                    splashColor: Colors.transparent,
                                                                    highlightColor: Colors.transparent,
                                                                    hoverColor: Colors.transparent,
                                                                    onPressed: () {
                                                                      downloadFile(context: context,
                                                                          fileUrl: fileUrl,
                                                                          documentName:snapshotDoc.data![index].docName,
                                                                          apiPath: DownloadDocumentRepository.getPatientInsuranceDocumentByFileName());
                                                                    },
                                                                    icon: const Icon(
                                                                      Icons.print_outlined,
                                                                      color: Color(0xFF686464),
                                                                    ),
                                                                    iconSize: providerState.isContactTrue?IconSize.I20 :IconSize.I22,
                                                                  ),
                                                                  const SizedBox(width: AppSize.s10,),
                                                                  ///download
                                                                  PdfDownloadButton(
                                                                    apiPath: DownloadDocumentRepository.getPatientInsuranceDocumentByFileName(),
                                                                    apiUrl: snapshotDoc.data![index].docUrl,// policiesdata.docurl,
                                                                    iconsize: IconSize.I22,
                                                                    documentName: snapshotDoc.data![index].docName,
                                                                    iconColor: const Color(0xFF686464),//policiesdata.docName!
                                                                  ),
                                                                  const SizedBox(width: AppSize.s10,),
                                                                  ///delete
                                                                  IconButton(
                                                                    onPressed: () async{
                                                                      bool dialogIsOpen = true;
                                                                      showDialog(
                                                                          context: context,
                                                                          builder: (context) =>
                                                                              StatefulBuilder(
                                                                                builder: (BuildContext context, void Function(void Function())setDialogState) {
                                                                                  return DeletePopup(
                                                                                    loadingDuration: _isDeletingDoc,
                                                                                    title: 'Delete Document',
                                                                                    onCancel: () {
                                                                                      dialogIsOpen = false;
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    onDelete: () async {
                                                                                      // FIX: this used the StatefulBuilder's own local
                                                                                      // `setState` param, which only rebuilds the dialog —
                                                                                      // the outer State's setState is what actually needs
                                                                                      // to run so `_isDeletingDoc` (now a real field) reflects
                                                                                      // correctly wherever else it's read.
                                                                                      setState(() {
                                                                                        _isDeletingDoc = true;
                                                                                      });
                                                                                      if (dialogIsOpen) setDialogState(() {});
                                                                                      try {
                                                                                        var response =  await deletePatientInsuranceDocument(context: context, documentId: snapshotDoc.data![index].insuranceDocumentId, );
                                                                                        if(response.statusCode == 200  || response.statusCode == 201) {
                                                                                          dialogIsOpen = false;
                                                                                          Navigator.pop(context);
                                                                                          _loadInsuranceDoc();
                                                                                          if (mounted) {
                                                                                            showDialog(
                                                                                              context: context,
                                                                                              builder: (BuildContext context) => const DeleteSuccessPopup(),
                                                                                            );
                                                                                          }
                                                                                        }
                                                                                      } finally {
                                                                                        if (mounted) {
                                                                                          setState(() {
                                                                                            _isDeletingDoc = false;
                                                                                          });
                                                                                        }
                                                                                        if (dialogIsOpen) setDialogState(() {});
                                                                                      }
                                                                                    },
                                                                                  );
                                                                                },
                                                                              ));
                                                                    },
                                                                    icon: const Icon(
                                                                      Icons.delete_outline,
                                                                      color: Color(0xFF686464),
                                                                    ),
                                                                    splashColor: Colors.transparent,
                                                                    highlightColor: Colors.transparent,
                                                                    hoverColor: Colors.transparent,
                                                                    iconSize:providerState.isContactTrue?IconSize.I20 :IconSize.I22,
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                          ),
                                                        );
                                                      }
                                                  ),
                                                );
                                              }
                                              else{
                                                return const SizedBox();
                                              }
                                            }
                                        ),
                                        const SizedBox(height: AppSize.s25),
                                        CustomIconButtonConst(
                                            width: 150,
                                            text: 'Add Attachment',
                                            icon: Icons.add,
                                            color: ColorManager.blueprime,
                                            onPressed: () async{
                                              FilePickerResult? result = await FilePicker.platform.pickFiles(
                                                type: FileType.custom,
                                                allowedExtensions: [
                                                  //'svg', 'png', 'jpg', 'gif',
                                                  'pdf'],
                                              );

                                              if (result != null) {
                                                final selectedFile = result.files.first;
                                                final fileSizeInMB = selectedFile.size / (1024 * 1024);

                                                if (fileSizeInMB > 20) {
                                                  // Show error if file size is greater than 20MB
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return const AddErrorPopup(
                                                        message: 'File is too large!',
                                                      );
                                                    },
                                                  );
                                                  return;
                                                }
                                                print('file name ${result.files.first.name}');
                                                ApiData apiData =  await addPatientInsuranceDocuments(
                                                  context: context,
                                                  ptId: diagnosisProvider.patientId,
                                                  documentUrl: '--',
                                                  documentName: result.files.first.name,
                                                  isPrimary: false,
                                                );
                                                // FIX: the create call's own status must be checked before
                                                // touching patientInsuranceDocId — on failure it's null, and
                                                // the old code dereferenced it unconditionally with `!`. There
                                                // was also no error feedback if either step failed, and no
                                                // reload of the doc list on success — so a successful upload
                                                // never showed up until the whole screen was reopened.
                                                if (apiData.statusCode != 200 && apiData.statusCode != 201) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return const AddErrorPopup(
                                                        message: 'Failed to upload document. ',
                                                      );
                                                    },
                                                  );
                                                  return;
                                                }
                                                var uploadPatientDoc = await uploadPatientInsuranceDocuments(
                                                  context: context,
                                                  documentId: apiData.patientInsuranceDocId!,
                                                  documentFile: result.files.first.bytes,
                                                  documentName: result.files.first.name,
                                                );
                                                if(uploadPatientDoc.success == true){
                                                  _loadInsuranceDoc();
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return const AddSuccessPopup(
                                                        message: 'Document Uploaded Successfully',
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return const AddErrorPopup(
                                                        message: 'Failed to upload document. ',
                                                      );
                                                    },
                                                  );
                                                }
                                              }
                                            }
                                        ),])),),
                          ),

                          const SizedBox(height: AppSize.s60),
                          // FIX: removed the StatefulBuilder that used to wrap this Row. It
                          // gave `_isLoading` a local `setState` that only rebuilt this
                          // subtree; combined with `_isLoading` being a build()-local
                          // variable (also fixed), a rebuild of the outer widget while
                          // Save was in flight could leave the spinner reflecting a value
                          // nothing was updating anymore. `_isLoading` is now a real field,
                          // so the outer State's own setState (used below) is all that's
                          // needed.
                          Builder(
                              builder: (BuildContext context){
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 10,
                                  children: [
                                    SkipButtonTransparent(
                                      text: "Skip",
                                      onPressed: () {
                                        print("🔹 Skip button tapped - going to info screen");
                                        widget.onSkip(); // This should trigger jumpToPage(4)
                                      },
                                    ),
                                    CustomElevatedButton(
                                      width: AppSize.s100,
                                      text: AppString.save,
                                      isLoading: _isLoading,
                                      onPressed: ()async{

                                        setState((){
                                          _isLoading = true;
                                        });
                                        try{
                                          var responseUpdate = await updatePatientInsuranceInfo(
                                            context: context,
                                            id: controller.data![1].rptiId,
                                            rptiPolicy: pharmaPolicyHicNo.text,
                                            rptiInsuranceProvider: pharmaName.text,
                                            rptiType: pharmaType.text,
                                            rptiInsurancePlan:pharmaType.text ,
                                            rptiEligibility: false,
                                            rptiAuthorization: false,
                                            rptiName: pharmaName.text,
                                            rptiCategory: pharmaCategory.text,
                                            rptiStreet:providerState.ctlrStreetInsuranceSecondProvider.text.isEmpty ? pharmacyaddress.text : providerState.ctlrStreetInsuranceSecondProvider.text,
                                            rptiSuite: pharmaSuitApt.text,
                                            rptiCity: providerState.ctlrCityInsuranceSecondProvider.text.isEmpty ? city.text : providerState.ctlrCityInsuranceSecondProvider.text,
                                            rptiState: providerState.ctlrStateInsuranceSecondProvider.text.isEmpty ? state.text : providerState.ctlrStateInsuranceSecondProvider.text,
                                            rptiZipcode: pharmacyzipcode.text,
                                            rptiContact: pharmaphone.text,
                                            // FIX: was sending raw date-picker display text
                                            // ("MM/DD/YYYY" or similar), which the backend
                                            // rejected with a 400 on PATCH /patient-insurance/{id}.
                                            // Convert to UTC ISO-8601 first, same convention used
                                            // elsewhere in this project. Handles both slash and
                                            // ISO-dash formats since the preloaded value comes
                                            // straight from the API's rptiEffectiveFrom/To.
                                            rptiEffectiveFrom: _toIsoDateOrEmpty(pharmaEftDateForm.text),
                                            rptiEffectiveTo: _toIsoDateOrEmpty(pharmaEftDateFormTo.text),
                                            // FIX: int.parse threw uncaught if the field was
                                            // empty/non-numeric, aborting the save before the
                                            // request was even sent. int.tryParse ?? 0 is safe.
                                            rptiGroupNumber: int.tryParse(pharmaGrpNo.text) ?? 0,
                                            rptiGroupName: pharmaGrpName.text,
                                            rptiEmail: pharmaEmail.text,
                                            rptiVerified: statustype == 'Yes' ? true : false,
                                            rptiComments: controller.data![1].comments.rptiComments,
                                            isSelfPay:false, // ✅ NEWLY ADDED
                                          );
                                          if(responseUpdate.statusCode == 200 || responseUpdate.statusCode == 201){
                                            //onMoveToIntake();
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return const AddSuccessPopup(
                                                  message: 'Patient Insurance Updated Successfully',
                                                );
                                              },
                                            );
                                            widget.onSave();
                                          }else{
                                            showDialog(
                                              context: context,
                                              builder: (_) => const AddErrorPopup(
                                                message: 'Please Check Your Input And Try Again',
                                              ),
                                            );
                                            print('API error: ${responseUpdate.message}');
                                            print('Please check your input and try again');

                                          }
                                        }finally{
                                          setState((){
                                            _isLoading = false;
                                          });
                                        }

                                      },
                                    ),
                                  ],
                                );
                              }),
                          const SizedBox(height: AppSize.s30),
                        ],
                      )
                  ),
                  // ),
                );
              }
          );
        }
    );
  }
}