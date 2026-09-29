// import 'package:flutter/material.dart';
// import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_activities_permitted/poc_activities_permitted.dart';
// import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_advance_directives/poc_advance_directives.dart';
// import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_allergies/poc_allergies.dart';
// import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_discharge_planning/poc_discharge_planning.dart';
// import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_dme_supplies/poc_dme_supplies.dart';
// import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_frequencies/poc_frequencies.dart';
// import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_functional_limitations/poc_functional_limitations.dart';
// import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_interventions_goals/poc_interventions_goals.dart';
// import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_medications/poc_medications.dart';
// import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_mental_status/poc_mental_status.dart';
// import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_nutritional_requirements/poc_nutritional_requirements.dart';
// import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_prognosis/poc_prognosis.dart';
// import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_rehab_potential/poc_rehab_potential.dart';
// import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_safety_measures/poc_safety_measures.dart';
// import 'package:provider/provider.dart';
// import '../../../../../../../app/resources/color.dart';
// import '../../../../../../../app/resources/font_manager.dart';
// import '../../../../../../../app/resources/provider/hh_emr/visit_details_provider.dart';
// import '../../../../../../../app/resources/value_manager.dart';
// import '../../../../../../../presentation/widgets/widgets/custom_scrollbar.dart';
// import 'widgets_poc/poc_diagnosis/poc_diagnosis.dart';
// import 'widgets_poc/poc_eligibility/poc_eligibility.dart';
//



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/providers/hh_emr/visit_details_provider.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

class PlanOfCareScreen extends StatelessWidget {
  final int ptId;
  const PlanOfCareScreen({super.key, required this.ptId});

  @override
  Widget build(BuildContext context) {
    final nav = context.read<EMRNavigationController>();

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSize.s20),
          // Back button
          Padding(
            padding: const EdgeInsets.only(left: AppPadding.p20),
            child: InkWell(
              onTap: () => nav.closePlanOfCare(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back,
                      size: AppSize.s14, color: ColorManager.darkgrey),
                  const SizedBox(width: AppSize.s6),
                  Text(
                    'Back',
                    style: TextStyle(
                      fontSize: FontSize.s13,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.darkgrey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Centered message
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppPadding.p40),
                child: Text(
                  'Dependency on forms builder which is under development!',
                  textAlign: TextAlign.center,
                  style: AllNoDataAvailable.customTextStyle(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}




////



///dont delete
// class PlanOfCareScreen extends StatefulWidget {
//   final int ptId;
//   const PlanOfCareScreen({super.key, required this.ptId});
//
//   @override
//   State<PlanOfCareScreen> createState() => _PlanOfCareScreenState();
// }
//
// class _PlanOfCareScreenState extends State<PlanOfCareScreen> {
//   int _selectedTab = 0;
//   final ScrollController _horizontalScrollController = ScrollController();
//
//   Color _pocStatusColor(String status) {
//     switch (status) {
//       case 'Resumption': return const Color(0xFFE65100);
//       case 'Discharge':  return const Color(0xFFC62828);
//       case 'Admitted':   return const Color(0xFF2E7D32);
//       default:           return const Color(0xFFF9A825);
//     }
//   }
//
//   Color _pocCareTeamColor(String tag) {
//     switch (tag.toUpperCase()) {
//       case 'RN':  return Colors.teal;
//       case 'PT':  return Colors.orange;
//       case 'OT':  return Colors.blue;
//       case 'SLP': return Colors.purple;
//       case 'HHA': return Colors.indigo;
//       case 'MSW': return Colors.green;
//       default:    return Colors.blueGrey;
//     }
//   }
//
//   @override
//   void dispose() {
//     _horizontalScrollController.dispose();
//     super.dispose();
//   }
//
//   static const List<String> _tabs = [
//     'Eligibility',
//     'Diagnosis',
//     'Medications',
//     'DME/Supplies',
//     'Safety Measures',
//     'Nutritional Requirements',
//     'Allergies',
//     'Functional Limitations',
//     'Activities Permitted',
//     'Mental Status',
//     'Prognosis',
//     'Interventions/Goals',
//     'Advance Directives',
//     'Rehab Potential',
//     'Discharge Planning',
//     'Frequencies',
//   ];
//   @override
//   Widget build(BuildContext context) {
//     final nav = context.watch<EMRNavigationController>();
//
//     return Container(
//       color: Colors.white,
//       padding: EdgeInsets.only(left: AppPadding.p10,right: AppPadding.p20),
//       child: LayoutBuilder(builder: (context, constraints) {
//         const double minContentWidth = 1200;
//         final double contentWidth = constraints.maxWidth > minContentWidth
//             ? constraints.maxWidth
//             : minContentWidth;
//         return CustomScrollbar(
//           controller: _horizontalScrollController,
//           scrollDirection: Axis.horizontal,
//           child: SingleChildScrollView(
//             controller: _horizontalScrollController,
//             scrollDirection: Axis.horizontal,
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: AppPadding.p10),
//               child: SizedBox(
//                 width: contentWidth,
//                 height: constraints.maxHeight,
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//           // ── LEFT SIDEBAR — Back + Tabs only ─────────────────────
//           SizedBox(
//             width: 200,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: AppSize.s20),
//
//                 // Back button
//                 Padding(
//                   padding: const EdgeInsets.only(left: AppPadding.p20),
//                   child: InkWell(
//                     onTap: () => nav.closePlanOfCare(),
//                     child: Row(
//                       children: [
//                         Icon(Icons.arrow_back,
//                             size: AppSize.s14, color: ColorManager.darkgrey),
//                         const SizedBox(width: AppSize.s6),
//                         Text(
//                           'Back',
//                           style: TextStyle(
//                             fontSize: FontSize.s13,
//                             fontWeight: FontWeight.w600,
//                             color: ColorManager.darkgrey,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: AppSize.s16),
//
//                 // Tabs list (scrollable)
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: _tabs.asMap().entries.map((e) {
//                         final index = e.key;
//                         final label = e.value;
//                         final isSelected = _selectedTab == index;
//                         return InkWell(
//                           onTap: () => setState(() => _selectedTab = index),
//                           child: Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: AppPadding.p20,
//                                 vertical: AppPadding.p14),
//                             decoration: BoxDecoration(
//                               border: Border(
//                                 left: BorderSide(
//                                   color: isSelected
//                                       ? ColorManager.blueprime
//                                       : Colors.transparent,
//                                   width: 3,
//                                 ),
//                               ),
//                             ),
//                             child: Text(
//                               label,
//                               style: TextStyle(
//                                 fontSize: FontSize.s12,
//                                 fontWeight: isSelected
//                                     ? FontWeight.w700
//                                     : FontWeight.w500,
//                                 color: isSelected
//                                     ? ColorManager.blueprime
//                                     : ColorManager.darkgrey,
//                               ),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // ── Vertical Divider ──────────────────────────────────
//           Container(
//             width: 1,
//             color: Colors.grey.shade200,
//           ),
//           // ── RIGHT — Breadcrumb + Patient card + Content ─────────
//           Expanded(
//             child: Container(
//               margin: EdgeInsets.only(left: AppPadding.p20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Breadcrumb
//                   Padding(
//                     padding: const EdgeInsets.only(
//                         left: AppPadding.p20,
//                         right: AppPadding.p25,
//                         top: AppPadding.p20,
//                         bottom: AppPadding.p12),
//                     child: Row(
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             nav.closePlanOfCare();
//                             nav.closePatientDetail();
//                           },
//                           child: Text(
//                             'Patients',
//                             style: TextStyle(
//                               fontSize: FontSize.s13,
//                               fontWeight: FontWeight.w600,
//                               color: ColorManager.blueprime,
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: AppPadding.p6),
//                           child: Icon(Icons.chevron_right,
//                               size: IconSize.I18,
//                               color: ColorManager.mediumgrey),
//                         ),
//                         InkWell(
//                           onTap: () => nav.closePlanOfCare(),
//                           child: Text(
//                             nav.selectedPatient?.name ?? '--',
//                             style: TextStyle(
//                               fontSize: FontSize.s13,
//                               fontWeight: FontWeight.w600,
//                               color: ColorManager.blueprime,
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: AppPadding.p6),
//                           child: Icon(Icons.chevron_right,
//                               size: IconSize.I18,
//                               color: ColorManager.mediumgrey),
//                         ),
//                         Text(
//                           'Plan of Care',
//                           style: TextStyle(
//                             fontSize: FontSize.s13,
//                             fontWeight: FontWeight.w600,
//                             color: ColorManager.blueprime,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // ── Patient card row ─────────────────────────────
//                   Container(
//                     margin: EdgeInsets.symmetric(horizontal: AppPadding.p20),
//                     padding: EdgeInsets.symmetric(vertical: AppPadding.p8,horizontal: AppPadding.p20),
//                     decoration: BoxDecoration(
//                       color: ColorManager.white,
//                       borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(12),
//                           bottomRight: Radius.circular(12),
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12)),
//                       border: Border(
//                         bottom: BorderSide(
//                           color: Colors.grey.shade300,
//                           width: 3,
//                         ),
//                         left: BorderSide(
//                           color: Colors.grey.shade300,
//                           width: 1,
//                         ),
//                         right: BorderSide(
//                           color: Colors.grey.shade300,
//                           width: 1,
//                         ),
//                         top: BorderSide(
//                           color: Colors.grey.shade300,
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: AppPadding.p20),
//                       child: Row(
//                         children: [
//                           // Avatar
//                           CircleAvatar(
//                             radius: 35,
//                             backgroundColor: Colors.transparent,
//                             child: ClipOval(
//                               child: nav.pocImgUrl.isNotEmpty
//                                   ? Image.network(
//                                 nav.pocImgUrl,
//                                 width: 65,
//                                 height: 65,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (_, __, ___) => Image.asset(
//                                   "images/profilepic.png",
//                                   width: 65,
//                                   height: 65,
//                                   fit: BoxFit.cover,
//                                 ),
//                               )
//                                   : Image.asset(
//                                 "images/profilepic.png",
//                                 width: 65,
//                                 height: 65,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: AppSize.s12),
//
//                           // Name + Status + tags
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Text(
//                                     nav.pocPatientName.isNotEmpty
//                                         ? nav.pocPatientName
//                                         : '—',
//                                     style: TextStyle(
//                                       fontSize: FontSize.s13,
//                                       fontWeight: FontWeight.w700,
//                                       color: ColorManager.darkgrey,
//                                     ),
//                                   ),
//                                   if (nav.pocPatientStatus.isNotEmpty) ...[
//                                     const SizedBox(width: AppSize.s20),
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: AppPadding.p8,
//                                           vertical: AppPadding.p2),
//                                       decoration: BoxDecoration(
//                                         color: _pocStatusColor(nav.pocPatientStatus).withOpacity(0.15),
//                                         borderRadius:
//                                         BorderRadius.circular(AppSize.s10),
//                                       ),
//                                       child: Text(
//                                         nav.pocPatientStatus,
//                                         style: TextStyle(
//                                           fontSize: FontSize.s10,
//                                           fontWeight: FontWeight.w600,
//                                           color: _pocStatusColor(nav.pocPatientStatus),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ],
//                               ),
//                               const SizedBox(height: AppSize.s10),
//
//                               // Tag badges
//                               Row(
//                                 children: [
//                                   for (int i = 0; i < nav.pocCareTeam.length; i++) ...[
//                                     if (i > 0) const SizedBox(width: 3),
//                                     _Tag(nav.pocCareTeam[i], _pocCareTeamColor(nav.pocCareTeam[i])),
//                                   ],
//                                 ],
//                               ),
//                             ],
//                           ),
//
//                           // const Spacer(),
//                           //
//                           // // View Current POC button
//                           // ElevatedButton.icon(
//                           //   onPressed: () {},
//                           //   icon: const Icon(Icons.visibility_outlined,
//                           //       size: 14, color: Colors.white),
//                           //   label: Text(
//                           //     'View Current POC',
//                           //     style: TextStyle(
//                           //       color: Colors.white,
//                           //       fontSize: FontSize.s12,
//                           //       fontWeight: FontWeight.w600,
//                           //     ),
//                           //   ),
//                           //   style: ElevatedButton.styleFrom(
//                           //     backgroundColor: ColorManager.blueprime,
//                           //     padding: const EdgeInsets.symmetric(
//                           //         horizontal: AppPadding.p16,
//                           //         vertical: AppPadding.p10),
//                           //     shape: RoundedRectangleBorder(
//                           //         borderRadius:
//                           //         BorderRadius.circular(AppSize.s6)),
//                           //     elevation: 0,
//                           //   ),
//                           // ),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: AppSize.s16),
//
//                   // ── Content area ─────────────────────────────────
//                   Expanded(
//                     child: IndexedStack(
//                       index: _selectedTab,
//                       children: const [
//                         PocEligibility(),
//                         PocDiagnosis(),
//                         PocMedications(),
//                         PocDmeSupplies(),
//                         PocSafetyMeasures(),
//                         PocNutritionalRequirements(),
//                         PocAllergies(),
//                         PocFunctionalLimitations(),
//                         PocActivitiesPermitted(),
//                         PocMentalStatus(),
//                         PocPrognosis(),
//                         PocInterventionsGoals(),
//                         PocAdvanceDirectives(),
//                         PocRehabPotential(),
//                         PocDischargePlanning(),
//                         PocFrequencies(),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//                   ],    // Row children
//                 ),      // Row
//               ),        // SizedBox
//             ),          // Padding(bottom)
//           ),            // SingleChildScrollView
//         );              // CustomScrollbar
//       }),               // LayoutBuilder
//     );
//   }
// }
//
// // ── Tag badge for sidebar ─────────────────────────────────────────────────────
// class _Tag extends StatelessWidget {
//   final String label;
//   final Color color;
//   const _Tag(this.label, this.color);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(3),
//       ),
//       child: Text(
//         label,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 9,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }