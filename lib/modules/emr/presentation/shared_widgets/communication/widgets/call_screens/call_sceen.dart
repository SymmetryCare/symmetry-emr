import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/calling/calling_Manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/communication_data/call_history_data/call_log_model.dart';
// removed in extraction: import '../../../../../main.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/call_screens/new_videocall_screen.dart';

class CallScreenCommunication extends StatefulWidget {
  final VoidCallback onCallTap;

  const CallScreenCommunication({
    super.key,
    required this.onCallTap,
  });

  @override
  State<CallScreenCommunication> createState() =>
      _CallScreenCommunicationState();
}

class _CallScreenCommunicationState extends State<CallScreenCommunication> {
  final StreamController<CallHistoryResponseLog> callLogController = StreamController<CallHistoryResponseLog>();
  String selectedTab = 'All Calls';

  // FIX: cache the future in a State field instead of calling
  // getEmpDetailCommunication() inline inside FutureBuilder's `future:`
  // param — that re-fired the API call on every rebuild. Re-assigned
  // (via _loadCallHistory) whenever the selected tab/filter changes.
  late Future<CallHistoryResponseLog> _callHistoryFuture;

  @override
  void initState() {
    super.initState();
    _loadCallHistory();
  }

  void _loadCallHistory() {
    _callHistoryFuture = getEmpDetailCommunication(
        context: context,
        pageNr: '1',
        pageSize: '99999',
        filterType: selectedTab);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 15, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabBar(),
          const SizedBox(height: 20),
           FutureBuilder<CallHistoryResponseLog>(
             future: _callHistoryFuture,
             builder: (context, snapshot) {
               if (snapshot.connectionState == ConnectionState.waiting) {
                 return Padding(
                   padding: const EdgeInsets.symmetric(vertical: 150),
                   child: Center(
                       child: CircularProgressIndicator(
                           color: ColorManager.blueprime)),
                 );
               }
               if (snapshot.hasError || snapshot.data!.data.isEmpty) {
                 return Padding(
                   padding: const EdgeInsets.symmetric(vertical: 150),
                   child: Center(
                     child: Text(
                       "Calls history not available!",
                       style: AllNoDataAvailable.customTextStyle(context),
                     ),
                   ),
                 );
               }
               if(snapshot.hasData){
                 return Expanded(
                   child: Row(
                     children: [
                       Expanded(
                         child:ScrollConfiguration(
                           behavior: const ScrollBehavior().copyWith(scrollbars: false),
                           child:ListView.builder(
                             itemCount: snapshot.data!.data.length,
                             itemBuilder: (context, index) {
                               var callData = snapshot.data!.data[index];
                               return Column(
                                 children: [
                                   _buildCallListTile(
                                     containerColor:callData.callDirection == 'MISSED' ? Colors.red.withOpacity(0.1)
                                         : callData.callDirection == 'DIALED' ?Colors.blue.withOpacity(0.1) :Colors.green.withOpacity(0.1),
                                     startTime: callData.startTime,
                                     iconBgColor: callData.callDirection == 'MISSED' ? Colors.red.withOpacity(0.10)
                                         : callData.callDirection == 'DIALED' ?Colors.blue.withOpacity(0.10) :Colors.green.withOpacity(0.10),
                                     icon: callData.callDirection == 'MISSED' ? "images/communication/call/call_miss.png" //"Icons.phone_missed_rounded"
                                         : callData.callDirection == 'DIALED' ? "images/communication/call/call_out.png" : "images/communication/call/call_in.png",
                                     iconColor: callData.callDirection == 'MISSED' ? Colors.red
                                         : callData.callDirection == 'DIALED' ?Colors.blue :Colors.green,
                                     callType: "You ${callData.callDirection.toLowerCase()}${callData.isVideo ? ' video' : ''}",
                                     callerName: callData.contactName[0].toUpperCase() + callData.contactName.substring(1).toLowerCase(),
                                     details: callData.phoneNo.isEmpty ? '${callData.timeAgo}':'${callData.phoneNo} - ${callData.timeAgo}',
                                     ratingPrompt: callData.callDirection == 'RECEIVED' ? true : false,
                                     userCallId: callData.contactUserId,
                                       callerTypeGrp:callData.callType
                                   ),
                                   const SizedBox(height: 15),
                                   // Add more tiles if needed
                                 ],
                               );
                             },
                           ),
                         ),
                       ),
                     ],
                   ),
                 );
               }
               else{
                 return const SizedBox();
               }

             }
           ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      'All Calls',
      'Missed Calls',
      'Received Calls',
      'Dialled Calls',
    ];

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tab) {
            final isSelected = selectedTab == tab;
            return Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTab = tab;
                    _loadCallHistory();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: isSelected
                      ? BoxDecoration(
                    color: ColorManager.lilyBright,
                    borderRadius: BorderRadius.circular(20),
                  )
                      : null,
                  child: Text(
                    tab,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCallListTile({
    required String icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color containerColor,
    required String callType,
    required String callerName,
    required String details,
    required List<int> userCallId,
    required bool ratingPrompt,
    required String startTime,
    required String callerTypeGrp
  }) {
    final isWide = MediaQuery.of(context).size.width >= 450;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius:
            BorderRadius.circular(15),
            border: Border.all(
              color: ColorManager.bordercolor.withOpacity(0.2), // change to your border color
              width: 1,          // border width
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _iconButtoncall(icon, iconColor, () {},iconBgColor),
              SizedBox(width: isWide ? 15 : 15),

              // Middle text section – single Expanded
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 7),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: callType,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: ' call '),
                          const TextSpan(text: ' - '),
                          TextSpan(
                            text: callerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      details,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 3),
                     Text(
                      'Last Subject ${startTime}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: AppSize.s20,),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _iconButton("images/communication/call/audio_call.png", ColorManager.greenDark, () async{
                    var callResponse = await addCallInitiate(context,
                        participantUserIds:  userCallId,
                        callType: callerTypeGrp, isVideo: false);
                    if(callResponse.statusCode == 201 || callResponse.statusCode == 200){
                      print('Call response ${callResponse.data}');
                      final data = callResponse.data as Map<String, dynamic>;
                      final busyList = data['busyParticipants'] ?? [];
                      bool isBusyCall = busyList.contains(userCallId);
                      Navigator.push(context, MaterialPageRoute(builder: (_)=>
                          VideoCallAgoraScreen(
                            isVideoOn: false,
                            isAudioOn: true,
                            channelName: data['channelName'] ?? '',
                            token: data['token'] ?? '',
                            callId: data['callId'] ?? '',
                            userImage: data['contactImage'],
                            userName: data['contactName'] ?? '',
                            groupName:data['groupName'] ?? '' ,
                            groupImage: data['groupImage'] ?? '',
                            isBusyCall: isBusyCall,
                            receiverImages: (data['receiverImages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
                            receiverNames: (data['receiverNames'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
                          )));
                    }else{
                      print('Call error ${callResponse.message}');
                    }
                  }),
                  const SizedBox(width: 10),
                  _iconButton("images/communication/call/video_call.png", ColorManager.blueprime, () async{
                    var callResponse = await addCallInitiate(context,
                        participantUserIds: userCallId,
                        callType: callerTypeGrp,
                        isVideo: true);
                    if(callResponse.statusCode == 201 || callResponse.statusCode == 200){
                      print('Call response ${callResponse.data}');
                      final data = callResponse.data as Map<String, dynamic>;
                      final busyList = data['busyParticipants'] ?? [];
                      bool isBusyCall = busyList.contains(userCallId);
                      Navigator.push(context, MaterialPageRoute(builder: (_)=>
                          VideoCallAgoraScreen(
                            isVideoOn: true,
                            isAudioOn: true,
                            channelName: data['channelName'] ?? '',
                            token: data['token'] ?? '',
                            callId: data['callId'] ?? '',
                            isBusyCall: isBusyCall,
                            receiverImages: (data['receiverImages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
                            receiverNames: (data['receiverNames'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
                            )));
                    }else{
                      print('Call error ${callResponse.message}');
                    }
                  }),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _iconButton(
      String icon,
      Color color,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 15,
        backgroundColor: Colors.grey.shade100,
        child: Image.asset(icon,height: 15,width: 15,),
      ),
    );
  }

  static Widget _iconButtoncall(
      String icon,
      Color color,
      VoidCallback onTap,
      Color iconBackColor,
      ) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 15,
        backgroundColor: iconBackColor,
        child: Image.asset(icon,height: 15,width: 15,),
      ),
    );
  }
}


