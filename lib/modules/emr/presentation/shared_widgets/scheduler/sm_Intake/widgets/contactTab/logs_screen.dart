import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/color.dart';

import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

class ContactLogsScreen extends StatelessWidget {
  const ContactLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8)),
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
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8)),
            border: Border(
                top: BorderSide(color: Color(0xFF1696C8), width: 5)),
          ),
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  width: 270,
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      bottom: 3,
                    ),
                    child: TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: ColorManager.textPrimaryColor,
                      indicatorPadding:
                          const EdgeInsets.symmetric(horizontal: 15, vertical: 1),
                      indicator: BoxDecoration(
                        color: ColorManager.SMFBlue,
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                      ),
                      tabs: [
                        Tab(
                          child: Text(
                            'Call Log',
                            style: CustomTextStylesCommon.commonStyle(
                              fontSize: FontSize.s14,
                              fontWeight: FontWeight.w700,
                              color: ColorManager.textPrimaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        Tab(
                          child: Text(
                            'E-Fax',
                            style: CustomTextStylesCommon.commonStyle(
                              fontSize: FontSize.s14,
                              fontWeight: FontWeight.w700,
                              color: ColorManager.textPrimaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(),
                ),
                const Expanded(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      CallLogsTab(),

                      ///
                      EFaxTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class CallLogsTab extends StatelessWidget {
  const CallLogsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
          itemCount: 10,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
                child: Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Image.asset(
                                "images/sm/logo_ph.png",
                                height: 40,
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: AppSize.s5),
                              Text(
                                'Prohealth',
                                style: CustomTextStylesCommon.commonStyle(
                                  fontSize: FontSize.s12,
                                  fontWeight: FontWeight.w700,
                                  color: ColorManager.mediumgrey,
                                ),
                              ),
                              const SizedBox(height: AppSize.s2),
                              Text(
                                '2024/08/05',
                                style: CustomTextStylesCommon.commonStyle(
                                  fontSize: FontSize.s12,
                                  fontWeight: FontWeight.w400,
                                  color: ColorManager.mediumgrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '6 mins 23 secs',
                            style: CustomTextStylesCommon.commonStyle(
                              fontSize: FontSize.s12,
                              fontWeight: FontWeight.w400,
                              color: ColorManager.mediumgrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ));
          }),
    );
  }
}

class EFaxTab extends StatelessWidget {
  const EFaxTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
          itemCount: 10,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 25,
                      children: [
                        Column(
                          children: [
                            Image.asset(
                              "images/sm/file.png",
                              height: 20,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 200,
                          child: Text(
                            'eFax sent by Warren. No document attached.',
                            style: CustomTextStylesCommon.commonStyle(
                              fontSize: FontSize.s12,
                              fontWeight: FontWeight.w500,
                              color: ColorManager.mediumgrey,
                            ),
                          ),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '2024/08/05',
                          style: CustomTextStylesCommon.commonStyle(
                            fontSize: FontSize.s12,
                            fontWeight: FontWeight.w400,
                            color: ColorManager.mediumgrey,
                          ),
                        ),
                        const SizedBox(height: AppSize.s2),
                        Text(
                          '8:17PM',
                          style: CustomTextStylesCommon.commonStyle(
                            fontSize: FontSize.s12,
                            fontWeight: FontWeight.w400,
                            color: ColorManager.mediumgrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ));
          }),
    );
  }
}
