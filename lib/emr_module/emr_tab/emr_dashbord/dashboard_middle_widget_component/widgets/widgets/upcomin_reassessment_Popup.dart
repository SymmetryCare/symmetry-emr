
import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/color.dart';
import '../../../../../../../../app/resources/common_resources/emr_theme_const.dart';
import '../../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../../app/resources/value_manager.dart';

class UpcomingReassessments extends StatelessWidget {
  const UpcomingReassessments({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header ──────────────────────────────────────────────────────
        Container(
          height: AppSize.s33,
          decoration: BoxDecoration(
            color: ColorManager.SMFBlue,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.only(right: AppPadding.p12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppPadding.p20),
                  child: Text("Patient Name",
                      textAlign: TextAlign.center,
                      style: EMRListViewHead.customTextStyle(context)),
                ),
              ),

              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppPadding.p10),
                  child: Text("Last Assessment Date",
                      textAlign: TextAlign.center,
                      style: EMRListViewHead.customTextStyle(context)),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppPadding.p10),
                  child: Text("Closest Scheduled Visit",
                      textAlign: TextAlign.center,
                      style: EMRListViewHead.customTextStyle(context)),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: AppPadding.p10),
                  child: Text("Due By Date",
                      textAlign: TextAlign.center,
                      style: EMRListViewHead.customTextStyle(context)),
                ),
              ),
              Expanded(flex: 1,child: Container())
            ],
          ),
        ),
        const SizedBox(height: AppSize.s10),

        // ── List ────────────────────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            itemCount: 4,
            separatorBuilder: (_, __) => Divider(color: Colors.grey.shade300),
            itemBuilder: (context, index) {
              // dummy data — swap with real model fields
              const String closestVisit = "Not Available"; // or "09/04/2025"
              const String dueDate = "06/04/2025";

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p12,
                  vertical: AppPadding.p10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Patient Info ─────────────────────────────────
                    Expanded(
                      flex: 3,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.orange.shade100,
                            child: Text(
                              "LG",
                              style: TextStyle(
                                  color: ColorManager.mediumgrey,
                                  fontWeight: FontWeight.w700,
                                  fontSize: FontSize.s12
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSize.s10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Lucas Garcia",
                                  style: EMRListViewHead.customTextStyle(context)),
                              const SizedBox(height: AppSize.s2),
                              Text("MRN: 659653454",
                                  style: EMRListViewHead.customTextStyle(context)
                                      .copyWith(fontWeight: FontWeight.w400)),
                              Text("05/08/2001 | 24y",
                                  style: EMRListViewHead.customTextStyle(context)
                                      .copyWith(fontWeight: FontWeight.w400)),
                              Text("Anxiety",
                                  style: EMRListViewHead.customTextStyle(context)
                                      .copyWith(fontWeight: FontWeight.w400)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Last Assessment Date ─────────────────────────
                    Expanded(
                      flex: 3,
                      child: Text(
                        "09/04/2025",
                        textAlign: TextAlign.center,
                        style: EMRListViewHead.customTextStyle(context)
                            .copyWith(fontWeight: FontWeight.w400),
                      ),
                    ),

                    // ── Closest Scheduled Visit ──────────────────────
                    Expanded(
                      flex: 3,
                      child: Text(
                        closestVisit,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: closestVisit == "Not Available"
                              ? Colors.red
                              : ColorManager.mediumgrey,
                          fontWeight: FontWeight.w500,
                          fontSize: FontSize.s12,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSize.s20,),
                    // ── Due By Date + Calendar Icon ──────────────────
                    Expanded(
                      flex: 3,
                      child: Text(
                        dueDate,
                        textAlign: TextAlign.center,
                        style: EMRListViewHead.customTextStyle(context)
                            .copyWith(fontWeight: FontWeight.w400),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 10,),
                      ],),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}