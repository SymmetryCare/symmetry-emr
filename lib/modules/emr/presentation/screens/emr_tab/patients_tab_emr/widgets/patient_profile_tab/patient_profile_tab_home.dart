import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_profile_tab/tab_screen/emr_demographics_tab/emr_demographics_tab.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_profile_tab/tab_screen/emr_initial_contact_tab.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_profile_tab/tab_screen/emr_insurance_tab/emr_insurance_tab.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_profile_tab/tab_screen/emr_order_tab.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_profile_tab/tab_screen/emr_physician_info_tab.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/emr_theme_const.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/providers/hh_emr/visit_details_provider.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart' show AppPadding, AppSize;
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/app_clickable_widget.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/company_identity_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/upper_menu_buttons.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/new_phsician_info/physician_info_tab.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_insurance/intake_insurance_screen.dart';

class PatientProfilePage extends StatefulWidget {
  final EMRSelectedPatient patient;
  const PatientProfilePage({required this.patient});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  int _selectedIndex = 0;

  void _selectButton(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breathing room from the patient header above — without it the tab
        // bar sits flush against the header's bottom edge/border.
        const SizedBox(height: 10),
        // ── Top tab bar ──────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EMRSMTabbar(
              onTap: (_) => _selectButton(0),
              index: 0,
              grpIndex: _selectedIndex,
              heading: "Demographics",
            ),
            EMRSMTabbar(
              onTap: (_) => _selectButton(1),
              index: 1,
              grpIndex: _selectedIndex,
              heading: "Insurance",
            ),
            EMRSMTabbar(
              onTap: (_) => _selectButton(2),
              index: 2,
              grpIndex: _selectedIndex,
              heading: "Physician Info",
            ),
            EMRSMTabbar(
              onTap: (_) => _selectButton(3),
              index: 3,
              grpIndex: _selectedIndex,
              heading: "Orders",
            ),
            EMRSMTabbar(
              onTap: (_) => _selectButton(4),
              index: 4,
              grpIndex: _selectedIndex,
              heading: "Initial Contact",
            ),
          ],
        ),

        // ── Page content ─────────────────────────────────────────────────
        // Offstage (not IndexedStack) so the column sizes itself to the
        // selected tab only — IndexedStack sizes to its tallest child,
        // which left blank space under shorter tabs.
        Offstage(
          offstage: _selectedIndex != 0,
          child: EmrDemographicsTab(patientId: widget.patient.patientId),
        ),
        Offstage(
          offstage: _selectedIndex != 1,
          child: EmrIsuerenceTab(patientId: widget.patient.patientId),
        ),
        Offstage(
          offstage: _selectedIndex != 2,
          child: EmrPhysicianInfoTab(patientId: widget.patient.patientId),
        ),
        Offstage(
          offstage: _selectedIndex != 3,
          child: EmrOrderTab(patientId: widget.patient.patientId),
        ),
        Offstage(
          offstage: _selectedIndex != 4,
          child: EmrInitialContactTab(patientId: widget.patient.patientId),
        ),
      ],
    );
  }
}


// ── EMRSMTabbar ─────────────────────────────────────────────────────────────

class EMRSMTabbar extends StatelessWidget {
  const EMRSMTabbar({
    super.key,
    required this.onTap,
    required this.index,
    required this.grpIndex,
    required this.heading,
    this.badgeNumber,
    this.width,
  });

  final OnManuButtonTapCallBack onTap;
  final int index;
  final int grpIndex;
  final String heading;
  final int? badgeNumber;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return AppClickableWidget(
      onTap: () => onTap(index),
      onHover: (bool val) {},
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: width ?? 170,
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  heading,
                  style: TransparentBgTabbar.customTextStyle(grpIndex, index),
                ),
              ),
              if (badgeNumber != null)
                Positioned(
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: ColorManager.blueprime,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeNumber!.toString(),
                      style: const TextStyle(
                        fontSize: FontSize.s10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final textPainter = TextPainter(
                text: TextSpan(
                  text: heading,
                  style: const TextStyle(
                    fontSize: FontSize.s14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                textDirection: TextDirection.ltr,
              )..layout();

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 3),
                height: 2,
                width: textPainter.size.width + 80,
                color: grpIndex == index
                    ? ColorManager.blueprime
                    : Colors.transparent,
              );
            },
          ),
        ],
      ),
    );
  }
}