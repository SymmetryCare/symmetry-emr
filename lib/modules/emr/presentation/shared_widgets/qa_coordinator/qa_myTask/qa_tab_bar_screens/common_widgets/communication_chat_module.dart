import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:symmetry_emr/app/resources/communication_model/communication_string.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/ask_clip/ask_clip_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/ask_clip/widgets/ask_clip_chat_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/broadcast/broadcast_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/call_screens/call_sceen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/call_screens/received_video_call.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/chat_screen_main.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/e_fax/e_fax_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/email/email_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/recent_activity/recent_activity_data_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/recent_activity/recent_activity_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/bottom_row.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/button_constant.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widget_for_tab_mobile/communication_tablet/communication_tab_home_screen.dart';



class QACommunicationChat extends StatefulWidget {
  final Function(int) onTap;
  const QACommunicationChat({super.key, required this.onTap});

  @override
  State<QACommunicationChat> createState() => _QACommunicationChatState();
}

class _QACommunicationChatState extends State<QACommunicationChat> {
  int selectedIndex = 1;
  bool showRecentActivityScreen = false;
  bool showNewAskClipScreen = false;
  bool showNewCallScreen = false;
  bool showReceivedVideoCallScreen = false;

  final List<String> labels = [
    "Broadcast",
    "Chat",
    "Email",
    "Call",
  ];

  final List<String> svgPaths = [
    "images/communication/bar_broadcast.svg",
    "images/communication/bar_chat.svg",
    "images/communication/bar_mail.svg",
    "images/communication/bar_call.svg",
  ];


  final List<Color> iconColors = [
    ColorManager.orangeBright,
    ColorManager.bluenBright,
    ColorManager.greenBright,
    ColorManager.lilyBright,
  ];

  @override
  void initState() {
    super.initState();
    checkpermission();
  }
  Future<void> checkpermission() async{
    cameras = await availableCameras();
  }
  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const BroadcastScreenCommunication(),
      ChatScreenCommunication(isClearShow: true,onClearTap: ()=>widget.onTap(0),),
      const EmailScreenCommunication(),
      CallScreenCommunication(
        onCallTap: (){
          setState(() {
            showNewCallScreen = true;
          });
        },
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: showNewCallScreen
          ? ReceivedVideoCall(
        onEndCall: () {
          setState(() {
            showNewCallScreen = false;
          });
        },

      )
          :   Column(
        children: [
          const SizedBox(height: AppSize.s15,),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: AppSize.s15),
                Container(
                  width: AppSize.s75,
                  color: ColorManager.white,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(labels.length, (index) {
                          return InkWell(
                            splashColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            onTap: () {
                              setState(() {
                                selectedIndex = 1;
                              });
                            },
                            child: Container(
                              width: AppSize.s90,
                              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p4, vertical: AppPadding.p10),
                              decoration: selectedIndex == index
                                  ? BoxDecoration(
                                color: const Color(0xFFECF7FC),
                                borderRadius: BorderRadius.circular(10),
                              )
                                  : null,
                              child: Column(
                                children: [
                                  SvgPicture.asset(
                                    svgPaths[index],
                                    height: 24,
                                    width: 24,
                                  ),
                                  const SizedBox(height: AppSize.s5),
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
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSize.s10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorManager.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:  screens[selectedIndex],

                  ),
                ),
                const SizedBox(width: AppSize.s15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
