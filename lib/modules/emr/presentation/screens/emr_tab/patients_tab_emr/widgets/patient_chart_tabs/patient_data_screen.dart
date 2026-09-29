import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/subtabs_popup/patients_data_summary_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/constant_components.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/emr_theme_const.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

// TODO: update these import paths to wherever your manager functions
// (getReffrealsPatientDocuments, getPatientSignatureDoc,
// getReffrealsPatientDocumentsFaceTwoFace, getPatientEmergencyContact,
// downloadFile) and their model classes (PatientDocumentsData,
// PatientSigDoc, PatientDocumentsFtwoFData, FTwoFDocumentsModel,
// PatientInsuranceDocumentData) actually live.
import 'package:symmetry_emr/modules/emr/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_patient_manager/patient_header_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/patient_insurance_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/refferals_manager/refferals_patient_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/patient_tab_data/patient_data_model.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/patient_insurance_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/patient_insurances_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/onboarding/download_doc_const.dart';


class PatientDataScreen extends StatefulWidget {
  final int patientId;

  const PatientDataScreen({super.key, required this.patientId});

  @override
  State<PatientDataScreen> createState() => _PatientDataScreenState();
}

class _PatientDataScreenState extends State<PatientDataScreen> {
  // Track expanded state per section
  final Map<String, bool> _expanded = {
    'Referral Paperwork': true,
    'Face-to-Face Encounter': true,
    'Insurance Verification/Authorization': true,
    'Signature Forms': true,
  };

  bool _isLoading = true;
  List<_SectionData> _sections = [];

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    setState(() => _isLoading = true);

    try {
      // Fire all API calls in parallel
      final results = await Future.wait([
        getReffrealsPatientDocuments(
          context: context,
          patientId: widget.patientId,
        ),
        getReffrealsPatientDocumentsFaceTwoFace(
          context: context,
          patientId: widget.patientId,
        ),
        getPatientSignatureDoc(
          context: context,
          patientId: widget.patientId,
        ),
        getPatientEmergencyContact(
          context: context,
          ptId: widget.patientId,
          isPrimary: true,
        ),
        getPatientEmergencyContact(
          context: context,
          ptId: widget.patientId,
          isPrimary: false,
        ),
      ]);

      final referralDocs = results[0] as List<PatientDocumentsData>;
      final f2fDocs = results[1] as List<PatientDocumentsFtwoFData>;
      final sigDocs = results[2] as List<PatientSigDoc>;
      final primaryInsuranceDocs =
      results[3] as List<PatientInsuranceDocumentData>;
      final secondaryInsuranceDocs =
      results[4] as List<PatientInsuranceDocumentData>;

      // Referral Paperwork section
      // ✅ rptd_created_at is already formatted as "yyyy/MM/dd" inside the
      // manager (convertIsoToDayMonthYear runs there) — do NOT re-run
      // _formatDate on it here, or DateTime.parse will fail on the already
      // -formatted string and every row will show "--"
      final referralItems = referralDocs
          .map(
            (item) => _DocItem(
          name: item.documentName,
          person: item.rptd_created_by.toString(),
          date: item.rptd_created_at,
          url: item.rptd_url,
        ),
      )
          .toList();

      // Face-to-Face Encounter section (flatten each record's nested documents)
      // ✅ f2f_doc_created_at is now kept as raw ISO in the manager
      // (no longer pre-formatted), so _formatDate here works correctly.
      final f2fItems = f2fDocs
          .expand((record) => record.documents!)
          .map(
            (doc) => _DocItem(
          name: doc.f2f_doc_name,
          person: doc.f2f_doc_created_by,
          date: _formatDate(doc.f2f_doc_created_at),
          url: doc.f2f_doc_url,
        ),
      )
          .toList();

      // Signature Forms section
      // sigDocCreatedAt is raw ISO from the API, so _formatDate applies here.
      final sigItems = sigDocs
          .map(
            (item) => _DocItem(
          name: item.sigDocName,
          person: item.sigDocCreatedBy,
          date: _formatDate(item.sigDocCreatedAt),
          url: item.sigDocUrl,
        ),
      )
          .toList();

      // Insurance Verification/Authorization section
      // (primary + secondary insurance documents combined)
      // createdAt here is already a DateTime, so format directly.
      final insuranceItems = [
        ...primaryInsuranceDocs,
        ...secondaryInsuranceDocs,
      ]
          .map(
            (item) => _DocItem(
          name: item.docName,
          person: item.createdBy,
          date: DateFormat('yyyy/MM/dd').format(item.createdAt),
          url: item.docUrl,
        ),
      )
          .toList();

      setState(() {
        _sections = [
          _SectionData(title: 'Referral Paperwork', items: referralItems),
          _SectionData(title: 'Face-to-Face Encounter', items: f2fItems),
          _SectionData(
            title: 'Insurance Verification/Authorization',
            items: insuranceItems,
          ),
          _SectionData(title: 'Signature Forms', items: sigItems),
        ];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading patient data: $e');
      setState(() => _isLoading = false);
    }
  }

  // Used only for sections that hand us a raw ISO date string
  // (Face-to-Face, Signature Forms). Referral Paperwork is pre-formatted
  // in the manager and must NOT go through this.
  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '--';
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('yyyy/MM/dd').format(dateTime);
    } catch (_) {}
    try {
      final dateTime = DateFormat('MM/dd/yyyy').parse(isoDate);
      return DateFormat('yyyy/MM/dd').format(dateTime);
    } catch (_) {
      return '--';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorManager.white,
      child: _isLoading
          ?  Center(child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: CircularProgressIndicator(color: ColorManager.blueprime,),
      ))
          : Padding(
        padding: const EdgeInsets.all(AppPadding.p20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Patient Data',
              style: PatientsFormsHeadData.customTextStyle(context),
            ),
            const SizedBox(height: AppSize.s25),

            // Sections
            ...List.generate(_sections.length, (i) {
              final section = _sections[i];
              final isOpen = _expanded[section.title] ?? true;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header
                  InkWell(
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () => setState(
                          () => _expanded[section.title] = !isOpen,
                    ),
                    child: Row(
                      children: [
                        Text(
                          section.title,
                          style: TextStyle(
                            fontSize: FontSize.s11,
                            fontWeight: FontWeight.w600,
                            color: ColorManager.darkgrey,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          isOpen
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 16,
                          color: ColorManager.blueprime,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSize.s8),

                  // Document rows
                  if (isOpen)
                    if (section.items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: Center(
                          child: Text(
                            'No documents found!',
                            style: EMRListViewData.customTextStyle(
                              context,
                            ),
                          ),
                        ),
                      )
                    else
                      ...section.items.map((doc) => _DocRow(doc: doc)),

                  const SizedBox(height: AppSize.s16),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Data models ──────────────────────────────────────────────

class _SectionData {
  final String title;
  final List<_DocItem> items;
  const _SectionData({required this.title, required this.items});
}

class _DocItem {
  final String name;
  final String person;
  final String date;
  final String url;
  const _DocItem({
    required this.name,
    required this.person,
    required this.date,
    required this.url,
  });
}

// ── Doc Row Widget ────────────────────────────────────────────

class _DocRow extends StatelessWidget {
  final _DocItem doc;
  const _DocRow({required this.doc});

  @override
  Widget build(BuildContext context) {
    final personLabel = doc.person.trim().isEmpty ? '--' : doc.person.trim();

    return ListViewContainerConstantEMR(
      paddingLeft: AppPadding.p60,
      paddingRight: AppPadding.p60,
      paddingTop: AppPadding.p10,
      paddingBottom: AppPadding.p10,
      marginRight: AppPadding.p20,
      child: Row(
        children: [
          // Document name (tap to download)
          Expanded(
            child: InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                if (doc.url.isEmpty) return;
                downloadFile(context: context,
                    fileUrl: doc.url,
                    documentName:doc.name,
                    apiPath: DownloadDocumentRepository.getPatientDocumentByFileName());
              },
              child: Text(
                doc.name,
                style: TextStyle(
                  fontSize: FontSize.s12,
                  color: ColorManager.pieChartBBlue,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),

          // Avatar + person name
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: Colors.teal.shade100,
                  child: Text(
                    personLabel[0],
                    style: TextStyle(
                      fontSize: FontSize.s12,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.mediumgrey,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    personLabel,
                    style: EMRListViewHead.customTextStyle(context),
                  ),
                ),
              ],
            ),
          ),

          // Date
          Expanded(
            child: Text(
              doc.date,
              style: EMRListViewData.customTextStyle(context),
            ),
          ),

          // AI Summary link
          Expanded(
            child: InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const PatientsDataSummaryPopup(),
                );
              },
              child: Text(
                'AI Summary',
                style: TextStyle(
                  fontSize: FontSize.s12,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.blueprime,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}