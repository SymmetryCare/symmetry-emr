import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/patient_insurance_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/patient_insurance_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_insurance/widgets/intake_insurance_primary/intake_insurance_primary_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_insurance/widgets/intake_insurance_secondary/intake_insurance_secondary_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_insurance/widgets/save_page/insurance_save_page.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/pdf_viewer.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_profile_tab/tab_screen/emr_insurance_tab/emr_primary_tab.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_profile_tab/tab_screen/emr_insurance_tab/emr_secondery_tab.dart';

class EmrIsuerenceTab extends StatefulWidget {
  final int patientId;
  const EmrIsuerenceTab({super.key, required this.patientId});

  @override
  State<EmrIsuerenceTab> createState() => _EmrIsuerenceTabState();
}

class _EmrIsuerenceTabState extends State<EmrIsuerenceTab> {
  int selectedIndex = 0;
  bool isSidebarLeftOpen = false;
  late AnimationController _animationLeftController;
  late Animation<Offset> _slideLeftAnimation;
  List<PatientInsuranceInfoData> insurancePatientData = [];
  int previousIndex = 0;

  // ── Cached "referred from" PDF text-extraction future — recomputed only
  // when the linked file actually changes, not on every rebuild ───────────
  String? _lastExtractedLinkOpen;
  late Future<String> _extractedTextFuture;
  @override
  void initState() {
    super.initState();
    fetchPrimaryInsuranceData(ptId: widget.patientId);
  }
  Future<void> fetchPrimaryInsuranceData({required int ptId}) async {
    final data = await getPatientInsuranceinfo(context: context, ptId: ptId);

    // check your condition
    final filled = data.isNotEmpty &&
        data[0].street.rptiStreet.isNotEmpty &&
        data[0].groupName.rptiGroupName.isNotEmpty &&
        data[0].email.rptiEmail.isNotEmpty &&
        data[0].rptiEffectiveFrom.isNotEmpty &&
        data[0].rptiEffectiveTo.isNotEmpty &&
        data[0].city.rptiCity.isNotEmpty;

    setState(() {
      insurancePatientData = data;
      previousIndex = filled ? 2 : 0;
      // jump to index 2 automatically
      if (filled) selectedIndex = 2;
    });
  }
  bool isShowingInsuranceSavePage = false;
  void switchToInsuranceSavePage() {
    setState(() {
      isShowingInsuranceSavePage = true;
    });
  }

  void goBackToInsuranceTabView() {
    setState(() {
      isShowingInsuranceSavePage = false;
    });
  }

  void selectButton(int index) {
    setState(() {
      previousIndex = selectedIndex;
      selectedIndex = index;
    });
  }
  Object? data;
  void toggleLeftSidebar() {
    setState(() {
      isSidebarLeftOpen = !isSidebarLeftOpen;
      if (isSidebarLeftOpen ) {
        _animationLeftController.forward();
      } else {
        _animationLeftController.reverse();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final providerContact = Provider.of<SmIntakeProviderManager>(context,listen: false);

    // FIX: only recompute the extraction future when the linked file
    // actually changes — previously this ran inline inside the
    // FutureBuilder below, re-firing on every rebuild of this tab.
    if (_lastExtractedLinkOpen != providerContact.isLinkeOpen) {
      _lastExtractedLinkOpen = providerContact.isLinkeOpen;
      _extractedTextFuture = extractTextFromPdf(providerContact.isLinkeOpen);
    }

    return Row(
      children: [
        isSidebarLeftOpen == true ? Flexible(
          flex: 0,
          child: AnimatedBuilder(
            animation: _slideLeftAnimation,
            builder: (context, child) {
              return SlideTransition(
                position: _slideLeftAnimation,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5,left: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.24,
                      color: Colors.white,
                      padding: const EdgeInsets.all(1),
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: MediaQuery.of(context).size.height,
                                minWidth: MediaQuery.of(context).size.height
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 100,),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5,bottom: 10,left: 20),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'Referred from ',
                                          style: CustomTextStylesCommon.commonStyle(
                                              color:const Color(0xFF686464),
                                              fontWeight: FontWeight.w700,fontSize: 12),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: '${providerContact.isLinkeFileName.toString()} ',
                                              style: CustomTextStylesCommon.commonStyle(
                                                  color:const Color(0xFF51B5E6),
                                                  fontWeight: FontWeight.w700,fontSize: 12),
                                            ),
                                            TextSpan(
                                              text: '(Page No.${providerContact.pageCountFromLink.toString()})',
                                              style: CustomTextStylesCommon.commonStyle(
                                                  color:const Color(0xFF51B5E6),
                                                  fontWeight: FontWeight.w700,fontSize: 12),
                                            ),

                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  FutureBuilder<String>(
                                      future: _extractedTextFuture,
                                      builder: (context,snapshot) {
                                        if(snapshot.connectionState == ConnectionState.waiting){
                                          return Padding(
                                            padding: const EdgeInsets.
                                            symmetric(vertical: 50),
                                            child: Center(
                                              child: SizedBox(
                                                height: 25,
                                                width: 25,
                                                child: CircularProgressIndicator(
                                                  color: ColorManager.blueprime,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        if(snapshot.data!.isEmpty){
                                          return Padding(
                                              padding: const EdgeInsets.
                                              symmetric(vertical: 50),
                                              child: Center(
                                                child: Text('No Data!',style: AllNoDataAvailable.customTextStyle(context),
                                                ),
                                              ));
                                        }
                                        return Container(
                                          width: MediaQuery.of(context).size.width / 1,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEEEEEE),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child:Container(
                                                color: Colors.white,
                                                padding: const EdgeInsets.all(10),
                                                child: Text(snapshot.data!,style: CustomTextStylesCommon.commonStyle(
                                                  color:const Color(0xFF686464),
                                                  fontWeight: FontWeight.w400,fontSize: 12,),),
                                              )

                                          ),
                                        );
                                      }
                                  ),
                                  const SizedBox(height: 100,),
                                ],
                              ),
                            ),
                          ),
                      ),

                    ),
                  ),
                ),
              );
            },
          ),
        )
            : const Offstage(),
        Flexible(
          child: Column(
            children: [
              const SizedBox(height: AppSize.s25,),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: AppSize.s30,
                      width: AppSize.s315,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 4),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                        color: ColorManager.blueprime,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Shift & Batch Button
                          InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onTap: () => selectButton(0),
                            child: Container(
                              height: AppSize.s30,
                              width: AppSize.s160,
                              decoration: BoxDecoration(
                                borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                                color: selectedIndex == 0 || (previousIndex == 0 && selectedIndex == 2)
                                    ? Colors.white
                                    : Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  'Primary',
                                  style: selectedIndex == 0 || (previousIndex == 0 && selectedIndex == 2) ? BlueBgTabbar.customTextStyle(
                                      0, 0) : BlueBgTabbar.customTextStyle(
                                      0, 1),
                                ),
                              ),
                            ),
                          ),
                          // Define Holiday Button
                          InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onTap: () {
                              selectButton(1);
                            },
                            child: Container(
                              height: AppSize.s30,
                              width: AppSize.s155,
                              decoration: BoxDecoration(
                                borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                                color: selectedIndex == 1 || (previousIndex == 1 && selectedIndex == 2)
                                    ? Colors.white
                                    : Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  'Secondary',
                                  style: selectedIndex == 1 || (previousIndex == 1 && selectedIndex == 2)? BlueBgTabbar.customTextStyle(
                                      1, 1):BlueBgTabbar.customTextStyle(
                                      1, 2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
              const SizedBox(
                height: 10,
              ),
              // Offstage (not PageView/Expanded) — this Column no longer sits
              // under a bounded-height ancestor, so it must size itself to
              // whichever sub-tab is selected rather than expand to fill.
              Offstage(
                offstage: selectedIndex != 0 && !(previousIndex == 0 && selectedIndex == 2),
                child: EMRPrimaryScreen(
                  patientId:widget.patientId,
                  onSave: (){
                    selectButton(2);
                  }
                  , onEditScreen: (){
                    selectButton(2);
                  },
                  isIButtonPressed: providerContact.isRightSliderOpen == true ?
                      (){
                  }
                      :(){
                    toggleLeftSidebar();
                    providerContact.toogleContactProvider();
                  }, onSkip: () {   selectButton(1); },

                ),
              ),
              Offstage(
                offstage: selectedIndex != 1 && !(previousIndex == 1 && selectedIndex == 2),
                child: EMRSecondaryScreen(
                  patientId:widget.patientId,
                  onSave: () {selectButton(2);  },
                  isIButtonPressed: providerContact.isRightSliderOpen == true ?
                      (){
                  }
                      :(){
                    toggleLeftSidebar();
                    providerContact.toogleContactProvider();
                    providerContact.toogleLeftSidebarProvider();
                  }, onSkip: () {  },),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
