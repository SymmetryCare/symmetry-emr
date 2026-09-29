import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/manage_history_version.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/onboarding/download_doc_const.dart';
import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/newpopup_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/ci_manage_button/newpopup_data.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/upload_edit_popup.dart';

class CICCCAPReports extends StatefulWidget {
  final int docId;
  final int subDocId;
  final String officeId;
  const CICCCAPReports(
      {super.key,
      required this.docId,
      required this.subDocId,
      required this.officeId});

  @override
  State<CICCCAPReports> createState() => _CICCCAPReportsState();
}

class _CICCCAPReportsState extends State<CICCCAPReports> {
  TextEditingController docNameController = TextEditingController();
  TextEditingController docIdController = TextEditingController();
  TextEditingController calenderController = TextEditingController();
  TextEditingController idOfDocController = TextEditingController();
  int docTypeMetaIdCC = FrontendConfigStore.data!.config.corporateAndCompliance;
  int docTypeMetaIdCCCap = FrontendConfigStore.data!.config.subDocId4CapReport;
  final StreamController<List<MCorporateComplianceModal>> _ccCapController =
      StreamController<List<MCorporateComplianceModal>>();

  String? selectedValue;
  late List<Color> hrcontainerColors;
  int docTypeMetaId = 0;
  int docSubTypeMetaId = 0;
  String? expiryType;
  bool _isLoading = false;
  int currentPage = 1;
  final int itemsPerPage = 10;
  final int totalPages = 5;

  void onPageNumberPressed(int pageNumber) {
    setState(() {
      currentPage = pageNumber;
    });
  }

  int docTypeId = 0;
  String? documentTypeName;
  dynamic filePath;
  String? selectedDocType;
  String fileName = '';
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        filePath = result.files.first.bytes;
        fileName = result.files.first.name;
        print('File path ${filePath}');
        print('File name ${fileName}');
      });
    }
  }

  // FIX: cache the prefill future once per edit-click instead of calling
  // getPrefillNewOrgOfficeDocument() inline inside the dialog's FutureBuilder,
  // which re-fired the API call on every rebuild of the dialog.
  Future<MCorporateCompliancePreFillModal>? _capPrefillFuture;

  @override
  void initState() {
    super.initState();
    _loadCapData();
  }

  // FIX: moved out of the StreamBuilder's builder callback, which re-fired
  // this API call on every rebuild instead of only once.
  void _loadCapData() {
    getListMCorporateCompliancefetch(context, FrontendConfigStore.data!.config.corporateAndCompliance,
        widget.officeId,FrontendConfigStore.data!.config.subDocId4CapReport, 1, 9999)
        .then((data) {
      if (mounted) _ccCapController.add(data);
    }).catchError((error) {
      // Handle error
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: StreamBuilder<List<MCorporateComplianceModal>>(
                stream: _ccCapController.stream,
                builder: (context, snapshot) {
                  print('55555555');
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: ColorManager.blueprime,
                      ),
                    );
                  }
                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        ErrorMessageString.noCR,
                        style: AllNoDataAvailable.customTextStyle(context)
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    int totalItems = snapshot.data!.length;
                    int totalPages = (totalItems / itemsPerPage).ceil();
                    List<MCorporateComplianceModal> paginatedData = snapshot.data!.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();

                    return Column(
                      children: [
                        Expanded(
                          child: ScrollConfiguration(
                            behavior: const ScrollBehavior().copyWith(scrollbars: false),
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: paginatedData.length,
                                itemBuilder: (context, index) {
                                  int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;
                                  String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                                  MCorporateComplianceModal CapReports = paginatedData[index];
                                  var ccCapReport = snapshot.data![index];
                                  var fileUrl = ccCapReport.docurl;
                                  final fileExtension = fileUrl.split('/').last;

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: AppSize.s8,),
                                      Container(
                                          margin: const EdgeInsets.symmetric(horizontal: AppSize.s5),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(4),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xff000000).withOpacity(0.25),
                                                spreadRadius: 0,
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          height: AppSize.s65,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p30),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  focusColor: Colors.transparent,
                                                      onTap: (){
                                                        print("FileExtension:${fileExtension}");
                                                        downloadFile(context: context,
                                                            fileUrl: fileUrl,
                                                            documentName:snapshot.data![index].fileName,
                                                            apiPath: DownloadDocumentRepository.getOrgOfficeDocumentByFileName());
                                                      },
                                                      child: Container(
                                                          width: AppSize.s62,
                                                          height: AppSize.s45,
                                                          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10,vertical: AppPadding.p8),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(4),
                                                            border: Border.all(width: 2, color: ColorManager.faintGrey),
                                                          ),
                                                          child: SvgPicture.asset('images/doc_vector.svg')),
                                                    ),
                                                   const SizedBox(width: AppSize.s10),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          "ID : ${CapReports.idOfDocument}",
                                                          style:  DocDefineTableDataID.customTextStyle(context),
                                                        ),
                                                        const SizedBox(height: AppSize.s8,),
                                                        Text(
                                                          CapReports.fileName.toString(),
                                                          textAlign: TextAlign.center,
                                                          style:  DocDefineTableData.customTextStyle(context),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              ManageHistoryPopup(docHistory: CapReports.docHistory,
                                                          ),
                                                        );
                                                      },
                                                      icon: Icon(
                                                        Icons.history,
                                                        size: IconSize.I22,
                                                        color: IconColorManager.blueprime,
                                                      ),
                                                      splashColor: Colors.transparent,
                                                      highlightColor: Colors.transparent,
                                                      hoverColor: Colors.transparent,
                                                    ),
                                                    const SizedBox(width: AppSize.s10,),
                                                    ///print
                                                    IconButton(
                                                      onPressed: () {
                                                        print("FileExtension:${fileExtension}");
                                                        downloadFile(context: context,
                                                            fileUrl: fileUrl,
                                                            documentName:snapshot.data![index].fileName,
                                                            apiPath: DownloadDocumentRepository.getOrgOfficeDocumentByFileName());
                                                      },
                                                      icon: Icon(
                                                        Icons
                                                            .print_outlined,
                                                        size:IconSize.I22,color: IconColorManager.blueprime,
                                                      ),
                                                      hoverColor: Colors.transparent,
                                                      splashColor: Colors.transparent,
                                                      highlightColor: Colors.transparent,
                                                    ),
                                                    const SizedBox(width: AppSize.s10,),
                                                    ///download saloni
                                                    PdfDownloadButton(
                                                        apiPath: DownloadDocumentRepository.getOrgOfficeDocumentByFileName(),
                                                        apiUrl: CapReports.docurl,
                                                        iconsize: IconSize.I22,
                                                        documentName: CapReports.fileName),
                                                    const SizedBox(width: AppSize.s10,),
                                                    IconButton(
                                                      onPressed: () {
                                                        String? selectedExpiryType = expiryType;
                                                        _capPrefillFuture = getPrefillNewOrgOfficeDocument(
                                                            context, CapReports.orgOfficeDocumentId);
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return FutureBuilder<
                                                                MCorporateCompliancePreFillModal>(
                                                              future: _capPrefillFuture,
                                                              builder: (context,
                                                                  snapshotPrefill) {
                                                                if (snapshotPrefill.connectionState == ConnectionState.waiting) {
                                                                  return Center(
                                                                    child: CircularProgressIndicator(
                                                                      color: ColorManager.blueprime,
                                                                    ),
                                                                  );
                                                                }

                                                                return StatefulBuilder(
                                                                  builder: (BuildContext context,
                                                                      void Function(void Function())
                                                                          setState) {
                                                                    return VCScreenPopupEditConst(
                                                                      fileName: snapshotPrefill.data!.fileName,
                                                                      url: snapshotPrefill.data!.url,
                                                                      expiryDate: snapshotPrefill.data!.expiry_date,
                                                                      title: EditPopupString.editCap,
                                                                      loadingDuration: _isLoading,
                                                                      officeId: widget.officeId,
                                                                      docTypeMetaIdCC: widget.docId,
                                                                      selectedSubDocId: widget.subDocId,
                                                                      orgDocId: snapshotPrefill.data!.orgOfficeDocumentId,
                                                                      orgDocumentSetupid: snapshotPrefill.data!.documentSetupId,
                                                                      docName: snapshotPrefill.data!.docName,
                                                                      selectedExpiryType: snapshotPrefill.data!.expType,
                                                                      documentType: AppStringEM.corporateAndComplianceDocuments,
                                                                      documentSubType: AppStringEM.capReport,
                                                                      isOthersDocs: snapshotPrefill.data!.isOthersDocs,
                                                                      idOfDoc: snapshotPrefill.data!.idOfDocument,
                                                                      expiryType: snapshotPrefill.data!.expType,
                                                                      threshhold: snapshotPrefill.data!.threshould,
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          },
                                                        // FIX: reload the CAP report list after the edit
                                                        // dialog closes so edits reflect immediately.
                                                        ).then((_) => _loadCapData());
                                                      },
                                                      icon:  Icon(Icons.edit_outlined,
                                                        size:IconSize.I22,color: IconColorManager.blueprime,),
                                                      splashColor: Colors.transparent,
                                                      highlightColor: Colors.transparent,
                                                      hoverColor: Colors.transparent,
                                                    ),
                                                    const SizedBox(width: AppSize.s10,),
                                                    IconButton(
                                                        splashColor: Colors.transparent,
                                                        highlightColor: Colors.transparent,
                                                        hoverColor: Colors.transparent,
                                                        onPressed: () {
                                                          // FIX: track dialog-open state, use the
                                                          // StatefulBuilder's own setDialogState for the
                                                          // dialog spinner, and reload the CAP report list
                                                          // after a successful delete.
                                                          bool dialogIsOpen = true;
                                                          showDialog(
                                                              context: context,
                                                              builder: (context) =>
                                                                  StatefulBuilder(
                                                                    builder: (BuildContext context,
                                                                        void Function(void Function()) setDialogState) {
                                                                      return DeletePopup(
                                                                          title: DeletePopupString.deleteCap ,
                                                                          loadingDuration: _isLoading,
                                                                          onCancel: () {
                                                                            dialogIsOpen = false;
                                                                            Navigator.pop(context);
                                                                          },
                                                                          onDelete: () async {
                                                                            setState(() {
                                                                              _isLoading = true;
                                                                            });
                                                                            if (dialogIsOpen) setDialogState(() {});
                                                                            try {
                                                                              await deleteOrgDoc(context: context, orgDocId: CapReports.orgOfficeDocumentId,);
                                                                              dialogIsOpen = false;
                                                                              Navigator.pop(context);
                                                                              _loadCapData();
                                                                              showDialog(context: context, builder: (context) => const DeleteSuccessPopup());
                                                                            } finally {
                                                                              if (mounted) {
                                                                                setState(() {
                                                                                  _isLoading = false;
                                                                                });
                                                                              }
                                                                              if (dialogIsOpen) setDialogState(() {});
                                                                            }
                                                                          });
                                                                    },
                                                                  ));
                                                        },
                                                        icon: Icon(Icons.delete_outline,size:IconSize.I22,color: IconColorManager.red,)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )),
                                    ],
                                  );
                                }),
                          ),
                        ),
                        PaginationControlsWidget(
                          currentPage: currentPage,
                          items: snapshot.data!,
                          itemsPerPage: itemsPerPage,
                          onPreviousPagePressed: () {
                            setState(() {
                              currentPage =
                                  currentPage > 1 ? currentPage - 1 : 1;
                            });
                          },
                          onPageNumberPressed: (pageNumber) {
                            setState(() {
                              currentPage = pageNumber;
                            });
                          },
                          onNextPagePressed: () {
                            setState(() {
                              currentPage = currentPage < totalPages
                                  ? currentPage + 1
                                  : totalPages;
                            });
                          },
                        ),
                      ],
                    );
                  }
                  return const Offstage();
                }),
          ),
        ],
      ),
    );
  }
}