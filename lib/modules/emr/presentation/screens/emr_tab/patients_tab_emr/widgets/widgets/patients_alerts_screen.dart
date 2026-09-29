import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/constant_components.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/providers/hh_emr/visit_details_provider.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/alert_manager/alert_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/alert_data/alart_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/header_content_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets/add_alert_popup.dart';


class PatientsAlertsScreen extends StatefulWidget {
  final int ptId;
  const PatientsAlertsScreen({super.key, required this.ptId});

  @override
  State<PatientsAlertsScreen> createState() => _PatientsAlertsScreenState();
}

class _PatientsAlertsScreenState extends State<PatientsAlertsScreen> {
  // ── State ──────────────────────────────────────────────────────────────────
  List<ClinicianAlertData> _alerts = [];
  bool _isLoading = false;
  String _selectedAlertType = 'patient'; // 'patient' | 'visit' | 'discipline'

  final _alertTypeMap = {
    'Patients Alert':    'patient',
    'Visits Alert':      'visit',
    'Discipline Alerts': 'discipline',
  };

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAlerts());
  }

  // ── GET alerts ─────────────────────────────────────────────────────────────
  Future<void> _fetchAlerts() async {
    setState(() => _isLoading = true);
    final result = await getAlertsByPatient(
      context:    context,
      patientId:  widget.ptId,
      alertType:  _selectedAlertType,
    );
    if (mounted) {
      setState(() {
        _alerts    = result ?? [];
        _isLoading = false;
      });
    }
  }

  // ── DELETE alert ───────────────────────────────────────────────────────────
  Future<void> _deleteAlert(int alertId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Alert'),
        content: const Text('Are you sure you want to delete this alert?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await deleteAlert(
      context: context,
      alertId: alertId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
      if (result.success) _fetchAlerts();
    }
  }

  // ── PATCH alert (resolve toggle) ───────────────────────────────────────────
  Future<void> _patchAlert(ClinicianAlertData alert) async {
    final result = await patchAlert(
      context:      context,
      alertId:      alert.alertId,
      userId:       0,
      clinicianId:  alert.clinicians.map((c) => c.employeeId).toList(),
      alertHeading: alert.alertHeading,
      alertBody:    alert.alertBody,
      alertResolve: !alert.alertResolve,
      alertType:    alert.alertType,
      fkPtId:       widget.ptId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
      if (result.success) _fetchAlerts();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final nav = context.read<EMRNavigationController>();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p70),
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Breadcrumb ─────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppPadding.p12),
            child: Row(
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  onTap: () {
                    nav.closeAlerts();
                    nav.closePatientDetail();
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Text(
                    'Patients',
                    style: TextStyle(
                      fontSize: FontSize.s13,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.blueprime,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppPadding.p6),
                  child: Icon(Icons.chevron_right,
                      size: IconSize.I18, color: ColorManager.mediumgrey),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  onTap: () => nav.closeAlerts(),
                  borderRadius: BorderRadius.circular(4),
                  child: Text(
                    nav.selectedPatient?.name ?? '',
                    style: TextStyle(
                      fontSize: FontSize.s13,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.blueprime,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppPadding.p6),
                  child: Icon(Icons.chevron_right,
                      size: IconSize.I18, color: ColorManager.mediumgrey),
                ),
                Text(
                  'Alerts',
                  style: TextStyle(
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.darkgrey,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Center(
            child: Text("Dependency on forms builder which is under development!",
              style: AllNoDataAvailable.customTextStyle(context),),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ── Alert Card ─────────────────────────────────────────────────────────────────
class _AlertCard extends StatelessWidget {
  final ClinicianAlertData alert;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _AlertCard({
    required this.alert,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 2, child: Container()),
        Expanded(
          flex: 6,
          child: ListViewContainerConstantEMR(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: 30),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Heading ── flex 2 ──────────────────────────────────────
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          alert.alertHeading,
                          style: TextStyle(
                            fontSize: FontSize.s12,
                            fontWeight: FontWeight.w600,
                            color: ColorManager.darkgrey,
                          ),
                        ),
                        if (alert.alertResolve)
                          const Text(
                            'Resolved',
                            style: TextStyle(
                              fontSize: FontSize.s10,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── Clinicians ── flex 3 ───────────────────────────────────
                  Expanded(
                    flex: 3,
                    child: alert.clinicians.isEmpty
                        ? const SizedBox()
                        : Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: AppSize.s16,
                              backgroundColor: alert.clinicians.first.color.isNotEmpty
                                  ? Color(int.parse(
                                  alert.clinicians.first.color
                                      .replaceFirst('#', '0xFF')))
                                  : const Color(0xFF4CAF50),
                              backgroundImage: alert.clinicians.first.imgUrl.isNotEmpty
                                  ? NetworkImage(alert.clinicians.first.imgUrl)
                                  : null,
                              child: alert.clinicians.first.imgUrl.isEmpty
                                  ? Text(
                                alert.clinicians.first.abbreviation,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white),
                              )
                                  : null,
                            ),
                            Positioned(
                              bottom: -2,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: ColorManager.blueprime,
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                      color: Colors.white, width: 1),
                                ),
                                child: Text(
                                  alert.clinicians.first.abbreviation,
                                  style: const TextStyle(
                                    fontSize: FontSize.s10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AppSize.s8),
                        Expanded(
                          child: Text(
                            alert.clinicians.first.fullName,
                            style: TextStyle(
                              fontSize: FontSize.s12,
                              fontWeight: FontWeight.w600,
                              color: ColorManager.darkgrey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Body ── flex 2 ─────────────────────────────────────────
                  Expanded(
                    flex: 2,
                    child: Text(
                      alert.alertBody,
                      style: TextStyle(
                        fontSize: FontSize.s12,
                        color: ColorManager.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),

                  // ── Edit + Delete ── flex 1 ────────────────────────────────
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: (){},
                          icon: Icon(Icons.edit_outlined,
                              size: AppSize.s16,
                              color: ColorManager.mediumgrey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: AppSize.s8),
                        IconButton(
                          onPressed: onDelete,
                          icon: Icon(Icons.delete_outline,
                              size: AppSize.s16,
                              color: ColorManager.mediumgrey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(flex: 2, child: Container()),
      ],
    );
  }
}