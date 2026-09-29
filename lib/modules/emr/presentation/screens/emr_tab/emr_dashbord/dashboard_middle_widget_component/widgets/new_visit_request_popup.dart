import 'dart:async';
import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/visit_request_components.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
// removed in extraction: import 'package:prohealth/modules/hr/presentation/screens/onboarding/widgets/widgets/banking_tab_constant.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dashboard_tab_manager/new_visit_request_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/new_visit_request_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/sucess_failed_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';

class NewVisitRequestPopup extends StatefulWidget {
  const NewVisitRequestPopup({super.key});

  @override
  State<NewVisitRequestPopup> createState() => _NewVisitRequestPopupState();
}

class _NewVisitRequestPopupState extends State<NewVisitRequestPopup> {
  final _stream = StreamController<RequestVisitResponseData?>();
  final _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _stream.close();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final clinicianId = await TokenManager.getEmployeeId();
      final data = await getRequestVisitList(
        context,
        clinicianId: clinicianId,
        visitStatus: 'pending',
        patientName: 'all',
      );
      if (mounted) _stream.add(data);
    } catch (e) {
      print("Error loading visits: $e");
      if (mounted) _stream.add(null);
    }
  }

  Future<void> _approveAll(List<RequestVisitData> visits) async {
    final visitIds = visits.map((v) => v.visitId).toList();

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: SizedBox(
            height: 150,
            width: 250,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(Icons.close, color: ColorManager.mediumgrey),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Are you sure you want to approve all the requests?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButtonTransparent(
                      text: "Cancel",
                      onPressed: () => Navigator.pop(ctx),
                      height: 30,
                    ),
                    const SizedBox(width: 10),
                    CustomButton(
                      height: 30,
                      width: 100,
                      borderRadius: 12,
                      text: "Approve",
                      isLoading: _isLoading,
                      onPressed: () async {
                        Navigator.pop(ctx);
                        setState(() => _isLoading = true);
                        try {
                          final result = await approveAllVisits(context, visitIds);
                          if (result.success) {
                            await _load();
                            if (mounted) {
                              showDialog(
                                context: context,
                                builder: (_) => const EMRSuccessPopup(
                                  title: 'Approved',
                                  message: 'All visits approved successfully.',
                                ),
                              );
                            }
                          } else {
                            if (mounted) {
                              showDialog(
                                context: context,
                                builder: (_) => EMRFailedPopup(
                                  title: 'Failed',
                                  message: result.message.isNotEmpty
                                      ? result.message
                                      : 'Failed to approve visits.',
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          print("Error $e");
                          if (mounted) {
                            showDialog(
                              context: context,
                              builder: (_) => const EMRFailedPopup(
                                title: 'Failed',
                                message: 'Something went wrong.\nPlease try again.',
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RequestVisitResponseData?>(
      stream: _stream.stream,
      builder: (context, snapshot) {
        final visits = snapshot.data?.visits ?? [];
        return DialogueTemplateNoButtons(
          width:950,
          height: AppSize.s500,
          body: [
            if (visits.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButtonTransparent(
                    width: 110,
                    text: "Approve all",
                    onPressed: () => _approveAll(visits),
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
            if (!snapshot.hasData)
              const SizedBox(
                height: 320,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (visits.isEmpty)
              SizedBox(
                height: 320,
                child: Center(
                  child: Text(
                    'No visit requests found!',
                    style: AllNoDataAvailable.customTextStyle(context),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 500),
                child: ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbColor: WidgetStateProperty.all(ColorManager.mediumgrey),
                    trackColor: WidgetStateProperty.all(const Color(0xFFE5E7EB)),
                    thickness: WidgetStateProperty.all(6),
                    radius: const Radius.circular(10),
                    trackVisibility: WidgetStateProperty.all(true),
                  ),
                  child:  Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child:ScrollConfiguration(
                      behavior: const ScrollBehavior().copyWith(scrollbars: false),
                      child:  ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemCount: visits.length,
                        itemBuilder: (ctx, i) => _VisitRequestRow(
                          visit: visits[i],
                          onRefresh: _load,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
          title: "New Visit Request",
        );
      },
    );
  }
}

// ─── Row Widget ───────────────────────────────────────────────────────────────

class _VisitRequestRow extends StatefulWidget {
  final RequestVisitData visit;
  final VoidCallback onRefresh;

  const _VisitRequestRow({
    required this.visit,
    required this.onRefresh,
  });

  @override
  State<_VisitRequestRow> createState() => _VisitRequestRowState();
}

class _VisitRequestRowState extends State<_VisitRequestRow> {
  bool _showNote = false;
  bool _isApproving = false;
  bool _isRejecting = false;

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '??';
  }

  String _formatDate(String isoString) {
    final dt = DateTime.tryParse(isoString)?.toLocal();
    if (dt == null) return isoString;
    return '${dt.year}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatTimeframe(String from, String to) {
    final f = DateTime.tryParse(from)?.toLocal();
    final t = DateTime.tryParse(to)?.toLocal();
    if (f == null || t == null) return '';
    String fmt(DateTime d) =>
        '${d.year}/'
            '${d.month.toString().padLeft(2, '0')}/'
            '${d.day.toString().padLeft(2, '0')}';
    return '${fmt(f)}-${fmt(t)}';
  }


  @override
  Widget build(BuildContext context) {
    final v = widget.visit;
    final initials = _initials(v.patientName);

    return GestureDetector(
      onTap: () => setState(() => _showNote = !_showNote),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _showNote ? Colors.white : ColorManager.listTileColor,
              border: Border(
                  bottom: BorderSide(color: Colors.grey.shade400, width: 1)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: _showNote
                ? _buildNoteView(v)
                : _buildCardView(v, initials),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildCardView(RequestVisitData v, String initials) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Patient info ─────────────────────────────────────────────────────
        Expanded(
          flex: 3,
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: ColorManager.circleColor,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.mediumgrey,
                  ),
                ),
              ),
              SizedBox(width: 8,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.patientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: FontSize.s12,
                            color: ColorManager.mediumgrey,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text('MRN: ${v.mrn}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: FontSize.s11,
                            color: ColorManager.mediumgrey,
                            fontWeight: FontWeight.w400)),
                    const SizedBox(height: 3),
                    Text('${v.patientAge}y | ${v.genderName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: FontSize.s11,
                            color: ColorManager.mediumgrey,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(v.primaryDiagnosisName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF795548))),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Middle info block (top-aligned) ────────────────────────────────
        Expanded(
          flex: 12,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _infoColumn('Visit Type:', v.visitType)),
              Expanded(flex: 2, child: _infoColumn('Visit Date:', _formatDate(v.visitTimeframeFrom))),

              // ── Address ──────────────────────────────────────────────────
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: ColorManager.blueprime, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          v.patientAddress.isNotEmpty
                              ? v.patientAddress
                              : 'Address not available',
                          style: TextStyle(
                              fontSize: FontSize.s11,
                              color: ColorManager.faintGrey,
                              fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                flex: 3,
                child: _infoColumn(
                  'Wait Timeframe:',
                  _formatTimeframe(v.visitTimeframeFrom, v.visitTimeframeTo),
                ),
              ),
              Expanded(flex: 2, child: _infoColumn('Request Type:', v.requestType ?? 'N/A')),
            ],
          ),
        ),

        // ── Approve button ───────────────────────────────────────────────────
        _actionBtn(
          label: 'Approve',
          bg: ColorManager.blueprime,
          fg: Colors.white,
          onTap: () => showDialog(
            context: context,
            builder: (_) => VisitRequestApprovePopup(
              visitId: widget.visit.visitId,
              onRefresh: widget.onRefresh,
              patientName: v.patientName,
              mrn: v.mrn,
              patientAge: v.patientAge,
              genderName: v.genderName,
              primaryDiagnosisName: v.primaryDiagnosisName,
              patientAddress: v.patientAddress,
              visitType: v.visitType,
              requestType: v.requestType ?? 'N/A',
              visitTimeframeFrom: v.visitTimeframeFrom,
              visitTimeframeTo: v.visitTimeframeTo,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // ── Reject button ────────────────────────────────────────────────
        _actionBtn(
          label: 'Reject',
          bg: Colors.white,
          fg: const Color(0xFFDC2626),
          border: const Color(0xFFDC2626),
          onTap: _isRejecting
              ? () {}
              : () => showDialog(
            context: context,
            builder: (_) => VisitRequestRejectPopup(
              visitId: widget.visit.visitId,
              onRefresh: widget.onRefresh,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteView(RequestVisitData v) {
    final noteText = v.visitNote;
    final hasNote = noteText.isNotEmpty;
    return SizedBox(
      height: 61,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Note :',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFBF360C))),
              GestureDetector(
                onTap: () => setState(() => _showNote = false),
                child: const Icon(Icons.close, size: 20, color: Colors.black45),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            hasNote ? noteText : 'No Note here',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade700,
              fontStyle: hasNote ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: FontSize.s12,
                  color: ColorManager.mediumgrey,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: FontSize.s11,
                  color: ColorManager.faintGrey,
                  fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required String label,
    required Color bg,
    required Color fg,
    Color? border,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: border != null ? Border.all(color: border, width: 1) : null,
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12, color: fg, fontWeight: FontWeight.w500)),
      ),
    );
  }
}