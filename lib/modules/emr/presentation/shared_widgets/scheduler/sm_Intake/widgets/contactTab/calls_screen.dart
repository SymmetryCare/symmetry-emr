import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
// removed in extraction: import 'package:prohealth/modules/hr/presentation/screens/manage/web_manage/manage_screen.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/constant_widgets/const_checckboxtile.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_flow_contgainer_const.dart';

class ContactCallsScreen extends StatelessWidget {
  const ContactCallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SmIntakeProviderManager>(
      builder: (context,providerState,child) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20,left: 15,right: 15,bottom: 10),
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
                    top: BorderSide(color: Color(0xFF1696C8),width: 5)
                  ),
                ),
                child: DefaultTabController(
                  length: 2,
                  initialIndex: providerState.initialIndex,
                  child: Column(
                    children: [
                      Padding(
                        padding:  const EdgeInsets.only(top: 10,bottom: 3,
                            left: 25,
                            right: 25,
                     ),
                        child: TabBar(
                          onTap: (index) {
                            providerState.indexChnage(index);

                      },
                      indicatorWeight: 3,
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                      indicatorPadding: const EdgeInsets.symmetric(horizontal: 15,vertical: 1),
                      indicator: BoxDecoration(
                        color: ColorManager.SMFBlue, // Background color for selected tab
                        borderRadius: BorderRadius.circular(8), // Optional
                      ),
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: ColorManager.textPrimaryColor,
                      labelStyle: const TextStyle(
                        fontSize: FontSize.s14,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelColor: ColorManager.textPrimaryColor,
                      dividerColor: Colors.black54,
                      tabs: [
                      providerState.isContactCallLive?  const Tab(child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Flexible(child: Icon(Icons.wifi_calling_3_outlined)),
                            Flexible(child: Text("Live Call"))
                          ],
                        ),): const Tab(child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 10,
                              children: [
                                Flexible(child: Icon(Icons.content_paste_search_outlined)),
                                Flexible(child: Text("Transcripts"))
                              ],
                            ),),
                            const Tab(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 10,
                                children: [
                                  Flexible(child: Icon(Icons.history)),
                                  Flexible(child: Text("Transcription History"))
                                ],
                              ),),
                          ],
                        ),
                      ),

                      Expanded(
                        child: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                          providerState.isContactCallLive?const LiveCallTab():const CallTranscriptTab(),
                            const CallTransictionTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        );
      }
    );
  }
}

class LiveCallTab extends StatelessWidget {
  const LiveCallTab({super.key});

  @override
  Widget build(BuildContext context) {
    bool isName = false;
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(),
            const SizedBox(height:40),
            Container(
              height: 31,
              width: double.maxFinite,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE1AD),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),bottomRight: Radius.circular(5))
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Intake Script', style: CustomTextStylesCommon.commonStyle(fontSize: FontSize.s14,
                      fontWeight: FontWeight.w700,
                      color:  ColorManager.textPrimaryColor,),),
                    Row(
                      spacing: 5,
                      children: [
                        const Icon(Icons.play_circle_outline_outlined),
                        Text('Play', style: CustomTextStylesCommon.commonStyle(fontSize: FontSize.s14,
                        fontWeight: FontWeight.w400,
                        color:  ColorManager.textPrimaryColor,),)
                      ],
                    )
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Align(
                alignment: Alignment.center,
                  child: Icon(Icons.keyboard_arrow_up_outlined,color: Color(0xFF1696C8),)),
            ),
            Container(
              height:160,
              color:const Color(0xFF1696C8).withOpacity(0.1),
              child:Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        spacing: 10,
                        children: [
                          CheckboxTile(
                            title: 'What is Your First Name?',
                            initialValue: isName,
                            onChanged: (value) {

                            },
                          ),
                          const CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 25,
                              backgroundImage: AssetImage('images/temp.jpg'),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 10,
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 25,
                              backgroundImage:
                              AssetImage('images/tmp2.jpg'),
                          ),
                          Text('My First Name is Erica', style: CustomTextStylesCommon.commonStyle(fontSize: FontSize.s12,
                          fontWeight: FontWeight.w700,
                          color:  ColorManager.textPrimaryColor,),)
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10,top: 5),
                        child: Row(
                          children: [
                            Image.asset("images/sm/aii.png",height: 20,),
                            const SizedBox(width: 2,),
                            Text(" : Erica ",style: CustomTextStylesCommon.commonStyle(fontSize: FontSize.s12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF008000),),),
                            const SizedBox(width: 2,),
                            Icon(Icons.copy,color: ColorManager.textPrimaryColor ,),
                          ],
                        ),
                      )
                    ]
                ),
              )
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Align(
                  alignment: Alignment.center,
                  child: Icon(Icons.keyboard_arrow_down_outlined,color: Color(0xFF1696C8),)),
            ),

          ],
        ),
      ),
    );
  }
}

/// Call logs
class CallTransictionTab extends StatelessWidget {
  const CallTransictionTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 5),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 40,bottom: 20,top: 20),
              child: Text('Yesterday',style: CustomTextStylesCommon.commonStyle(
                color:const Color(0xFF2B647F),
                fontWeight: FontWeight.w600,fontSize: FontSize.s16,
              ),),
            ),
            Container(
              height: MediaQuery.of(context).size.height / 1.5,
              child: ListView.builder(
                itemCount: 5,
                  itemBuilder: (BuildContext,index){
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:CrossAxisAlignment.start,
                                    children: [
                                      Image.asset("images/sm/outgoing_call.jpg",height: 20,),
                                    ],
                                  ),
                                  const SizedBox(width: 5,),
                                  Column(
                                    crossAxisAlignment:CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 5,),
                                      Text('John Smith',style: CustomTextStylesCommon.commonStyle(
                                        color:const Color(0xFF686464),
                                        fontWeight: FontWeight.w700,fontSize: FontSize.s14,
                                      )),
                                      const SizedBox(height: 5,),
                                      Container(
                                        width: 70,
                                        height: 18,
                                        decoration: BoxDecoration(border: Border.all(color: Colors.red),borderRadius: BorderRadius.circular(5),color: const Color(0xFFE9E9FA)),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.circle,color: Colors.red,size:8 ,),
                                            Text('02:22:50',style:CustomTextStylesCommon.commonStyle(
                                              color:const Color(0xFF686464),
                                              fontWeight: FontWeight.w400,fontSize: FontSize.s10,
                                            ) ,)
                                          ],
                                        ),
                                      )

                                    ],
                                  )
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                spacing: 5,
                                children: [
                                  Text('12:30 PM',style: CustomTextStylesCommon.commonStyle(
                                    color:const Color(0xFF374151),
                                    fontWeight: FontWeight.w400,fontSize: FontSize.s14,
                                  ),),
                                  Text('Follow-Up Added',style: CustomTextStylesCommon.commonStyle(
                                    color:const Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w700,fontSize: FontSize.s14,
                                  ),)
                                ],
                              ),


                            ],
                          ),
                        ),
                        const SizedBox(height: 5,),
                        const Divider()
                      ],
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Call transcript
class CallTranscriptTab extends StatelessWidget {
  const CallTranscriptTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> messages = [
      {'text': 'What is your refferals_manager ID?', 'isMe': false,'time':'12:00 PM'},
      {'text': 'Insurance ID95946233333', 'isMe': true,'time':'12:12 PM'},
      {'text': 'What is your First name?', 'isMe': false,'time':'14:00 PM'},
      {'text': 'My first name is Erica', 'isMe': true,'time':'14:10 PM'},
    ];
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical:10),
            child: Text('Yesterday',style:CustomTextStylesCommon.commonStyle(
              color:const Color(0xFF686464),
              fontWeight: FontWeight.w700,fontSize: FontSize.s12,
            ),),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 25),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message['isMe']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: message['isMe']
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!message['isMe'])
                        Column(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                              AssetImage('images/tmp2.jpg'), // Replace with your asset
                              radius: 23,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(message['time'],style: CustomTextStylesCommon.commonStyle(
                                color:const Color(0xFF727272),
                                fontWeight: FontWeight.w500,fontSize: FontSize.s10,
                              ),),
                            )
                          ],
                        ),
                      const SizedBox(width: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (message['isMe']) const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Icon(Icons.copy,size: 20,)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            constraints: const BoxConstraints(maxWidth: 250),
                            decoration: BoxDecoration(
                              color: message['isMe']
                                  ? Colors.blue[100]
                                  : Colors.grey[300],
                              borderRadius: const BorderRadius.only(topRight: Radius.circular(10),bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
                            ),
                            child: Text(message['text'],style: message['isMe'] ? CustomTextStylesCommon.commonStyle(
                              color:Colors.white,
                              fontWeight: FontWeight.w600,fontSize: FontSize.s12,
                            ):CustomTextStylesCommon.commonStyle(
                              color:const Color(0xFF686464),
                              fontWeight: FontWeight.w600,fontSize: FontSize.s12,
                            ),),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      if (message['isMe'])  Column(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.transparent,
                            backgroundImage:
                            AssetImage('images/temp.jpg'), // Replace with your asset
                            radius: 23,
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(message['time'],style: CustomTextStylesCommon.commonStyle(
                              color:const Color(0xFF727272),
                              fontWeight: FontWeight.w500,fontSize: FontSize.s10,
                            ),),
                          )
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
