import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/communication_model/communication_string.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
// removed in extraction: import '../../../../../main.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/bottom_row.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/ask_clip/ask_clip_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/ask_clip/widgets/ask_clip_chat_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/broadcast/broadcast_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/call_screens/call_sceen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/chat_screen_main.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/communication_app_bar.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/e_fax/e_fax_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/email/email_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/recent_activity/recent_activity_data_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/recent_activity/recent_activity_screen.dart';
List<CameraDescription>? cameras;
class CommunicationTabHomeScreen extends StatefulWidget {
  const CommunicationTabHomeScreen({super.key});

  @override
  State<CommunicationTabHomeScreen> createState() => _CommunicationTabHomeScreenState();
}

class _CommunicationTabHomeScreenState extends State<CommunicationTabHomeScreen> {
  int selectedIndex = 0;
  bool showRecentActivityScreen = false;
  bool showNewAskClipScreen = false;
  bool showNewCallScreen = false;
  bool showReceivedVideoCallScreen = false;


  final List<String> labels = [
    "Recent Activity",
    "Ask Klip",
    "Broadcast",
    "Chat",
    "Email",
    "E-Fax",
    "Call",
  ];

  final List<String> svgPaths = [
    "images/communication/bar_clock.svg",
    "images/communication/bar_ask_clip.svg",
    "images/communication/bar_broadcast.svg",
    "images/communication/bar_chat.svg",
    "images/communication/bar_mail.svg",
    "images/communication/bar_efax.svg",
    "images/communication/bar_call.svg",
  ];


  final List<Color> iconColors = [
    ColorManager.blueBright,
    ColorManager.pinkBright,
    ColorManager.orangeBright,
    ColorManager.bluenBright,
    ColorManager.greenBright,
    ColorManager.yellowBright,
    ColorManager.lilyBright,
  ];




  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      showRecentActivityScreen
          ? RecentActivityDataScreenCommunication(
          onBackTap: () {
            setState(() {
              showRecentActivityScreen = false;
            });
          }
      )
          : RecentActivityscreenCommunication(
        onImgTap: () {
          setState(() {
            showRecentActivityScreen = true;
          });
        },
      ),
      showNewAskClipScreen
          ? const AskClipChatScreen()
          : AskClipScreenCommunication(
        onMicTap: () {
          setState(() {
            showNewAskClipScreen = true;
          });
        },
      ),
      const BroadcastScreenCommunication(),
      ChatScreenCommunication(),
      const EmailScreenCommunication(),
      const EFaxScreenCommmunication(),
      CallScreenCommunication(
        onCallTap: (){
          setState(() {
            showNewCallScreen = true;
          });
        },
      ),
    ];
    return Material(
      color: ColorManager.white,
      child: Column(
        children: [
          const CommunicationAppBar(),
          const SizedBox(height: AppSize.s10,),
          Stack(
            clipBehavior: Clip.none, // allow shadow to overflow
            children: [
              // Main container with Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppPadding.p15),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SchedularIconButtonConst(
                        onPressed: () {},
                        borderRadius: 10,
                        text: CommunicationString.latestAction,
                        width: AppSize.s250,
                      ),
                      const SizedBox(width: AppSize.s10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(AppPadding.p5),
                          height: AppSize.s25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSize.s20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: AppSize.s37,
                            height: AppSize.s25,
                            decoration: BoxDecoration(
                              color: ColorManager.white,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {},
                              child: Center(
                                child: SvgPicture.asset('images/menuLines.svg'),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSize.s10),
                          StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return DZoneButton(
                                isSelected: false,
                                onTap: () {},
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Thin shadow line below the container
              Positioned(
                bottom:-6, // slightly below the container
                left: 0, // match container horizontal padding
                right: 0,
                child: Container(
                  height: 6,
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(3, 3), // moves shadow downward
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),// shadow color
                ),
              ),
            ],
          ),


          Container(
            height: AppSize.s75,
            color: ColorManager.white,
            padding: const EdgeInsets.only(left: AppPadding.p20),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(labels.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                            decoration: selectedIndex == index
                                ? BoxDecoration(
                              color: Colors.blueGrey.shade50,
                              borderRadius: BorderRadius.circular(6),
                            )
                                : null,
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  svgPaths[index],
                                  height: 20,
                                  width: 20,
                                ),
                                const SizedBox(width: AppSize.s5),
                                Text(
                                  labels[index],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: iconColors[index],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: AppSize.s30,)
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSize.s15),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: AppPadding.p20,right: AppPadding.p20),
              child: Container(
                decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selectedIndex == 3 ? ColorManager.white : ColorManager.greyShade200,width: 1)
                ),
                child:  screens[selectedIndex],
              ),
            ),
          ),
          const SizedBox(height: AppSize.s10),
          const BottomBarRow()
        ],
      ),
    );
  }
}
