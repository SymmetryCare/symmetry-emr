import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/sm_intake_manager/intake_demographics/intake_demographic_dropdown_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/scheduler_create_data/create_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/schedular_textfield_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/pdf_viewer.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_profile_tab/const_textfiled_emr.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_profile_tab/tab_screen/emr_demographics_tab/emr_patient_info.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_profile_tab/tab_screen/emr_demographics_tab/emr_related_party.dart';

class EmrDemographicsTab extends StatefulWidget {
  final int patientId;
  const EmrDemographicsTab({super.key, required this.patientId});

  @override
  State<EmrDemographicsTab> createState() => _EmrDemographicsTabState();
}

class _EmrDemographicsTabState extends State<EmrDemographicsTab>
    with TickerProviderStateMixin {
  int selectedIndex = 0;

  String? selectedStatus;
  String? selectedCountry;
  String? selectedState;

  final TextEditingController dummyCtrl = TextEditingController();

  late Future<List<StateData>> _stateFuture;
  late Future<List<CountryData>> _countryFuture;

  // ── Cached "referred from" PDF text-extraction future — recomputed only
  // when the linked file actually changes, not on every rebuild ───────────
  String? _lastExtractedLinkOpen;
  late Future<String> _extractedTextFuture;

  // ── Left "referred from" sidebar (same pattern as SmIntakeDemographicsScreen) ──
  bool isSidebarLeftOpen = false;
  late AnimationController _animationLeftController;
  late Animation<Offset> _slideLeftAnimation;

  @override
  void initState() {
    super.initState();
    _stateFuture = getStateDropDown(context);
    _countryFuture = getCountryDropDown(context);

    _animationLeftController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideLeftAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
        parent: _animationLeftController, curve: Curves.easeInOut));
  }

  // ✅ Exact same toggle pattern as SmIntakeDemographicsScreen
  void toggleLeftSidebar() {
    setState(() {
      isSidebarLeftOpen = !isSidebarLeftOpen;
      if (isSidebarLeftOpen) {
        _animationLeftController.forward();
      } else {
        _animationLeftController.reverse();
      }
    });
  }

  void selectButton(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  void dispose() {
    dummyCtrl.dispose();
    _animationLeftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providerContact =
    Provider.of<SmIntakeProviderManager>(context, listen: false);

    // FIX: only recompute the extraction future when the linked file
    // actually changes — previously this ran inline inside the
    // FutureBuilder below, re-firing on every rebuild of this tab.
    if (_lastExtractedLinkOpen != providerContact.isLinkeOpen) {
      _lastExtractedLinkOpen = providerContact.isLinkeOpen;
      _extractedTextFuture = extractTextFromPdf(providerContact.isLinkeOpen);
    }

    // ✅ Same callback shape as intake — toggles local slide + shared provider flag
    void onIButtonPressed() {
      toggleLeftSidebar();
      providerContact.toogleLeftSidebarProvider();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Referred-from PDF sidebar ──────────────────────────────────────
        isSidebarLeftOpen
            ? Flexible(
          flex: 0,
          child: AnimatedBuilder(
            animation: _slideLeftAnimation,
            builder: (context, child) {
              return SlideTransition(
                position: _slideLeftAnimation,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, left: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.24,
                      color: Colors.white,
                      padding: const EdgeInsets.all(1),
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(scrollbars: false),
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight:
                              MediaQuery.of(context).size.height,
                              minWidth:
                              MediaQuery.of(context).size.height,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 100),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, bottom: 10, left: 20),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'Referred from ',
                                          style: CustomTextStylesCommon.commonStyle(
                                              color: const Color(0xFF686464),
                                              fontWeight:
                                              FontWeight.w700,
                                              fontSize: 12),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text:
                                              '${providerContact.isLinkeFileName.toString()} ',
                                              style: CustomTextStylesCommon.commonStyle(
                                                  color: const Color(0xFF51B5E6),
                                                  fontWeight:
                                                  FontWeight.w700,
                                                  fontSize: 12),
                                            ),
                                            TextSpan(
                                              text:
                                              '(Page No.${providerContact.pageCountFromLink.toString()})',
                                              style: CustomTextStylesCommon
                                                  .commonStyle(
                                                  color: const Color(0xFF51B5E6),
                                                  fontWeight:
                                                  FontWeight.w700,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  FutureBuilder<String>(
                                    future: _extractedTextFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Padding(
                                          padding: const EdgeInsets
                                              .symmetric(vertical: 80),
                                          child: Center(
                                            child: SizedBox(
                                              height: 25,
                                              width: 25,
                                              child:
                                              CircularProgressIndicator(
                                                  color: ColorManager
                                                      .blueprime),
                                            ),
                                          ),
                                        );
                                      }
                                      final text = snapshot.data ?? '';
                                      return Container(
                                        width: MediaQuery.of(context)
                                            .size
                                            .width /
                                            1,
                                        decoration: BoxDecoration(
                                          color:
                                          const Color(0xFFEEEEEE),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.all(20),
                                          child: Container(
                                            color: Colors.white,
                                            padding:
                                            const EdgeInsets.all(10),
                                            child: text.isEmpty
                                                ? Center(
                                              child: Text(
                                                'No Data!',
                                                style: CustomTextStylesCommon
                                                    .commonStyle(
                                                    color: const Color(
                                                        0xFF686464),
                                                    fontWeight:
                                                    FontWeight
                                                        .w400,
                                                    fontSize:
                                                    12),
                                              ),
                                            )
                                                : Text(
                                              text,
                                              style: CustomTextStylesCommon
                                                  .commonStyle(
                                                  color: const Color(
                                                      0xFF686464),
                                                  fontWeight:
                                                  FontWeight
                                                      .w400,
                                                  fontSize:
                                                  12),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 100),
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

        // ── Main content ────────────────────────────────────────────────────
        Flexible(
          child: Column(
            children: [
              const SizedBox(height: AppSize.s25),
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
                          color: selectedIndex == 0
                              ? Colors.white
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Text('Patient Info',
                              style: BlueBgTabbar.customTextStyle(
                                  0, selectedIndex)),
                        ),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: () => selectButton(1),
                      child: Container(
                        height: AppSize.s30,
                        width: AppSize.s155,
                        decoration: BoxDecoration(
                          borderRadius:
                          const BorderRadius.all(Radius.circular(20)),
                          color: selectedIndex == 1
                              ? Colors.white
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Text('Related Parties',
                              style: BlueBgTabbar.customTextStyle(
                                  1, selectedIndex)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSize.s10),
              // Offstage (not PageView/Expanded) — this Column no longer sits
              // under a bounded-height ancestor, so it must size itself to
              // whichever sub-tab is selected rather than expand to fill.
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Offstage(
                  offstage: selectedIndex != 0,
                  child: EmrPatientInfo(
                    patientId: widget.patientId,
                    isIButtonPressed: onIButtonPressed,
                    childState: FutureBuilder<List<StateData>>(
                      future: _stateFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SchedularTextField(
                              width: 350,
                              controller: dummyCtrl,
                              labelText: 'State*');
                        }
                        if (snapshot.hasData) {
                          return EmrDropdownTextFieldConst(
                            headText: 'State*',
                            dropDownMenuList: snapshot.data!
                                .map((e) => DropdownMenuItem<String>(
                                value: e.name, child: Text(e.name!)))
                                .toList(),
                            onChanged: (v) {
                              for (var a in snapshot.data!) {
                                if (a.name == v) selectedState = a.name!;
                              }
                            },
                          );
                        }
                        return const Offstage();
                      },
                    ),
                    childCountry: FutureBuilder<List<CountryData>>(
                      future: _countryFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SchedularTextField(
                              controller: dummyCtrl,
                              labelText: 'Country*');
                        }
                        if (snapshot.hasData) {
                          return EmrDropdownTextFieldConst(
                            headText: 'Country*',
                            dropDownMenuList: snapshot.data!
                                .map((e) => DropdownMenuItem<String>(
                                value: e.name, child: Text(e.name!)))
                                .toList(),
                            onChanged: (v) {
                              for (var a in snapshot.data!) {
                                if (a.name == v) {
                                  selectedCountry = a.name!;
                                }
                              }
                            },
                          );
                        }
                        return const Offstage();
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Offstage(
                  offstage: selectedIndex != 1,
                  child: EmrRelatedParty(
                    patientId: widget.patientId,
                    onIButtonPressed: onIButtonPressed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}