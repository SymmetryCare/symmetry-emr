import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/subtabs_popup/patients_data_summary_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/widget/const_form_tap.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/common_resources/emr_theme_const.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_patient_manager/patient_tab_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/patient_tab_data/patient_form_emr_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/constant_components.dart';


class VisitTimelineScreen extends StatefulWidget {
  final int patientId;
  final int chartId;
  final int episodeId;

  const VisitTimelineScreen({
    super.key,
    required this.patientId,
    required this.chartId,
    required this.episodeId,
  });

  @override
  State<VisitTimelineScreen> createState() => _VisitTimelineScreenState();
}

class _VisitTimelineScreenState extends State<VisitTimelineScreen> {
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
      formCategory: 'visit-timeline',
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
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.p20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visit Timeline',
                  style: PatientsFormsHeadData.customTextStyle(context),
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
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _emrData!.data.length,
                    itemBuilder: (context, index) => ListViewContainerConstantEMR(
                      marginRight: AppPadding.p20,
                      child: _VisitTimelineNoteRow(note: _emrData!.data[index],onTapForm: () {
                        prividerData.onTap(context: context,
                            patientFormId: _emrData!.data[index].patientFormId,
                            ptId: _emrData!.data[index].patientId,
                            chartNo: _emrData!.data[index].chartId);
                      },),
                    ),
                  ),
              ],
            ),
          ),
        );
      }
    );
  }
}

class _VisitTimelineNoteRow extends StatelessWidget {
  final FormEMRData note;
  final VoidCallback onTapForm;
  const _VisitTimelineNoteRow({required this.note, required this.onTapForm});

  bool get _isCompleted => note.status == 'SUBMITTED_BY_CLINICIAN' ||
      note.status == 'QA_APPROVED'            ||
      note.status == 'ASSIGNED_TO_CODER';

  bool get _hasQA =>
      note.assignedTo.any((a) => a.role == 'QA Coordinator');

  AssignedTo? get _provider =>
      note.assignedTo.isNotEmpty ? note.assignedTo.first : null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status + QA badges top-right
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            StatusBadgeEMR(
              status: _isCompleted ? NoteStatus.completed : NoteStatus.pending,
            ),
            const SizedBox(width: AppSize.s8),
            if (_isCompleted && _hasQA)
              QaBadgeEMR(
                status: _isCompleted ? NoteStatus.completed : NoteStatus.pending,
              ),
          ],
        ),

        const SizedBox(height: AppSize.s4),

        // Main content row
        Padding(
          padding: const EdgeInsets.symmetric(
              vertical: AppPadding.p8, horizontal: AppPadding.p60),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Note title
              Expanded(
                flex: 2,
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

              // Avatar + provider name
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    CircleAvatarListViewData(
                      name:       _provider?.name ?? '',
                      bgColor:    _provider!.color.replaceAll("#", ""),
                      abrivation: _provider!.abbreviation,
                    ),
                    const SizedBox(width: AppSize.s6),
                    Flexible(
                      child: Text(
                        _provider?.name ?? '-',
                        style: const TextStyle(
                            fontSize: FontSize.s12, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Date
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
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const PatientsDataSummaryPopup(),
                    );
                  },
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

              // Delete (completed only — matches original logic)
              if (_isCompleted)
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
        const SizedBox(height: AppSize.s12),
      ],
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