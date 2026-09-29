import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/widget/const_form_tap.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/constant_components.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/common_resources/emr_theme_const.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_patient_manager/patient_tab_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/patient_tab_data/patient_form_emr_data.dart';

class PhysicianOrdersScreen extends StatefulWidget {
  final int patientId;
  final int chartId;
  final int episodeId;

  const PhysicianOrdersScreen({
    super.key,
    required this.patientId,
    required this.chartId,
    required this.episodeId,
  });

  @override
  State<PhysicianOrdersScreen> createState() => _PhysicianOrdersScreenState();
}

class _PhysicianOrdersScreenState extends State<PhysicianOrdersScreen> {
  PatientFormEmrData? _emrData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final result = await getPatientFormEMR(
      context:      context,
      patientId:    widget.patientId,
      chartId:      widget.chartId,
      episodeId:    widget.episodeId,
      formCategory: 'physician_orders',
      page:         1,
      limit:        9999,
    );
    if (mounted) {
      setState(() {
        _emrData   = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatienFormTapping>(
        builder: (context,prividerData,data) {
        return Container(
          color: ColorManager.white,
          padding: const EdgeInsets.all(AppPadding.p20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Physician Order',
                          style: PatientsFormsHeadData.customTextStyle(context),
                        ),
                        const SizedBox(height: AppSize.s8),
                        Text(
                          _emrData != null
                              ? 'Total Records: ${_emrData!.total}'
                              : '--',
                          style: PatientsFormsSubData.customTextStyle(context),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSizeConst.A20),

                // ── loading / empty / list ──
                if (_isLoading)
                  const Center(child: Padding(
                    padding:  EdgeInsets.symmetric(vertical: AppPadding.p50),
                    child: CircularProgressIndicator(),
                  ))
                else if (_emrData == null || _emrData!.data.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppPadding.p50),
                    child: Center(child: Text('No records found!',
                    style: AllNoDataAvailable.customTextStyle(context),)),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _emrData!.data.length,
                    separatorBuilder: (_, __) => const Divider(
                        height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                    itemBuilder: (context, index) =>
                        _OasisNoteRow(note: _emrData!.data[index],onTapForm: () {
                          prividerData.onTap(context: context,
                              patientFormId: _emrData!.data[index].patientFormId,
                              ptId: _emrData!.data[index].patientId,
                              chartNo: _emrData!.data[index].chartId);
                        },),
                  ),
              ],
            ),
        );
      }
    );
  }
}

// ─────────────────────────────────────────────

class _OasisNoteRow extends StatelessWidget {
  final FormEMRData note;
  final VoidCallback onTapForm;
  const _OasisNoteRow({required this.note, required this.onTapForm});

  bool get _isCompleted => note.status == 'SUBMITTED_BY_CLINICIAN' ||
      note.status == 'QA_APPROVED'            ||
      note.status == 'ASSIGNED_TO_CODER';

  // first assigned staff that matches a role
  AssignedTo? _staffByRole(String role) =>
      note.assignedTo.where((a) => a.role == role).firstOrNull;

  bool get _hasQA     => _staffByRole('QA Coordinator') != null;
  bool get _hasCoded  => _staffByRole('Certified Coder') != null;

  @override
  Widget build(BuildContext context) {
    final provider = note.assignedTo.isNotEmpty ? note.assignedTo.first : null;

    return ListViewContainerConstantEMR(
      paddingLeft:   AppPadding.p60,
      marginRight:   AppPadding.p30,
      paddingBottom: AppPadding.p8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── status badges ──
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_isCompleted) ...[
                const StatusBadgeEMR(status: NoteStatus.completed),
                const SizedBox(width: AppSize.s6),
                if (_hasQA)
                  const QaBadgeEMR(status: NoteStatus.completed),
                if (_hasCoded) ...[
                  const SizedBox(width: AppSize.s6),
                  const StatusBadgeEMR(status: NoteStatus.completed),
                ],
              ] else
                const StatusBadgeEMR(status: NoteStatus.pending),
            ],
          ),
          const SizedBox(height: AppSize.s6),

          // ── row content ──
          Padding(
            padding: const EdgeInsets.only(right: 40.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Expanded(
                  flex: 3,
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: onTapForm,
                    child: Text(
                      note.formName,
                      style: TextStyle(
                        fontSize:        FontSize.s13,
                        fontWeight:      FontWeight.w500,
                        color:           ColorManager.blueprime,
                        decoration:      TextDecoration.underline,
                        decorationColor: ColorManager.blueprime,
                      ),
                    ),
                  ),
                ),

                // Avatar + Provider name
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      CircleAvatarListViewData(
                        name:    provider?.name ?? '',
                        bgColor: provider!.color.replaceAll("#", ""),
                        abrivation: provider!.abbreviation,
                      ),
                      const SizedBox(width: AppSize.s6),
                      Flexible(
                        child: Text(
                          provider?.name ?? '-',
                          style: const TextStyle(
                              fontSize: FontSize.s12, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Date (createdAt)
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatDate(note.createdAt),
                    style: const TextStyle(
                        fontSize: FontSize.s12, color: Colors.black87),
                  ),
                ),

                // AI Summary
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      'AI Summary',
                      style: TextStyle(
                        fontSize:        FontSize.s12,
                        color:           ColorManager.blueprime,
                        fontWeight:      FontWeight.w500,
                        decoration:      TextDecoration.underline,
                        decorationColor: ColorManager.blueprime,
                      ),
                    ),
                  ),
                ),

                // Delete (pending only)
                if (!_isCompleted)
                  GestureDetector(
                    onTap: () {},
                    child: Icon(Icons.delete_outline,
                        size: AppSize.s16, color: ColorManager.redDark),
                  )
                else
                  const SizedBox(width: AppSize.s28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Converts ISO date string → MM/DD/YYYY
  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}