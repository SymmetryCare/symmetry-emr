import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/qa_coordinator_data/my_task/patient_form_myTask_data.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/model/chart_patient_referral_data_model.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/model/patient_form_model.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/oasis_form_builder.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/oasis_form_mapper.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/services/api/managers/patient_form_manager.dart';
// removed in extraction: import '../../../../oasis_module/widgets/home_screen/responsive_screen_oasis.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_manager/qa_manager_tabs/qa_assignments/widgets/coder_details_popup.dart';

class ListTileQaWidget extends StatefulWidget {
  final VoidCallback?   onCallClick;
  final VoidCallback?   onRefresh;          // ← NEW
  final PatientFormTask? item;
  final String?         patientImgUrl;

  const ListTileQaWidget({
    super.key,
    this.onCallClick,
    this.onRefresh,                         // ← NEW
    this.item,
    this.patientImgUrl,
  });

  @override
  State<ListTileQaWidget> createState() => _ListTileQaWidgetState();
}

class _ListTileQaWidgetState extends State<ListTileQaWidget> {
  bool _isLoading = false;

  Future<void> _onTap() async {
    if (widget.item == null) return;

    setState(() => _isLoading = true);

    final result = await getPatientFormByPatientID(
      context,
      patientFormId: widget.item!.patientFormId,
    );
    String role = await TokenManager.getRole();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == null) return;

    await Navigator.push(                   // ← awaited
      context,
      MaterialPageRoute(
        builder: (_) => OasisFormMapper(
          form: PatientForm(
            formID:     result.formId,
            formName:   result.formName,
            fillStatus: result.status,
            subForms: result.subForms
                .map((e) => PatientSubForm(
              formID:        result.formId,
              subFormID:     e.id,
              subFormName:   e.subFormName,
              patientFormID: result.patientFormId,
              fillStatus:    e.isFilled,
              commentCount:  e.comment_count,
            ))
                .toList(),
          ),
          subForm: PatientSubForm(
            formID:        result.formId,
            subFormID:     result.subForms.isNotEmpty ? result.subForms.first.id : 0,
            subFormName:   result.subForms.isNotEmpty ? result.subForms.first.subFormName : '',
            patientFormID: result.patientFormId,
            fillStatus:    result.subForms.isNotEmpty ? result.subForms.first.isFilled : false,
            commentCount:  result.subForms.isNotEmpty ? result.subForms.first.comment_count : 0,
          ),
          patient: ChartPatientReferral(
            patientId:     widget.item!.patient.ptId,
            firstName:     result.referralData.patientFirstname,
            lastName:      result.referralData.patientLastname,
            contactNumber: result.referralData.patientPhone,
            address:       result.referralData.patientAddress,
            imageUrl:      result.referralData.patientImageUrl,
            gender:        Gender(genderID: 1, genderName: 'Male'),
            dateOfBirth:   DateTime.tryParse(result.referralData.patientDob ?? '') ?? DateTime.now(),
            chartNo:       result.referralData.patientChartNo,
            episodes:      [],
          ),
          userRole:     role,
          appBarString: 'QA Coordinator',
        ),
      ),
    );

    widget.onRefresh?.call();               // ← fires on pop
  }

  // ─── Patient Avatar ────────────────────────────────────────────────────────
  Widget _buildPatientAvatar() {
    final imgUrl = widget.patientImgUrl ?? '';
    return ClipOval(
      child: imgUrl.isNotEmpty
          ? Image.network(
        imgUrl,
        height: 44,
        width:  44,
        fit:    BoxFit.cover,
        errorBuilder: (_, __, ___) => CircleAvatar(
          radius:          22,
          backgroundColor: Colors.transparent,
          child: Image.asset('images/profilepic.png'),
        ),
      )
          : CircleAvatar(
        radius:          22,
        backgroundColor: Colors.transparent,
        child: Image.asset('images/profilepic.png'),
      ),
    );
  }

  // ─── Clinician Avatar ──────────────────────────────────────────────────────
  Widget _buildClinicianAvatar() {
    final imgUrl = widget.item?.clinician.imgUrl ?? '';
    return ClipOval(
      child: imgUrl.isNotEmpty
          ? Image.network(
        imgUrl,
        height: 44,
        width:  44,
        fit:    BoxFit.cover,
        errorBuilder: (_, __, ___) => CircleAvatar(
          radius:          22,
          backgroundColor: Colors.transparent,
          child: Image.asset('images/profilepic.png'),
        ),
      )
          : CircleAvatar(
        radius:          22,
        backgroundColor: Colors.transparent,
        child: Image.asset('images/profilepic.png'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ tick is only shown when a coding staff is actually assigned & has a name
    final String? coderName = widget.item?.codingStaff?.name;
    final bool hasCoder = widget.item?.codingStaff != null && coderName != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p5),
      child: InkWell(
        splashColor:    Colors.transparent,
        hoverColor:     Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: _isLoading ? null : _onTap,
        child: Container(
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 3),
              left:   BorderSide(color: Colors.grey.shade300, width: 1),
              right:  BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: Container(
            width: 6,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: ColorManager.red, width: 6),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                topLeft:    Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical:   AppPadding.p15,
                horizontal: AppPadding.p15,
              ),
              child: _isLoading
                  ?  SizedBox(
                height: 44,
                child: Center(
                  child: SizedBox(
                    height: 20,
                    width:  20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: ColorManager.blueprime,),
                  ),
                ),
              )
                  : Row(
                children: [
                  // ─── Patient Avatar ───────────────────────────────
                  // ─── Patient Name & MRN ───────────────────────────
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        _buildPatientAvatar(),
                        const SizedBox(width: AppSize.s10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment:  MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.item?.patient.name ?? '-',
                              style: CustomTextStylesCommon.commonStyle(
                                fontSize:   FontSize.s12,
                                fontWeight: FontWeight.w700,
                                color:      ColorManager.mediumgrey,
                              ),
                            ),
                            const SizedBox(height: AppSize.s5),
                            Text(
                              widget.item?.patient.mrn != null
                                  ? "MR#${widget.item!.patient.mrn}"
                                  : '-',
                              style: CustomTextStylesCommon.commonStyle(
                                fontSize:   FontSize.s11,
                                fontWeight: FontWeight.w400,
                                color:      ColorManager.mediumgrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSize.s10),
                  // ─── Form Type ────────────────────────────────────
                  Expanded(
                    flex: 3,
                    child: Text(
                      widget.item?.formType ?? '-',
                      textAlign: TextAlign.center,
                      style: CustomTextStylesCommon.commonStyle(
                        fontSize:   FontSize.s12,
                        fontWeight: FontWeight.w700,
                        color:      ColorManager.textBlack,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSize.s10),
                  // ─── Form Date ────────────────────────────────────
                  Expanded(
                    flex: 3,
                    child: Text(
                      widget.item?.formDate ?? '-',
                      textAlign: TextAlign.center,
                      style: CustomTextStylesCommon.commonStyle(
                        fontSize:   FontSize.s12,
                        fontWeight: FontWeight.w700,
                        color:      ColorManager.mediumgrey,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSize.s10),
                  // ─── Clinician ────────────────────────────────────
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 10,),
                        Stack(
                          children: [
                            _buildClinicianAvatar(),
                            Positioned(
                              bottom: 0,
                              right:  0,
                              child: Container(
                                width:  23,
                                height: 15,
                                decoration: BoxDecoration(
                                  color: Color(int.parse(
                                      '0xFF${widget.item!.clinician.colorCode}')),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.item!.clinician.abbreviation,
                                    style: CustomTextStylesCommon.commonStyle(
                                      fontSize:   FontSize.s10,
                                      fontWeight: FontWeight.w400,
                                      color:      ColorManager.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AppSize.s5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment:  MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.item?.clinician.name ?? '-',
                                maxLines: 2,
                                style: CustomTextStylesCommon.commonStyle(
                                  fontSize:   FontSize.s12,
                                  fontWeight: FontWeight.w700,
                                  color:      ColorManager.mediumgrey,
                                ),
                              ),
                              InkWell(
                                splashColor:    Colors.transparent,
                                hoverColor:     Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: widget.onCallClick,
                                child:
                                Image.asset(
                                    'images/emr_clinician/patient_chat.png',
                                    height: 30,
                                    width: 20),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSize.s10),
                  // ─── Primary Insurance ────────────────────────────
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 40),
                      child: Text(
                        widget.item?.patient.primaryInsurance ?? '-',
                        textAlign: TextAlign.center,
                        style: CustomTextStylesCommon.commonStyle(
                          fontSize:   FontSize.s12,
                          fontWeight: FontWeight.w700,
                          color:      ColorManager.mediumgrey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSize.s10),
                  // ─── Timely Filing Deadline ───────────────────────
                  Expanded(
                    flex: 2,
                    child: Text(
                      widget.item?.timelyFilingDeadline ?? '-',
                      textAlign: TextAlign.center,
                      style: CustomTextStylesCommon.commonStyle(
                        fontSize:   FontSize.s12,
                        fontWeight: FontWeight.w700,
                        color:      ColorManager.mediumgrey,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSize.s10),
                  // ─── Coding Staff (nullable) ──────────────────────
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      splashColor:    Colors.transparent,
                      hoverColor:     Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: hasCoder
                          ? () => showDialog(
                        context: context,
                        builder: (_) => CoderDetailsPopupQA(
                          coderId: widget.item!.codingStaff!.staffId,
                        ),
                      )
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            coderName ?? '-',
                            textAlign: TextAlign.center,
                            style: CustomTextStylesCommon.commonStyle(
                              fontSize:   FontSize.s12,
                              fontWeight: FontWeight.w700,
                              color:      ColorManager.mediumgrey,
                            ),
                          ),
                          // ✅ only render tick when coder name/coding staff exists
                          if (hasCoder) ...[
                            const SizedBox(width: AppSize.s10),
                            SvgPicture.asset(
                                'images/qa_coordinator/verified_task.svg'),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}