import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/administration_screen_tab.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/clinician_screen_tab.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/patient_screen_tab.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/sales_screen_tab.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/dapartment_info_sidebar.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/group_info_sidebar.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/company_identity_screen.dart';



class ChatScreenCommunication extends StatefulWidget {
  bool? isClearShow;
  VoidCallback? onClearTap;
   ChatScreenCommunication({super.key,this.isClearShow = false, this.onClearTap});

  @override
  State<ChatScreenCommunication> createState() =>
      _ChatScreenCommunicationState();
}

class _ChatScreenCommunicationState extends State<ChatScreenCommunication> {
  int selectedTabIndex = 0;
  bool _showProfileUrl = false;
  bool _showProfileEmpUrl = false;
  int? _selectedGroupId;
  int? _selectedEmpId;

  final PageController _tabPageController = PageController();


  void _selectButton(int index) {
    setState(() {
      selectedTabIndex = index;
    });
    _tabPageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
          children: [
            Expanded(
              flex: 10,
              child: Container(
                decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColorManager.greyShade200)
                ),
                child: Column(
                  children: [
                    Container(
                    decoration:  BoxDecoration(
                        color: ColorManager.white,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                        border: Border.all(color: ColorManager.bordercolorcontainer)
                      ),
                      child: Row(
                        mainAxisAlignment: widget.isClearShow! ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 20),
                              SMTabbar(
                                onTap: (_) => _selectButton(0),
                                index: 0,
                                grpIndex: selectedTabIndex,
                                heading: 'Patient',
                                image: "images/communication//chat/patient_icon.svg",
                                height: 22,
                              ),
                              const SizedBox(width: 20),
                              SMTabbar(
                                onTap: (_) => _selectButton(1),
                                index: 1,
                                grpIndex: selectedTabIndex,
                                heading: 'Clinician',
                                image: "images/communication//chat/chat_clinician.svg",
                                height: 22,
                              ),
                              const SizedBox(width: 20),
                              SMTabbar(
                                onTap: (_) => _selectButton(2),
                                index: 2,
                                grpIndex: selectedTabIndex,
                                heading: 'Sales',
                                image: "images/communication/chat/salse_icon.svg",
                                height: 22,
                              ),
                              const SizedBox(width: 20),
                              SMTabbar(
                                onTap: (_) => _selectButton(3),
                                index: 3,
                                grpIndex: selectedTabIndex,
                                heading: 'Administration',
                                image: "images/communication//chat/chat_admin.svg",
                                height: 22,
                              ),
                            ],
                          ),
                          widget.isClearShow! ?  Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                                onTap: widget.onClearTap,
                                child: const Icon(Icons.clear)),
                          ) : const Offstage()
                        ],
                      ),
                    ),
                    const Divider(thickness: 2, height: 1),
                    Expanded(
                      child: NonScrollablePageView(
                        controller: _tabPageController,
                        onPageChanged: (index) {
                          setState(() => selectedTabIndex = index);
                        },
                        children: [
                          PatientScreen(
                            showProfileUrl: _showProfileUrl,
                            onShowProfileUrlChanged: (value) {
                              setState(() => _showProfileUrl = value);
                            },
                            onGroupSelected: (groupId) {
                              setState(() => _selectedGroupId = groupId);
                            },
                          ),
                          ClinicianScreenTabChats(
                            showProfileUrl: _showProfileEmpUrl,
                            onShowProfileUrlChanged: (value) {
                              setState(() => _showProfileEmpUrl = value);
                            },
                            onEmpSelected: (otherEmpId) {
                              setState(() => _selectedEmpId = otherEmpId);
                            },
                          ),
                          SalesScreenTab(
                            showProfileUrl: _showProfileEmpUrl,
                            onShowProfileUrlChanged: (value) {
                              setState(() => _showProfileEmpUrl = value);
                            },
                              onEmpSelected: (otherEmpId) {
                                setState(() => _selectedEmpId = otherEmpId);
                              }
                          ),
                          AdministrationScreenTab(
                            showProfileUrl: _showProfileEmpUrl,
                            onShowProfileUrlChanged: (value) {
                              setState(() => _showProfileEmpUrl = value);
                            },
                              onEmpSelected: (otherEmpId) {
                                setState(() => _selectedEmpId = otherEmpId);
                              }
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showProfileUrl)  const SizedBox(width: 10,),
            if (_showProfileUrl)  Expanded(

              flex: 3,
              child: GroupInfoScreen(groupId: _selectedGroupId!,
                onClose: () {
                  setState(() {
                    _showProfileUrl = false;
                  });
                },)
            ),
            if (_showProfileEmpUrl)  const SizedBox(width: 10,),
            if (_showProfileEmpUrl)  Expanded(
                flex: 3,
                child: DepartmentInfoScreen(empId: _selectedEmpId!,
                  onClose: () {
                    setState(() {
                      _showProfileEmpUrl = false;
                    });
                  },)
            ),
          ],
        );
  }
}




typedef void OnMenuButtonTapCallBack(int index);

class SMTabbar extends StatelessWidget {
  const SMTabbar({
    super.key,
    required this.onTap,
    required this.index,
    required this.grpIndex,
    required this.heading,
    required this.image,
    required this.height,
  });

  final OnMenuButtonTapCallBack onTap;
  final int index;
  final int grpIndex;
  final String heading;
  final String image;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = grpIndex == index;

    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor:Colors.transparent ,
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 10,bottom: 6),
              child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(image,
                    height: height,
                    color: isSelected ? ColorManager.blueprime : Colors.black38,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    heading,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? ColorManager.blueprime : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final textPainter = TextPainter(
                text: TextSpan(
                  text: heading,
                  style: const TextStyle(
                    fontSize: FontSize.s14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                textDirection: TextDirection.ltr,
              )..layout();

              final textWidth = textPainter.size.width;

              return Container(
                height: 4,
                width: textWidth + 50,
                color: isSelected ? ColorManager.blueprime : Colors.transparent,
              );
            },
          ),
        ],
      ),
    );
  }
}

