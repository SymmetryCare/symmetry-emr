import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/communication_manger/chats_manager/clinician_manager/emp_clinician_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/communication_manger/chats_manager/patients_manager/group_info_api.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/onboarding/download_doc_const.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/communication_data/chats_data/clinitian_data/clinitian_emp_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/communication_data/chats_data/patients_data/patients_group_info.dart';

class

DepartmentInfoScreen extends StatefulWidget {
  final int empId;
  final VoidCallback onClose;
  const DepartmentInfoScreen({super.key, required this.empId,
    required this.onClose});

  @override
  State<DepartmentInfoScreen> createState() => _DepartmentInfoScreenState();
}

class _DepartmentInfoScreenState extends State<DepartmentInfoScreen>
    with SingleTickerProviderStateMixin {
  final StreamController<EmpDetailsDataClass> groupInfoController = StreamController<EmpDetailsDataClass>();
  late TabController _tabController;
  int currentUserid = 0 ;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPatientsGroupInfo();
  }

  Future<void> _loadPatientsGroupInfo() async {
    final userId = await TokenManager.getuserId();
    try {
      final data = await getEmpDetailCommunication(context, widget.empId);
      // print("✅ API returned ${data!.length} broadcasts");
      groupInfoController.add(data!);
      setState(() {
        currentUserid = userId;
      });
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
              Text("Info",style: TextStyle(
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
                    size: IconSize.I16,
                  ),
                ),

              ),
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder<EmpDetailsDataClass> (
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
                        "Failed to load employee info",
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
                            child: (groupInfo.profileUrl.isEmpty || groupInfo.profileUrl == 'imgurl')
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
                                    groupInfo.profileUrl,
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
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                      groupInfo.userId == currentUserid
                          ?"${groupInfo.firstName} ${groupInfo.lastName} (You)"
                          :"${groupInfo.firstName} ${groupInfo.lastName}",
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
                          const Text(
                            "NA",
                            style: TextStyle(color: Colors.black87, fontSize: 10),
                          ),
                          const SizedBox(height: 14),
                          const Divider(thickness: 2, height: 1),
                          const SizedBox(height: 14),
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
                                PointerDeviceKind.mouse, // enable mouse drag scrolling
                              },
                            ),
                            child: SizedBox(
                              height: 60, // enough height for images + scrollbar below
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Scrollbar(
                                      controller: _scrollController,
                                      thumbVisibility: true,
                                      trackVisibility: true,
                                      thickness: 6,
                                      radius: const Radius.circular(12),
                                      scrollbarOrientation: ScrollbarOrientation.bottom, // 👈 forces scrollbar at bottom
                                      child: SingleChildScrollView(
                                        controller: _scrollController,
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            for (var img in groupInfo.media)
                                              Padding(
                                                padding: const EdgeInsets.only(right: 6),
                                                child: InkWell(
                                                  onTap: () async {
                                                    if (img.toLowerCase().contains(".pdf")) {
                                                      await downloadFile(
                                                        context: context,
                                                        fileUrl: img,
                                                        documentName: "commuchat_pdf_${img.split('/').last}",
                                                        apiPath: DownloadDocumentRepository.getCliniciansChatImageByFileName(),
                                                      );
                                                    } else {
                                                      await openImageInNewTab(
                                                        context: context,
                                                        fileUrl: img,
                                                        documentName: "commuchat_image_${img.split('/').last}",
                                                        apiPath: DownloadDocumentRepository.getCliniciansChatImageByFileName(),
                                                      );
                                                    }
                                                  },

                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: img.toLowerCase().contains(".pdf")
                                                        ? Icon(
                                                      Icons.description,
                                                      size: 40,
                                                      color: ColorManager.blueprime,
                                                    )
                                                        : Image.network(
                                                      img,
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
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

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
                  radius: 15,
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
