import 'package:flutter/material.dart';
import '../../../../../../../../app/resources/color.dart';
import '../../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../../app/resources/value_manager.dart';
// ── Data model for each row in SectionChildPocData ───────────────────────────
class PocDataItem {
  final String text;
  final String date;
  const PocDataItem({required this.text, required this.date});
}

class SectionHeaderPOC extends StatelessWidget {
  final String label;
  const SectionHeaderPOC({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: FontSize.s12,
            fontWeight: FontWeight.w700,
            color: ColorManager.mediumgrey,
            letterSpacing: 0.4,
          ),
        ),
        Container(
          width: AppSize.s22,
          height: AppSize.s22,
          decoration: BoxDecoration(
            color: ColorManager.blueprime,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, size: 20, color: Colors.white),
        ),
      ],
    );
  }
}


class SectionChildPocData extends StatelessWidget {
  final String title;
  final String formName;
  final String clinicianName;
  final String abbreviation;
  final String date;
  final Widget? child;
  final bool showBottomDivider;
  final List<PocDataItem> items;
  const SectionChildPocData({super.key,
    required this.title,
    this.child,
    required this.formName,
    required this.clinicianName,
    required this.date,
    required this.items,
    required this.abbreviation,
    this.showBottomDivider = true,});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Form Name : ",
                    style: TextStyle(
                      fontSize: FontSize.s13,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.darkgrey,
                    ),
                  ),
                  TextSpan(
                    text: formName,
                    style: TextStyle(
                      fontSize: FontSize.s13,
                      fontWeight: FontWeight.w500,
                      color: ColorManager.darkgrey,
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Clinician Name : ",
                    style: TextStyle(
                      fontSize: FontSize.s13,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.darkgrey,
                    ),
                  ),
                  TextSpan(
                    text: clinicianName,
                    style: TextStyle(
                      fontSize: FontSize.s13,
                      fontWeight: FontWeight.w500,
                      color: ColorManager.darkgrey,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Abbreviation : ",
                        style: TextStyle(
                          fontSize: FontSize.s13,
                          fontWeight: FontWeight.w700,
                          color: ColorManager.darkgrey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10,),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: ColorManager.green,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    abbreviation,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
        SizedBox(height: AppSize.s10,),
        Container(
          decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12)),
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
                width: 3,
              ),
              left: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
              right: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
              top: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with green dot
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppPadding.p16, AppPadding.p14, AppPadding.p16, AppPadding.p10),
                child: Row(
                      children: [
                        Container(
                          width: AppSize.s8,
                          height: AppSize.s8,
                          decoration: BoxDecoration(
                            color: ColorManager.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSize.s10),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: FontSize.s13,
                            fontWeight: FontWeight.w700,
                            color: ColorManager.darkgrey,
                          ),
                        ),
                      ],
                    ),

              ),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
              // ── Data rows (driven by items list) ──────────────────────
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == items.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppPadding.p16, AppPadding.p12, AppPadding.p16, AppPadding.p12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 8,
                            child: Text(
                              item.text,
                              style: TextStyle(
                                fontSize: FontSize.s11,
                                color: ColorManager.darkgrey,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSize.s20),
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Effective: ${item.date}',
                                    style: TextStyle(
                                      fontSize: FontSize.s11,
                                      color: ColorManager.grey,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSize.s10),
                                Icon(Icons.info_outline,
                                    size: AppSize.s16, color: ColorManager.blueprime),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                  ],
                );
              }),
              if (showBottomDivider)
                Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
              Container(
                child: child,
              )
            ],
          ),
        ),
      ],
    );
  }
}
