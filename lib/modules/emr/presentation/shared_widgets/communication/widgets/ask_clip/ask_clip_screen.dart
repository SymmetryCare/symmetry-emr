import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/ask_clip/widgets/ask_clip_chat_sidebar.dart';
import 'package:symmetry_emr/app/resources/communication_model/communication_string.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
class AskClipScreenCommunication extends StatelessWidget {
  final VoidCallback onMicTap;
  const AskClipScreenCommunication({super.key, required this.onMicTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MediaQuery.of(context).size.width >= 600 ? const SizedBox(
          width: 200,
          child: ChatSidebar(),
        ) : const Offstage(),
        Expanded(
          child: AskClipChat(onMicTap: onMicTap,),
        ),
      ],
    );
  }
}

class AskClipChat extends StatelessWidget {
  final VoidCallback onMicTap;
  const AskClipChat({super.key,required this.onMicTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset("images/communication/ask_clip.svg"),
              const SizedBox(width: 5,),
              Text(
                CommunicationString.klip,
                style: TextStyle(
                  fontSize: 16,
                  color: ColorManager.mediumgrey,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSize.s20),
          Text(
            CommunicationString.canAssist,
            style: TextStyle(
              fontSize: FontSize.s18,
              fontWeight: FontWeight.w700,
              color: ColorManager.mediumgrey,
            ),
          ),
          const SizedBox(height: AppSize.s25),
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Container()),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        //width: AppSize.s450,
                        height: AppSize.s40,
                        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
                        decoration: BoxDecoration(
                          color: ColorManager.white,
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30)),
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
                        child: TextField(
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,color: Colors.blueGrey.shade600),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.only(bottom: AppPadding.p18,
                                top: AppPadding.p10),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSize.s8),
                    GestureDetector(
                      onTap: onMicTap,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFEA6191),
                        child: SvgPicture.asset("images/communication/mic_logo.svg",height: IconSize.I22,width: IconSize.I22,),
                      ),
                    ),
                    const SizedBox(width: AppSize.s15),
                    GestureDetector(
                      onTap: (){},
                      child: Icon(
                        size: IconSize.I20,
                        Icons.send,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Container()),
            ],
          ),
        ],
      ),
    );
  }
}