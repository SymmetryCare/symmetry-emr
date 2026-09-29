import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/subtabs_popup/add_medication_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/subtabs_popup/discontinued_medication_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/subtabs_popup/drug_interaction_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/subtabs_popup/edit_allergies_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/subtabs_popup/medication_tablet_popup.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/common_resources/emr_theme_const.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

enum MedicationTag { none, new_, starting, changing, pin, highRisk }

class MedicationItem {
  final String name;
  final String dose;
  final String frequency;
  final String route;
  final String specialInstructions;
  final MedicationTag tag;
  final bool isHighRisk;

  const MedicationItem({
    required this.name,
    required this.dose,
    required this.frequency,
    required this.route,
    required this.specialInstructions,
    this.tag = MedicationTag.none,
    this.isHighRisk = false,
  });
}

class MedicationsScreen extends StatefulWidget {
  final int patientId;
  final int chartId;
  final int episodeId;

  const MedicationsScreen({
    super.key,
    required this.patientId,
    required this.chartId,
    required this.episodeId,
  });

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  static const List<MedicationItem> _medications = [
    MedicationItem(
      name: ' ',
      dose: ' ',
      frequency: ' ',
      route: ' ',
      specialInstructions: ' ',
      tag: MedicationTag.new_,
    ),
    MedicationItem(
      name: ' ',
      dose: ' ',
      frequency: ' ',
      route: ' ',
      specialInstructions: ' ',
      tag: MedicationTag.new_,
    ),
    MedicationItem(
      name: ' ',
      dose: ' ',
      frequency: ' ',
      route: ' ',
      specialInstructions: ' ',
      tag: MedicationTag.starting,
    ),
    MedicationItem(
      name: ' ',
      dose: ' ',
      frequency: ' ',
      route: ' ',
      specialInstructions: ' ',
      tag: MedicationTag.starting,
      isHighRisk: true,
    ),
    MedicationItem(
      name: ' ',
      dose: ' ',
      frequency: ' ',
      route: ' ',
      specialInstructions: ' ',
      tag: MedicationTag.changing,
      isHighRisk: true,
    ),
    MedicationItem(
      name: ' ',
      dose: ' ',
      frequency: ' ',
      route: ' ',
      specialInstructions: ' ',
      tag: MedicationTag.pin,
      isHighRisk: true,
    ),
    MedicationItem(
      name: ' ',
      dose: ' ',
      frequency: ' ',
      route: ' ',
      specialInstructions: ' ',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Text("Dependency on Forms Builder under development and is not available in the current build!",
          style: AllNoDataAvailable.customTextStyle(context),),
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: FontSize.s12,
          fontWeight: FontWeight.w600,
          color: ColorManager.blueprime,
          decoration: TextDecoration.underline,
          decorationColor: ColorManager.blueprime,
        ),
      ),
    );
  }
}

// ── Medications Table ─────────────────────────────────────────────────────────
class _MedicationsTable extends StatelessWidget {
  final List<MedicationItem> medications;
  const _MedicationsTable({required this.medications});

  static Widget _vLine() => Container(width: 1, color: const Color(0xFFE0E0E0));

  static Widget _cell({required Widget child, int flex = 1}) => Expanded(
    flex: flex,
    child: Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p8, vertical: AppPadding.p10),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        borderRadius: BorderRadius.circular(AppSize.s4),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSize.s4),
                topRight: Radius.circular(AppSize.s4),
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  const SizedBox(width: AppSize.s30),
                  _cell(flex: 3, child: Text('Medication', style: _headerStyle())),
                  _vLine(),
                  _cell(flex: 2, child: Text('Dose', style: _headerStyle())),
                  _vLine(),
                  _cell(flex: 2, child: Text('Frequency', style: _headerStyle())),
                  _vLine(),
                  _cell(flex: 2, child: Text('Route', style: _headerStyle())),
                  _vLine(),
                  _cell(flex: 3, child: Text('Special Instructions', style: _headerStyle())),
                  _vLine(),
                  const SizedBox(width: AppSize.s32),
                ],
              ),
            ),
          ),

          // Table rows
          ...medications.map((med) => _MedicationRow(item: med)),
        ],
      ),
    );
  }

  TextStyle _headerStyle() => TextStyle(
    fontSize: FontSize.s11,
    fontWeight: FontWeight.w700,
    color: ColorManager.darkgrey,
  );
}

// ── Medication Row ────────────────────────────────────────────────────────────
class _MedicationRow extends StatelessWidget {
  final MedicationItem item;
  const _MedicationRow({required this.item});

  static Widget _vLine() => Container(width: 1, color: const Color(0xFFE0E0E0));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border:
        Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Side tag bar
            Padding(
              padding: const EdgeInsets.only(
                  left: AppPadding.p5,
                  top: AppPadding.p6,
                  bottom: AppPadding.p6),
              child: _TagBar(tag: item.tag),
            ),
            const SizedBox(width: AppSize.s8),

            // Medication name + High Risk badge
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.p8, vertical: AppPadding.p8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (item.isHighRisk) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [_HighRiskBadge()],
                      ),
                      const SizedBox(height: AppSize.s4),
                    ],
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => const MedicationTabletPopup(),
                        );
                      },
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: FontSize.s12,
                          color: ColorManager.blueprime,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _vLine(),

            // Dose
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.p8, vertical: AppPadding.p8),
                child: Text(item.dose,
                    style: TextStyle(
                        fontSize: FontSize.s12, color: ColorManager.grey)),
              ),
            ),

            _vLine(),

            // Frequency
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.p8, vertical: AppPadding.p8),
                child: Text(item.frequency,
                    style: TextStyle(
                        fontSize: FontSize.s12, color: ColorManager.grey)),
              ),
            ),

            _vLine(),

            // Route
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.p8, vertical: AppPadding.p8),
                child: Text(item.route,
                    style: TextStyle(
                        fontSize: FontSize.s12, color: ColorManager.grey)),
              ),
            ),

            _vLine(),

            // Special Instructions
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.p8, vertical: AppPadding.p8),
                child: Text(
                  item.specialInstructions,
                  style: TextStyle(
                      fontSize: FontSize.s11, color: ColorManager.grey),
                ),
              ),
            ),

            _vLine(),

            // Info icon
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p8, vertical: AppPadding.p8),
              child: Icon(Icons.info_outline,
                  size: AppSize.s16, color: ColorManager.blueprime),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tag Bar (colored left side) ───────────────────────────────────────────────
class _TagBar extends StatelessWidget {
  final MedicationTag tag;
  const _TagBar({required this.tag});

  Color get _color {
    switch (tag) {
      case MedicationTag.new_:
        return ColorManager.green;
      case MedicationTag.starting:
        return Colors.orange;
      case MedicationTag.changing:
        return Colors.blue;
      case MedicationTag.pin:
        return Colors.purple;
      default:
        return Colors.transparent;
    }
  }

  String get _label {
    switch (tag) {
      case MedicationTag.new_:
        return 'New';
      case MedicationTag.starting:
        return 'Starting';
      case MedicationTag.changing:
        return 'Changing';
      case MedicationTag.pin:
        return 'Pin';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tag == MedicationTag.none) return const SizedBox(width: AppSize.s6);
    return Container(
      width: AppSize.s15,
      height: AppSize.s50,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(AppSize.s2),
      ),
      alignment: Alignment.center,
      child: RotatedBox(
        quarterTurns: 3,
        child: Text(
          _label,
          style: const TextStyle(
            fontSize: FontSize.s9,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── High Risk Badge ───────────────────────────────────────────────────────────
class _HighRiskBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: AppPadding.p6, vertical: 2),
      decoration: BoxDecoration(
        color: ColorManager.red,
        borderRadius: BorderRadius.circular(AppSize.s4),
      ),
      child: const Text(
        'High Risk',
        style: TextStyle(
          fontSize: FontSize.s9,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}