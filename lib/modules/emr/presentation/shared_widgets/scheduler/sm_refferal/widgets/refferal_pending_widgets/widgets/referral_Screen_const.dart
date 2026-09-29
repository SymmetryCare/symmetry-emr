import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/refferals_manager/master_patient_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/refferals_manager/refferals_patient_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/referral_service_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/dialogue_template.dart';
import 'package:symmetry_emr/app/resources/provider/async_data_controller.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';

class BlueBGHeadConst extends StatefulWidget {
  final String HeadText;
  final Widget body;
  final bool initiallyExpanded;
  const BlueBGHeadConst({super.key, required this.HeadText,
    required this.body,
    this.initiallyExpanded = false,});

  @override
  State<BlueBGHeadConst> createState() => _BlueBGHeadConstState();
}

class _BlueBGHeadConstState extends State<BlueBGHeadConst> {
  late bool _expanded = widget.initiallyExpanded;
  @override
  Widget build(BuildContext context) {
    return Consumer<SmIntakeProviderManager>(
      builder: (context,providerState,child) {
        return Column(
          children: [
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                height: AppSize.s33,
                decoration: BoxDecoration(
                  color: ColorManager.SMFBlue,
                ),
                padding: const EdgeInsets.only(left: 25, right: 30),
                // margin: EdgeInsets.symmetric(vertical: AppPadding.p8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.HeadText,
                      style:TextStyle(
                        fontSize: providerState.isContactTrue? FontSize.s13 :FontSize.s16,
                        fontWeight: FontWeight.w700,
                        color: ColorManager.mediumgrey,
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.arrow_drop_up_outlined
                          : Icons.arrow_drop_down_outlined,
                      size: IconSize.I24,
                      color: ColorManager.mediumgrey,
                    ),
                  ],
                ),
              ),
            ),
            Container(
             child: _expanded
                  ? const SizedBox(height: 50,)
                  : widget.body,
            ),
            // AnimatedCrossFade(
            //   duration: const Duration(milliseconds: 250),
            //   crossFadeState: _expanded
            //       ? CrossFadeState.showSecond
            //       : CrossFadeState.showFirst,
            //   firstChild: const SizedBox(height: 50,),
            //   secondChild: widget.body!,
            // ),
          ],
        );
      }
    );
  }
}


class SMCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const SMCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      side: BorderSide(color: ColorManager.blueprime,width: 2),
      splashRadius: 0,
      activeColor: ColorManager.blueprime,
      value: value,
      onChanged: onChanged,
    );
  }
}




class CustomSearchFieldSM extends StatelessWidget {
  final VoidCallback onPressed;
   TextEditingController? searchController;
  final double? width;
  final String? hintText;

   CustomSearchFieldSM({Key? key,required this.onPressed, this.width,  this.searchController, this.hintText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 381,
      height: 36,
      child: TextField(
        textCapitalization: TextCapitalization.words,
        style: DocumentTypeDataStyle.customTextStyle(context),
        controller: searchController,
        onChanged: (_) => onPressed(),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF8F8F8),
          hintText: hintText ?? 'Search',
          alignLabelWithHint: true,
          hintStyle:  CustomTextStylesCommon.commonStyle(fontSize: FontSize.s14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF7F7F7F),),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade200,//Color(0xFFF0F0F0),
                width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            icon: Center(
              child: Image.asset(
                "images/sm/sm_refferal/magnifying_glass.png",
                height: IconSize.I24,
                width: IconSize.I24,
                //color: ColorManager.mediumgrey,
              ),
              //Image.asset("images/sm/search_icon.jpg",)
            ),
            onPressed: onPressed,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        ),
      ),
    );
  }
}

class CustomSearchFieldCM extends StatelessWidget {
  final VoidCallback onPressed;
  TextEditingController? searchController;
  final double? width;
  final double? height;
  final double? iconSize;

  CustomSearchFieldCM({Key? key,required this.onPressed,
   this.height, this.width,  this.searchController, this.iconSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 381,
      height: height ?? 36,
      child: TextField(
        textCapitalization: TextCapitalization.words,
        style: DocumentTypeDataStyle.customTextStyle(context),
        controller: searchController,
        onChanged: (_) => onPressed(),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Search',
          alignLabelWithHint: true,
          hintStyle:  CustomTextStylesCommon.commonStyle(fontSize: FontSize.s14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF7F7F7F),),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade200,//Color(0xFFF0F0F0),
                width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            icon: Center(
              child: Image.asset(
                "images/sm/sm_refferal/magnifying_glass.png",
                height: iconSize ?? IconSize.I24,
                width: iconSize ?? IconSize.I24,
                //color: ColorManager.mediumgrey,
              ),
              //Image.asset("images/sm/search_icon.jpg",)
            ),
            onPressed: onPressed,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        ),
      ),
    );
  }
}







class AddDiagnosisDialog extends StatelessWidget {
  const AddDiagnosisDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<
        AsyncDataController<List<PatientDiagnosisMasterData>>>(
      create: (ctx) => AsyncDataController<List<PatientDiagnosisMasterData>>()
        ..load(() => getPatientDiagnosisMaster(context: ctx)),
      child: const _AddDiagnosisDialogBody(),
    );
  }
}

class _AddDiagnosisDialogBody extends StatefulWidget {
  const _AddDiagnosisDialogBody();

  @override
  State<_AddDiagnosisDialogBody> createState() => _AddDiagnosisDialogBodyState();
}

class _AddDiagnosisDialogBodyState extends State<_AddDiagnosisDialogBody> {
  String dgnNameSelected = "Select";
  int dgnIdSelected = 0;
  bool dgnAddLoader = false;

  @override
  void initState() {
    super.initState();
    dgnNameSelected = "Select";
    dgnIdSelected = 0;
    // Any init logic here if needed
  }

  @override
  Widget build(BuildContext context) {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
    // final int patientId = diagnosisProvider.patientId;
    return DialogueTemplate(
      title: "Add Diagnosis",
      width: AppSize.s407,
      height: AppSize.s260,
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p13),
          child: Column(
            children: [
              Consumer<AsyncDataController<List<PatientDiagnosisMasterData>>>(
                builder: (context, snapshotDgn, _) {
                  if (snapshotDgn.isLoading) {
                    return Container(
                      height: 30,
                      width: 354,
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorManager.containerBorderGrey, width: AppSize.s1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
                                child: Text(
                                  dgnNameSelected,
                                  style: DocumentTypeDataStyle.customTextStyle(context),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: AppPadding.p8),
                              child: Icon(Icons.arrow_drop_down),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (snapshotDgn.data != null && snapshotDgn.data!.isEmpty) {
                    return _buildEmptyDropdownPlaceholder();
                  }
                  if (snapshotDgn.data != null) {
                    List<DropdownMenuItem<String>> dropDownItems = snapshotDgn.data!.map((item) {
                      return DropdownMenuItem<String>(
                        value: item.dgnName,
                        child: Text(item.dgnName),
                      );
                    }).toList();

                    return CICCDropdown(
                      initialValue: dgnNameSelected == "Select" ? null : dgnNameSelected,
                      onChange: (val) {
                        final selected = snapshotDgn.data!.firstWhere(
                              (a) => a.dgnName == val,
                          orElse: () => snapshotDgn.data!.first,
                        );
                        setState(() {
                          dgnNameSelected = selected.dgnName;
                          dgnIdSelected = selected.dgnId;
                        });
                      },
                      items: dropDownItems,
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        )
      ],
      bottomButtons: dgnAddLoader
          ? Center(child: SizedBox(  height: 30,
          width: 30,child: CircularProgressIndicator(color: ColorManager.blueprime)))
          : SizedBox(
        height: 30,
        child: CustomElevatedButtonnull(
          text: 'Add',
          color: ColorManager.blueprime,
          onPressed: dgnNameSelected == "Select"
              ? null // Disable button
              : () async {
            try {
              setState(() => dgnAddLoader = true);
              var response = await addPatientDiagnosis(
                context: context,
                dgnId: dgnIdSelected,
                fk_pt_id: diagnosisProvider.patientId,
              );
              if (response.statusCode == 200 || response.statusCode == 201) {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => const AddSuccessPopup(message: 'Data Added Successfully'),
                );
              } else {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AddErrorPopup(
                    message: response.message,
                  ),
                );
              }
            } finally {
              if (mounted) setState(() => dgnAddLoader = false);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDropdownPlaceholder(String selectedText) {
    return Container(
      height: 30,
      width: 354,
      decoration: BoxDecoration(
        border: Border.all(color: ColorManager.containerBorderGrey, width: AppSize.s1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
          child: Text(
            selectedText,
            style: DocumentTypeDataStyle.customTextStyle(context),
          ),
        ),
      ),
    );
  }
  Widget _buildEmptyDropdownPlaceholder() {
    return Container(
      height: 30,
      width: 354,
      decoration: BoxDecoration(
        border: Border.all(color: ColorManager.containerBorderGrey, width: AppSize.s1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.p10),
          child: Text("No Diagnosis"),
        ),
      ),
    );
  }
}
