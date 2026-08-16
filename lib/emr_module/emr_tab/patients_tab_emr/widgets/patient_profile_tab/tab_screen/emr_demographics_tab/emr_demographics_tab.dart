import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../../app/resources/color.dart';
import '../../../../../../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../../../../../../app/resources/provider/sm_provider/sm_slider_provider.dart';
import '../../../../../../../../../app/resources/theme_manager.dart';
import '../../../../../../../../../app/resources/value_manager.dart';
import '../../../../../../../../../app/services/api/managers/sm_module_manager/sm_intake_manager/intake_demographics/intake_demographic_dropdown_manager.dart';
import '../../../../../../../../../data/api_data/sm_data/scheduler_create_data/create_data.dart';
import '../../../../../../../scheduler_model/textfield_dropdown_constant/schedular_textfield_const.dart';
import '../../../../../../../scheduler_model/widgets/constant_widgets/dropdown_constant_sm.dart';
import '../../../../../../../scheduler_model/widgets/constant_widgets/pdf_viewer.dart';
import 'emr_patient_info.dart';
import 'emr_related_party.dart';


class EmrDemographicsTab extends StatefulWidget {
  final int patientId;
  const EmrDemographicsTab({super.key, required this.patientId});

  @override
  State<EmrDemographicsTab> createState() => _EmrDemographicsTabState();
}

class _EmrDemographicsTabState extends State<EmrDemographicsTab>
    with TickerProviderStateMixin {
  int selectedIndex = 0;
  final PageController smIntakePageController = PageController();

  String? selectedStatus;
  String? selectedCountry;
  String? selectedState;

  final TextEditingController dummyCtrl = TextEditingController();

  // ── FIX 2: Cache futures in initState so they don't re-fire on every rebuild
 // late Future<List<PatientStatusData>> _statusFuture;
  late Future<List<StateData>>         _stateFuture;
  late Future<List<CountryData>>       _countryFuture;

  @override
  void initState() {
    super.initState();
    //_statusFuture  = StatusChange(context);
    _stateFuture   = getStateDropDown(context);
    _countryFuture = getCountryDropDown(context);
  }

  void selectButton(int index) {
    setState(() => selectedIndex = index);
    smIntakePageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  @override
  void dispose() {
    smIntakePageController.dispose();
    dummyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── FIX 1: Return Column directly — Flexible is invalid here because
    //           this widget is used as a PageView child / tab body,
    //           NOT directly inside a Row/Column/Flex parent.
    return Column(
      children: [
        // ── Sub-tab toggle ──────────────────────────────────────────────
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
              // Patient Info
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () => selectButton(0),
                child: Container(
                  height: AppSize.s30,
                  width: AppSize.s160,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: selectedIndex == 0 ? Colors.white : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      'Patient Info',
                      style: BlueBgTabbar.customTextStyle(0, selectedIndex),
                    ),
                  ),
                ),
              ),
              // Related Parties
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () => selectButton(1),
                child: Container(
                  height: AppSize.s30,
                  width: AppSize.s155,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: selectedIndex == 1 ? Colors.white : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      'Related Parties',
                      style: BlueBgTabbar.customTextStyle(1, selectedIndex),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSize.s10),

        // ── Page content ────────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: PageView(
              controller: smIntakePageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // ── index 0: Patient Info ───────────────────────────────
                EmrPatientInfo(
                  patientId: widget.patientId,
                  childState: FutureBuilder<List<StateData>>(
                    future: _stateFuture,           // ← cached
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SchedularTextField(
                            width: 350, controller: dummyCtrl, labelText: 'State*');
                      }
                      if (snapshot.hasData) {
                        return CustomDropdownTextFieldsm(
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
                    future: _countryFuture,         // ← cached
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SchedularTextField(
                            controller: dummyCtrl, labelText: 'Country*');
                      }
                      if (snapshot.hasData) {
                        return CustomDropdownTextFieldsm(
                          headText: 'Country*',
                          dropDownMenuList: snapshot.data!
                              .map((e) => DropdownMenuItem<String>(
                              value: e.name, child: Text(e.name!)))
                              .toList(),
                          onChanged: (v) {
                            for (var a in snapshot.data!) {
                              if (a.name == v) selectedCountry = a.name!;
                            }
                          },
                        );
                      }
                      return const Offstage();
                    },
                  ),
                ),

                // ── index 1: Related Parties ────────────────────────────
                EmrRelatedParty(patientId: widget.patientId),
              ],
            ),
          ),
        ),
      ],
    );
  }
}