import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
import 'package:symmetry_emr/modules/emr/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/patient_insurance_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/patient_insurance_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/onboarding/download_doc_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_flow_contgainer_const.dart';
class InsuranceSavePage extends StatelessWidget {
  final VoidCallback onPrimaryBack;
  final VoidCallback onSecondBack;
  final int patientId;
   const InsuranceSavePage(
      {super.key, required this.patientId, required this.onPrimaryBack, required this.onSecondBack,});

  @override
  Widget build(BuildContext context) {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
    return ChangeNotifierProvider<AsyncDataController<List<PatientInsuranceInfoData>>>(
      create: (ctx) => AsyncDataController<List<PatientInsuranceInfoData>>()
        ..load(() => getPatientInsuranceinfo(context: ctx, ptId: diagnosisProvider.patientId)),
      child: _InsuranceSavePageBody(onPrimaryBack: onPrimaryBack, onSecondBack: onSecondBack),
    );
  }
}

class _InsuranceSavePageBody extends StatefulWidget {
  final VoidCallback onPrimaryBack;
  final VoidCallback onSecondBack;
  const _InsuranceSavePageBody({required this.onPrimaryBack, required this.onSecondBack});

  @override
  State<_InsuranceSavePageBody> createState() => _InsuranceSavePageBodyState();
}

// FIX: was a StatelessWidget with the StreamControllers created fresh inside
// build() and the fetches fired directly in each StreamBuilder's builder: —
// that meant a brand-new controller (and a new network request) on every
// rebuild. Converted to State so the controllers persist and the fetches run
// once in initState.
class _InsuranceSavePageBodyState extends State<_InsuranceSavePageBody> {
  final StreamController<List<PatientInsuranceDocumentData>> _streamControllerDoc = StreamController<List<PatientInsuranceDocumentData>>.broadcast();
  final StreamController<List<PatientSecondInsuranceDocumentData>> _streamSecControllerDoc = StreamController<List<PatientSecondInsuranceDocumentData>>.broadcast();
  // FIX: hoisted out of build() — a build()-local bool gets a brand new
  // instance (reset to false) on every rebuild, which orphaned in-flight
  // delete closures from what was actually on screen.
  bool _isLoading = false;
  // FIX: guards the one-time re-fetch below — see its comment.
  bool _hasReloadedDocs = false;

  void _loadPrimaryDoc() {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
    getPatientEmergencyContact(context: context,
      ptId: diagnosisProvider.patientId, isPrimary: true,).then((data) {
      _streamControllerDoc.add(data);
    }).catchError((error) {
      // Handle error
    });
  }

  void _loadSecondaryDoc() {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
    getPatientInsuranceDoc(context: context,
      ptId: diagnosisProvider.patientId,
    ).then((data) {
      _streamSecControllerDoc.add(data);
    }).catchError((error) {
      // Handle error
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPrimaryDoc();
    _loadSecondaryDoc();
  }

  @override
  void dispose() {
    _streamControllerDoc.close();
    _streamSecControllerDoc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print('Passed object data ${patientData}');
    return Consumer<AsyncDataController<List<PatientInsuranceInfoData>>>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return Center(
              child: CircularProgressIndicator(color: ColorManager.blueprime,)
          );
        }
        // FIX: the Attachments sections' StreamBuilders (further down this
        // same builder) only exist once we get past the controller.isLoading
        // check above. _loadPrimaryDoc()/_loadSecondaryDoc() were fired from
        // initState() in parallel with this controller's own fetch — if
        // either won that race and resolved first, it added its one-and-only
        // event to a broadcast stream that had no listener yet (this whole
        // subtree, including the StreamBuilders, hadn't been built), and
        // that event was silently dropped. Re-fetching once we know the
        // StreamBuilders are about to actually mount guarantees they're
        // listening in time.
        if (!_hasReloadedDocs) {
          _hasReloadedDocs = true;
          _loadPrimaryDoc();
          _loadSecondaryDoc();
        }
        return Consumer<SmIntakeProviderManager>(
            builder: (context,providerstate,child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Review and confirm the data pulled is correct',
                            style: SMItalicTextConst.customTextStyle(context))
                      ],
                    ),
                    //SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Insurance I',
                            style: CustomTextStylesCommon.commonStyle(
                              //  color:Color(0xFF575757),
                              fontSize: FontSize.s16,
                              fontWeight: FontWeight.w700,
                              color: ColorManager.mediumgrey,
                            ))
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    BlueBGHeadConst(HeadText: "Policy Details",
                    body: Column(
                      children: [  Container(
                        height: 320,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 120,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF008000),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Verified",
                                            style: CustomTextStylesCommon.commonStyle(
                                              //  color:Color(0xFF575757),
                                              fontSize: FontSize.s12,
                                              fontWeight: FontWeight.w700,
                                              color: ColorManager.white,
                                            )),
                                        Image.asset(
                                          "images/sm/white_tik.png",
                                          height: 20,
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text('Name:',
                                            style: DocDefineTableData.customTextStyle(
                                                context)),
                                        const SizedBox(
                                          height: AppSize.s15,
                                        ),
                                        Text('Code:',
                                            style: DocDefineTableData.customTextStyle(
                                                context)),
                                        // const SizedBox(height: AppSize.s15),
                                        // Text('Street:',
                                        //     style: DocDefineTableData.customTextStyle(
                                        //         context)),
                                        const SizedBox(height: AppSize.s15),
                                        Text('Street:',
                                            style: DocDefineTableData.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15,),
                                        Text('Suite/Apt#:',
                                            style: DocDefineTableData.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15,),
                                        Text('City:',
                                            style: DocDefineTableData.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15),
                                        Text('State:',
                                            style: DocDefineTableData.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15),
                                        Text('Zip Code:',
                                            style: DocDefineTableData.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15),
                                        Text('Phone Number:',
                                            style: DocDefineTableData.customTextStyle(
                                                context)),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 60,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(controller.data![0].name.rptiName ?? '',
                                            style: ThemeManagerDarkFont.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15,),
                                        Text(controller.data![0].groupNumber.rptiGroupNumber.toString() ?? '',
                                            style: ThemeManagerDarkFont.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15),
                                        Text(controller.data![0].street.rptiStreet ?? '',
                                            style: ThemeManagerDarkFont.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15),
                                        Text(controller.data![0].suite.rptiSuite ?? '',
                                            style: ThemeManagerDarkFont.customTextStyle(
                                                context)),
                                        const SizedBox(
                                          height: AppSize.s15,
                                        ),
                                        Text(controller.data![0].city.rptiCity ?? '',
                                            style: ThemeManagerDarkFont.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15),
                                        Text(controller.data![0].state.rptiState ?? '',
                                            style: ThemeManagerDarkFont.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15),
                                        Text(controller.data![0].zipcode.rptiZipcode ?? '',
                                            style: ThemeManagerDarkFont.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15),
                                        Text(controller.data![0].contact.rptiContact ?? '',
                                            style: ThemeManagerDarkFont.customTextStyle(
                                                context)),
                                      ],
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text('Category:',
                                            style: DocDefineTableData.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15,),
                                        Text('Type:',
                                            style: DocDefineTableData.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15),
                                        Text('Policy/HIC Number:',
                                            style: DocDefineTableData.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15),
                                        Text('Group Number:',
                                            style: DocDefineTableData.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15,),
                                        Text('Group Name:',
                                            style: DocDefineTableData.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15,),
                                        Text('Effective From:',
                                            style: DocDefineTableData.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15),
                                        Text('Effective To:',
                                            style: DocDefineTableData.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15),
                                        Text('',
                                            style: ThemeManagerDark.customTextStyle(
                                                context)),

                                      ],
                                    ),
                                    const SizedBox(
                                      width: 60,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(controller.data![0].category.rptiCategory ?? '',
                                            style: ThemeManagerDarkFont.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15,),
                                        Text(controller.data![0].type.rptiType ?? '',
                                            style: ThemeManagerDarkFont.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15),
                                        Text(controller.data![0].policy.rptiPolicy ?? '',
                                            style: ThemeManagerDarkFont.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15),
                                        Text(controller.data![0].groupNumber.rptiGroupNumber.toString() ?? '',
                                            style: ThemeManagerDarkFont.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15,),
                                        Text(controller.data![0].groupName.rptiGroupName ?? '',
                                            style: ThemeManagerDarkFont.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15,),
                                        Text(controller.data![0].rptiEffectiveFrom ?? '',
                                            style: ThemeManagerDarkFont.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15),
                                        Text(controller.data![0].rptiEffectiveTo ?? '',
                                            style: ThemeManagerDarkFont.customTextStyle(
                                                context)),
                                        const SizedBox(height: AppSize.s15),
                                        Text('',
                                            style: ThemeManagerDarkFont.customTextStyle(
                                                context)),

                                      ],
                                    )
                                  ],
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        //mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text('Auth Status:',
                                              style: DocDefineTableData.customTextStyle(
                                                  context)),
                                          const SizedBox(
                                            height: AppSize.s15,
                                          ),
                                          Text('Eligibility Status:',
                                              style: DocDefineTableData.customTextStyle(
                                                  context)),
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 60,
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        // mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(controller.data![0].rptiAuthorization ? 'NOT REQUIRED' : 'REQUIRED',
                                              style: CustomTextStylesCommon.commonStyle(
                                                //  color:Color(0xFF575757),
                                                fontSize: FontSize.s12,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xff04BF00),
                                              )),
                                          const SizedBox(height: AppSize.s15,),
                                          Text(controller.data![0].rptiVerified ? 'Active Coverage' : 'Inactive Coverage',
                                              style: ThemeManagerDarkFont.customTextStyle(context)),
                                        ],
                                      )
                                    ],
                                  ),
                                ),

                                ///
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(right: 20, bottom: 200),
                                      child: IconButton(
                                        onPressed: () {
                                          widget.onPrimaryBack();
                                        },
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          color: ColorManager.blueprime,
                                          size: IconSize.I22,
                                        ),
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                        const Divider(),
                      ],
                    )),

                    const SizedBox(
                      height: 20,
                    ),
                    BlueBGHeadConst(HeadText: "Suggested Care & Diagnosis",
                    body: Container(),),
                    const SizedBox(
                      height: 30,
                    ),
                    BlueBGHeadConst(HeadText: "Attachments",
                    body:  StreamBuilder<List<PatientInsuranceDocumentData>>(
                        stream: _streamControllerDoc.stream,
                        builder: (context, snapshotDocPrimary){
                          if(snapshotDocPrimary.connectionState == ConnectionState.waiting){
                            return Center(
                              child: CircularProgressIndicator(color: ColorManager.blueprime,),
                            );
                          }
                          if(snapshotDocPrimary.data!.isEmpty){
                            return Center(
                                child: Padding(
                                  padding:const EdgeInsets.symmetric(vertical: 76),
                                  child: Text(
                                    AppStringSMModule.patientInsuranceDocNoData,
                                    style: AllNoDataAvailable.customTextStyle(context),
                                  ),
                                ));
                          }
                          if(snapshotDocPrimary.hasData){
                            return  Container(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshotDocPrimary.data!.length,
                                  itemBuilder: (context,index) {
                                    var fileUrl = snapshotDocPrimary.data![index].docUrl;
                                    var formatedData = DateFormat('yyyy/MM/dd').format(snapshotDocPrimary.data![index].createdAt);
                                    return snapshotDocPrimary.data![index].isPrimary != true? const Offstage():Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 40.0,vertical: 10),
                                      child: Container(
                                        height: AppSize.s65,
                                        // padding: const EdgeInsets.symmetric(horizontal: AppPadding.p30, vertical: AppPadding.p15),
                                        decoration: BoxDecoration(
                                          color: ColorManager.white,
                                          // borderRadius: BorderRadius.circular(5),
                                          // border: Border.symmetric(vertical: BorderSide(width: 0.2,color: ColorManager.grey),horizontal: BorderSide(width: 0.2,color: ColorManager.grey),),//all(width: 1, color: Color(0xFFBCBCBC)),
                                          border: Border(
                                            bottom: BorderSide(width: 0.5,color: ColorManager.lightGrey),
                                          ),//all(width: 1, color: Color(0xFFBCBCBC)),
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
                                                  Text('${snapshotDocPrimary.data![index].docName}',
                                                      style: DocDefineTableData.customTextStyle(context)),
                                                  const SizedBox(height: AppSize.s8,),
                                                  Text("Uploaded $formatedData, ${DateFormat.jm().format(snapshotDocPrimary.data![index].createdAt)} PST by ${snapshotDocPrimary.data![index].updatedBy}",
                                                      style: TextStyle(
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
                                              // InkWell(
                                              //   splashColor: Colors.transparent,
                                              //   highlightColor: Colors.transparent,
                                              //   hoverColor: Colors.transparent,
                                              //   child: Image.asset("images/sm/telegram.png", height:  providerstate.isContactTrue?IconSize.I20 :IconSize.I22,),
                                              //   onTap: () {
                                              //   },
                                              // ),
                                              // const SizedBox(width: AppSize.s10,),
                                              IconButton(
                                                splashColor: Colors.transparent,
                                                highlightColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                onPressed: () {
                                                  downloadFile(context: context,
                                                      fileUrl: fileUrl,
                                                      documentName:snapshotDocPrimary.data![index].docName,
                                                      apiPath: DownloadDocumentRepository.getPatientInsuranceDocumentByFileName());
                                                },
                                                icon: const Icon(
                                                  Icons.print_outlined,
                                                  color: Color(0xFF686464),
                                                ),
                                                iconSize: providerstate.isContactTrue?IconSize.I20 :IconSize.I22,
                                              ),
                                              const SizedBox(width: AppSize.s10,),
                                              ///download
                                              PdfDownloadButton(
                                                apiPath: DownloadDocumentRepository.getPatientInsuranceDocumentByFileName(),
                                                apiUrl: snapshotDocPrimary.data![0].docUrl,// policiesdata.docurl,
                                                iconsize: IconSize.I22,
                                                documentName: snapshotDocPrimary.data![0].docName,
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
                                                                loadingDuration: _isLoading,
                                                                title: 'Delete Document',
                                                                onCancel: () {
                                                                  dialogIsOpen = false;
                                                                  Navigator.pop(context);
                                                                },
                                                                onDelete: () async {
                                                                  setState(() {
                                                                    _isLoading = true;
                                                                  });
                                                                  if (dialogIsOpen) setDialogState(() {});
                                                                  try {
                                                                    var response =  await deletePatientInsuranceDocument(context: context, documentId: snapshotDocPrimary.data![index].insuranceDocumentId, );
                                                                    if(response.statusCode == 200  || response.statusCode == 201) {
                                                                      dialogIsOpen = false;
                                                                      Navigator.pop(context);
                                                                      _loadPrimaryDoc();
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
                                                                        _isLoading = false;
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
                                                iconSize:providerstate.isContactTrue?IconSize.I20 :IconSize.I22,
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
                    ),),

                    const SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Insurance II',
                            style: CustomTextStylesCommon.commonStyle(
                              //  color:Color(0xFF575757),
                              fontSize: FontSize.s16,
                              fontWeight: FontWeight.w700,
                              color: ColorManager.mediumgrey,
                            ))
                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                    BlueBGHeadConst(HeadText: "Policy Details",
                    body: Column(
                      children: [
                        Container(
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: controller.data!.length - 1,
                              itemBuilder: (context,index) {
                                final item = controller.data![index + 1];
                                return Container(
                                  height: 320,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: 120,
                                            height: 30,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF008000),
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(10),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text("Verified",
                                                      style: CustomTextStylesCommon.commonStyle(
                                                        //  color:Color(0xFF575757),
                                                        fontSize: FontSize.s12,
                                                        fontWeight: FontWeight.w700,
                                                        color: ColorManager.white,
                                                      )),
                                                  Image.asset(
                                                    "images/sm/white_tik.png",
                                                    height: 20,
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text('Name:',
                                                      style: DocDefineTableData.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15,),
                                                  Text('Code:',
                                                      style: DocDefineTableData.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15),
                                                  Text('Street:',
                                                      style: DocDefineTableData.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15,),
                                                  Text('Suite/Apt#:',
                                                      style: DocDefineTableData.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15,),
                                                  Text('City:',
                                                      style: DocDefineTableData.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15),
                                                  Text('State:',
                                                      style: DocDefineTableData.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15),
                                                  Text('Zip Code:',
                                                      style: DocDefineTableData.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15),
                                                  Text('Phone Number:',
                                                      style: DocDefineTableData.customTextStyle(
                                                          context)),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 60,
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(item.name.rptiName,
                                                      style: ThemeManagerDarkFont.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15,),
                                                  Text(item.groupNumber.rptiGroupNumber.toString(),
                                                      style: ThemeManagerDarkFont.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15),
                                                  Text(item.street.rptiStreet,
                                                      style: ThemeManagerDarkFont.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15,),
                                                  Text(item.suite.rptiSuite,
                                                      style: ThemeManagerDarkFont.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15,),
                                                  Text(item.city.rptiCity,
                                                      style: ThemeManagerDarkFont.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15),
                                                  Text(item.state.rptiState,
                                                      style: ThemeManagerDarkFont.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15),
                                                  Text(item.zipcode.rptiZipcode,
                                                      style: ThemeManagerDarkFont.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15),
                                                  Text(item.contact.rptiContact,
                                                      style: ThemeManagerDarkFont.customTextStyle(
                                                          context)),
                                                ],
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text('Category:',
                                                      style: DocDefineTableData.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15,),
                                                  Text('Type:',
                                                      style: DocDefineTableData.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15),
                                                  Text('Policy/HIC Number:',
                                                      style: DocDefineTableData.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15),
                                                  Text('Group Number:',
                                                      style: DocDefineTableData.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15,),
                                                  Text('Group Name:',
                                                      style: DocDefineTableData.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15,),
                                                  Text('Effective From:',
                                                      style: DocDefineTableData.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15),
                                                  Text('Effective To:',
                                                      style: DocDefineTableData.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15),
                                                  Text('',
                                                      style: ThemeManagerDark.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15),
                                                  Text('',
                                                      style: DocDefineTableData.customTextStyle(
                                                          context)),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 60,
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(item.category.rptiCategory,
                                                      style: ThemeManagerDarkFont.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15,),
                                                  Text(item.type.rptiType,
                                                      style: ThemeManagerDarkFont.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15),
                                                  Text(item.policy.rptiPolicy,
                                                      style: ThemeManagerDarkFont.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15),
                                                  Text(item.groupNumber.rptiGroupNumber.toString(),
                                                      style: ThemeManagerDarkFont.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15,),
                                                  Text(item.groupName.rptiGroupName,
                                                      style: ThemeManagerDarkFont.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15,),
                                                  Text(item.rptiEffectiveFrom,
                                                      style: ThemeManagerDarkFont.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15),
                                                  Text(item.rptiEffectiveTo,
                                                      style: ThemeManagerDarkFont.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15),
                                                  Text('',
                                                      style: ThemeManagerDarkFont.customTextStyle(
                                                          context)),
                                                  const SizedBox(height: AppSize.s15),
                                                  Text('',
                                                      style: DocDefineTableData.customTextStyle(
                                                          context)),
                                                ],
                                              )
                                            ],
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 30.0),
                                            child: Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  //mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text('Auth Status:',
                                                        style: DocDefineTableData.customTextStyle(
                                                            context)),
                                                    const SizedBox(
                                                      height: AppSize.s15,
                                                    ),
                                                    Text('Eligibility Status:',
                                                        style: DocDefineTableData.customTextStyle(
                                                            context)),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  width: 60,
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  // mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(item.rptiAuthorization ? 'NOT REQUIRED' : 'REQUIRED',
                                                        style: CustomTextStylesCommon.commonStyle(
                                                          //  color:Color(0xFF575757),
                                                          fontSize: FontSize.s12,
                                                          fontWeight: FontWeight.w700,
                                                          color: const Color(0xff04BF00),
                                                        )),
                                                    const SizedBox(
                                                      height: AppSize.s15,
                                                    ),
                                                    Text(item.rptiVerified ? 'Active Coverage' : 'Inactive Coverage',
                                                        style: ThemeManagerDarkFont.customTextStyle(context)),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),

                                          ///
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(right: 20, bottom: 200),
                                                child: IconButton(
                                                  onPressed: () {
                                                    widget.onSecondBack();
                                                  },
                                                  icon: Icon(
                                                    Icons.edit_outlined,
                                                    color: ColorManager.blueprime,
                                                    size: IconSize.I22,
                                                  ), splashColor: Colors.transparent,
                                                  highlightColor: Colors.transparent,
                                                  hoverColor: Colors.transparent,
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }
                          ),
                        ),
                        const Divider(),
                      ],
                    )),


                    const SizedBox(
                      height: 20,
                    ),
                    BlueBGHeadConst(HeadText: "Suggested Care & Diagnosis",body: Container(),),
                    const SizedBox(
                      height: 30,
                    ),
                    BlueBGHeadConst(HeadText: "Attachments",
                    body: StreamBuilder<List<PatientSecondInsuranceDocumentData>>(
                        stream: _streamSecControllerDoc.stream,
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
                          } if (snapshotDoc.hasData) {
                            // Step 1: Filter primary items
                            final secondDocs = snapshotDoc.data!
                                .where((doc) => doc.isPrimary == false)
                                .toList();

                            // Step 2: Get count
                            final primaryCount = secondDocs.length;

                            // Optionally use `primaryCount` somewhere in UI
                            // e.g., print("Primary documents count: $primaryCount");
                            // if (snapshotDoc.data!.length <= 1) {
                            //   return Container(
                            //     height: 60,
                            //     child: Center(child: Text('No attachments uploaded!',
                            //     style:  CustomTextStylesCommon.commonStyle(
                            //         color: ColorManager.mediumgrey,
                            //         fontSize: FontSize.s14,
                            //         fontWeight: FontWeight.w700),)),
                            //   ); // Nothing to show beyond index 0
                            // }
                            return Container(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: primaryCount, // ← adjust count
                                itemBuilder: (context, index) {
                                  var doc = snapshotDoc.data![index]; // ← safe now
                                  final fileUrl = doc.docUrl;
                                  final formatedDate = DateFormat('yyyy/MM/dd').format(doc.createdAt);
                                  final time = DateFormat.jm().format(doc.createdAt);

                                  print("document Second name backend ${doc.docName}");
                                  return  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10),
                                    child: Container(
                                      height: AppSize.s65,
                                      decoration: BoxDecoration(
                                        color: ColorManager.white,
                                        border: Border(
                                          bottom: BorderSide(width: 0.5, color: ColorManager.lightGrey),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const VerticalDivider(
                                                color: Color(0xFF50B5E5),
                                                thickness: 4.5,
                                              ),
                                              const SizedBox(width: AppSize.s20),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('${doc.docName}',
                                                      style: DocDefineTableData.customTextStyle(context)),
                                                  const SizedBox(height: AppSize.s8),
                                                  Text("Uploaded $formatedDate, $time PST by ${doc.updatedBy}",
                                                      style: TextStyle(
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
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  downloadFile(context: context,
                                                      fileUrl: fileUrl,
                                                      documentName:doc.docName,
                                                      apiPath: DownloadDocumentRepository.getPatientInsuranceDocumentByFileName());
                                                },
                                                icon: const Icon(Icons.print_outlined, color: Color(0xFF686464)),
                                                iconSize: providerstate.isContactTrue ? IconSize.I20 : IconSize.I22,
                                              ),
                                              const SizedBox(width: AppSize.s10),
                                              PdfDownloadButton(
                                                apiPath: DownloadDocumentRepository.getPatientInsuranceDocumentByFileName(),
                                                apiUrl: doc.docUrl,
                                                iconsize: IconSize.I22,
                                                documentName: doc.docName,
                                                iconColor: const Color(0xFF686464),
                                              ),
                                              const SizedBox(width: AppSize.s10),
                                              IconButton(
                                                onPressed: () async {
                                                  bool dialogIsOpen = true;
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => StatefulBuilder(
                                                      builder: (BuildContext context, void Function(void Function()) setDialogState) {
                                                        return DeletePopup(
                                                          loadingDuration: _isLoading,
                                                          title: 'Delete Document',
                                                          onCancel: () {
                                                            dialogIsOpen = false;
                                                            Navigator.pop(context);
                                                          },
                                                          onDelete: () async {
                                                            setState(() {
                                                              _isLoading = true;
                                                            });
                                                            if (dialogIsOpen) setDialogState(() {});
                                                            try {
                                                              var response = await deletePatientInsuranceDocument(
                                                                context: context,
                                                                documentId: doc.insuranceDocumentId,
                                                              );
                                                              if (response.statusCode == 200 || response.statusCode == 201) {
                                                                dialogIsOpen = false;
                                                                Navigator.pop(context);
                                                                _loadSecondaryDoc();
                                                                if (mounted) {
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (context) => const DeleteSuccessPopup(),
                                                                  );
                                                                }
                                                              }
                                                            } finally {
                                                              if (mounted) {
                                                                setState(() {
                                                                  _isLoading = false;
                                                                });
                                                              }
                                                              if (dialogIsOpen) setDialogState(() {});
                                                            }
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(Icons.delete_outline, color: Color(0xFF686464)),
                                                iconSize: providerstate.isContactTrue ? IconSize.I20 : IconSize.I22,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                          else{
                            return const SizedBox();
                          }
                        }
                    ),),
                    const SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }
}
