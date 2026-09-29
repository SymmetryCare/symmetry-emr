import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets/upload_protocol_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/providers/hh_emr/visit_details_provider.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_patient_manager/patient_protocol_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/patient_tab_data/patient_protocol_model.dart';

class PatientsProtocolScreen extends StatefulWidget {
  final int ptId;
  const PatientsProtocolScreen({super.key, required this.ptId});

  @override
  State<PatientsProtocolScreen> createState() => _PatientsProtocolScreenState();
}

class _PatientsProtocolScreenState extends State<PatientsProtocolScreen> {
  // ── Cached future — prevents refetch/rebuild loop on every build ──
  late Future<List<PatientProtocolListModule>> _protocolListFuture;

  @override
  void initState() {
    super.initState();
    _protocolListFuture = getProtocolListData(
      context: context,
      ptId: widget.ptId,
    );
  }

  // FIX: call this instead of relying on setState() to trigger a rebuild
  // that re-ran the (now cached) inline future.
  void _refreshProtocolList() {
    setState(() {
      _protocolListFuture = getProtocolListData(
        context: context,
        ptId: widget.ptId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p70),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Breadcrumb header ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppPadding.p12),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    final nav = context.read<EMRNavigationController>();
                    nav.closeProtocol();
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
                      size: IconSize.I18, color: ColorManager.blueprime),
                ),
                InkWell(
                  onTap: () =>
                      context.read<EMRNavigationController>().closeProtocol(),
                  borderRadius: BorderRadius.circular(4),
                  child: Text(
                    context.read<EMRNavigationController>().selectedPatient?.name ?? '',
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
                      size: IconSize.I18, color: ColorManager.blueprime),
                ),
                Text(
                  'Protocols',
                  style: TextStyle(
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.darkgrey,
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomIconButtonConst(
                icon: Icons.file_upload_outlined,
                text: 'Upload Protocol',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => UploadProtocolPopup(
                      ptId: widget.ptId,
                    onRefresh: (){
                        _refreshProtocolList();
                    },),
                  );
                },
              ),
            ],
          ),

          // ── Body: PDF Grid ───────────────────────────────────────────
          Expanded(
            child: FutureBuilder<List<PatientProtocolListModule>>(
              future: _protocolListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No protocols found!",
                  style: AllNoDataAvailable.customTextStyle(context),));
                }

                final protocols = snapshot.data!;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppPadding.p30,
                    horizontal: AppPadding.p120,
                  ),
                  child: Wrap(
                    spacing: AppSize.s30,
                    runSpacing: AppSize.s30,
                    children: protocols
                        .map((protocol) => _ProtocolFileCard(
                      fileName: protocol.fileName,
                      pdfUrl: protocol.pdfUrl,
                    ))
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtocolFileCard extends StatelessWidget {
  final String fileName;
  final String pdfUrl;
  const _ProtocolFileCard({required this.fileName, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // use pdfUrl to open the file
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF3FB),
          borderRadius: BorderRadius.circular(AppSize.s12),
          border: Border.all(color: const Color(0xFFD0E6F5), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // PDF icon
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Icon(
                Icons.file_copy_rounded,
                size: IconSize.I30,
                color: ColorManager.blueprime,
              ),
            ),
            Container(
              height: 40,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                border: Border.all(color: const Color(0xFFD0E6F5), width: 1),
              ),
              child: Text(
                fileName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: FontSize.s11,
                  color: ColorManager.blueprime,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}