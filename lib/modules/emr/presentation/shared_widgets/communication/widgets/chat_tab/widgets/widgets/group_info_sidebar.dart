import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/communication_manger/chats_manager/patients_manager/group_info_api.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_emr/modules/emr/data/models/communication_data/chats_data/patients_data/patients_group_info.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/onboarding/download_doc_const.dart';

class GroupInfoScreen extends StatefulWidget {
  final int groupId;
  final VoidCallback onClose;
  const GroupInfoScreen({super.key, required this.groupId,
  required this.onClose});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen>
    with SingleTickerProviderStateMixin {
  final StreamController<PatientsGroupInfoData> groupInfoController = StreamController<PatientsGroupInfoData>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPatientsGroupInfo();
  }

  Future<void> _loadPatientsGroupInfo() async {
    try {
      final data = await getAllPatientsGroupInfo(context, widget.groupId);
      groupInfoController.add(data!);
    } catch (e) {
      print("❌ group info API Error: $e");
      groupInfoController.addError(e);
    }
  }
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  //final List<String> _patients = List.generate(8, (i) => 'Patient #${i + 1}');
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:  BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorManager.greyShade200)
      ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Close icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Group Info",style: TextStyle(
                    color: ColorManager.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),),
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: widget.onClose,     // <--- CALL CLOSE FUNCTION
                      child: Icon(
                        Icons.close,
                        color: ColorManager.greyShade400,
                        size: IconSize.I20,
                      ),
                    ),

                  ),
                ],
              ),
              const SizedBox(height: 10),
        StreamBuilder<PatientsGroupInfoData> (
            stream: groupInfoController.stream,
            builder: (context, snapshot) {
              print('1111111');
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 100),
                  child: Center(
                    child: SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                        color: ColorManager.blueprime,
                      ),
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 100),
                  child: Center(
                    child: Text(
                      "Failed to load group info",
                      style: AllNoDataAvailable.customTextStyle(context),
                    ),
                  ),
                );
              }
              if (snapshot.hasData) {
                final groupInfo = snapshot.data!;
                return Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ClipOval(
                        child: (groupInfo.groupProfileUrl.isEmpty || groupInfo.groupProfileUrl == 'imgurl')
                            ? CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.transparent,
                          child: Image.asset("images/profilepic.png"),
                        )
                            : Builder(
                          builder: (context) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                groupInfo.groupProfileUrl,
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                                errorBuilder: (context, error, stackTrace) {
                                  //   print("❌ Failed to load image: $error"); // Optional: Print load failure
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    // backgroundColor: Colors.transparent,
                                    child: Image.asset("images/profilepic.png",height: 40,width: 40,),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      /// Edit icon dont delete
                      // Positioned(
                      //   bottom: 0,
                      //   right: -2,
                      //   child: Container(
                      //     width: 20,
                      //     height: 20,
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       shape: BoxShape.circle,
                      //       boxShadow: [
                      //         BoxShadow(
                      //           color: Colors.black12,
                      //           blurRadius: 4,
                      //           offset: Offset(0, 2),
                      //         ),
                      //       ],
                      //     ),
                      //     child: Icon(
                      //       Icons.edit_outlined,
                      //       size: 16,
                      //       color: Colors.grey[800],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    groupInfo.groupName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12,color: ColorManager.black,),
                  ),
                  const SizedBox(height: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        "About",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 12,color: ColorManager.blackfaint),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        groupInfo.groupDescription,
                        style: const TextStyle(color: Colors.black87, fontSize: 10),
                      ),
                      const SizedBox(height: 12),
                      const Divider(thickness: 2, height: 1),
                      const SizedBox(height: 12),
                      // Media section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "Media, links and doc",
                              style:TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 12,color: ColorManager.blackfaint)
                          ),
                          Icon(Icons.chevron_right, color: ColorManager.greyShade400,size: IconSize.I16,),

                        ],
                      ),
                      const SizedBox(height: 8),
                      ScrollConfiguration(
                        behavior: const MaterialScrollBehavior().copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                          },
                        ),

                        child: SizedBox(
                          height: 60,
                          child: Column(
                            children: [
                              Expanded(
                                child: Scrollbar(
                                  controller: _scrollController,
                                  thumbVisibility: true,        // show scrollbar always (optional)
                                  trackVisibility: true,        // show track (optional)
                                  thickness: 4,                 // thickness of the scrollbar
                                  radius: const Radius.circular(12),  // rounded corners
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: SingleChildScrollView(
                                      controller: _scrollController,
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          for (var img in snapshot.data!.mediaLinksAndDocs)

                                            Padding(
                                              padding: const EdgeInsets.only(right: 6.0),
                                              child: InkWell(
                                                onTap: () async {
                                                  if (img.mediaUrl.toLowerCase().contains(".pdf")) {
                                                    await downloadFile(
                                                      context: context,
                                                      fileUrl: img.mediaUrl,
                                                      documentName: "commuchat_pdf_${img.mediaUrl.split('/').last}",
                                                      apiPath: DownloadDocumentRepository.getCliniciansChatImageByFileName(),
                                                    );
                                                  } else {
                                                    await openImageInNewTab(
                                                      context: context,
                                                      fileUrl: img.mediaUrl,
                                                      documentName: "commuchat_image_${img.mediaUrl.split('/').last}",
                                                      apiPath: DownloadDocumentRepository.getCliniciansChatImageByFileName(),
                                                    );
                                                  }
                                                },
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: img.mediaUrl.toLowerCase().contains(".pdf")
                                                      ? Icon(
                                                    Icons.description,
                                                    size: 40,
                                                    color: ColorManager.blueprime,
                                                  )
                                                      : Image.network(
                                                    img.mediaUrl,
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(thickness: 2, height: 1),
                      const SizedBox(height: 12),
                      Text(
                          "All Participants",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 12,color: ColorManager.blackfaint)
                      ),
                      const SizedBox(height: 8),
                      ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          scrollbars: false,
                          overscroll: false,
                        ),
                        child: SingleChildScrollView(
                          child: Container(
                            child: ListView.builder(
                              physics: const ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: groupInfo.allParticipants.length,
                              // FIX: lets Flutter find a participant's previous slot by
                              // its key when the refetched list reorders it, so the
                              // Element (and its already-decoded avatar) is truly reused
                              // instead of torn down and redecoded from scratch.
                              findChildIndexCallback: (key) {
                                final valueKey = key as ValueKey<int>;
                                final index = groupInfo.allParticipants.indexWhere((p) => p.participantId == valueKey.value);
                                return index == -1 ? null : index;
                              },
                              itemBuilder: (context, index) {
                                final participant = groupInfo.allParticipants[index];
                                return SingleChildScrollView(
                                  key: ValueKey(participant.participantId),
                                  child: _participantTile(
                                    participant.fullName,
                                    participant.imgUrl,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      )

                    ],
                  ),
                ],
              );
              }
              return Center(
                child: Text(
                  "No broadcast data available",
                  style: AllNoDataAvailable.customTextStyle(context),
                ),
              );
            })
            ],
          ),
    );
  }

  Widget _participantTile(String name, String imagePath) {
    return Column(
      children: [
        Row(
          children: [
            ClipOval(
              child: (imagePath!.isEmpty || imagePath == 'imgurl')
                  ? CircleAvatar(
                radius: 12,
                backgroundColor: Colors.transparent,
                child: Image.asset("images/profilepic.png"),
              )
                  : Builder(
                builder: (context) {
                  return Image.network(
                    imagePath,
                    height: 20,
                    width: 20,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) {
                      //   print("❌ Failed to load image: $error"); // Optional: Print load failure
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        // backgroundColor: Colors.transparent,
                        child: Image.asset("images/profilepic.png",height: 20,width: 20,),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 6,),
            Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,color: ColorManager.blackfaint)),
          ] ),
        const SizedBox(height: 6,)
      ],
    );
  }
}
