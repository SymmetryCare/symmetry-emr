import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/color.dart';

import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/common_resources/emr_theme_const.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

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
    );
  }
}