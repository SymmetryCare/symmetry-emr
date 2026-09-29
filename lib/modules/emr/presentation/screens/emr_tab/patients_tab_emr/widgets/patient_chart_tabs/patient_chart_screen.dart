import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/patient_chart_view_old_auth_popup.dart';
class PatientChartScreen extends StatelessWidget {
  const PatientChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Text("Dependency on Forms Builder under development and is not available in the current build!",
        style: AllNoDataAvailable.customTextStyle(context),),
      ),
    );
        ///do not delete
    //   Padding(
    //   padding: const EdgeInsets.all(AppPadding.p20),
    //   child: Row(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       /// LEFT: Outstanding Documentation
    //       Expanded(
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Text(
    //               'Outstanding Documentation:',
    //               style: TextStyle(
    //                 fontSize: FontSize.s18,
    //                 fontWeight: FontWeight.w700,
    //                 color: ColorManager.darkgrey,
    //                 decoration: TextDecoration.none,
    //               ),
    //             ),
    //             const SizedBox(height: AppSize.s20),
    //
    //             // Need Correction group
    //             Text(
    //               'Need Correction - 2',
    //               style: TextStyle(
    //                 fontSize: FontSize.s14,
    //                 fontWeight: FontWeight.w600,
    //                 color: Colors.orange,
    //                 decoration: TextDecoration.none,
    //               ),
    //             ),
    //             const SizedBox(height: AppSize.s8),
    //             _DocItem(label: 'OASIS Start of Care (4/12/2025)'),
    //             const SizedBox(height: AppSize.s6),
    //             _DocItem(label: 'Skilled Nursing Discharge Visit (8/7/2025)'),
    //
    //             const SizedBox(height: AppSize.s20),
    //
    //             // Pending group
    //             Text(
    //               'Pending - 1',
    //               style: TextStyle(
    //                 fontSize: FontSize.s14,
    //                 fontWeight: FontWeight.w600,
    //                 color: Colors.orange,
    //                 decoration: TextDecoration.none,
    //               ),
    //             ),
    //             const SizedBox(height: AppSize.s8),
    //             _DocItem(label: 'Skilled Nursing Discharge Visit (8/28/2025)'),
    //           ],
    //         ),
    //       ),
    //
    //       const SizedBox(width: AppSize.s20),
    //       Container(width: 1, height: 160, color: Colors.grey.shade300),
    //       const SizedBox(width: AppSize.s20),
    //
    //       /// RIGHT: Active Authorization
    //       Expanded(
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Text(
    //               'Active Authorization:',
    //               style: TextStyle(
    //                 fontSize: FontSize.s18,
    //                 fontWeight: FontWeight.w700,
    //                 color: ColorManager.darkgrey,
    //                 decoration: TextDecoration.none,
    //               ),
    //             ),
    //             const SizedBox(height: AppSize.s20),
    //
    //             // Auth card
    //             Container(
    //               padding: const EdgeInsets.all(AppPadding.p10),
    //               decoration: BoxDecoration(
    //                 border: Border(
    //                   left: BorderSide(color: Colors.green, width: 3),
    //                 ),
    //                 color: Colors.grey.shade50,
    //               ),
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   // Title row + table headers
    //                   Row(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: [
    //                       Expanded(
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             Text(
    //                               'Authorization #2',
    //                               style: TextStyle(
    //                                 fontSize: FontSize.s12,
    //                                 fontWeight: FontWeight.w700,
    //                                 color: ColorManager.mediumgrey,
    //                                 decoration: TextDecoration.none,
    //                               ),
    //                             ),
    //                             const SizedBox(height: AppSize.s10),
    //                             Text(
    //                               'Admin: 4/15/2025, OrderedBy: Nursing, Rebecca',
    //                               style: TextStyle(
    //                                 fontSize: FontSize.s12,
    //                                 fontWeight: FontWeight.w600,
    //                                 color: ColorManager.faintGrey,
    //                                 decoration: TextDecoration.none,
    //                               ),
    //                             ),
    //                             const SizedBox(height: AppSize.s10),
    //                             Text(
    //                               'Effective: 2/15/2025 - 7/5/2025',
    //                               style: TextStyle(
    //                                 fontSize: FontSize.s12,
    //                                 fontWeight: FontWeight.w700,
    //                                 color: ColorManager.mediumgrey,
    //                                 decoration: TextDecoration.none,
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                       // Authorized / Used / Remaining columns
    //                       Padding(
    //                         padding: const EdgeInsets.only(top: 10),
    //                         child: Row(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //
    //                             _AuthColumn(header: 'Authorized', value: '1'),
    //                             const SizedBox(width: AppSize.s16),
    //                             _AuthColumn(header: 'Used', value: '1'),
    //                             const SizedBox(width: AppSize.s16),
    //                             _AuthColumn(header: 'Remaining', value: '4'),
    //                           ],
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //
    //                   const SizedBox(height: AppSize.s10),
    //
    //                   // View Old Auth button
    //                   Align(
    //                     alignment: Alignment.centerRight,
    //                     child: ElevatedButton.icon(
    //                       onPressed: () {
    //                         showDialog(
    //                           context: context,
    //                           builder: (_) => const PatientChartViewOldAuthPopup(),
    //                         );
    //                       },
    //                       icon: const Icon(Icons.visibility_outlined, size: 12),
    //                       label: const Text(
    //                         'View Old Auth',
    //                         style: TextStyle(fontSize: 10),
    //                       ),
    //                       style: ElevatedButton.styleFrom(
    //                         backgroundColor: ColorManager.blueprime,
    //                         foregroundColor: Colors.white,
    //                         padding: const EdgeInsets.symmetric(
    //                             horizontal: 10, vertical: 15),
    //                         minimumSize: Size.zero,
    //                         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    //                         shape: RoundedRectangleBorder(
    //                           borderRadius: BorderRadius.circular(6),
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}

/// A single documentation item with a blue link style and + icon
class _DocItem extends StatelessWidget {
  final String label;
  const _DocItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 5, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: FontSize.s12,
              color: ColorManager.blueprime,
              decoration: TextDecoration.underline,
              decorationColor: ColorManager.blueprime,
            ),
          ),
        ),
        const Icon(Icons.add, size: 14, color: Colors.blue),
      ],
    );
  }
}

/// A column showing header + value for auth table
class _AuthColumn extends StatelessWidget {
  final String header;
  final String value;
  const _AuthColumn({required this.header, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          header,
          style: TextStyle(
            fontSize: FontSize.s12,
            fontWeight: FontWeight.w500,
            color: ColorManager.mediumgrey,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: FontSize.s12,
            fontWeight: FontWeight.w500,
            color: ColorManager.mediumgrey,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
