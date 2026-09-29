import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/communication_model/communication_string.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
class RecentActivityDataScreenCommunication extends StatelessWidget {
  final VoidCallback onBackTap;
  const RecentActivityDataScreenCommunication({super.key, required this.onBackTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppPadding.p15,right: AppPadding.p15,),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBackTap,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: AppPadding.p10),
                child: Text(
                  CommunicationString.recentactivity,
                  style: TextStyle(
                    fontSize: FontSize.s18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false,
                overscroll: false,
              ),
              child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return  Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0x0D4AF90D),
                                       // color: ColorManager.greyShade,
                                      borderRadius: const BorderRadius.only(
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
                            ),
                                      ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p12, vertical: AppPadding.p10),
                         child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundImage:
                            AssetImage("images/profile.png"),
                          ),
                          const SizedBox(width: AppSize.s15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Allen Anderson",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: FontSize.s14,
                                        color: ColorManager.mediumgrey,
                                      ),
                                    ),
                                    const SizedBox(width: AppSize.s12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: AppPadding.p6, vertical: AppPadding.p2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.grey.shade300, width: 1)
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.notifications_active,color: ColorManager.blueBright,size: FontSize.s12,),
                                          const SizedBox(width: AppSize.s6,),
                                          Text(
                                            "Broadcast",
                                            style: TextStyle(
                                              fontSize: FontSize.s11,
                                              color: ColorManager.blueBright,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSize.s4),
                                Text(
                                  "Let’s pause the medication for now. I’ll schedule a follow-up call to reassess tomorrow.",
                                  style: TextStyle(
                                    fontSize: FontSize.s11,
                                    fontWeight: FontWeight.w400,
                                    color: ColorManager.mediumgrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          /// Time
                          Text(
                            "12:00  pm  | Thu  |  12.05.24",
                            style: TextStyle(
                              fontSize: FontSize.s11,
                              fontWeight: FontWeight.w400,
                              color: ColorManager.mediumgrey,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                                        ),
                                      ),
                                    ),
                        const SizedBox(height: AppSize.s12),
                      ],
                    );}),
            ),
          )
        ],
      ),
    );
  }
}