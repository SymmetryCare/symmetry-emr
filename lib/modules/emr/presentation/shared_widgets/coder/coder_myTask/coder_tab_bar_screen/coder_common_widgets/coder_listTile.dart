import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/qa_coordinator_data/my_task/patient_form_myTask_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/coder/coder_myTask/coder_tab_bar_screen/coder_common_widgets/coder_clinical_info_popup.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/model/chart_patient_referral_data_model.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/model/patient_form_model.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/oasis_form_mapper.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/services/api/managers/patient_form_manager.dart';

class ListTileCoderWidget extends StatefulWidget {
  final bool?         isDateCurrectionShown;
  final VoidCallback? onCallClick;
  final VoidCallback? onRefresh;
  final PatientFormTask? item;
  final String?       patientImgUrl;

  const ListTileCoderWidget({
    super.key,
    this.isDateCurrectionShown = false,
    this.onCallClick,
    this.onRefresh,
    this.item,
    this.patientImgUrl,
  });

  @override
  State<ListTileCoderWidget> createState() => _ListTileCoderWidgetState();
}

class _ListTileCoderWidgetState extends State<ListTileCoderWidget> {
  bool _isLoading = false;


  // ── Left border color: null → red, true → blueprime, false → red ──────────
  Color get _leftBorderColor {
    final f2f = widget.item?.faceToFace;
    if (f2f == null)  return ColorManager.red;
    if (f2f == true)  return ColorManager.white;   // bool? comparison — safe after model fix
    if (f2f == false)  return ColorManager.white;   // bool? comparison — safe after model fix
    return ColorManager.red;
  }

  Future<void> _onTap() async {
    if (widget.item == null) return;

    setState(() => _isLoading = true);

    final result = await getPatientFormByPatientID(
      context,
      patientFormId: widget.item!.patientFormId,
    );
    final String role = await TokenManager.getRole();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == null) return;

    await Navigator.push(
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
            commentCount:  result.subForms.isNotEmpty ? result.subForms.first.comment_count : 0,
            fillStatus:    result.subForms.isNotEmpty ? result.subForms.first.isFilled : false,
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
          appBarString: 'Coder',
        ),
      ),
    );

    widget.onRefresh?.call();
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

  // ─── F2F Icon: null → "N/A", true → verified svg, false → red svg ─────────
  Widget _buildF2FWidget() {
    final bool? f2f = widget.item?.faceToFace;   // ← explicitly typed bool?
    if (f2f == null) {
      return Text(
        'N/A',
        textAlign: TextAlign.center,
        style: CustomTextStylesCommon.commonStyle(
          fontSize:   FontSize.s12,
          fontWeight: FontWeight.w700,
          color:      ColorManager.mediumgrey,
        ),
      );
    }
    if (f2f == true) {
      return SvgPicture.asset(
        'images/coder/coder_verified.svg',
        height: 15,
        width:  10,
      );
    }
    return SvgPicture.asset(
      'images/coder/coder_red.svg',
      height: 15,
      width:  10,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                left: BorderSide(color: _leftBorderColor, width: 6),
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
                  ? SizedBox(
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
                  // ── Patient Avatar + Name ─────────────────────────
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
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
                                widget.item?.patient.primaryDiagnosis?.dgnName ?? '-',   // ← real diagnosis instead of hardcoded "Anxiety"
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
                  ),
                  const SizedBox(height: AppSize.s10),
                  // ── Form Type ─────────────────────────────────────
                  Expanded(
                    flex: 3,
                    child: Text(
                      textAlign: TextAlign.center,
                      widget.item?.formType ?? '-',
                      style: CustomTextStylesCommon.commonStyle(
                        fontSize:   FontSize.s12,
                        fontWeight: FontWeight.w700,
                        color:      ColorManager.textBlack,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSize.s10),
                  // ── Form Date ─────────────────────────────────────
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppPadding.p10),
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
                  ),
                  const SizedBox(height: AppSize.s10),
                  // ── Clinician ─────────────────────────────────────
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 40,),
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
                                  color: Color(int.parse('0xFF${widget.item!.clinician.colorCode}')),
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
                  const SizedBox(height: AppSize.s10),
                  // ── Primary Insurance ─────────────────────────────
                  Expanded(
                    flex: 3,
                    child: Text(
                      textAlign: TextAlign.center,
                      widget.item?.patient.primaryInsurance ?? '-',
                      style: CustomTextStylesCommon.commonStyle(
                        fontSize:   FontSize.s12,
                        fontWeight: FontWeight.w700,
                        color:      ColorManager.mediumgrey,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSize.s10),
                  // ── Timely Filing Deadline ────────────────────────
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
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
                  ),
                  const SizedBox(height: AppSize.s10),
                  // ── F2F Icon (3-condition) ─────────────────────────
                  Expanded(
                    flex: 2,
                    child: _buildF2FWidget(),
                  ),

                  // ── Date Sent For Correction (conditional) ────────
                  widget.isDateCurrectionShown == true
                      ? Expanded(
                    flex: 3,
                    child: Text(
                      widget.item?.dateSentForCorrection ?? '-',
                      textAlign: TextAlign.center,
                      style: CustomTextStylesCommon.commonStyle(
                        fontSize:   FontSize.s12,
                        fontWeight: FontWeight.w700,
                        color:      ColorManager.mediumgrey,
                      ),
                    ),
                  )
                      : const Offstage(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}