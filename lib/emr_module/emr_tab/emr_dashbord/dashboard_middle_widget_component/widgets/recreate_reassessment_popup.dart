import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/recert_reassessment_popup.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/upcomin_reassessment_Popup.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/upcoming_supervisory_visits_popup.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/popup_const_emr.dart';

import '../../../../../../../app/resources/color.dart';
import '../../../../../../../app/resources/common_resources/common_theme_const.dart';
import '../../../../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../../../../app/resources/value_manager.dart';

class RecertReassessmentPopup extends StatefulWidget {
  const RecertReassessmentPopup({super.key});

  @override
  State<RecertReassessmentPopup> createState() =>
      _RecertReassessmentPopupState();
}

class _RecertReassessmentPopupState
    extends State<RecertReassessmentPopup> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 80,vertical: 30),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: ColorManager.bluebottom,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.only(top: AppPadding.p2,bottom: AppPadding.p2,
                  left: AppPadding.p20,right: AppPadding.p18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p10),
                    child: Text(
                      "Recerts, Reassessments, Supervisory Visits",
                      style:PopupBlueBarText.customTextStyle(context),
                    ),
                  ),
                  IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: ColorManager.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 80,vertical: 10),
                width: double.infinity,
                height: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ── Tabs ─────────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final label = i == 0
                            ? 'Recert/DC Decisions'
                            : i == 1 ? "Upcoming Reassessments"
                            : "Upcoming Supervisory Visits";

                        final active = _tab == i;

                        final textStyle = TextStyle(
                          fontSize: 14,
                          fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                        );

                        final textPainter = TextPainter(
                          text: TextSpan(text: label, style: textStyle),
                          maxLines: 1,
                          textDirection: TextDirection.ltr,
                        )..layout();

                        final underlineWidth = textPainter.width + 20;

                        return GestureDetector(
                          onTap: () => setState(() => _tab = i),
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  label,
                                  style: textStyle.copyWith(
                                    color: active
                                        ? Colors.blue.shade700
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 3,
                                  width: underlineWidth,
                                  color: active
                                      ? Colors.blue.shade700
                                      : Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),

                    // ── Body ─────────────────────────────────────────────
                    Expanded(
                      child: _tab == 0
                          ? RecertDCDecisions()
                          : _tab == 1
                        ? UpcomingReassessments()
                       : UpcomingSupervisoryVisits(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}