import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/patients_emergency_contact_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/patients_physician_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/patients_care_analysis_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/rehospitalization_risk_popup.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/patients_tab_constants.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/em_dashboard_theme.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/providers/hh_emr/visit_details_provider.dart';
import 'package:symmetry_emr/modules/emr/providers/emr_provider/emr_patient_provider.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/patient_tab_data/patient_header_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/sucess_failed_popup_const.dart';

class PatientConstantHeader extends StatelessWidget {
  final EMRSelectedPatient patient;
  final PatientReferralHeaderData? headerData;
  final bool hasGroup;

  const PatientConstantHeader({
    required this.patient,
    required this.headerData,
    this.hasGroup = false,
    super.key,
  });

  void _showNoGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Group Assignment Missing",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "This patient does not have a Patient Group or Clinician Group assigned. "
                    "Care Team Chat is not available until groups are configured.",
                style: TextStyle(
                  fontSize: 12,
                  color: ColorManager.mediumgrey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.blueprime,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "OK, Got it",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final header = headerData;
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppPadding.p10,),
      decoration: BoxDecoration(
        color: ColorManager.whitebluecolor,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        children: [
          (header?.patientStatus ?? "").isEmpty
              ? const SizedBox(height: AppSize.s10)
              : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: AppPadding.p8, vertical: AppPadding.p3),
                decoration: BoxDecoration(
                  color: (header?.patientStatus ?? "") == "Resumption"
                      ? ColorManager.orangeheading
                      : (header?.patientStatus ?? "") == "Discharge"
                          ? const Color(0xFFC62828)
                          : (header?.patientStatus ?? "") == "Admitted"
                         ? ColorManager.greenDark : ColorManager.SMYellow,
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(8),),
                ),
                child: Text(
                  header?.patientStatus ?? "",
                  style: TextStyle(
                    fontSize: FontSize.s12,
                    color: ColorManager.white,
                    fontWeight: FontWeight.w600,
                  )
                ),
              ),
            ],
          ),
          Row(
            children: [
              /// LEFT: Avatar + Name + MRN + Care Team badges
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.p12,),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSize.s10),
                      _HoverableAvatar(
                        patient: patient,
                        imgUrl: header?.imgUrl ?? '',
                      ),
                      const SizedBox(height: AppSize.s8),
                      Text(
                        header?.patientName ?? patient.name,
                        style: TextStyle(
                          fontSize: FontSize.s14,
                          fontWeight: FontWeight.w700,
                          color: ColorManager.textBlack,
                        ),
                      ),
                      const SizedBox(height: AppSize.s5),
                      Text(
                        "MRN ${header?.mrn ?? '—'}",
                        style: TextStyle(
                          fontSize: FontSize.s12,
                          color: ColorManager.blackfaint,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      const SizedBox(height: AppSize.s5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: header != null &&
                            header.careTeam.isNotEmpty
                            ? header.careTeam
                            .map((tag) => Padding(
                          padding:
                          const EdgeInsets.only(right: 3),
                          child: _tag(
                              tag, _careTeamColor(tag), tag),
                        ))
                            .toList()
                            : [_tag("—", Colors.grey, "No care team")],
                      ),
                      const SizedBox(height: AppSize.s5),
                    ],
                  ),
                ),
              ),

              /// MIDDLE: Patient Details
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12,),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _detailRow("Primary Physician",
                          header?.primaryPhysician ?? '—'),
                      const SizedBox(height: AppSize.s20),
                      _detailRow(
                          "Physician Phone", header?.physicianPhone ?? '—'),
                      const SizedBox(height: AppSize.s20),
                      _detailRow("Primary Diagnosis",
                          header?.primaryDiagnosis ?? '—'),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.p12,),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _detailRow(
                        "Special Precautions",
                        header?.specialPrecautions.isNotEmpty == true
                            ? header!.specialPrecautions
                            : '—',
                      ),
                      const SizedBox(height: AppSize.s20),
                      _detailRow("Insurance", header?.insurance ?? '—'),
                      const SizedBox(height: AppSize.s20),
                      InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) =>
                          const RehospitalizationRiskPopup(),
                        ),
                        borderRadius: BorderRadius.circular(4),
                        child: _detailRowHighlight(
                          "Rehospitalization Risk",
                          header?.rehospitalizationRisk.isNotEmpty == true
                              ? header!.rehospitalizationRisk
                              : '—',
                          header?.rehospitalizationRisk.isNotEmpty == true ? Colors.orange : ColorManager.blackfaint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// RIGHT: Image buttons + Emergency button
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8,),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _imageButtonSVG(
                            "Physicians",
                            'images/emr_clinician/patients_tab/physicians.svg',
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => PatientsPhysicianPopup(
                                    ptId: patient.patientId),
                              );
                            },
                          ),
                          const SizedBox(width: AppSize.s14),
                          _imageButtonSVG(
                            "Plan of Care",
                            'images/emr_clinician/patients_tab/plan_of_care.svg',
                            onTap: () {
                              context
                                  .read<EMRNavigationController>()
                                  .openPlanOfCare(
                                patientName: header?.patientName ?? patient.name ?? '',
                                patientStatus: header?.patientStatus ?? '',
                                imgUrl: header?.imgUrl ?? '',
                                careTeam: header?.careTeam ?? [],
                              );
                            },
                          ),
                          const SizedBox(width: AppSize.s14),
                          _imageButtonSVG(
                            "Alerts",
                            'images/emr_clinician/patients_tab/alerts.svg',
                            onTap: () {
                              context
                                  .read<EMRNavigationController>()
                                  .openAlerts();
                            },
                          ),
                          const SizedBox(width: AppSize.s14),
                          _imageButtonSVG(
                            "Protocols",
                            'images/emr_clinician/patients_tab/protocols.svg',
                            onTap: () {
                              context
                                  .read<EMRNavigationController>()
                                  .openProtocol();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSize.s10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _imageButtonSVG(
                            "Patient Chat",
                            'images/emr_clinician/patients_tab/patient_chat.svg',
                            onTap: () {
                              if (!hasGroup) {
                                _showNoGroupDialog(context);
                                return;
                              }
                              context
                                  .read<EmrPatientProvider>()
                                  .toggleQaChat();
                            },
                          ),
                          const SizedBox(width: AppSize.s14),
                          _imageButtonSVG(
                            "Care Analysis",
                            'images/emr_clinician/patients_tab/care_analysis.svg',
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => const EMRUnderDevelopmentPopup(),
                              );
                            },
                          ),
                          const SizedBox(width: AppSize.s14),
                          // ── Emergency Contacts red button ───────────
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) =>
                                    PatientsEmergencyContactPopup(
                                      ptId: patient.patientId,
                                    ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppPadding.p12, vertical: AppPadding.p6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD16D6A),
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFD16D6A).withValues(alpha: 0.5),
                                    offset: const Offset(0, 4),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Text(
                                "Emergency Contacts",
                                style: TextStyle(
                                  color: ColorManager.white,
                                  fontSize: FontSize.s12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          (header?.patientStatus ?? "").isEmpty
              ? const SizedBox(height: AppSize.s10)
              :const SizedBox(height: AppSize.s16,),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Color _careTeamColor(String tag) {
    switch (tag.toUpperCase()) {
      case 'RN':  return Colors.teal;
      case 'PT':  return Colors.orange;
      case 'OT':  return Colors.blue;
      case 'SLP': return Colors.purple;
      case 'HHA': return Colors.indigo;
      case 'MSW': return Colors.green;
      default:    return Colors.blueGrey;
    }
  }

  Widget _tag(String label, Color color, String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(3)),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: FontSize.s10,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        Text("$label : ",
            style: TextStyle(
                fontSize: FontSize.s12,
                color: ColorManager.blackfaint,
                fontWeight: FontWeight.w500
            ),),
        Flexible(
          child: Text(value,
              style: TextStyle(
                  fontSize: FontSize.s12,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.textBlack),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _detailRowHighlight(String label, String value, Color valueColor) {
    return Row(
      children: [
        Text("$label : ",
            style: TextStyle(
                fontSize: FontSize.s12,
                color: ColorManager.blackfaint,
                fontWeight: FontWeight.w500
            )),
        Text(value,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: valueColor)),
      ],
    );
  }

}

Widget _imageButtonSVG(
    String tooltip,
    String imagePath, {
      double width = 28,
      double height = 28,
      VoidCallback? onTap,
    }) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSize.s5),
        SvgPicture.asset(
          imagePath,
          width: width,
          height: height,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => Icon(
            Icons.image_not_supported,
            size: width,
            color: ColorManager.blueprime,
          ),
        ),
        const SizedBox(height: AppSize.s10),
        Text(
          tooltip,
          style: TextStyle(
            fontSize: FontSize.s12,
            color: ColorManager.blueprime,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// ── Hoverable avatar ──────────────────────────────────────────────────────────
class _HoverableAvatar extends StatefulWidget {
  final EMRSelectedPatient patient;
  final String imgUrl;
  const _HoverableAvatar({required this.patient, required this.imgUrl});

  @override
  State<_HoverableAvatar> createState() => _HoverableAvatarState();
}

class _HoverableAvatarState extends State<_HoverableAvatar> {
  OverlayEntry? _overlay;
  final LayerLink _layerLink = LayerLink();

  void _showOverlay() {
    final patient = widget.patient;

    const labels = [
      "MRN", "Episode", "Physician", "Diagnosis",
      "Insurance", "Authorization", "Status"
    ];

    final values = [
      patient.mrn,
      patient.episode,
      patient.physician,
      patient.diagnosis,
      patient.insurance,
      patient.authorization,
      patient.status,
    ];

    _overlay = OverlayEntry(
      builder: (_) => Positioned(
        width: 280,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(80, 110),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: labels
                            .map((l) => Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(l,
                              style: TextStyle(
                                  fontSize: FontSize.s11,
                                  color: ColorManager.grey)),
                        ))
                            .toList(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: values
                              .map((v) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(v,
                                style: TextStyle(
                                    fontSize: FontSize.s11,
                                    fontWeight: FontWeight.w600,
                                    color: ColorManager.darkgrey),
                                overflow: TextOverflow.ellipsis),
                          ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _showOverlay(),
        onExit: (_) => _removeOverlay(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.transparent,
              child: ClipOval(
                child: widget.imgUrl.isNotEmpty
                    ? Image.network(
                  widget.imgUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    "images/profilepic.png",
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                )
                    : Image.asset(
                  "images/profilepic.png",
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}