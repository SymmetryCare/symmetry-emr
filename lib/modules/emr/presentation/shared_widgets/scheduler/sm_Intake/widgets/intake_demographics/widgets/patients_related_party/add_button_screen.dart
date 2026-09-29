


import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/related_parties_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/sm_intake_manager/intake_demographics/intake_demographic_dropdown_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/scheduler_create_data/create_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/demographics_dropdown_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/related_parties_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/constant_widgets/const_checckboxtile.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/schedular_textfield_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/dropdown_constant_sm.dart';

import 'package:flutter/material.dart';























class PrimaryCaregiver extends StatefulWidget {
  final int patientId;
  final VoidCallback onRemove;
  final int index;
  final bool isVisible;
  const PrimaryCaregiver({super.key, required this.patientId, required this.onRemove, required this.index, required this.isVisible});

  @override
  PrimaryCaregiverState createState() => PrimaryCaregiverState();
}

class PrimaryCaregiverState extends State<PrimaryCaregiver> {
  late Future<List<RelationshipData>> _relationshipDropDownFuture;

  @override
  void initState() {
    super.initState();
    _relationshipDropDownFuture = getRelationshipDropDown(context);
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController firstNamePCController = TextEditingController();
    TextEditingController lastNamePCController = TextEditingController();
    TextEditingController streetPCController = TextEditingController();
    TextEditingController stateController = TextEditingController();
    TextEditingController cityController = TextEditingController();
   TextEditingController suitAptPCController = TextEditingController();
   TextEditingController phoneNumberPCController = TextEditingController();
   TextEditingController zipCodePCController = TextEditingController();
   TextEditingController emailPCController = TextEditingController();

    bool copyEmergencyContactPC = false;
    bool copyPatientPC = false;

    bool noPCData = false;
    bool noPRData = false;
    bool noEmergencyData = false;

    String? status = 'Active';

    String? selectedRelationshipEC;





    final CaregiverProvider = Provider.of<SmIntakeProviderManager>(context, listen: false);
    return  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.index > 1) ...[
          const Divider(),
          const SizedBox(height: 20),
        ],
        Padding(
          padding:EdgeInsets.only(top: widget.index > 1 ? 10 : 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 20,
                children: [
                  CheckboxTile(
                    title: 'Copy Emergency Contact',
                    initialValue: copyEmergencyContactPC,
                    onChanged: (value) {
                    },
                  ),
                  CheckboxTile(
                    title: 'Copy Patient Representative',
                    initialValue: copyPatientPC,
                    onChanged: (value) {

                    },
                  )
                ],
              ),
              (widget.index > 1)
                  ? IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                icon: Icon(Icons.delete_outline_rounded, color: ColorManager.blueprime),
                onPressed: widget.onRemove,
              )
                  : CheckboxTile(
                title: 'No Caregiver Available',
                initialValue: noPCData,
                onChanged: (value) {
                  // update state accordingly
                },
              ),

            ],
          ),
        ),
        const SizedBox(height: AppSize.s16),
        CaregiverProvider.isContactTrue ?  Row(
          children: [
            Flexible(
                child: SchedularTextField(
                  controller: firstNamePCController,
                  labelText: 'First Name*',

                )),
            SizedBox(width:CaregiverProvider.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
            Flexible(
                child: SchedularTextField(
                  controller: lastNamePCController,
                  labelText: 'Last Name*',
                )),
            SizedBox(width:CaregiverProvider.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
            Flexible(
              child:FutureBuilder<List<RelationshipData>>(
                future: _relationshipDropDownFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CustomDropdownTextFieldsm(
                      initialValue: 'Select',
                      headText: 'Relationship',items: const [],
                      onChanged: (newValue) {

                      },);
                  }
                  if (snapshot.hasData) {
                    List<DropdownMenuItem<String>> dropDownList = [];
                    for (var i in snapshot.data!) {
                      dropDownList.add(DropdownMenuItem<String>(
                        child: Text(i.relationship!),
                        value: i.relationship,
                      ));
                    }

                    return CustomDropdownTextFieldsm(headText: 'Relationship*',dropDownMenuList: dropDownList,
                      onChanged: (newValue) {
                        for (var a in snapshot.data!) {
                          if (a.relationship == newValue) {
                            selectedRelationshipEC = a.relationship!;
                          }
                        }
                      },);


                  } else {
                    return const Offstage();
                  }
                },
              ),
            ),
          ],
        ):
        Row(
          children: [
            Flexible(
                child: SchedularTextField(
                  controller: firstNamePCController,
                  labelText: 'First Name*',

                )),
            const SizedBox(width: AppSize.s35),
            Flexible(
                child: SchedularTextField(
                  controller: lastNamePCController,
                  labelText: 'Last Name*',
                )),
            const SizedBox(width: AppSize.s35),
            Flexible(
              child:FutureBuilder<List<RelationshipData>>(
                future: _relationshipDropDownFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CustomDropdownTextFieldsm(
                      initialValue: 'Select',
                      headText: 'Relationship',items: const [],
                      onChanged: (newValue) {

                      },);
                  }
                  if (snapshot.hasData) {
                    List<DropdownMenuItem<String>> dropDownList = [];
                    for (var i in snapshot.data!) {
                      dropDownList.add(DropdownMenuItem<String>(
                        child: Text(i.relationship!),
                        value: i.relationship,
                      ));
                    }

                    return CustomDropdownTextFieldsm(headText: 'Relationship*',dropDownMenuList: dropDownList,
                      onChanged: (newValue) {
                        for (var a in snapshot.data!) {
                          if (a.relationship == newValue) {
                            selectedRelationshipEC = a.relationship!;
                          }
                        }
                      },);


                  } else {
                    return const Offstage();
                  }
                },
              ),
            ),
            const SizedBox(width: AppSize.s35),
            const Flexible(
                child: SizedBox()),
            const SizedBox(width: AppSize.s35),
            const Flexible(
                child: SizedBox()),
          ],
        ),
        const SizedBox(height: AppSize.s16),
        CaregiverProvider.isContactTrue ?  Row(
          children: [
            Flexible(
                child: SchedularTextField(
                    controller: streetPCController,
                    icon: Icon(Icons.location_on_outlined, color: ColorManager.blueprime,size: IconSize.I18,),
                    labelText: "Street*")),
            SizedBox(width:CaregiverProvider.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
            Flexible(
                child: SchedularTextField(
                    controller: suitAptPCController,
                    labelText: "Suite/Apt#")),
            SizedBox(width:CaregiverProvider.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
            Flexible(
              child: SchedularTextField(
                  controller: cityController,
                  labelText: AppString.city),
            ),
          ],
        ):
        Row(
          children: [
            Flexible(
                child: SchedularTextField(
                    controller: streetPCController,
                    icon: Icon(Icons.location_on_outlined, color: ColorManager.blueprime,size: IconSize.I18,),

                    labelText: "Street*")),
            const SizedBox(width: AppSize.s35),
            Flexible(
                child: SchedularTextField(
                    controller: suitAptPCController,
                    labelText: "Suite/Apt#")),
            const SizedBox(width: AppSize.s35),
            Flexible(
              child: SchedularTextField(
                  controller: cityController,
                  labelText: "City*"),
            ),
            const SizedBox(width: AppSize.s35),
            Flexible(
              child: SchedularTextField(
                  controller: stateController,
                  labelText: "State*"),
            ),
            const SizedBox(width: AppSize.s35),
            Flexible(
                child: SchedularTextField(
                    controller: zipCodePCController,
                    allowSSNBR: true,
                    labelText: "Zip Code*")),

          ],
        ),
        const SizedBox(height: AppSize.s16),
        CaregiverProvider.isContactTrue ?  Row(
          children: [
            ///state
            Flexible(
              child: SchedularTextField(
                  controller: stateController,
                  labelText: "State*"),
            ),
            SizedBox(width: CaregiverProvider.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
            Flexible(
                child: SchedularTextField(
                    controller: zipCodePCController,
                    allowSSNBR: true,
                    labelText: "Zip Code*")),
            SizedBox(width: CaregiverProvider.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
            Flexible(
                child: SchedularTextField(
                    controller: phoneNumberPCController,
                    phoneField:true,
                    labelText: "Phone Number*")),
          ],
        ):
        Row(
          children: [
            Flexible(
                child: SchedularTextField(
                    controller: phoneNumberPCController,
                    phoneField:true,
                    labelText: "Phone Number*")),
            const SizedBox(width: AppSize.s35),
            Flexible(
                child: SchedularTextField(
                    controller: emailPCController,
                    labelText: "Email")),
            // Empty container for alignment
            const SizedBox(width: AppSize.s35),
            Flexible(child: Container()),
            const SizedBox(width: AppSize.s35),
            Flexible(child: Container()),
            const SizedBox(width: AppSize.s35),
            Flexible(child: Container()),
          ],
        ),
        const SizedBox(height: AppSize.s16),
        CaregiverProvider.isContactTrue ?  Row(
          children: [
            Flexible(
                child: SchedularTextField(
                    controller: emailPCController,
                    labelText: "Email")),
            // Empty container for alignment
            SizedBox(width: CaregiverProvider.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
            Flexible(child: Container()),
            SizedBox(width:CaregiverProvider.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
            Flexible(child: Container()),
          ],
        ) : const Offstage(),


      ],
    );
  }
}







