import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/calender_screen_late_doc.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/list_screen_late_doc.dart';
import 'package:provider/provider.dart';

import '../../../../../../../app/resources/color.dart';
import '../../../../../../../app/resources/common_resources/emr_theme_const.dart';
import '../../../../../../../app/resources/provider/hh_emr/visit_details_provider.dart';
import '../../../../../../../app/resources/value_manager.dart';
import '../../../../../scheduler_model/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import '../../../popup_const_emr.dart';

class LateDocumentationPopup extends StatefulWidget {
  const LateDocumentationPopup({super.key});

  @override
  State<LateDocumentationPopup> createState() => _LateDocumentationPopupState();
}

class _LateDocumentationPopupState extends State<LateDocumentationPopup> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 200),
      child: DialogueTemplateNoButtons(
        width: double.infinity,
        height: double.infinity,
        title: "Late Documentation",
        body: [
          Row(
            children: [
              // ── Search + Filter ──────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomSearchFieldSM(onPressed: () {}),
                  const SizedBox(width: 20),
                  IconButton(
                      highlightColor:  Colors.transparent,
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                    onPressed: () {
                      // Opens screen-level drawer — popup stays open
                     // context.read<FilterDrawerProvider>().openFilter();
                    },
                    icon:  Image.asset("images/sm/sm_refferal/filter_icon.png",
                        height: AppSize.s18,
                        width: AppSize.s16)
                  ),
                ],
              ),

              // ── List / Calendar tabs ─────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (i) {
                  final label = i == 0 ? 'List' : 'Calendar';
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            ],
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 400,
            child: _tab == 0
                ? const ListScreenLateDocumentation()
                : const CalenderScreenLateDocumentation(),
          ),
        ],
      ),
    );
  }
}