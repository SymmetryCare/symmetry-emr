import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/calender_screen_pending_doc.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/list_screen_pending_doc.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/providers/hh_emr/visit_details_provider.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';

class PendingDocumentationPopup extends StatefulWidget {
  const PendingDocumentationPopup({super.key});

  @override
  State<PendingDocumentationPopup> createState() => _PendingDocumentationPopupState();
}

class _PendingDocumentationPopupState extends State<PendingDocumentationPopup> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 200),
      child: DialogueTemplateNoButtons(width: double.infinity, height: double.infinity,
          body: [
            Row(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomSearchFieldSM(onPressed: (){}),
                    const SizedBox(width: 20,),
                    IconButton(onPressed: (){
                    }, icon: Icon(Icons.filter_alt_sharp,color: ColorManager.mediumgrey,))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (i) {
                    final label = i == 0
                        ? 'List'
                        : "Calender";

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
                                    ? ColorManager.blueprime
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 3,
                              width: underlineWidth,
                              color: active
                                  ? ColorManager.blueprime
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
            const SizedBox(height: 10,),
            Container(
                height: 400,
                child: _tab == 0
                    ? ListScreenPendingDoc()
                    : const CalenderScreenPendingDoc())
          ], title: "Pending Documentation"),
    );
  }
}

