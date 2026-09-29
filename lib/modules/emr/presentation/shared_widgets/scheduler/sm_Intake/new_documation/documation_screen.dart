import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/provider/async_data_controller.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/refferals_manager/refferals_patient_manager.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/patient_insurances_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/referral_service_data.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/schedular_textfield_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/dropdown_constant_sm.dart';
// removed in extraction: import '../widgets/intake_profile_bar.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/new_documation/add_popup_const.dart';

class DocumationScreenTab extends StatelessWidget {
  const DocumationScreenTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AsyncDataController<List<PatientMarketerData>>>(
      create: (ctx) => AsyncDataController<List<PatientMarketerData>>(),
      child: const _DocumationScreenTabBody(),
    );
  }
}

class _DocumationScreenTabBody extends StatefulWidget {
  const _DocumationScreenTabBody();

  @override
  State<_DocumationScreenTabBody> createState() => _DocumationScreenTabBodyState();
}

class _DocumationScreenTabBodyState extends State<_DocumationScreenTabBody> {

  TextEditingController ffdateController = TextEditingController();
  TextEditingController ffpostController = TextEditingController();
  TextEditingController ffappoController = TextEditingController();
  bool isLoading = false;
  final StreamController<List<PatientDocumentsData>> _streamController = StreamController<List<PatientDocumentsData>>.broadcast();
  final StreamController<List<PatientDocumentsBillingData>> _streamControllerBillingAttachment = StreamController<List<PatientDocumentsBillingData>>.broadcast();
  final StreamController<List<PatientDocumentsFtwoFData>> _streamControllerF2F = StreamController<List<PatientDocumentsFtwoFData>>.broadcast();
  final StreamController<List<PatientDocumentsConsentData>> _streamControllerConsent = StreamController<List<PatientDocumentsConsentData>>.broadcast();
 // String? loginName = '';
  bool isCreating = false;
  bool isPostOpChecked = false;
  TextEditingController postOpDateController = TextEditingController();

  bool isAppointmentChecked = false;

  DateTime? selectedDate;
  String? selectedDropdownItem;

  // bool get isFormValid =>
  //     selectedDate != null &&
  //         selectedDropdownItem != null &&
  //         isPostOpChecked &&
  //         isAppointmentChecked;
  String? loginName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    // FIX: these fetches were previously fired inline inside each
    // StreamBuilder's builder:, re-hitting the API on every rebuild. Moved
    // here so each runs exactly once.
    _loadClinicalAttachments();
    _loadBillingAttachment();
    _loadConsent();
    // FIX: _loadFaceTwoFace() intentionally NOT called here. Its
    // StreamBuilder only exists once isCreating is true (see the "Create"
    // button below), so firing this fetch during initState — before that
    // StreamBuilder has ever mounted — populates a broadcast stream with no
    // listener attached yet. Broadcast streams drop events with no current
    // subscriber, so that one-and-only event was silently lost, and the
    // StreamBuilder that mounted later sat in ConnectionState.waiting
    // forever. It's fired instead right when isCreating flips to true.
  }

  Future<void> _loadUserName() async {
    loginName = await TokenManager.getUserName();
    setState(() {});  // triggers rebuild so loginName is available
  }

  void _loadClinicalAttachments() {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
    final int patientId = diagnosisProvider.patientId;
    getReffrealsPatientDocumentsByDocType(context: context, patientId: patientId,documentType:
    FrontendConfigStore.data!.config.clinicianAttachment).then((data) {
      _streamController.add(data);
    }).catchError((error) {
      // Handle error
    });
  }

  void _loadBillingAttachment() {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
    final int patientId = diagnosisProvider.patientId;
    getReffrealsPatientDocumentsBillingAttachment(context: context, patientId: patientId,).then((data) {
      _streamControllerBillingAttachment.add(data);
    }).catchError((error) {
      // Handle error
    });
  }

  void _loadFaceTwoFace() {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
    final int patientId = diagnosisProvider.patientId;
    getReffrealsPatientDocumentsFaceTwoFace(context: context, patientId: patientId,).then((data) {
      _streamControllerF2F.add(data);
    }).catchError((error) {
      // Handle error
    });
  }

  void _loadConsent() {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
    final int patientId = diagnosisProvider.patientId;
    getReffrealsPatientDocumentsConsent(context: context, patientId: patientId, doctypeId: FrontendConfigStore.data!.config.consent,).then((data) {
      _streamControllerConsent.add(data);
    }).catchError((error) {
      // Handle error
    });
  }

  @override
  void dispose() {
    _streamController.close();
    _streamControllerBillingAttachment.close();
    _streamControllerF2F.close();
    _streamControllerConsent.close();
    super.dispose();
  }
  int marketerId = 0;
  bool isFormValid = false;
  String selectedMarketer = 'Select';

  void _checkFormValidity() {
    setState(() {
      isFormValid = ffdateController.text.isNotEmpty &&
          postOpDateController.text.isNotEmpty &&
          ffappoController.text.isNotEmpty &&
          // selectedMarketer != null &&
          isPostOpChecked &&
          isAppointmentChecked;
    });
  }


  TextEditingController residencyController = TextEditingController();

  bool _areRequiredFieldsFilled() {
    return ffdateController.text.trim().isNotEmpty &&
        marketerId != null &&
        (postOpDateController.text.trim().isNotEmpty ||
            ffappoController.text.trim().isNotEmpty);
  }



  @override
  Widget build(BuildContext context) {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context,listen: false);
    final int patientId = diagnosisProvider.patientId;
    return Consumer<SmIntakeProviderManager>(
        builder: (context,providerState,child) {
          return Padding(
            padding: const EdgeInsets.only(top: 5),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: AppSize.s20,bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Review and confirm the data pulled is correct  ',
                              style: SMItalicTextConst.customTextStyle(context))
                        ],
                      ),
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     Text(
                    //       'Missing Paperwork: Therapy Notes',
                    //       style: TextStyle(fontSize: FontSize.s12,
                    //           fontWeight: FontWeight.w300,
                    //           color: Color(0xFFC30909)),)
                    //   ],),
                  //  SizedBox(height: AppSize.s10,),
                    BlueBGHeadConst(HeadText: "Clinical Attachments*",
                    body: Column(children: [
                      const SizedBox(height: AppSize.s10,),
                      StreamBuilder<List<PatientDocumentsData>>(
                          stream: _streamController.stream,
                          builder: (context,snapshotDoc) {
                            if(snapshotDoc.connectionState == ConnectionState.waiting){
                              return Center(
                                child: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator(color: ColorManager.blueprime,)),
                              );
                            }
                            if(snapshotDoc.data!.isEmpty){
                              return Center(
                                  child: Padding(
                                    padding:const EdgeInsets.symmetric(vertical: 76),
                                    child: Text(
                                      AppStringSMModule.patientDocNoData,
                                      style: AllNoDataAvailable.customTextStyle(context),
                                    ),
                                  ));
                            }
                            if(snapshotDoc.hasData){
                              return Container(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: snapshotDoc.data!.length,
                                    itemBuilder: (context,index){
                                      print("login name is :::::::::::: $loginName");
                                      return FileInfoCard(
                                          content: snapshotDoc.data![index].rptd_content,
                                          documentName: snapshotDoc.data![index].documentName,
                                          fileUrl: snapshotDoc.data![index].rptd_url,
                                          fileName: snapshotDoc.data![index].documentName,// "Erica Thompson REF.pdf",
                                          uploadedInfo: providerState.isContactTrue
                                              ? "Uploaded ${snapshotDoc.data![index].rptd_created_at}\nAM PST by $loginName"
                                              : "Uploaded ${snapshotDoc.data![index].rptd_created_at} AM PST by $loginName",
                                          isContact: providerState.isContactTrue,
                                          // onHistoryTap: () {},
                                          // onTelegramTap: () {},
                                          onPrintTap: () {},
                                          onDownloadTap: () {},
                                          onDeleteTap: () async{
                                            bool dialogIsOpen = true;
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    StatefulBuilder(
                                                      builder: (BuildContext context, void Function(void Function())setDialogState) {
                                                        return DeletePopup(
                                                          loadingDuration: isLoading,
                                                          title: 'Delete Document',
                                                          onCancel: () {
                                                            dialogIsOpen = false;
                                                            Navigator.pop(context);
                                                          },
                                                          onDelete: () async {
                                                            setState(() {
                                                              isLoading = true;
                                                            });
                                                            if (dialogIsOpen) setDialogState(() {});
                                                            try {
                                                              var response =  await deletePatientDocument(context: context, docId: snapshotDoc.data![index].rptd_id, );
                                                              if(response.statusCode == 200  || response.statusCode == 201) {
                                                                dialogIsOpen = false;
                                                                Navigator.pop(context);
                                                                _loadClinicalAttachments();
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
                                                                  isLoading = false;
                                                                });
                                                              }
                                                              if (dialogIsOpen) setDialogState(() {});
                                                            }
                                                          },
                                                        );
                                                      },
                                                    ));
                                          }
                                      );
                                    }),
                              );
                            }else{
                              return const SizedBox();
                            }

                          }
                      ),
                      const SizedBox(height: AppSize.s20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconButtonConst(
                            icon: Icons.add,
                            width: AppSize.s150,
                            color: ColorManager.blueprime,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AddPopupConstant(title: 'Add  Clinical Attachment',docTypeId: FrontendConfigStore.data!.config.clinicianAttachment);
                                  // return AddPopupConstant(title: 'Add  Clinical Attachment',docTypeId: AppConfig.clinicianAttachment);
                                },
                              ).then((_) => _loadClinicalAttachments());
                            },
                            text: "Add Attachment",
                          ),

                        ],
                      ),
                    ],),),

                    ///
                    const SizedBox(height: AppSize.s30,),
                    BlueBGHeadConst(HeadText: "Billing Attachments*",
                    body: Column(
                      children: [
                        const SizedBox(height: AppSize.s10,),
                        StreamBuilder<List<PatientDocumentsBillingData>>(
                            stream: _streamControllerBillingAttachment.stream,
                            builder: (context,snapshotDoc) {
                              if(snapshotDoc.connectionState == ConnectionState.waiting){
                                return Center(
                                  child: SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator(color: ColorManager.blueprime,)),
                                );
                              }
                              if(snapshotDoc.data!.isEmpty){
                                return Center(
                                    child: Padding(
                                      padding:const EdgeInsets.symmetric(vertical: 76),
                                      child: Text(
                                        AppStringSMModule.patientDocNoData,
                                        style: AllNoDataAvailable.customTextStyle(context),
                                      ),
                                    ));
                              }
                              if(snapshotDoc.hasData){
                                return Container(
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: snapshotDoc.data!.length,
                                      itemBuilder: (context,index){
                                        return FileInfoCard(
                                          content: snapshotDoc.data![index].rptd_content,
                                          documentName: snapshotDoc.data![index].documentName,
                                          fileUrl: snapshotDoc.data![index].rptd_url,
                                          fileName: snapshotDoc.data![index].documentName,
                                          uploadedInfo: providerState.isContactTrue
                                              ? "Uploaded ${snapshotDoc.data![index].rptd_created_at}\nAM PST by $loginName"
                                              : "Uploaded ${snapshotDoc.data![index].rptd_created_at} AM PST by $loginName",
                                          isContact: providerState.isContactTrue,
                                          // onHistoryTap: () {},
                                          // onTelegramTap: () {},
                                          onPrintTap: () {},
                                          onDownloadTap: () {},
                                          onDeleteTap: () async{
                                            bool dialogIsOpen = true;
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    StatefulBuilder(
                                                      builder: (BuildContext context, void Function(void Function())setDialogState) {
                                                        return DeletePopup(
                                                          loadingDuration: isLoading,
                                                          title: 'Delete Document',
                                                          onCancel: () {
                                                            dialogIsOpen = false;
                                                            Navigator.pop(context);
                                                          },
                                                          onDelete: () async {
                                                            setState(() {
                                                              isLoading = true;
                                                            });
                                                            if (dialogIsOpen) setDialogState(() {});
                                                            try {
                                                              var response =  await deletePatientDocument(context: context, docId: snapshotDoc.data![index].rptd_id, );
                                                              if(response.statusCode == 200  || response.statusCode == 201) {
                                                                dialogIsOpen = false;
                                                                Navigator.pop(context);
                                                                _loadBillingAttachment();
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
                                                                  isLoading = false;
                                                                });
                                                              }
                                                              if (dialogIsOpen) setDialogState(() {});
                                                            }
                                                          },
                                                        );
                                                      },
                                                    ));
                                          },
                                        );
                                      }),
                                );
                              }else{
                                return const SizedBox();
                              }

                            }
                        ),
                        const SizedBox(height: AppSize.s20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconButtonConst(
                              icon: Icons.add,
                              width: AppSize.s150,
                              color: ColorManager.blueprime,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AddPopupConstant(title: 'Add Billing Attachment',docTypeId: FrontendConfigStore.data!.config.billingAttachment);
                                    // return AddPopupConstant(title: 'Add Billing Attachment',docTypeId: AppConfig.billingAttachment);
                                  },
                                ).then((_) => _loadBillingAttachment());
                              },
                              text: "Add Attachment",
                            ),
                          ],
                        ),
                      ],
                    ),),

                    const SizedBox(height: AppSize.s30,),

                    BlueBGHeadConst(HeadText: "Face to Face Encounter",
                    body: Column(
                      children: [
                        const SizedBox(height: AppSize.s10,),
                        Column(
                          children: [
                            if (!isCreating)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomIconButtonConst(
                                    paddingLeft: AppPadding.p40,
                                    paddingRight: AppPadding.p40,
                                    icon: Icons.add,
                                    width: AppSize.s150,
                                    color: ColorManager.blueprime,
                                    onPressed: () {
                                      setState(() {
                                        isCreating = true;
                                      });
                                      context.read<AsyncDataController<List<PatientMarketerData>>>().load(
                                        () => getMarketerWithDeptId(context: context, deptId: FrontendConfigStore.data!.config.salesId),
                                      );
                                      // FIX: fetch F2F documents now that the StreamBuilder
                                      // showing them is about to be mounted (it only exists
                                      // once isCreating is true) — see the initState note.
                                      _loadFaceTwoFace();
                                    },
                                    text: "Create",
                                  ),
                                ],
                              ),

                            if (isCreating) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: SchedularTextField(
                                          dateFormateMMDDYYYY: true,
                                          controller: ffdateController,
                                          labelText: 'F2F Date:',
                                          enable: true,
                                          showDatePicker: true,
                                          onChanged: (_) => _checkFormValidity(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 30),
                                    Flexible(
                                      child:  Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: StatefulBuilder(
                                            builder: (BuildContext context, StateSetter setState) {
                                              residencyController = TextEditingController(text:selectedMarketer);
                                              print(isFormValid);
                                              return Consumer<AsyncDataController<List<PatientMarketerData>>>(
                                                builder: (context, controller, _) {
                                                  if (controller.isLoading) {
                                                    return  Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                'Marketer',
                                                                style:SMTextfieldHeadings.customTextStyle(context),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Container(
                                                          height: AppSize.s30,
                                                          padding: const EdgeInsets.only(bottom: 3, top: 4, left: AppPadding.p10,right: AppPadding.p7),
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.grey),
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                selectedMarketer,
                                                                style: TableSubHeading.customTextStyleWithColor(context,const Color(0xff686464)),// TableSubHeading.customTextStyle(context),//DocumentTypeDataStyle.customTextStyle(context),
                                                              ),
                                                              Icon(Icons.arrow_drop_down_sharp, color: ColorManager.blueprime,),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }
                                                  if (controller.data != null) {
                                                    List<DropdownMenuItem<String>> dropDownList = [];
                                                    for (var i in controller.data!) {
                                                      dropDownList.add(DropdownMenuItem<String>(
                                                        child: Text(i.firstName),
                                                        value: i.firstName,
                                                      ));
                                                    }

                                                    return CustomDropdownTextFieldsm(
                                                        headText: 'Marketer',
                                                        dropDownMenuList: dropDownList,
                                                        value: selectedMarketer,
                                                        onChanged: (newValue) {
                                                          for (var a in controller.data!) {
                                                            if (a.firstName == newValue) {
                                                              selectedMarketer = a.firstName;
                                                              _checkFormValidity();
                                                              //country = a
                                                              marketerId = a.employeeId;
                                                            }
                                                          }
                                                        });
                                                  } else {
                                                    return const Offstage();
                                                  }
                                                },
                                              );
                                            }
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 30),
                                    Flexible(
                                        child: StatefulBuilder(
                                            builder: (BuildContext context, StateSetter setState) {
                                              print(isFormValid);
                                              return SchedularTextFieldcheckbox(
                                                controller: postOpDateController,
                                                labelText: 'Post-op Visit Note Needed',
                                                showDatePicker: true,
                                                hintText: '',
                                                enable: isPostOpChecked,
                                                initialCheckboxValue: isPostOpChecked,
                                                onCheckboxChanged: (bool? newValue) {
                                                  setState(() {
                                                    isPostOpChecked = newValue ?? false;
                                                    isPostOpChecked == true ?'':postOpDateController.clear();// 🔁 Update enabled state
                                                  });
                                                  _checkFormValidity();
                                                },
                                              );
                                            }
                                        )
                                    ),
                                    const SizedBox(width: 30),
                                    Flexible(
                                      child: StatefulBuilder(
                                          builder: (BuildContext context, StateSetter setState) {
                                            print(isFormValid);
                                            return SchedularTextFieldcheckbox(
                                              hintText: " ",
                                              enable: isAppointmentChecked,
                                              controller: ffappoController,
                                              labelText: 'F2F Appointment Needed',
                                              showDatePicker: true,
                                              initialCheckboxValue: isAppointmentChecked,
                                              //onChanged: (_) => _checkFormValidity(),
                                              onCheckboxChanged: (bool? newValue) {
                                                setState(() {
                                                  isAppointmentChecked = newValue ?? false;
                                                  isAppointmentChecked == true ?'':ffappoController.clear();
                                                });
                                                _checkFormValidity();
                                              },
                                            );
                                          }
                                      ),

                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              StreamBuilder<List<PatientDocumentsFtwoFData>>(
                                  stream: _streamControllerF2F.stream,
                                  builder: (context,snapshotDoc) {
                                    if(snapshotDoc.connectionState == ConnectionState.waiting){
                                      return Center(
                                        child: SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: CircularProgressIndicator(color: ColorManager.blueprime,)),
                                      );
                                    }
                                    if(snapshotDoc.data!.isEmpty){
                                      return Center(
                                          child: Padding(
                                            padding:const EdgeInsets.symmetric(vertical: 76),
                                            child: Text(
                                              AppStringSMModule.patientDocNoData,
                                              style: AllNoDataAvailable.customTextStyle(context),
                                            ),
                                          ));
                                    }
                                    if(snapshotDoc.hasData){
                                      return Column(
                                        children: [
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(), // prevent scroll conflict
                                            itemCount: snapshotDoc.data!.length,
                                            itemBuilder: (context, index) {
                                              final f2fData = snapshotDoc.data![index];
                                              final documents = f2fData.documents ?? [];

                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: documents.map((doc) {
                                                  return FileInfoCard(
                                                    content: doc.f2f_doc_content,
                                                    documentName: doc.f2f_doc_name,
                                                    fileUrl: doc.f2f_doc_url,
                                                    fileName: doc.f2f_doc_name,
                                                    uploadedInfo: providerState.isContactTrue
                                                        ? "Uploaded ${snapshotDoc.data![index].documents!.isNotEmpty ? snapshotDoc.data![index].documents![0].f2f_doc_created_at : '--'}\nAM PST by $loginName"
                                                        : "Uploaded ${snapshotDoc.data![index].documents!.isNotEmpty ? snapshotDoc.data![index].documents![0].f2f_doc_created_at : '--'} AM PST by $loginName",
                                                    isContact: providerState.isContactTrue,
                                                    onPrintTap: () {},
                                                    onDownloadTap: () {},
                                                    onDeleteTap: () async{
                                                      bool dialogIsOpen = true;
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              StatefulBuilder(
                                                                builder: (BuildContext context, void Function(void Function())setDialogState) {
                                                                  return DeletePopup(
                                                                    loadingDuration: isLoading,
                                                                    title: 'Delete Document',
                                                                    onCancel: () {
                                                                      dialogIsOpen = false;
                                                                      Navigator.pop(context);
                                                                    },
                                                                    onDelete: () async {
                                                                      setState(() {
                                                                        isLoading = true;
                                                                      });
                                                                      if (dialogIsOpen) setDialogState(() {});
                                                                      try {
                                                                        var response =  await deleteFTwoFDocument(
                                                                          context: context,
                                                                          id: doc.f2f_doc_id,
                                                                        );
                                                                        if(response.statusCode == 200  || response.statusCode == 201) {
                                                                          dialogIsOpen = false;
                                                                          Navigator.pop(context);
                                                                          _loadFaceTwoFace();
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
                                                                            isLoading = false;
                                                                          });
                                                                        }
                                                                        if (dialogIsOpen) setDialogState(() {});
                                                                      }
                                                                    },
                                                                  );
                                                                },
                                                              ));
                                                    },

                                                    // async {
                                                    //   setState(() {
                                                    //     isLoading = true;
                                                    //   });
                                                    //   try {
                                                    //     var response = await deleteFTwoFDocument(
                                                    //       context: context,
                                                    //       id: doc.f2f_doc_id,
                                                    //     );
                                                    //     if (response.statusCode == 200 || response.statusCode == 201) {
                                                    //       showDialog(
                                                    //         context: context,
                                                    //         builder: (BuildContext context) => const DeleteSuccessPopup(),
                                                    //       );
                                                    //     }
                                                    //   } finally {
                                                    //     setState(() {
                                                    //       isLoading = false;
                                                    //     });
                                                    //   }
                                                    // },
                                                  );
                                                }).toList(),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    }else{
                                      return const SizedBox();
                                    }

                                  }
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomIconButtonConstzipcode(
                                    icon: Icons.add,
                                    width: AppSize.s150,
                                    color:  _areRequiredFieldsFilled() ? ColorManager.blueprime : Colors.grey,
                                    text: "Add Attachment",
                                    onPressed:
                                    _areRequiredFieldsFilled()
                                        ?
                                        () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AddF2FPopupConstant(
                                          title: 'Add Face to Face Attachment',
                                          ffDate: ffdateController.text,
                                          marketerId: marketerId,
                                          postOpDate: postOpDateController.text,
                                          visitNote: ffappoController.text,
                                          docTypeId: 0,
                                        ),
                                      ).then((_) => _loadFaceTwoFace());
                                    }
                                        : null, // disabled if not valid
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),),
                    const SizedBox(height: AppSize.s30,),
                    BlueBGHeadConst(HeadText: "Consents",
                    body: Column(
                      children: [
                        const SizedBox(height: AppSize.s10,),
                        StreamBuilder<List<PatientDocumentsConsentData>>(
                            stream: _streamControllerConsent.stream,
                            builder: (context,snapshotDoc) {
                              if(snapshotDoc.connectionState == ConnectionState.waiting){
                                return Center(
                                  child: SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator(color: ColorManager.blueprime,)),
                                );
                              }
                              if(snapshotDoc.data!.isEmpty){
                                return Center(
                                    child: Padding(
                                      padding:const EdgeInsets.symmetric(vertical: 76),
                                      child: Text(
                                        AppStringSMModule.patientDocNoData,
                                        style: AllNoDataAvailable.customTextStyle(context),
                                      ),
                                    ));
                              }
                              if(snapshotDoc.hasData){
                                return Container(
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: snapshotDoc.data!.length,
                                      itemBuilder: (context,index){
                                        return FileInfoCard(
                                          content: snapshotDoc.data![index].rptd_content,
                                          documentName: snapshotDoc.data![index].documentName,
                                          fileUrl: snapshotDoc.data![index].rptd_url,
                                          fileName: snapshotDoc.data![index].documentName,
                                          uploadedInfo: providerState.isContactTrue
                                              ? "Uploaded ${snapshotDoc.data![index].rptd_created_at}\nAM PST by $loginName"
                                              : "Uploaded ${snapshotDoc.data![index].rptd_created_at} AM PST by $loginName",
                                          isContact: providerState.isContactTrue,
                                          // onHistoryTap: () {},
                                          // onTelegramTap: () {},
                                          onPrintTap: () {},
                                          onDownloadTap: () {},
                                          onDeleteTap: () async{
                                            bool dialogIsOpen = true;
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    StatefulBuilder(
                                                      builder: (BuildContext context, void Function(void Function())setDialogState) {
                                                        return DeletePopup(
                                                          loadingDuration: isLoading,
                                                          title: 'Delete Document',
                                                          onCancel: () {
                                                            dialogIsOpen = false;
                                                            Navigator.pop(context);
                                                          },
                                                          onDelete: () async {
                                                            setState(() {
                                                              isLoading = true;
                                                            });
                                                            if (dialogIsOpen) setDialogState(() {});
                                                            try {
                                                              var response =  await deletePatientDocument(context: context, docId: snapshotDoc.data![index].rptd_id, );
                                                              if(response.statusCode == 200  || response.statusCode == 201) {
                                                                dialogIsOpen = false;
                                                                Navigator.pop(context);
                                                                _loadConsent();
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
                                                                  isLoading = false;
                                                                });
                                                              }
                                                              if (dialogIsOpen) setDialogState(() {});
                                                            }
                                                          },
                                                        );
                                                      },
                                                    ));
                                          },
                                        );
                                      }),
                                );
                              }else{
                                return const SizedBox();
                              }

                            }
                        ),
                        const SizedBox(height: AppSize.s20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconButtonConst(
                              icon: Icons.add,
                              width: AppSize.s150,
                              color: ColorManager.blueprime,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AddPopupConstant(title: 'Add Consents Attachment',docTypeId: FrontendConfigStore.data!.config.consent);
                                    // return AddPopupConstant(title: 'Add Consents Attachment',docTypeId: AppConfig.consent);
                                  },
                                ).then((_) => _loadConsent());
                              },
                              text: "Add Attachment",
                            ),

                          ],
                        ),
                      ],
                    ),),

                    const SizedBox(height: AppSize.s80),
                    ///
                    ///
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   spacing: 10,
                    //   children: [
                    //     CustomButtonTransparent(
                    //       text: "Cancel",
                    //       onPressed: () {
                    //
                    //       },
                    //     ),
                    //     CustomElevatedButton(
                    //       width: AppSize.s100,
                    //       text: AppString.save,
                    //       onPressed: (){},
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(height: AppSize.s30),
                  ],
                ),
              ),
            ),
          );
        }
    );

  }
}
