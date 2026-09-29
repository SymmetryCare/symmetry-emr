import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/data/patient_form_data.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/services/api/managers/patient_form_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';

class CoderPatientInfoPopup extends StatefulWidget {
  final int patientFormId;
  const CoderPatientInfoPopup({super.key, required this.patientFormId});

  @override
  State<CoderPatientInfoPopup> createState() => _CoderPatientInfoPopupState();
}

class _CoderPatientInfoPopupState extends State<CoderPatientInfoPopup> {
  bool                    _isLoading = true;
  PatientByPtIdFormModel? _data;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final result = await getPatientFormByPatientID(
      context,
      patientFormId: widget.patientFormId,
    );
    if (!mounted) return;
    setState(() {
      _data      = result;
      _isLoading = false;
    });
  }

  // ── helpers ───────────────────────────────────────────────────────────────
  String _genderLabel(int id) {
    switch (id) {
      case 1:  return 'Male';
      case 2:  return 'Female';
      default: return '-';
    }
  }

  String _ageFromDob(String dob) {
    if (dob.isEmpty) return '-';
    try {
      final birth = DateTime.parse(dob);
      final now   = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      final formatted =
          '${birth.day.toString().padLeft(2, '0')}/${birth.month.toString().padLeft(2, '0')}/${birth.year}';
      return '$formatted ($age years)';
    } catch (_) {
      return dob;
    }
  }
  static const double _kDesignWidth = 855;
  @override
  Widget build(BuildContext context) {
    final ref = _data?.referralData;
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kDesignWidth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
    return DialogueTemplateNoButtons(
      width: 500,
      height: 250,
      title: 'Patient Details',
      body: [
        if (_isLoading)
          SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator(color: ColorManager.blueprime,)),
          )
        else
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // ── Avatar + name ─────────────────────────────────────────
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: (ref?.patientImageUrl.isNotEmpty ?? false)
                      ? NetworkImage(ref!.patientImageUrl)
                      : const AssetImage('images/profilepic.png')
                  as ImageProvider,
                ),
                const SizedBox(height: 8),
                Text(
                  ref != null
                      ? '${ref.patientFirstname} ${ref.patientLastname}'.trim()
                      : '-',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizeConst.A20),

            // ── Row 1: Gender | DOB + Age ─────────────────────────────
            _buildInfoRow(
              leftLabel:  'Gender',
              leftValue:  ref != null ? _genderLabel(ref.patientGenderId) : '-',
              rightLabel: 'Date of Birth',
              rightValue: ref != null ? _ageFromDob(ref.patientDob) : '-',
            ),
            const SizedBox(height: AppSizeConst.A20),

            // ── Row 2: Address | Phone ────────────────────────────────
            _buildInfoRow(
              leftLabel:  'Address',
              leftValue:  ref?.patientAddress.isNotEmpty == true ? ref!.patientAddress : '-',
              rightLabel: 'Phone Number',
              rightValue: ref?.patientPhone.isNotEmpty == true ? ref!.patientPhone : '-',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildCell(label: leftLabel, value: leftValue)),
        const SizedBox(width: AppSizeConst.A20),
        Expanded(child: _buildCell(label: rightLabel, value: rightValue)),
      ],
    );
  }

  Widget _buildCell({required String label, required String value}) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
           "$label:",
            style: const TextStyle(
              fontSize: FontSize.s12,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: AppSize.s10),
        if (value.isNotEmpty)
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: FontSize.s11,
                color: ColorManager.granitegray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}