import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/color.dart';

import '../../../../../../../../app/resources/common_resources/emr_theme_const.dart';
import '../../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../../app/resources/value_manager.dart';

class UpcomingSupervisoryVisits extends StatelessWidget {
  const UpcomingSupervisoryVisits({super.key});

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
              // Patient Name
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppPadding.p30),
                  child: Text("Patient Name",
                      textAlign: TextAlign.center,
                      style: EMRListViewHead.customTextStyle(context)),
                ),
              ),
              // Clinician Name
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppPadding.p20),
                  child: Text("Clinician Name",
                      textAlign: TextAlign.center,
                      style: EMRListViewHead.customTextStyle(context)),
                ),
              ),
              // Last Supervisory Date
              Expanded(
                flex: 3,
                child: Text("Last Supervisory Date",
                    textAlign: TextAlign.center,
                    style: EMRListViewHead.customTextStyle(context)),
              ),
              // Due By Date
              Expanded(
                flex: 2,
                child: Text("Due By Date",
                    textAlign: TextAlign.center,
                    style: EMRListViewHead.customTextStyle(context)),
              ),
              // Closest Scheduled Visit
              Expanded(
                flex: 3,
                child: Text("Closest Scheduled Visit",
                    textAlign: TextAlign.center,
                    style: EMRListViewHead.customTextStyle(context)),
              ),
              // Icon placeholder
              const SizedBox(width: 50),
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
                      flex: 4,
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

                    // ── Clinician ────────────────────────────────────
                    Expanded(
                      flex: 3,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(
                                  "https://i.pravatar.cc/150?img=3",
                                ),
                              ),
                              Positioned(
                                right: -3,
                                bottom: -3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "PTA",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Era Thompson",
                            style: EMRListViewHead.customTextStyle(context)
                                .copyWith(fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),

                    // ── Last Supervisory Date ────────────────────────
                    Expanded(
                      flex: 3,
                      child: Text(
                        "09/04/2025",
                        textAlign: TextAlign.center,
                        style: EMRListViewHead.customTextStyle(context)
                            .copyWith(fontWeight: FontWeight.w400),
                      ),
                    ),

                    // ── Due By Date ──────────────────────────────────
                    Expanded(
                      flex: 2,
                      child: Text(
                        "06/04/2025",
                        textAlign: TextAlign.center,
                        style: EMRListViewHead.customTextStyle(context)
                            .copyWith(fontWeight: FontWeight.w400),
                      ),
                    ),

                    // ── Closest Scheduled Visit ──────────────────────
                    Expanded(
                      flex: 3,
                      child: Text(
                        "06/04/2025",
                        textAlign: TextAlign.center,
                        style: EMRListViewHead.customTextStyle(context)
                            .copyWith(fontWeight: FontWeight.w400),
                      ),
                    ),

                    // ── Document Icon ────────────────────────────────
                    const SizedBox(
                      width: 50,
                      child: Icon(Icons.description_outlined, color: Colors.blue),
                    ),
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