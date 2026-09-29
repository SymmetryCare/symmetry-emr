import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_flow_contgainer_const.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/provider/async_data_controller.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/inirial_contact_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_initial_contact_data/initial_contact_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/constant_widgets/const_checckboxtile.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/schedular_textfield_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/dropdown_constant_sm.dart';

class SmIntakeInitialContactScreen extends StatelessWidget {
  final int patientId;
  final VoidCallback onOpenContact;
  const SmIntakeInitialContactScreen(
      {super.key, required this.patientId, required this.onOpenContact});

  @override
  Widget build(BuildContext context) {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
    return ChangeNotifierProvider<AsyncDataController<List<PatientInitialContactData>>>(
      create: (ctx) => AsyncDataController<List<PatientInitialContactData>>()
        ..load(() => getInitialContactWithPtid(context: ctx, ptId: diagnosisProvider.patientId)),
      child: _SmIntakeInitialContactScreenBody(
          patientId: patientId, onOpenContact: onOpenContact),
    );
  }
}

class _SmIntakeInitialContactScreenBody extends StatelessWidget {
  final int patientId;
  final VoidCallback onOpenContact;
  const _SmIntakeInitialContactScreenBody(
      {required this.patientId, required this.onOpenContact});

  @override
  Widget build(BuildContext context) {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
    bool isDementia = false;
    bool isCatheterCare = false;
    bool isWoundCare = false;
    bool isZenMed = false;
    bool isOrthoPatient = false;
    bool isPtInr = false;
    bool _isLoading = false;
    int initialContactId = 0;
    TextEditingController receivedDateController = TextEditingController();
    TextEditingController caseManagerController = TextEditingController();
    TextEditingController patientDcDateController = TextEditingController();
    return Consumer<SmIntakeProviderManager>(
        builder: (context,providerState,child) {
        return SingleChildScrollView(
          child: Consumer<AsyncDataController<List<PatientInitialContactData>>>(
              builder: (context,controller,child) {
                if(controller.isLoading){
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 100),
                    child: Center(
                      child: CircularProgressIndicator(color: ColorManager.blueprime,),
                    ),
                  );
                }
                final data = controller.data ?? <PatientInitialContactData>[];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: AppSize.s25, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('Review and confirm the data pulled is correct  ',
                                style: SMItalicTextConst.customTextStyle(context))
                          ],
                        ),
                      ),
                      BlueBGHeadConst(HeadText: "Call Details",
                      body: Column(
                        children: [
                          Container(
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: data.isEmpty ? 1 : data.length,
                                itemBuilder: (context,index) {
                                  isDementia = data.isEmpty? false:data[index].introCallComplete;
                                  isCatheterCare = data.isEmpty? false:data[index].demographicsConfirmed;
                                  isWoundCare = data.isEmpty? false:data[index].patientIsHome;
                                  isZenMed = data.isEmpty? false:data[index].consentsNeeded;
                                  isOrthoPatient = data.isEmpty? false:data[index].representativePresentSoc;
                                  isPtInr = data.isEmpty? false:data[index].sendConsentsForSign;
                                  // initialContactId = data[index].initialContactId;
                                  patientDcDateController = TextEditingController(text: data.isEmpty || data[index].potentialDcDate == '0000-00-00T00:00:00.000Z'? '':data[index].potentialDcDate);
                                  return Container(
                                      padding: const EdgeInsets.only(top: 60),
                                      height: 190,
                                      child: Row(
                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 30.0),
                                                    child: FloatingActionButton(
                                                      onPressed: onOpenContact,
                                                      backgroundColor: ColorManager
                                                          .blueprime, // Adjust color as needed
                                                      shape: const CircleBorder(),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          const Icon(
                                                            Icons.call,
                                                            size: 18,
                                                          ),
                                                          const SizedBox(
                                                            height: 2,
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(
                                                                horizontal: 1.0),
                                                            child: Text(
                                                              "Contact",
                                                              style:
                                                              CustomTextStylesCommon.commonStyle(
                                                                fontSize: FontSize.s9,
                                                                fontWeight: FontWeight.w500,
                                                                color: ColorManager.white,
                                                              ),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                          StatefulBuilder(
                                              builder: (BuildContext context, void Function(void Function())setState) {
                                                return Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            CheckboxTile(
                                                              title:'Intro Call Complete',
                                                              initialValue: isDementia,
                                                              onChanged: (value) {
                                                                setState((){
                                                                  isDementia = value;

                                                                });
                                                              },
                                                            ),
                                                            CheckboxTile(
                                                              title:providerState.isContactTrue?'Demographics\nConfirmed' :'Demographics Confirmed',
                                                              initialValue: isCatheterCare,
                                                              onChanged: (value) {
                                                                setState((){
                                                                  isCatheterCare = value;
                                                                });
                                                              },
                                                            )
                                                          ]),
                                                    ));}
                                          ),
                                          StatefulBuilder(
                                              builder: (BuildContext context, void Function(void Function())setState) {
                                                return Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      padding: const EdgeInsets.only(top: 20),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          CheckboxTile(
                                                            title: 'Patient is home',
                                                            initialValue: isWoundCare,
                                                            onChanged: (value) {
                                                              setState((){
                                                                isWoundCare = value;
                                                              });
                                                            },
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets.only(left: 8.0, top: 5),
                                                            child: SchedularTextField(
                                                              width: 215,
                                                              isIconVisible: true,
                                                              dateFormateMMDDYYYY: true,
                                                              controller: patientDcDateController,
                                                              labelText: 'Potential DC Date',
                                                              showDatePicker: true,
                                                              enable: false,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ));
                                              }),
                                          StatefulBuilder(
                                              builder: (BuildContext context, void Function(void Function())setState) {
                                                return Expanded(
                                                    flex: providerState.isContactTrue ? 3 : 2,
                                                    child: Container(
                                                      padding: const EdgeInsets.only(top: 20),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          CheckboxTile(
                                                            title: 'Consents Needed',
                                                            initialValue: isZenMed,
                                                            onChanged: (value) {
                                                              setState((){
                                                                isZenMed = value;
                                                              });
                                                            },
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 40),
                                                            child: ExpCheckboxTile(
                                                              title:
                                                              providerState.isContactTrue?'Patient representative will be\npresent at SOC':'Patient representative will be present at SOC',
                                                              initialValue: isOrthoPatient,
                                                              onChanged: (value) {
                                                                setState((){
                                                                  isOrthoPatient = value;
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 40),
                                                            child: SizedBox(
                                                              width: 300,
                                                              child: ExpCheckboxTile(
                                                                icon: Image.asset(
                                                                  "images/sm/sm_refferal/telegram.png",
                                                                  height: 18,
                                                                  width: 18,
                                                                ),
                                                                title: 'Send consents for signature',
                                                                initialValue: isPtInr,
                                                                isInfoIconVisible: true,
                                                                onChanged: (value) {
                                                                  setState((){
                                                                    isPtInr = value;
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ));}
                                          ),
                                        ],
                                      ));
                                }
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(),
                        ],
                      ),),

                      const SizedBox(height: 200,),
                      // BlueBGHeadConst(HeadText: "Scheduling Requests"),
                      // Container(
                      //   height: 250,
                      //   padding: EdgeInsets.only(top: 50, left: 28, bottom: 20),
                      //   child: Column(
                      //     children: [
                      //       Padding(
                      //         padding: const EdgeInsets.only(top: 8.0),
                      //         child: Row(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             Flexible(
                      //               child: CustomDropdownTextFieldsm(
                      //                // width:  providerState.isContactTrue ? AppSize.s150 :AppSize.s210,
                      //                 isIconVisible: false,
                      //                 headText: 'User',
                      //                 onChanged: (newValue) {},
                      //               ),
                      //             ),
                      //             SizedBox(width: providerState.isContactTrue ? AppSize.s35 : AppSize.s70),
                      //             Flexible(
                      //               child: CustomDropdownTextFieldsm(
                      //                // width: providerState.isContactTrue ? AppSize.s150 :AppSize.s210,
                      //                 isIconVisible: false,
                      //                 headText: 'Gender',
                      //                 onChanged: (newValue) {},
                      //               ),
                      //             ),
                      //             SizedBox(width: providerState.isContactTrue ? AppSize.s35 : AppSize.s70),
                      //             Flexible(
                      //               child: CustomDropdownTextFieldsm(
                      //                 //width: providerState.isContactTrue ? AppSize.s150 :AppSize.s210,
                      //                 isIconVisible: false,
                      //                 headText: 'Language',
                      //                 onChanged: (newValue) {},
                      //               ),
                      //             ),
                      //             providerState.isContactTrue ?Offstage() : SizedBox(width: providerState.isContactTrue ? AppSize.s35 : AppSize.s70),
                      //             providerState.isContactTrue ? Offstage() : Flexible(
                      //               child: SchedularTextField(
                      //               //  width: providerState.isContactTrue ? AppSize.s150 :AppSize.s210,
                      //                 isIconVisible: true,
                      //                 enable: false,
                      //                 controller: receivedDateController,
                      //                 labelText: 'Select Date',
                      //                 showDatePicker: true,
                      //               ),
                      //             ),
                      //             SizedBox(width: providerState.isContactTrue ? AppSize.s35 : AppSize.s70),
                      //           ],
                      //         ),
                      //       ),
                      //       SizedBox(
                      //         height: 40,
                      //       ),
                      //       Row(
                      //         children: [
                      //           providerState.isContactTrue
                      //               ? Flexible(
                      //             child: SchedularTextField(
                      //               width: AppSize.s240,
                      //               isIconVisible: true,
                      //               enable: false,
                      //               controller: receivedDateController,
                      //               labelText: 'Select Date',
                      //               showDatePicker: true,
                      //             ),
                      //           )
                      //               : Offstage(),
                      //           providerState.isContactTrue
                      //               ?  SizedBox(width: AppSize.s35,)   : Offstage(),
                      //           Row(
                      //             children: [
                      //               Padding(
                      //                   padding: EdgeInsets.only(top: 20, right: 20),
                      //                   child: Text('Notes',
                      //                       style:
                      //                           SMTextfieldHeadings.customTextStyle(context)
                      //                       //AllPopupHeadings.customTextStyle(context)
                      //                       )),
                      //               SchedularTextField(
                      //                 isIconVisible: true,
                      //                 width: 395,
                      //                 enable: false,
                      //                 controller: caseManagerController,
                      //                 labelText: '',
                      //               )
                      //             ],
                      //           ),
                      //
                      //         ],
                      //       )
                      //     ],
                      //   ),
                      // ),
                      // Divider(),
                      // SizedBox(height: AppSize.s100),
                      StatefulBuilder(
                          builder: (BuildContext context, void Function(void Function())setState) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 10,
                              children: [
                                CustomButtonTransparent(
                                  text: "Skip",
                                  onPressed: () {},
                                ),
                                CustomElevatedButton(
                                  width: AppSize.s100,
                                  text: AppString.save,
                                  isLoading: _isLoading,
                                  onPressed: () async{
                                    String? patientDcDate;
                                    try{
                                      DateTime _parseMMDDYYYY(String dateStr) {
                                        final parts = dateStr.split('/'); // [MM, DD, YYYY]
                                        if (parts.length != 3) {
                                          throw FormatException('Invalid date format: $dateStr');
                                        }
                                        final month = int.parse(parts[0]);
                                        final day = int.parse(parts[1]);
                                        final year = int.parse(parts[2]);
                                        return DateTime(year, month, day);
                                      }

// Use it:
                                      final receivedDate = _parseMMDDYYYY(patientDcDateController.text);
                                      patientDcDate = receivedDate.toUtc().toIso8601String();

                                      setState((){
                                        _isLoading = true;
                                      });
                                      print('Patient Id ${patientId}');
                                      print('Patient Id ${isDementia}');
                                      print('Patient Id ${isWoundCare}');
                                      print('Patient Id ${isZenMed}');
                                      print('Patient Id ${isCatheterCare}');
                                      print('Patient Id ${patientDcDate}');
                                      print('Patient Id ${isPtInr}');
                                      print('Patient Id ${isOrthoPatient}');
                                      var response = data.isEmpty ?
                                     await addPatientinitialContact(
                                          context: context,
                                          ptId: diagnosisProvider.patientId,
                                          introCallComplete: isDementia,
                                          patientIsHome: isWoundCare,
                                          consentsNeeded: isZenMed,
                                          demographicsConfirmed: isCatheterCare,
                                          potentialDcDate:patientDcDate.isEmpty ?'0000-00-00':patientDcDate,
                                          sendConsentsForSign: isPtInr,
                                          representativePresentSoc: isOrthoPatient):
                                     await updatePatientinitialContact(
                                          context: context,
                                          id: data[0].initialContactId,
                                          ptId: diagnosisProvider.patientId,
                                          introCallComplete: isDementia,
                                          patientIsHome: isWoundCare,
                                          consentsNeeded: isZenMed,
                                          demographicsConfirmed: isCatheterCare,
                                          potentialDcDate: patientDcDate,
                                          sendConsentsForSign: isPtInr,
                                          representativePresentSoc: isOrthoPatient);

                                      if(response.statusCode == 200 || response.statusCode == 201){
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return const AddSuccessPopup(
                                              message: 'Initial Contact Added Successfully',
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
                                        print('API error: ${response.message}');
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
                            );}
                      ),
                     const SizedBox(height: AppSize.s30),
                    ],
                  ),
                );
              }
          ),
        );
      }
    );
  }
}
